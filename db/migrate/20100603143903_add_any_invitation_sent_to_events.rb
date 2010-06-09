class AddAnyInvitationSentToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :any_invitation_sent, :boolean, :default => false
    ActiveRecord::Base.connection.execute "update events set any_invitation_sent = 1 where stage_passed = 4"
  end

  def self.down
    remove_column :events, :any_invitation_sent
  end
end
