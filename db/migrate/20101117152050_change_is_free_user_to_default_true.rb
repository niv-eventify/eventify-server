class ChangeIsFreeUserToDefaultTrue < ActiveRecord::Migration
  def self.up
    change_column :users, :is_free, :boolean, :default => true
    User.update_all "is_free = true"
  end
  def self.down
    change_column :users, :is_free, :boolean, :default => false
    User.update_all "is_free = false"
  end
end
