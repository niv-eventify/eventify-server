class CreateReminderLogs < ActiveRecord::Migration
  def self.up
    create_table :reminder_logs do |t|
      t.integer   :reminder_id
      t.integer   :guest_id
      t.string    :destination
      t.string    :message
      t.string    :status
      t.timestamps
    end
  end

  def self.down
    drop_table :reminder_logs
  end
end
