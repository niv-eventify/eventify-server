class ChangeNetpayLogToHostedV2 < ActiveRecord::Migration
  def self.up
    remove_column :netpay_logs, :request
    remove_column :netpay_logs, :response
    remove_column :netpay_logs, :exception
    remove_column :netpay_logs, :http_code
    remove_column :netpay_logs, :context
    rename_column :netpay_logs, :netpay_status, :replyCode
    add_column :netpay_logs, :replyDesc, :string
    add_column :netpay_logs, :trans_id, :string
    add_column :netpay_logs, :trans_date, :datetime
    add_column :netpay_logs, :trans_amount, :float
    add_column :netpay_logs, :trans_currency, :string
    add_column :netpay_logs, :trans_installments, :integer
    add_column :netpay_logs, :trans_refNum, :string
    add_column :netpay_logs, :client_id, :string, :limit => 10
    add_column :netpay_logs, :paymentDisplay, :string
    add_column :netpay_logs, :client_fullName, :string
    add_column :netpay_logs, :client_phoneNum, :string
    change_column :payments, :succeed_netpay_log_id, :string
    rename_column :payments, :succeed_netpay_log_id, :transaction_id
  end

  def self.down
    add_column :netpay_logs, :request, :string, :limit => 1024
    add_column :netpay_logs, :response, :string, :limit => 1024
    add_column :netpay_logs, :exception, :string
    add_column :netpay_logs, :http_code, :integer
    add_column :netpay_logs, :context, :string
    rename_column :netpay_logs, :replyCode, :netpay_status
    remove_column :netpay_logs, :replyDesc
    remove_column :netpay_logs, :trans_id
    remove_column :netpay_logs, :trans_date
    remove_column :netpay_logs, :trans_amount
    remove_column :netpay_logs, :trans_currency
    remove_column :netpay_logs, :trans_installments
    remove_column :netpay_logs, :trans_refNum
    remove_column :netpay_logs, :client_id
    remove_column :netpay_logs, :paymentDisplay
    remove_column :netpay_logs, :client_fullName
    remove_column :netpay_logs, :client_phoneNum
    change_column :payments, :transaction_id, :integer
    rename_column :payments, :transaction_id, :succeed_netpay_log_id
    add_index :netpay_logs, :context
  end
end
