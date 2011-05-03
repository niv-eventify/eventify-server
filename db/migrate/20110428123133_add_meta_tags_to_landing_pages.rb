class AddMetaTagsToLandingPages < ActiveRecord::Migration
  def self.up
    add_column :landing_pages, :title, :string
    add_column :landing_pages, :meta_description, :string
    add_column :landing_pages, :meta_keywords, :string
  end

  def self.down
    remove_column :landing_pages, :title
    remove_column :landing_pages, :meta_description
    remove_column :landing_pages, :meta_keywords
  end
end