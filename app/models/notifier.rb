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

protected

  def domain
    if domain = GlobalPreference.get(:domain)
      default_url_options[:host] = domain
    end
    @domain ||= domain
  end

end
