class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :design

  has_many :hosts
  accepts_nested_attributes_for :hosts, :allow_destroy => true

  accepts_nested_attributes_for :user
  validates_associated :user, :if => proc { |e| e.user.activated_at.blank? }

  has_many :guests
  has_many :things

  has_attached_file :map,
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket) || "junk",
    :path =>        "/maps/:id/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    }
  attr_accessible :map
  validates_attachment_size :map, :less_than => 10.megabytes

  attr_accessible :category_id, :design_id, :name, :starting_at, :ending_at, 
    :location_name, :location_address, :map_link, :guest_message, :category, :design

  datetime_select_accessible :starting_at, :ending_at

  validates_presence_of :category_id, :design_id, :name, :starting_at
  validates_length_of :guest_message, :maximum => 345, :allow_nil => true, :allow_blank => true
  validates_format_of :map_link,
    :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix,
    :allow_nil => true, :allow_blank => true, :live_validator => /|/

  named_scope :upcoming, :conditions => ["events.starting_at > ?", Time.now.utc]
  named_scope :past, :conditions => ["events.starting_at < ?", Time.now.utc]
  named_scope :with, lambda {|*with_associations| {:include => with_associations} }

  def invitations_to_send_counts
    e, s = guests.invite_by_email.not_invited_by_email.count, guests.invite_by_sms.not_invited_by_sms.count
    {
      :email => e,
      :sms => s,
      :total => (e + s)
    }
  end

  def payments
    [] # TODO association with payment history
  end

  def extra_payment_required?
    false
  end

  def validate
    errors.add(:starting_at, _("should be in a future")) if starting_at && starting_at < Time.now.utc
  end

  def has_map?
    !map_link.blank? || (map && !map.url.blank?)
  end

  def update_last_invitation_sent!(time_stamp)
    self.last_invitation_sent_at = time_stamp
    save!
  end

  def allow_send_invitations?
    true # TODO: payments logic
  end
end
