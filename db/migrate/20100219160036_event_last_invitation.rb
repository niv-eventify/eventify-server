class EventLastInvitation < ActiveRecord::Migration
  def self.up
    change_column :events, :last_invitation_sent_at, :datetime
  end

  def self.down
    change_column :events, :last_invitation_sent_at, :integer
  end
end
