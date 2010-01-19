class CreateThings < ActiveRecord::Migration
  def self.up
    create_table :things do |t|
      t.integer :event_id
      t.string  :name
      t.integer :amount
      t.integer :amount_picked, :default => 0
      t.timestamps
    end

    add_index :things, :event_id
  end

  def self.down
    drop_table :things
  end
end
