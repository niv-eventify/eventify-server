class BounceChange < ActiveRecord::Migration
  def self.up
    drop_table :bounces
    add_column :guests, :bounced_at, :datetime
    add_column :guests, :bounce_status, :string
    add_column :guests, :bounce_reason, :string

    add_index :guests, [:event_id, :bounced_at]
    remove_index :guests, :event_id
  end

  def self.down
    remove_index :guests, [:event_id, :bounced_at]
    add_index :guests, :event_id

    remove_column :guests, :bounce_reason
    remove_column :guests, :bounce_status
    remove_column :guests, :bounced_at
    create_table "bounces", :force => true do |t|
      t.integer  "event_id"
      t.string   "status"
      t.string   "reason"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "guest_id"
    end
  end
end
