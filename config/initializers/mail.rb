domain = (GlobalPreference.get(:domain) || "eventify.com") rescue "eventify.com"
ActionMailer::Base.smtp_settings = {
  :address => "smtp.sendgrid.net",
  :port => '25',
  :domain => domain,
  :authentication => :plain,
  :user_name => "dev@eventify.co.il",
  :password => "dev123456"
}