class AddInvitationTitleToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :invitation_title, :string, :limit => 100
    Event.update_all "invitation_title = name"
  end

  def self.down
    remove_column :events, :invitation_title
  end
end
