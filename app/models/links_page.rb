class LinksPage < ActiveRecord::Base
  validates_presence_of :language, :friendly_url, :page_html
  #validates_uniqueness_of :friendly_url, :message => "must be unique"
  attr_accessible  :language, :friendly_url, :title, :meta_description, :meta_keywords, :page_html
end
