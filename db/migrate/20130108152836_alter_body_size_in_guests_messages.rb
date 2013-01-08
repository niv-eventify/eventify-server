class AlterBodySizeInGuestsMessages < ActiveRecord::Migration
  def self.up
    change_column :guests_messages, :body, :string, :limit => 2048
  end

  def self.down
    change_column :guests_messages, :body, :string
  end
end
