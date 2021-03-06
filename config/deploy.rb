# require "vladify/delayed_job"
require "vladify/delayed_job_monit"
require "vladify/fast_gettext"
# require "vladify/gettext"
require "vladify/thinking_sphinx"
require "vladify/www_app"
# require "vladify/ultrasphinx"
require "vladify/whenever"
# require "vladify/workling"

#set :repository, "git@alpha.astrails.com:eventify/eventify-server"
set :repository, "git@bitbucket.org:ncaner/eventify-server.git"

desc "production"
task :prod do
  set :domain, "astrails@eventify.co.il"
  set :application, "eventify.com"
end

task :stage do
  set :domain, "astrails@staging.eventify.co.il"
  set :application, "eventify.astrails.com"
end

