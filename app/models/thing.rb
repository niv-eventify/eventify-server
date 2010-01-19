class Thing < ActiveRecord::Base
  belongs_to :event
  validates_presence_of :event_id
  validates_presence_of :name
  validates_presence_of :amount
  validates_numericality_of :amount, :greater_than => -1

  attr_accessible :amount, :name

  def validate
    errors.add(:base, _("already would be brought by somebody else")) if amount.to_i < 0 && amount_picked > 0
  end
end
