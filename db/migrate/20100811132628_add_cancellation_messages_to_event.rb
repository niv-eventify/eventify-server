class AddCancellationMessagesToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :cancellation_sms, :string
    add_column :events, :cancellation_email, :string, :limit => 8192
    add_column :events, :cancellation_email_subject, :string

    add_column :guests, :cancellation_sms_sent_at, :datetime
    add_column :guests, :cancellation_email_sent_at, :datetime

    add_column :events, :cancellation_sent_at, :datetime
    add_column :events, :cancel_by_sms, :boolean
    add_column :events, :cancel_by_email, :boolean
  end

  def self.down
    remove_column :events, :cancel_by_email
    remove_column :events, :cancel_by_sms
    remove_column :events, :cancellation_sent_at
    remove_column :guests, :cancellation_email_sent_at
    remove_column :guests, :cancellation_sms_sent_at

    remove_column :events, :cancellation_email_subject
    remove_column :events, :cancellation_email
    remove_column :events, :cancellation_sms    
  end
end
