class Bounce

  include HTTParty
  
  def self.all
    res = get("https://sendgrid.com/api/bounces.get.xml?api_user=#{ActionMailer::Base.smtp_settings[:user_name]}&api_key=#{ActionMailer::Base.smtp_settings[:password]}")
    res && res["bounces"] && res["bounces"]["bounce"]
  end

  def self.cron_job
    begin
      (all || []).each do |bounce|
        if g = Guest.not_bounced_by_email(bounce["email"]).first
          g.bounce!(bounce["status"], bounce["reason"])
        end
      end
    rescue => e
      HoptoadNotifier.notify(e)
    end
  end
end