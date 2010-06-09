class Thing < ActiveRecord::Base
  belongs_to :event
  validates_presence_of :event_id
  validates_presence_of :name
  validates_presence_of :amount
  validates_numericality_of :amount, :greater_than => -1

  attr_accessible :amount, :name

  has_many :takings, :dependent => :destroy

  named_scope :left, :conditions => "(things.amount - things.amount_picked) > 0"
  named_scope :taken, :conditions => "(things.amount - things.amount_picked) < 1"

  def to_taking
    Taking.new(:thing => self, :amount => 0)
  end

  def left_to_bring
    amount.to_i - amount_picked.to_i
  end

  def validate
    errors.add(:base, _("already would be brought by somebody else")) if amount.to_i < 0 && amount_picked.to_i > 0
    if left_to_bring < 0
      self.amount = amount_picked.to_i
      errors.add(:amount, _("some guests already selected this item to bring, please remove them from the list before changing the amounts"))
    end
  end
end
