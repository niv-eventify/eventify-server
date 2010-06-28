module InvitationsHelper
  def invitations_to_send
    return if @invitations_to_send[:sms].zero? && @invitations_to_send[:email].zero?

    text = _("Invitations to send: %{email_count} by email and %{sms_count} by SMS") % { :email_count => @invitations_to_send[:email], :sms_count => @invitations_to_send[:sms]}
    haml_tag(:h3, text)
  end

  def invitations_to_resend
    return if @invitations_to_send[:resend_sms].zero? && @invitations_to_send[:resend_email].zero?

    text = _("Invitations to re-send: %{email_count} by email and %{sms_count} by SMS") % { :email_count => @invitations_to_send[:resend_email], :sms_count => @invitations_to_send[:resend_sms]}
    haml_tag(:h3, text)
  end
end
