domain = 'heroku.com' #(GlobalPreference.get(:domain) || "eventify.co.il") rescue "eventify.co.il"
ActionMailer::Base.smtp_settings = {
  :address => "smtp.sendgrid.net",
  :port => '587',
  :domain => domain,
  :authentication => :plain,
  :user_name => ENV['SENDGRID_USERNAME'],
  :password => ENV['SENDGRID_PASSWORD']
}