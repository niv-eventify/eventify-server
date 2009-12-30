class CreateGuests < ActiveRecord::Migration
  def self.up
    create_table :guests do |t|
      t.integer   :event_id
      t.string    :name
      t.string    :email
      t.string    :mobile_phone
      t.boolean   :send_email
      t.boolean   :send_sms
      t.boolean   :allow_snow_ball
      t.string    :token
      t.timestamps
    end

    add_index :guests, :event_id
  end

  def self.down
    drop_table :guests
  end
end
