class Notifier < ActionMailer::Base

  def invite_guest(guest)
    subject     guest.event.name
    recipients  [guest.email_recipient]
    from        "noreply@#{domain}"
    sent_on     Time.now.utc
    body        :guest => guest, :url => rsvp_url(guest.email_token)
  end

  def guest_reminder(guest, subj, message)
    subject     subj
    recipients  [guest.email_recipient]
    from        "noreply@#{domain}"
    sent_on     Time.now.utc
    body        :guest => guest, :message => message, :url => rsvp_url(guest.email_token)
  end

  def guests_summary(event, guests_groups, summary_since)
    subject     _("%{event_name} - RSVP summary") % {:event_name => event.name}
    recipients  [event.user.email]
    from        "noreply@#{domain}"
    sent_on     Time.now.utc
    body        :event => event, :guests_groups => guests_groups, :summary_since => summary_since, :url => event_url(event)
  end

protected

  def domain
    if domain = GlobalPreference.get(:domain)
      default_url_options[:host] = domain
    end
    @domain ||= domain
  end

end
