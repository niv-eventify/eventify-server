class Host < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  attr_accessible :name, :email
  validates_presence_of :name, :email
end
