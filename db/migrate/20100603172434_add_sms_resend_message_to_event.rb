class AddSmsResendMessageToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :sms_resend_message, :string
  end

  def self.down
    remove_column :events, :sms_resend_message
  end
end
