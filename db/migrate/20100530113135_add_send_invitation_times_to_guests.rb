class AddSendInvitationTimesToGuests < ActiveRecord::Migration
  def self.up
    add_column :guests, :send_email_invitation_at, :datetime
    add_column :guests, :send_sms_invitation_at, :datetime
  end

  def self.down
    remove_column :guests, :send_email_invitation_at
    remove_column :guests, :send_sms_invitation_at
  end
end
