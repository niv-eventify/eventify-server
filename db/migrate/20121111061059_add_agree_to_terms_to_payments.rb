class AddAgreeToTermsToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :is_agreed_to_terms, :boolean, :default => false
    Payment.update_all "is_agreed_to_terms = true"
  end

  def self.down
    remove_column :payments, :is_agreed_to_terms
  end
end
