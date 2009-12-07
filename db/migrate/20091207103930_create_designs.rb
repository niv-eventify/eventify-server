class CreateDesigns < ActiveRecord::Migration
  def self.up
    create_table :designs do |t|
      t.integer   :category_id
      t.integer   :creator_id
      t.datetime  :disabled_at

      t.string    :card_file_name
      t.string    :card_content_type
      t.integer   :card_file_size
      t.datetime  :card_updated_at

      t.string    :background_file_name
      t.string    :background_content_type
      t.integer   :background_file_size
      t.datetime  :background_updated_at

      t.string    :preview_file_name
      t.string    :preview_content_type
      t.integer   :preview_file_size
      t.datetime  :preview_updated_at

      t.timestamps
    end

    add_index :designs, :category_id
  end

  def self.down
    drop_table :designs
  end
end
