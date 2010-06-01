class AddCarouselToDesigns < ActiveRecord::Migration
  def self.up
    add_column :designs, :in_carousel, :boolean, :default => false
    add_column :designs, :carousel_file_name, :string
    add_column :designs, :carousel_content_type, :string
    add_column :designs, :carousel_file_size, :integer
    add_column :designs, :carousel_updated_at, :datetime
  end

  def self.down
    remove_column :designs, :in_carousel
    remove_column :designs, :carousel_file_name
    remove_column :designs, :carousel_content_type
    remove_column :designs, :carousel_file_size
    remove_column :designs, :carousel_updated_at
  end
end
