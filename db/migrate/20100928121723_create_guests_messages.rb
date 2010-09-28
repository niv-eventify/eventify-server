class CreateGuestsMessages < ActiveRecord::Migration
  def self.up
    create_table :guests_messages do |t|
      t.integer :event_id
      t.string :subject
      t.string :body
      t.timestamps
    end
    add_index :guests_messages , :event_id
  end

  def self.down
    drop_table :guests_messages
  end
end
