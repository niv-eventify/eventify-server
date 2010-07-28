class AddDelayedSmsToGuests < ActiveRecord::Migration
  def self.up
    add_column :guests, :delayed_sms_resend, :boolean, :default => false
  end

  def self.down
    remove_column :guests, :delayed_sms_resend
  end
end
