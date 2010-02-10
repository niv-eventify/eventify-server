class StagePassed < ActiveRecord::Migration
  def self.up
    add_column :events, :stage_passed, :integer
    add_column :events, :last_invitation_sent_at, :integer
    ActiveRecord::Base.connection.execute "update events set stage_passed=3"
  end

  def self.down
    remove_column :events, :last_invitation_sent_at
    remove_column :events, :stage_passed
  end
end
