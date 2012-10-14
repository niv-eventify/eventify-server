class AddFilterToGuestMessages < ActiveRecord::Migration
  def self.up
    add_column :guests_messages, :filter, :string
  end

  def self.down
    remove_column :guests_messages, :filter
  end
end
