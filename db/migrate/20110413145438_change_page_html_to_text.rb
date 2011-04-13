class ChangePageHtmlToText < ActiveRecord::Migration
  def self.up
    change_column :links_pages, :page_html, :text
  end

  def self.down
    change_column :links_pages, :page_html, :string
  end
end
