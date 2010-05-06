class SimplifyDesignsTable < ActiveRecord::Migration
  def self.up
    remove_column :designs, :background_file_name
    remove_column :designs, :background_content_type
    remove_column :designs, :background_file_size
    remove_column :designs, :background_updated_at
    remove_column :designs, :preview_with_text_file_name
    remove_column :designs, :preview_with_text_content_type
    remove_column :designs, :preview_with_text_file_size
    remove_column :designs, :preview_with_text_updated_at
    remove_column :designs, :no_repeat_background
    remove_column :designs, :background_color
  end

  def self.down
    add_column :designs, :background_file_name, :string
    add_column :designs, :background_content_type, :string
    add_column :designs, :background_file_size, :integer
    add_column :designs, :background_updated_at, :datetime
    add_column :designs, :preview_with_text_file_name, :string
    add_column :designs, :preview_with_text_content_type, :string
    add_column :designs, :preview_with_text_file_size, :integer
    add_column :designs, :preview_with_text_updated_at, :datetime
    add_column :designs, :no_repeat_background, :boolean
    add_column :designs, :background_color, :string
  end
end
