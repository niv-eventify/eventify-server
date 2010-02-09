class Invitations < ActiveRecord::Migration
  def self.up
    add_column :guests, :email_invitation_sent_at, :datetime
    add_column :guests, :sms_invitation_sent_at, :datetime
    add_column :guests, :rsvp, :integer
    add_column :guests, :attendees_count, :integer
    rename_column :guests, :token, :email_token
  end

  def self.down
    rename_column :guests, :email_token, :token
    remove_column :guests, :attendees_count
    remove_column :guests, :rsvp
    remove_column :guests, :email_invitation_sent_at
    remove_column :guests, :sms_invitation_sent_at
  end
end
