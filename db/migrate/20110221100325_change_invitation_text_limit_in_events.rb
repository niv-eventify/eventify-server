class ChangeInvitationTextLimitInEvents < ActiveRecord::Migration
  def self.up
    change_column :events, :invitation_title, :string, :limit => 1024
    change_column :events, :guest_message, :string, :limit => 1024
  end

  def self.down
    change_column :events, :invitation_title, :string, :limit => 100
    change_column :events, :guest_message, :string, :limit => 345
  end
end
