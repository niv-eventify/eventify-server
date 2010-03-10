class AddHostMobileAndSmsTextToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :host_mobile_number, :string
    add_column :events, :sms_message, :string
  end

  def self.down
    remove_column :events, :sms_message
    remove_column :events, :host_mobile_number
  end
end
