class Host < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  attr_accessible :name, :email, :user, :event
  validates_presence_of :name, :email
end
