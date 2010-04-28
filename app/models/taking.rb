class Taking < ActiveRecord::Base
  belongs_to :event
  belongs_to :thing
  belongs_to :guest

  attr_accessible :thing, :thing_id, :amount

  after_save    :update_thing_amounts
  after_destroy :update_thing_amounts
  def update_thing_amounts
    if self.frozen?
      self.thing.amount_picked -= amount
    elsif amount_changed?
      self.thing.amount_picked += changes["amount"].last.to_i - changes["amount"].first.to_i
    end
    self.thing.save if self.thing.changed?
  end
end
