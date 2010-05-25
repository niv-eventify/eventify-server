class Category < ActiveRecord::Base

  validates_presence_of :name_en
  validates_presence_of :name_he

  has_many :designs, :conditions => "designs.disabled_at IS NULL" do
    def popular(offset)
      if offset >= 0
        find(:first, :offset => offset)
      else
        find(:first, :offset => rand(self.count() - 1) + 1)
      end
    end
  end

  attr_accessible :name_en, :name_he, :popularity, :disabled_at

  named_scope :enabled, :conditions => "categories.disabled_at IS NULL"
  named_scope :disabled, :conditions => "categories.disabled_at IS NOT NULL"

  def disabled?
    !disabled_at.blank?
  end

  def name
    #TODO: use current language
    msg = "name_#{current_controller.send(:current_locale)}"
    respond_to?(msg) ? send(msg) : name_en
  end

  def self.popular(limit)
    find(:all, :limit => limit, :order => "popularity DESC")
  end

end