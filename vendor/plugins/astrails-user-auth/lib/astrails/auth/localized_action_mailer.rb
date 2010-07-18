module Astrails
  module Auth
    class LocalizedActionMailer < ActionMailer::Base
      layout 'mail_template'

      private
      def initialize_defaults(method_name)
        super
        @template = "#{I18n.locale}_#{method_name}"
      end 

      protected
      def _set_receipient_header(obj)
        hdr = SmtpApiHeader.new
        hdr.addTo([obj.email])
        hdr.setCategory("event_#{obj['event_id'] || '0'}")
        @headers["X-SMTPAPI"] = hdr.asJSON
      end

      def domain
        if domain = GlobalPreference.get(:domain)
          default_url_options[:host] = domain
        end
        @domain ||= domain
      end
    end

  end
end