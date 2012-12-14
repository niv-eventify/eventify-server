class Bounce

  include HTTParty
  require 'hpricot'

  def self.blocks
    res = get("https://sendgrid.com/api/blocks.get.xml?api_user=#{ActionMailer::Base.smtp_settings[:user_name]}&api_key=#{ActionMailer::Base.smtp_settings[:password]}")
    logger.info("blocks: #{res}")
    return res
  end
  def self.all
    res = get("https://sendgrid.com/api/bounces.get.xml?api_user=#{ActionMailer::Base.smtp_settings[:user_name]}&api_key=#{ActionMailer::Base.smtp_settings[:password]}")
    logger.info("bounces: #{res}")
    return res
  end

  def self.cron_job
    begin
      doc = Hpricot::XML(all)
      (doc/:bounce || []).each do |bounce|
        if g = Guest.not_bounced_by_email(bounce.at("email").innerHTML).first
          g.bounce!(bounce.at("status").innerHTML, "bounced: #{bounce.at('reason').innerHTML}")
        end
      end

      self.blocks.parsed_response['blocks']['block'].each do |block|
        if g = Guest.not_bounced_by_email(block["email"]).first
          g.bounce!(block["status"], "blocked: #{block['reason']}")
        end
      end
    rescue => e
      HoptoadNotifier.notify(e)
    end
  end
end
