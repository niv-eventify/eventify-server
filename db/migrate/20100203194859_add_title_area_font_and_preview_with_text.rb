class AddTitleAreaFontAndPreviewWithText < ActiveRecord::Migration
  def self.up
    add_column :designs, :title_top_x, :integer
    add_column :designs, :title_top_y, :integer
    add_column :designs, :title_width, :integer
    add_column :designs, :title_height, :integer
    add_column :designs, :font, :string
    add_column :designs, :title_color, :string
    add_column :designs, :message_color, :string
    add_column :designs, :text_align, :string
    add_column :designs, :preview_with_text_file_name, :string
    add_column :designs, :preview_with_text_content_type, :string
    add_column :designs, :preview_with_text_file_size, :integer
    add_column :designs, :preview_with_text_updated_at, :datetime
  end

  def self.down
    remove_column :designs, :title_top_x
    remove_column :designs, :title_top_y
    remove_column :designs, :title_width
    remove_column :designs, :title_height
    remove_column :designs, :font
    remove_column :designs, :title_color
    remove_column :designs, :message_color
    remove_column :designs, :text_align
    remove_column :designs, :preview_with_text_file_name
    remove_column :designs, :preview_with_text_content_type
    remove_column :designs, :preview_with_text_file_size
    remove_column :designs, :preview_with_text_updated_at
  end
end
