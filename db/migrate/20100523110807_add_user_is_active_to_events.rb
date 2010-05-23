class AddUserIsActiveToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :user_is_activated, :boolean, :default => false
    ActiveRecord::Base.connection.execute "update events set user_is_activated = 1"
  end

  def self.down
    remove_column :events, :user_is_activated
  end
end
