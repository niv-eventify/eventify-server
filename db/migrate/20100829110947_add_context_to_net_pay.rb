class AddContextToNetPay < ActiveRecord::Migration
  def self.up
    add_column :netpay_logs, :context, :string
    add_index :netpay_logs, :context
  end

  def self.down
    remove_index :netpay_logs, :context
    remove_column :netpay_logs, :context
  end
end
