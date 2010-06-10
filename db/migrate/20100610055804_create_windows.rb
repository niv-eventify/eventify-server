class CreateWindows < ActiveRecord::Migration
  def self.up
    create_table :windows do |t|
      t.integer   :design_id
      t.integer   :top_x
      t.integer   :top_y
      t.integer   :width
      t.integer   :height
      t.timestamps
    end
  end

  def self.down
    drop_table :windows
  end
end
