class AddTextPosToDesigns < ActiveRecord::Migration
  def self.up
    add_column :designs, :text_top_x, :integer
    add_column :designs, :text_top_y, :integer
    add_column :designs, :text_width, :integer
    add_column :designs, :text_height, :integer
  end

  def self.down
    remove_column :designs, :text_top_x
    remove_column :designs, :text_top_y
    remove_column :designs, :text_width
    remove_column :designs, :text_height
  end
end
