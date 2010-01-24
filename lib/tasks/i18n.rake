namespace :gettext do
  desc "sync .po files to db"
  task :sync => :sync_po_to_db
end

