class AllowSeeingOtherGuests < ActiveRecord::Migration
  def self.up
    add_column :events, :allow_seeing_other_guests, :boolean, :default => true
  end

  def self.down
    remove_column :events, :allow_seeing_other_guests
  end
end
