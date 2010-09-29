class RemoveTextsFromReminders < ActiveRecord::Migration
  def self.up
    remove_column :reminders, :email_subject
    remove_column :reminders, :email_body
    remove_column :reminders, :sms_message
  end

  def self.down
    add_column :reminders, :email_subject, :string
    add_column :reminders, :email_body, :string, :limit => 2048
    add_column :reminders, :sms_message, :string
  end
end
