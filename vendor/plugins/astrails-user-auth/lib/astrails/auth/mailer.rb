module Astrails
  module Auth
    class Mailer < ActionMailer::Base

      def password_reset_instructions(user)
        subject       (_("%{domain}: Password Reset Instructions") % {:domain => domain})
        from          "Password Reset <noreply@#{domain}>"
        recipients    user.email
        _set_receipient_header(user)
        sent_on       Time.now
        body          :domain => domain, :user => user, :edit_password_url => edit_password_url(user.perishable_token)
      end

      def password_reset_confirmation(user)
        subject       (_("%{domain}: Password Reset Notification") % {:domain => domain})
        from          "Password Reset <noreply@#{domain}>"
        recipients    user.email
        _set_receipient_header(user)
        sent_on       Time.now
        body          :domain => domain, :user => user, :login_url => login_url
      end

      def activation_instructions(user)
        subject       (_("%{domain}: Account Activation Instructions") % {:domain => domain})
        from          "Activation <noreply@#{domain}>"
        recipients    user.email
        _set_receipient_header(user)
        sent_on       Time.now
        body          :domain => domain, :user => user, :account_activation_url => activate_url(user.perishable_token)
      end

      def activation_confirmation(user)
        subject       (_("Welcome to %{domain}") % {:domain => domain})
        from          "Activation <noreply@#{domain}>"
        recipients    user.email
        _set_receipient_header(user)
        sent_on       Time.now
        body          :domain => domain, :user => user, :login_url => login_url
      end

      protected

      def domain
        @domain ||= default_url_options[:host] = GlobalPreference.get(:domain)
      end

      def _set_receipient_header(obj)
        hdr = SmtpApiHeader.new
        hdr.addTo([obj.email])
        @headers["X-SMTPAPI"] = hdr.asJSON
      end

    end
  end
end
