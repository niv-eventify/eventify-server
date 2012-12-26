class AlterBounceReasonInGuest < ActiveRecord::Migration
  def self.up
    change_column :guests, :bounce_reason, :string, :limit => 2048
  end

  def self.down
    change_column :guests, :bounce_reason, :string
  end
end
