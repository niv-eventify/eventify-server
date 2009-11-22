class RenameSource < ActiveRecord::Migration
  def self.up
    rename_column :contact_importers, :source, :contact_source
  end

  def self.down
    rename_column :contact_importers, :contact_source, :source
  end
end
