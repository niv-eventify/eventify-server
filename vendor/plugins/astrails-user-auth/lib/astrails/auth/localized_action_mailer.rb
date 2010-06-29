module Astrails
  module Auth
    class LocalizedActionMailer < ActionMailer::Base

      private
      def initialize_defaults(method_name)
        super
        @template = "#{I18n.locale}_#{method_name}"
      end 

      protected
      def _set_receipient_header(obj)
        hdr = SmtpApiHeader.new
        hdr.addTo([obj.email])
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