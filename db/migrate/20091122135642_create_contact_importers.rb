class CreateContactImporters < ActiveRecord::Migration
  def self.up
    create_table :contact_importers do |t|
      t.integer   :user_id
      t.string    :source, :limit => 16
      t.datetime  :completed_at
      t.string    :last_error
      t.integer   :contacts_imported
      t.timestamps
    end
  end

  def self.down
    drop_table :contact_importers
  end
end
