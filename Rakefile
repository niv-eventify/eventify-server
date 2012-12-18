# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))
require 'ruby-debug'
require 'rake'
require 'rake/testtask'
require 'rdoc/task'

require 'tasks/rails'


task :cruise_control do
  system "cp ../database.yml config/database.yml"
  Rake::Task['db:migrate'].invoke
  Rake::Task['default'].invoke
end

task :tags do
  system "ctags -R --sort=yes --exclude=\*.js"
end

begin
  gem 'delayed_job', '~>2.0.4'
  require 'delayed/tasks'
rescue LoadError
  STDERR.puts "Run `rake gems:install` to install delayed_job"
end
