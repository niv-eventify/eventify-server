class Movie < ActiveRecord::Base
  belongs_to :event
  belongs_to :embedding_provider
  attr_accessible :in_site_id, :event_id, :embedding_provider_id
end
