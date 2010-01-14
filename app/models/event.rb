class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :design

  has_many :hosts
  accepts_nested_attributes_for :hosts, :allow_destroy => true

  accepts_nested_attributes_for :user
  validates_associated :user, :if => proc { |e| e.user.activated_at.blank? }

  has_many :guests

  has_attached_file :map,
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket),
    :path =>        "/maps/:id/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key),
      :secret_access_key => GlobalPreference.get(:s3_secret),
    }
  attr_accessible :map
  validates_attachment_size :map, :less_than => 10.megabytes

  attr_accessible :category_id, :design_id, :name, :starting_at, :ending_at, 
    :location_name, :location_address, :map_link, :guest_message, :category, :design

  datetime_select_accessible :starting_at, :ending_at

  validates_presence_of :category, :design, :name, :starting_at, :location_name
  validates_length_of :guest_message, :maximum => 345, :allow_nil => true, :allow_blank => true

  named_scope :upcoming, :conditions => ["events.starting_at > ?", Time.now.utc]
  named_scope :past, :conditions => ["events.starting_at < ?", Time.now.utc]
  named_scope :with, lambda {|*with_associations| {:include => with_associations} }

  def validate
    errors.add(:starting_at, _("should be in a future")) if starting_at && starting_at < Time.now.utc
  end
end
