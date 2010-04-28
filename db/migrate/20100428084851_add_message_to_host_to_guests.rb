class AddMessageToHostToGuests < ActiveRecord::Migration
  def self.up
    add_column :guests, :message_to_host, :string
  end

  def self.down
    remove_column :guests, :message_to_host
  end
end
