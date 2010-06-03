class AddAnyInvitationSentToGuests < ActiveRecord::Migration
  def self.up
    add_column :guests, :any_invitation_sent, :boolean, :default => false
    ActiveRecord::Base.connection.execute "update guests set any_invitation_sent = 1 where (email_invitation_sent_at is not null) or (sms_invitation_sent_at is not null)"
  end

  def self.down
    remove_column :guests, :any_invitation_sent
  end
end
