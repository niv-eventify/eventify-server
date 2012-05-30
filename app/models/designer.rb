class Designer < ActiveRecord::Base
  belongs_to :user
  has_many :designs
  attr_accessible :user, :about, :friendly_url, :link1, :is_activated
  validates_uniqueness_of :friendly_url
  validates_presence_of :friendly_url
  has_attached_file :avatar,
    :styles         => {:thumb => "100x100>", :medium => "200x200>"},
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket),
    :path           => "designers/:id/avatar/:style/:filename",
    :default_url    => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url            => ':s3_domain_url'
  attr_accessible :avatar
  validates_attachment_size :avatar, :less_than => 2.megabytes

  has_attached_file :work1,
    :styles         => {:thumb => "134x100>", :medium => "368x275>"},
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket),
    :path           => "designers/:id/work1/:style/:filename",
    :default_url    => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url            => ':s3_domain_url'
  attr_accessible :work1
  validates_attachment_size :work1, :less_than => 2.megabytes

  has_attached_file :work2,
    :styles         => {:thumb => "134x100>", :medium => "368x275>"},
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket),
    :path           => "designers/:id/work2/:style/:filename",
    :default_url    => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url            => ':s3_domain_url'
  attr_accessible :work2
  validates_attachment_size :work2, :less_than => 2.megabytes

  has_attached_file :work3,
    :styles         => {:thumb => "134x100>", :medium => "368x275>"},
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket),
    :path           => "designers/:id/work3/:style/:filename",
    :default_url    => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url            => ':s3_domain_url'
  attr_accessible :work3
  validates_attachment_size :work3, :less_than => 2.megabytes

  def validate_on_update
    if !self.is_activated
      errors.add(:is_activated, _("Please agree to the terms of use."))
    end
  end

  def name
    user.name
  end

end
