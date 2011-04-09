class LinksPage < ActiveRecord::Base
  validates_presence_of :language, :friendly_url, :page_html
  attr_accessible  :language, :friendly_url, :page_html
end
