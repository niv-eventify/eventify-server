class CreateUploadedPictures < ActiveRecord::Migration
  def self.up
    create_table :uploaded_pictures do |t|
      t.integer   :event_id
      t.string    :pic_file_name
      t.string    :pic_content_type
      t.integer   :pic_file_size
      t.datetime  :pic_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :uploaded_pictures
  end
end
