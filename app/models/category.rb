class Category < ActiveRecord::Base

  validates_presence_of :name_en
  validates_presence_of :name_he

  attr_accessible :name_en, :name_he

  named_scope :enabled, :conditions => "categories.disabled_at IS NULL"

  def name
    #TODO: use current language
    name_en
  end
end