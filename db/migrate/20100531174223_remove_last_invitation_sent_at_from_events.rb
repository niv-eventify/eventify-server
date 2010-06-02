class RemoveLastInvitationSentAtFromEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :last_invitation_sent_at
  end

  def self.down
    add_column :events, :last_invitation_sent_at, :datetime
  end
end
