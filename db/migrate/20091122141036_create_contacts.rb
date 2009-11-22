class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.integer :user_id
      t.string  :name
      t.string  :email
      t.string  :mobile
      t.string  :country
      t.string  :city
      t.string  :street
      t.string  :zip
      t.string  :company
      t.string  :title
      t.timestamps
    end

    add_index :contacts, [:user_id, :email], :name => "user_email"
  end

  def self.down
    drop_table :contacts
  end
end
