class ChangeEventDefaultFontSizes < ActiveRecord::Migration
  def self.up
    change_column :events, :title_font_size, :integer, :default => 22
    change_column :events, :msg_font_size, :integer, :default => 20
  end

  def self.down
    change_column :events, :title_font_size, :integer, :default => 35
    change_column :events, :msg_font_size, :integer, :default => 32
  end
end
