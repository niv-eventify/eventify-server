class Movie < ActiveRecord::Base
  belongs_to :event
  belongs_to :embedding_provider
  attr_accessible :in_site_id, :event_id, :embedding_provider_id

  #TODO: we should handle adding a movie after some payment has been paid for the event. need to calculate the correct upgrade plan considering event_type is changing.
  before_create :assert_event_is_still_free
  def assert_event_is_still_free
    return !self.event.is_paid_for_invitations?
  end

  after_create :set_event_to_movie
  def set_event_to_movie
    self.event.event_type=EVENT_TYPES[:MOVIE]
    self.event.save
  end
end
