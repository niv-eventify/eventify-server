class AddInvitationFailedAtToGuests < ActiveRecord::Migration
  def self.up
    add_column :guests, :sms_invitation_failed_at, :datetime
    add_column :guests, :email_invitation_failed_at, :datetime
  end

  def self.down
    remove_column :guests, :sms_invitation_failed_at
    remove_column :guests, :email_invitation_failed_at
  end
end
