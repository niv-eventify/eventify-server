class AddNoRepeatBackgroundToDesign < ActiveRecord::Migration
  def self.up
    add_column :designs, :no_repeat_background, :boolean
    add_column :designs, :background_color, :string
  end

  def self.down
    remove_column :designs, :no_repeat_background
    remove_column :designs, :background_color
  end
end
