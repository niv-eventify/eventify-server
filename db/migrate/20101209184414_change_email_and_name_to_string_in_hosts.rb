class ChangeEmailAndNameToStringInHosts < ActiveRecord::Migration
  def self.up
    change_column :hosts, :name, :string, :null => false
    change_column :hosts, :email, :string, :null => false
  end

  def self.down
    change_column :hosts, :name, :integer
    change_column :hosts, :email, :integer
  end
end
