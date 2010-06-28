class Notifier < Astrails::Auth::LocalizedActionMailer

  def invite_resend_guest(guest)
    subject     guest.event.invitation_email_subject
    recipients  [guest.email_recipient]
    _set_receipient_header(guest)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :guest => guest, :url => rsvp_url(guest.email_token)
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

  def guests_summary(event, guests_groups, summary_since)
    subject     _("%{event_name} - RSVP summary") % {:event_name => event.name}
    recipients  [event.user.email]
    _set_receipient_header(event.user)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :event => event, :guests_groups => guests_groups, :summary_since => summary_since, :url => summary_url(event)
  end

  def taking_removed(guest, thing)
    subject     guest.event.name
    recipients  [guest.email_recipient]
    _set_receipient_header(guest)
    from        "Eventify <invitations@#{domain}>"
    sent_on     Time.now.utc
    body        :guest => guest, :thing => thing, :url => rsvp_url(guest.email_token, :more => true)
  end

end
