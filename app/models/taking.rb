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
      @overtaken = true
    end
  end

  def overtaken?
    @overtaken
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

  def skip_noitfication=(skip_noitfication)
    @skip_noitfication = skip_noitfication
  end

  after_destroy :notify_guest
  def notify_guest
    Notifier.deliver_taking_removed(guest, thing)
  end

  def max_amount
    thing.left_to_bring + amount.to_i
  end

end
