class ChangeIsFreeUserToDefaultFalse < ActiveRecord::Migration
  def self.up
    change_column :users, :is_free, :boolean, :default => false
  end
  def self.down
    change_column :users, :is_free, :boolean, :default => true
  end
end
