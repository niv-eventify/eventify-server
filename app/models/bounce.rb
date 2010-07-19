class Bounce < ActiveRecord::Base
  belongs_to :event
  belongs_to :guest
  attr_accessible :event_id, :guest_id, :status, :reason
end
