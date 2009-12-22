class CreateHosts < ActiveRecord::Migration
  def self.up
    create_table :hosts do |t|
      t.integer     :event_id
      t.integer     :name
      t.integer     :email
      t.integer     :user_id # can be nil
      t.timestamps
    end

    add_index :hosts, :event_id
    add_index :hosts, :user_id
    add_index :hosts, :email
  end

  def self.down
    drop_table :hosts
  end
end
