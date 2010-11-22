class AddOrderAndRedirectToDesigns < ActiveRecord::Migration
  def self.up
    add_column :designs, :ordering, :integer, :default => 0
    add_column :designs, :redirect_to_category, :integer
  end

  def self.down
    remove_column :designs, :ordering
    remove_column :designs, :redirect_to_category
  end
end
