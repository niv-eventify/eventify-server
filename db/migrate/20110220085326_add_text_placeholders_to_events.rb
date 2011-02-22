class AddTextPlaceholdersToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :text_top_x, :integer
    add_column :events, :text_top_y, :integer
    add_column :events, :text_width, :integer
    add_column :events, :text_height, :integer
    add_column :events, :title_top_x, :integer
    add_column :events, :title_top_y, :integer
    add_column :events, :title_width, :integer
    add_column :events, :title_height, :integer
  end

  def self.down
    remove_column :events, :text_top_x
    remove_column :events, :text_top_y
    remove_column :events, :text_width
    remove_column :events, :text_height
    remove_column :events, :title_top_x
    remove_column :events, :title_top_y
    remove_column :events, :title_width
    remove_column :events, :title_height
  end
end
