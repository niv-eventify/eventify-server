domain = (GlobalPreference.get(:domain) || "eventify.com") rescue "eventify.com"
ActionMailer::Base.smtp_settings = {
  :address => "localhost",
  :port => 25,
  :domain => domain,
}
