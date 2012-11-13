module Netpay

  require "cgi"
  require "net/http"
  require "net/https"

  DEFAULT_TIMEOUT = 3.minutes

  class Poster
    # names are the same as provided by NetPay documentation
    REQUIRED_OPTS = [:CardNum, :ExpMonth, :ExpYear, :Member, :Amount, :Currency, :CVV2, :Email, :PersonalNum, :PhoneNumber, :Comment]
    OBFUSCATE_OPTS = [:CardNum, :PersonalNum]
    NEVERLOG_OPTS = [:ExpMonth, :ExpYear, :CVV2]

    DEFAULT_OPTS = {
      :TransType => 0,
      :TypeCredit => 1,
      :Payments => 1
    }

    attr_reader :response, :log_id

    def initialize(url, company_number, context, skip_ssl_verification)
      @url, @company_number, @context, @skip_ssl_verification = url, company_number, context, skip_ssl_verification
    end

    def post(opts)
      opts.symbolize_keys!

      missed_params = REQUIRED_OPTS - opts.keys
      raise ArgumentError.new("Missed keys: #{missed_params.join(', ')}") unless missed_params.blank?

      form_data = opts.merge(DEFAULT_OPTS).merge(:CompanyNum => @company_number)
      @response = nil

      success = false
      exception = nil
      code = nil

      uri = URI.parse(@url)
      request = Net::HTTP::Post.new(uri.path)
      request.set_form_data(form_data)

      net = Net::HTTP.new(uri.host, uri.port)
      net.use_ssl = true
      net.verify_mode = OpenSSL::SSL::VERIFY_NONE if @skip_ssl_verification

      res = net.start do |http|
        http.open_timeout = DEFAULT_TIMEOUT
        http.request(request)
      end

      begin
        case res
        when Net::HTTPSuccess
          @response = res.body
          success = true
        else
          @response = res.try(:body)
        end
        code = res.code
      rescue => e
        exception = e
      end

      log_record = NetpayLog.create(:request => Poster.obfuscate(form_data).inspect, :response => @response,
        :exception => exception, :netpay_status => parsed_response[:Reply], :http_code => code,
        :context => @context)

      @log_id = log_record.id

      success
    end

    def success?
      "000" == parsed_response[:Reply]
    end

    def parsed_response
      self.class.parse_response(@response) rescue {}
    end

  protected

    def self.obfuscate(opts)
     OBFUSCATE_OPTS.each do |key|
       opts[key] = "FILTERED#{opts[key][-4..-1]}"
     end 
     NEVERLOG_OPTS.each do |key|
       opts[key] = "[FILTERED]"
     end

     opts
    end

    def self.parse_response(response_string)
      res = CGI.parse(response_string)
      res.keys.inject(HashWithIndifferentAccess.new) do |h, v|
        h[v] = res[v].is_a?(Array) && 1 == res[v].size ? res[v].first : res[v]
        h
      end
    end
  end

  class SilentPost < Poster
    def initialize(company_number, context = nil, skip_ssl_verification = false)
      super("https://process.netpay-intl.com/member/remote_charge.asp", company_number, context, skip_ssl_verification)
    end

    def process(cc, expiration_month, expiration_year, name_on_card, amount_cents, ccv2, email, user_ident, phone_number, transaction_description, currency = "ILS")
      amount = sprintf("%d.%02d", amount_cents/100, amount_cents%100)
      post(:CardNum => cc, :ExpMonth => expiration_month, :ExpYear => expiration_year, 
        :Member => name_on_card, :Amount => amount, :Currency => currency, :CVV2 => ccv2,
        :Email => email, :PersonalNum => user_ident, :PhoneNumber => phone_number,
        :Comment => transaction_description)
    end
  end

  class HostedPage
    @@opts = {
      :trans_currency => "ILS",
      :trans_installments => 1,
      :skin_no => 1,
      :disp_paymentType => "CC",
      :disp_lng => "he-il",
      :disp_lngList => "hide"
    }
    def initialize(payment, payment_details, redirect_to, notify_to)
      @secret = payment.user.is_super_admin ? NETPAY_PERSONAL_HASH_DEBUG : NETPAY_PERSONAL_HASH
      opts = {
        :merchantID => payment.user.is_super_admin ? NETPAY_MERCHANT_ID_DEBUG : NETPAY_MERCHANT_ID,
        :trans_amount => sprintf("%d.%02d", payment.amount/100, payment.amount%100),
        :client_fullName => payment.name_on_card,
        :client_email => payment.email,
        :trans_refNum => payment.id,
        :disp_payFor => payment_details,
        :url_redirect => redirect_to,
        :url_notify => notify_to
      }
      @opts = @@opts.merge(opts)
    end
    def get_url
      str_to_signature = ""
      @url = "https://services.netpay-intl.com/hosted/?"
      @opts.each_pair do |key, value|
        #value = CGI::escape(value.to_s)
        str_to_signature += value.to_s
        @url += "#{key}=#{CGI::escape(value.to_s)}&"
      end
      str_to_signature += @secret
      @signature = Base64.encode64(Digest::SHA256.digest(str_to_signature)).chomp
      @url += "signature=#{CGI::escape(@signature)}"
    end
    def self.validate_response(params)
      #replyCode + trans_id + PersonalHashKey
      str_to_signature = "#{params[:replyCode]}#{params[:trans_id]}#{NETPAY_PERSONAL_HASH}"
      return params[:signature] == Base64.encode64(Digest::SHA256.digest(str_to_signature)).chomp
    end
    def self.success?(reply_code)
      "000" == reply_code
    end
  end
end
