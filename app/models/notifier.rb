class Notifier < Astrails::Auth::LocalizedActionMailer

  def invite_resend_guest(guest)
    subject     guest.event.invitation_email_subject
    recipients  [guest.email_recipient]
    reply_to    guest.event.user.email
    content_type    "multipart/alternative"
    _set_receipient_header(guest)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :guest => guest, :url => rsvp_url(guest.email_token, :host => host)
  end

  def event_cancelled(guest, message_subject, message_text)
    subject     message_subject
    recipients  [guest.email_recipient]
    reply_to    guest.event.user.email
    content_type    "multipart/alternative"
    _set_receipient_header(guest)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :message => message_text
  end

  def invite_guest(guest)
    subject     guest.event.invitation_email_subject
    recipients  [guest.email_recipient]
    reply_to    guest.event.user.email
    content_type    "multipart/alternative"
    _set_receipient_header(guest)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :guest => guest, :url => rsvp_url(guest.email_token, :host => host)
  end

  def guest_reminder(guest, subj, message)
    subject     subj
    recipients  [guest.email_recipient]
    reply_to    guest.event.user.email
    content_type    "multipart/alternative"
    _set_receipient_header(guest)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :guest => guest, :message => message, :url => rsvp_url(guest.email_token, :host => host)
  end

  def guests_summary(event, guests_groups, summary_since, start_time, start_date)
    subject     _("%{event_name} - RSVP summary") % {:event_name => event.name}
    recipients  [event.user.email]
    content_type    "multipart/alternative"
    _set_receipient_header(event.user)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :event => event, :guests_groups => guests_groups, :summary_since => summary_since, :url => summary_url(event, :locale => event.language), :start_time => start_time, :start_date => start_date
  end

  def taking_removed(guest, thing)
    subject     guest.event.name
    recipients  [guest.email_recipient]
    reply_to    guest.event.user.email
    content_type    "multipart/alternative"
    _set_receipient_header(guest)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :guest => guest, :thing => thing, :url => rsvp_url(guest.email_token, :more => true, :host => host)
  end

  def ical_attachment(event, guest)
    subject     event.name
    recipients  [(guest.respond_to?(:email_recipient) && guest.email_recipient) || guest]
    _set_receipient_header(guest)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc

    attachment :content_type => "text/calendar; charset=UTF-8", :body => event.to_ical, :filename => event.ical_filename
  end

  def message_to_guest(guest,message)
    subject     message.subject
    recipients  [guest.email_recipient]
    content_type    "multipart/alternative"
    _set_receipient_header(guest)
    from        guest.event.user.email
    sent_on     Time.now.utc
    body        :guest => guest, :message => message, :url => rsvp_url(guest.email_token, :host => host)
  end

end
