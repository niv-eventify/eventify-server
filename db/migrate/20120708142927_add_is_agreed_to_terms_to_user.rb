class AddIsAgreedToTermsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :is_agreed_to_terms, :boolean
  end

  def self.down
    remove_column :users, :is_agreed_to_terms
  end
end
