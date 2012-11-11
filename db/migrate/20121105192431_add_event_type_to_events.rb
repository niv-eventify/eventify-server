class AddEventTypeToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :event_type, :integer, :default => 10
  end

  def self.down
    remove_column :events, :event_type
  end
end
