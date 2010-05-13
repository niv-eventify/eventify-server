class CreateSmsMessages < ActiveRecord::Migration
  def self.up
    create_table :sms_messages do |t|
      t.integer     :guest_id
      t.integer     :event_id
      t.string      :kind, :limit => 10
      t.string      :sender_mobile
      t.string      :receiver_mobile
      t.string      :message
      t.string      :request_dump, :limit => 2048
      t.string      :response_dump, :limit => 2048
      t.boolean     :success
      t.datetime    :sent_at
      t.timestamps
    end

    add_column :guests, :sms_messages_count, :integer, :default => 0
    add_column :events, :sms_messages_count, :integer, :default => 0

    add_index :sms_messages, [:event_id, :guest_id]
    add_index :sms_messages, :sent_at
  end

  def self.down
    remove_column :events, :sms_messages_count
    remove_column :guests, :sms_messages_count
    drop_table :sms_messages
  end
end
