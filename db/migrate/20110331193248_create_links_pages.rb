class CreateLinksPages < ActiveRecord::Migration
  def self.up
    create_table :links_pages do |t|
      t.string    :language
      t.string    :friendly_url
      t.string    :page_html
      t.timestamps
    end
  end

  def self.down
    drop_table :links_pages
  end
end
