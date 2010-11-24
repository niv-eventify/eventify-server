class AddIndexToWindow < ActiveRecord::Migration
  def self.up
    add_index :windows, :design_id
  end

  def self.down
    remove_index :windows, :design_id
  end
end
