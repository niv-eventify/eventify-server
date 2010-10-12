class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer :user_id
      t.integer :event_id
      t.integer :amount
      t.integer :emails_plan
      t.integer :sms_plan
      t.integer :prints_plan
      t.integer :succeed_netpay_log_id
      t.datetime :paid_at
      t.timestamps
    end

    add_index :payments, :event_id
    add_index :payments, :user_id
  end

  def self.down
    drop_table :payments
  end
end
