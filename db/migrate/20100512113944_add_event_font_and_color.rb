class AddEventFontAndColor < ActiveRecord::Migration
  def self.up
    add_column :events, :font, :string
    add_column :events, :title_color, :string
    add_column :events, :msg_color, :string
  end

  def self.down
    remove_column :events, :font
    remove_column :events, :title_color
    remove_column :events, :msg_color
  end
end
