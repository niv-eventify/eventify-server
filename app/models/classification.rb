class Classification < ActiveRecord::Base
  attr_accessible :all
  validates_presence_of :category_id
  belongs_to :design
  belongs_to :category

  named_scope :not_root, {:include => :category, :conditions => "categories.root <> 1"}
end
