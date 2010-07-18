class CreateBounces < ActiveRecord::Migration
  def self.up
    create_table :bounces do |t|
      t.column :event_id, :integer
      t.column :email, :string
      t.column :status, :string
      t.column :reason, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :bounces
  end
end
