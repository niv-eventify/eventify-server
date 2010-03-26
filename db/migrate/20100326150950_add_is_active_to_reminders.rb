class AddIsActiveToReminders < ActiveRecord::Migration
  def self.up
    add_column :reminders, :is_active, :boolean, :default => true
    remove_index :reminders, [:send_reminder_at, :reminder_sent_at]
    add_index :reminders, [:send_reminder_at, :reminder_sent_at, :is_active], :name => "dates_and_activity"
  end

  def self.down
    remove_index :reminders, :name => "dates_and_activity"
    add_index :reminders, [:send_reminder_at, :reminder_sent_at]
    remove_column :reminders, :is_active
  end
end
