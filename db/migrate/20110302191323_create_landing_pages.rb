class CreateLandingPages < ActiveRecord::Migration
  def self.up
    create_table :landing_pages do |t|
      t.integer   :category_id
      t.string    :language
      t.string    :friendly_url
      t.string    :h1
      t.string    :h2
      t.string    :item1_header
      t.string    :item1_body
      t.string    :item2_header
      t.string    :item2_body
      t.string    :item3_header
      t.string    :item3_body
      t.string    :quote
      t.string    :quoted_name
      t.string    :quoted_city
      t.string    :image_file_name
      t.string    :image_content_type
      t.integer   :image_file_size
      t.datetime  :image_updated_at
      t.string    :quoted_file_name
      t.string    :quoted_content_type
      t.integer   :quoted_file_size
      t.datetime  :quoted_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :landing_pages
  end
end
