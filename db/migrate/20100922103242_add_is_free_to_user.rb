class AddIsFreeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :is_free, :boolean
  end

  def self.down
    remove_column :users, :is_free
  end
end
