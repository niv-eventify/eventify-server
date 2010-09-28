class GuestsMessage < ActiveRecord::Base

  belongs_to :event

  validates_presence_of :subject , :body
end

