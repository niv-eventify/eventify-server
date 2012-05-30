class AddIsActivatedToDesigner < ActiveRecord::Migration
  def self.up
    add_column :designers, :is_activated, :boolean
  end

  def self.down
    remove_column :designers, :is_activated
  end
end
