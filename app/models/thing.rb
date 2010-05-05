class Thing < ActiveRecord::Base
  belongs_to :event
  validates_presence_of :event_id
  validates_presence_of :name
  validates_presence_of :amount
  validates_numericality_of :amount, :greater_than => -1

  attr_accessible :amount, :name

  has_many :takings

  named_scope :left, :conditions => "(things.amount - things.amount_picked) > 0"
  named_scope :taken, :conditions => "(things.amount - things.amount_picked) < 1"

  def to_taking
    Taking.new(:thing => self, :amount => 0)
  end

  def left_to_bring
    amount - amount_picked
  end

  def validate
    errors.add(:base, _("already would be brought by somebody else")) if amount.to_i < 0 && amount_picked > 0
  end
end
