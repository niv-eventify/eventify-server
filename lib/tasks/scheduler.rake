desc "This task is called by the Heroku scheduler add-on"

#task :update_feed => :environment do
#  puts "Updating feed..."
#  NewsFeed.update
#  puts "done."
#end

task :send_reminders => :environment do
  Reminder.send_reminders
end

task :send_morning_sms => :environment do
  Guest.delayed_sms_cron_job
end

task :send_summary_email => :environment do
  Event.summary_cron_job
end

task :check_email_bounces => :environment do
  Bounce.cron_job
end

