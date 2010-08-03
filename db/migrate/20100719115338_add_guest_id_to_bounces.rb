class AddGuestIdToBounces < ActiveRecord::Migration
  def self.up
    add_column :bounces, :guest_id, :integer
    remove_column :bounces, :email
  end

  def self.down
  	remove_column :bounces, :guest_id
  	add_column :bounces, :email, :string
  end
end
