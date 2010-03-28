class AddKindToReminderLogs < ActiveRecord::Migration
  def self.up
    add_column :reminder_logs, :kind, :string, :limit => 8
  end

  def self.down
    remove_column :reminder_logs, :kind
  end
end
