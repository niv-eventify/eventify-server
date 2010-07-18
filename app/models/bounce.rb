class Bounce < ActiveRecord::Base
  belongs_to :event
  attr_accessible :event_id, :email, :status, :reason
end
