module Astrails
  module Auth
    class Mailer < LocalizedActionMailer

      def password_reset_instructions(user)
        subject       (_("%{domain}: Password Reset Instructions") % {:domain => domain})
        from          "Eventify - Password Reset <invitations@#{domain}>"
        recipients    user.email
        _set_receipient_header(user)
        sent_on       Time.now
        body          :domain => domain, :user => user, :edit_password_url => edit_password_url(user.perishable_token)
      end

      def password_reset_confirmation(user)
        subject       (_("%{domain}: Password Reset Notification") % {:domain => domain})
        from          "Eventify - Password Reset <invitations@#{domain}>"
        recipients    user.email
        _set_receipient_header(user)
        sent_on       Time.now
        body          :domain => domain, :user => user, :login_url => login_url
      end

      def activation_instructions(user)
        subject       (_("%{domain}: Account Activation Instructions") % {:domain => domain})
        from          "Eventify - Activation <invitations@#{domain}>"
        recipients    user.email
        _set_receipient_header(user)
        sent_on       Time.now
        body          :domain => domain, :user => user, :account_activation_url => activate_url(user.perishable_token)
      end

      def activation_confirmation(user)
        subject       (_("Welcome to %{domain}") % {:domain => domain})
        from          "Eventify - Activation <invitations@#{domain}>"
        recipients    user.email
        _set_receipient_header(user)
        sent_on       Time.now
        body          :domain => domain, :user => user, :login_url => login_url
      end

    end
  end
end
