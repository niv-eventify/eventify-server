class Taking < ActiveRecord::Base
  belongs_to :event
  belongs_to :thing
  belongs_to :guest

  attr_accessible :thing, :thing_id, :amount

  before_validation_on_create :set_event_id
  def set_event_id
    self.event_id = thing.event_id
  end

  before_save :check_thing_amounts
  def check_thing_amounts
    if amount_changed? && self.thing.amount_picked + (changes["amount"].last.to_i - changes["amount"].first.to_i) > self.thing.amount
      self.amount = self.thing.amount - self.thing.amount_picked
    end
  end

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

  after_destroy :notifiy_guest
  def notifiy_guest
    Notifier.send_later(:deliver_taking_removed, guest, thing)
  end
end
