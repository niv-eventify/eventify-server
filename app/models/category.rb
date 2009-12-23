class Category < ActiveRecord::Base

  validates_presence_of :name_en
  validates_presence_of :name_he

  has_many :designs do
    def popular(offset)
      find(:first, :offset => offset)
    end
  end

  attr_accessible :name_en, :name_he, :disabled_at

  named_scope :enabled, :conditions => "categories.disabled_at IS NULL"
  named_scope :disabled, :conditions => "categories.disabled_at IS NOT NULL"

  def disabled?
    !disabled_at.blank?
  end

  def name
    #TODO: use current language
    name_en
  end

  def self.popular(limit)
    find(:all, :limit => limit)
  end
end