class CreateTakings < ActiveRecord::Migration
  def self.up
    create_table :takings do |t|
      t.integer     :guest_id
      t.integer     :event_id
      t.integer     :thing_id
      t.integer     :amount
      t.timestamps
    end

    add_index :takings, [:guest_id, :thing_id]
  end

  def self.down
    drop_table :takings
  end
end
