module Event::Summary

  SUMMARY_DEFAULTS = {
    0 => N_("Don't send"),
    1 => N_("When a guest updates RSVP"),
    2 => N_("Once a day"),
    3 => N_("Once a week")
  }

  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      named_scope :overdue_summary, lambda {{:conditions => ["events.rsvp_summary_send_at < ?", Time.now.utc]}}
      named_scope :delayed_summary, :conditions => "events.rsvp_summary_send_every in (2, 3)" # others - send on demand
      before_update :update_summary
    end
  end

  module ClassMethods
    def summary_cron_job
      upcoming.delayed_summary.overdue_summary.find_each(:batch_size => 1) do |event|
        event.update_next_summary_send!
        event.send_later(:send_summary_email!)
      end
    end
  end

  def immediately_send_rsvp?
    1 == rsvp_summary_send_every
  end

  def update_summary
    return unless rsvp_summary_send_every_changed?
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

  def send_summary_email!
    guests_count, rsvps = guests_for_this_summary!

    return if guests_count.zero?

    # sending email
    summary_since = last_summary_sent_at || created_at
    self.last_summary_sent_at = Time.now.utc
    save!

    Notifier.deliver_guests_summary(self, rsvps, summary_since)
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