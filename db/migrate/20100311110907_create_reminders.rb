class CreateReminders < ActiveRecord::Migration
  def self.up
    create_table :reminders do |t|
      t.integer     :event_id
      t.boolean     :to_yes
      t.boolean     :to_no
      t.boolean     :to_may_be
      t.boolean     :to_not_responded
      t.boolean     :by_email
      t.boolean     :by_sms
      t.string      :email_subject
      t.string      :email_body, :limit => 2048
      t.string      :sms_message
      t.string      :before_units, :default => "days"
      t.integer     :before_value
      t.datetime    :send_reminder_at
      t.datetime    :reminder_sent_at
      t.timestamps
    end

    add_index :reminders, :event_id
    add_index :reminders, [:send_reminder_at, :reminder_sent_at]
  end

  def self.down
    drop_table :reminders
  end
end
