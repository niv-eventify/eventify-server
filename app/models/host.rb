class Host < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  belongs_to :garden

  attr_accessible :name, :email, :user, :event, :garden
  validates_presence_of :name, :email
end
