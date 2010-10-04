class AddPaymentDetails < ActiveRecord::Migration
  def self.up
    add_column :payments, :emails_plan_prev, :integer
    add_column :payments, :sms_plan_prev, :integer
    add_column :payments, :prints_plan_prev, :integer
    add_column :payments, :pay_sms, :integer
    add_column :payments, :pay_emails, :integer
    add_column :payments, :pay_prints, :integer
  end

  def self.down
    remove_column :payments, :pay_sms
    remove_column :payments, :pay_emails
    remove_column :payments, :pay_prints
    remove_column :payments, :emails_plan_prev
    remove_column :payments, :sms_plan_prev
    remove_column :payments, :prints_plan_prev
  end
end
