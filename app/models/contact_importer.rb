class ContactImporter < ActiveRecord::Base
  belongs_to :user_id
  validates_presence_of :source

  SOURCES = %w(gmail yahoo hotmail aol csv)

  attr_accessible :source
  validates_inclusion_of :source, :in => SOURCES, :message => "not included in the list"
end
