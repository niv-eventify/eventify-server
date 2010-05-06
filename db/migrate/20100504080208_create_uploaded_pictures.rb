class CreateUploadedPictures < ActiveRecord::Migration
  def self.up
    create_table :uploaded_pictures do |t|
      t.integer   :user_id
      t.string    :file_name
      t.string    :content_type
      t.integer   :file_size
      t.datetime  :updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :uploaded_pictures
  end
end
