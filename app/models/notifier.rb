class Notifier < Astrails::Auth::LocalizedActionMailer

  def invite_resend_guest(guest)
    subject     guest.event.invitation_email_subject
    recipients  [guest.email_recipient]
    _set_receipient_header(guest)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :guest => guest, :url => rsvp_url(guest.email_token)
  end

  def event_cancelled(guest, message_subject, message_text)
    subject     message_subject
    recipients  [guest.email_recipient]
    _set_receipient_header(guest)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :message => message_text
  end

  def invite_guest(guest)
    subject     guest.event.invitation_email_subject
    recipients  [guest.email_recipient]
    _set_receipient_header(guest)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :guest => guest, :url => rsvp_url(guest.email_token)
  end

  def guest_reminder(guest, subj, message)
    subject     subj
    recipients  [guest.email_recipient]
    _set_receipient_header(guest)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :guest => guest, :message => message, :url => rsvp_url(guest.email_token)
  end

  def guests_summary(event, guests_groups, summary_since, start_time)
    subject     _("%{event_name} - RSVP summary") % {:event_name => event.name}
    recipients  [event.user.email]
    _set_receipient_header(event.user)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :event => event, :guests_groups => guests_groups, :summary_since => summary_since, :url => summary_url(event, :locale => event.language), :start_time => start_time
  end

  def taking_removed(guest, thing)
    subject     guest.event.name
    recipients  [guest.email_recipient]
    _set_receipient_header(guest)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :guest => guest, :thing => thing, :url => rsvp_url(guest.email_token, :more => true, :host => host)
  end

  def ical_attachment(event)
    subject     event.name
    recipients  [event.user.email]
    _set_receipient_header(event.user)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc

    attachment :content_type => "text/calendar; charset=UTF-8", :body => event.to_ical, :filename => event.ical_filename
  end

  def message_to_guest(guest,message)
    subject     message.subject
    recipients  [guest.email_recipient]
    _set_receipient_header(guest)
    from        guest.event.user.email
    sent_on     Time.now.utc
    body        :guest => guest, :message => message
  end

end
