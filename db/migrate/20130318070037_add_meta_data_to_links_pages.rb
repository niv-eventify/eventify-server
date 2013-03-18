class AddMetaDataToLinksPages < ActiveRecord::Migration
  def self.up
    add_column :links_pages, :title, :string
    add_column :links_pages, :meta_description, :string
    add_column :links_pages, :meta_keywords, :string
  end

  def self.down
    remove_column :links_pages, :title
    remove_column :links_pages, :meta_description
    remove_column :links_pages, :meta_keywords
  end
end
