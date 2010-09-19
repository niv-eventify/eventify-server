class AddFirstViewedInvitationAtToGuests < ActiveRecord::Migration
  def self.up
    add_column :guests, :first_viewed_invitation_at, :datetime
  end

  def self.down
  	remove_column :guests, :first_viewed_invitation_at
  end
end
