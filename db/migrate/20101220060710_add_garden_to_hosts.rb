class AddGardenToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :garden_id, :integer
  end

  def self.down
    remove_column :hosts, :garden_id
  end
end
