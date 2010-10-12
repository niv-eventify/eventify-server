class AddPlansToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :emails_plan, :integer, :default => 0
    add_column :events, :sms_plan, :integer, :default => 0
    add_column :events, :prints_plan, :integer, :default => 0
    add_column :events, :prints_ordered, :integer, :default => 0
    Event.update_all "emails_plan = 100", "emails_plan = 0"
  end

  def self.down
    remove_column :events, :prints_ordered
    remove_column :events, :prints_plan
    remove_column :events, :sms_plan
    remove_column :events, :emails_plan
  end
end
