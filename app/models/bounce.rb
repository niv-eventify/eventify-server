class Bounce

  include HTTParty
  require 'hpricot'

  def self.all
    res = get("https://sendgrid.com/api/bounces.get.xml?api_user=#{ActionMailer::Base.smtp_settings[:user_name]}&api_key=#{ActionMailer::Base.smtp_settings[:password]}")
  end

  def self.cron_job
    begin
      doc = Hpricot::XML(all)
      (doc/:bounce || []).each do |bounce|
        if g = Guest.not_bounced_by_email(bounce.at("email").innerHTML).first
          g.bounce!(bounce.at("status").innerHTML, bounce.at("reason").innerHTML)
        end
      end
    rescue => e
      HoptoadNotifier.notify(e)
    end
  end
end