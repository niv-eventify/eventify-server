# require "vladify/delayed_job"
require "vladify/delayed_job_monit"
require "vladify/fast_gettext"
# require "vladify/gettext"
require "vladify/thinking_sphinx"
# require "vladify/ultrasphinx"
require "vladify/whenever"
# require "vladify/workling"

set :repository, "git@alpha.astrails.com:eventify/eventify-server"
set :domain, "astrails@eventify.astrails.com"


desc "production"
task :prod do
  set :application, "eventify.com"
end

task :stage do
  set :application, "eventify.astrails.com"
end

