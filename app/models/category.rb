class Category < ActiveRecord::Base

  validates_presence_of :name_en
  validates_presence_of :name_he

  has_many :classifications
  has_many :designs, :through => :classifications, :conditions => "designs.disabled_at IS NULL" do
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
  named_scope :popular, lambda {|limit| {:limit => limit, :order => "popularity DESC"}}
  named_scope :has_designs, :conditions => "categories.id IN (SELECT DISTINCT category_id FROM classifications LEFT OUTER JOIN designs on classifications.design_id = designs.id WHERE designs.disabled_at IS NULL)"

  def disabled?
    !disabled_at.blank?
  end

  def name
    msg = "name_#{I18n.locale}"
    respond_to?(msg) ? send(msg) : name_en
  end

  def self.root
    @@root = first(:conditions => {:root => true})
  end
end