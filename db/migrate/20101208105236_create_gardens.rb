class CreateGardens < ActiveRecord::Migration
  def self.up
    create_table :gardens do |t|
      t.string    :name
      t.string    :address
      t.string    :url
      t.string    :map_file_name
      t.string    :map_content_type
      t.integer   :map_file_size
      t.datetime  :map_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :gardens
  end
end
