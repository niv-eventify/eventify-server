class AddEmailsIndexToGuests < ActiveRecord::Migration
  def self.up
    add_index :guests, [:email, :bounced_at]
  end

  def self.down
    remove_index :guests, [:email, :bounced_at]
  end
end
