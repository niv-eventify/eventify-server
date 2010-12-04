module Event::Summary

  SUMMARY_DEFAULTS = {
    0 => N_("RSVP summary|Don't send"),
    1 => N_("RSVP summary|When a guest updates RSVP"),
    2 => N_("RSVP summary|Once a day"),
    3 => N_("RSVP summary|Once a week")
  }

  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      named_scope :overdue_summary, lambda {{:conditions => ["events.rsvp_summary_send_at < ?", Time.now.utc]}}
      named_scope :delayed_summary, :conditions => "events.user_is_activated = 1 AND events.rsvp_summary_send_every in (2, 3)" # others - send on demand
      before_update :update_summary
      attr_accessible :rsvp_summary_send_every
    end
  end

  module ClassMethods
    def summary_cron_job
      loop do
        e = next_event_to_send_summary
        break unless e

        e.update_next_summary_send!
        e.send_later(:send_summary_email!)
      end
    end

    def next_event_to_send_summary
      upcoming.delayed_summary.overdue_summary.first
    end
  end

  def immediately_send_rsvp?
    1 == rsvp_summary_send_every
  end

  def update_summary
    return if rsvp_summary_send_every_changed?
    return unless rsvp_summary_send_at.nil?

    self.rsvp_summary_send_at = created_at # reset
    save!
  end

  def update_next_summary_send!
    self.rsvp_summary_send_at = Time.now.utc + (2 == rsvp_summary_send_every ? 1.day : 1.week)
    if rsvp_summary_send_at > starting_at
      self.rsvp_summary_send_at = starting_at - 1.hour
    end

    if rsvp_summary_send_at < Time.now.utc
      # just skip
      self.rsvp_summary_send_at = starting_at + 1.second
    end
    save!
  end

  RSVP_SUMMARY_HEADER = [
    N_("The newly Declined invitees are:"), N_("The newly approved invitees are:"), N_("The newly Tentative invitees are:")]

  def send_summary_email!
    guests_count, rsvps = guests_for_this_summary!

    return if guests_count.zero?

    # sending email
    summary_since = last_summary_sent_at || created_at
    self.last_summary_sent_at = Time.now.utc
    save!
    start_time = self.with_time_zone do
      self.starting_at.to_s(:isra_time)
    end
    I18n.with_locale(language) {Notifier.deliver_guests_summary(self, rsvps, summary_since, start_time)}
  end

  def guests_for_this_summary!
    rsvps = { 0 => [], 1 => [], 2 => []}

    # gather guests
    guests_count = 0
    guests.summary_email_not_sent.find_each(:batch_size => 1) do |guest|
      guest.reset_summary_status!      
      if guest.rsvp
        rsvps[guest.rsvp] << guest.to_rsvp_email_params
        guests_count += 1
      end
    end

    [guests_count, rsvps]
  end
  
end
