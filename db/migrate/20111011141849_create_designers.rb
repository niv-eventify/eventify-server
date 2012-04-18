class CreateDesigners < ActiveRecord::Migration
  def self.up
    create_table :designers do |t|
      t.integer :user_id
      t.string :name
      t.text :about
      t.string :link1
      t.string    :avatar_file_name
      t.string    :avatar_content_type
      t.integer   :avatar_file_size
      t.datetime  :avatar_updated_at

      t.string    :work1_file_name
      t.string    :work1_content_type
      t.integer   :work1_file_size
      t.datetime  :work1_updated_at

      t.string    :work2_file_name
      t.string    :work2_content_type
      t.integer   :work2_file_size
      t.datetime  :work2_updated_at

      t.string    :work3_file_name
      t.string    :work3_content_type
      t.integer   :work3_file_size
      t.datetime  :work3_updated_at


      t.timestamps
    end
    add_column :designs, :designer_id, :integer
  end

  def self.down
    remove_column :designs, :designer_id
    drop_table :designers
  end
end
