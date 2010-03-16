class ChangeMapLinkLength < ActiveRecord::Migration
  def self.up
    change_column :events, :map_link, :string, :limit => 2048
  end

  def self.down
    change_column :events, :map_link, :string, :limit => 255
  end
end
