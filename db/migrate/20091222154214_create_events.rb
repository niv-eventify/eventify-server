class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer   :user_id
      t.integer   :category_id
      t.integer   :design_id
      t.string    :name

      t.datetime  :starting_at
      t.datetime  :ending_at

      t.string    :location_name
      t.string    :location_address

      t.string    :map_link
      t.string    :map_file_name
      t.string    :map_content_type
      t.integer   :map_file_size
      t.datetime  :map_updated_at

      t.string    :guest_message, :limit  => 345

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
