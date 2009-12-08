class Design < ActiveRecord::Base
  belongs_to :category
  belongs_to :creator, :class_name => "User"

  validates_presence_of :category
  attr_accessible :category_id

  named_scope :available, {:conditions => "designs.disabled_at IS NULL"}

  has_attached_file :card,
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket),
    :path =>        "designs/:id/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key),
      :secret_access_key => GlobalPreference.get(:s3_secret),
    }
  attr_accessible :card
  validates_attachment_presence :card
  validates_attachment_size :card, :less_than => 10.megabytes

  has_attached_file :background,
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket),
    :path =>        "designs/:id/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key),
      :secret_access_key => GlobalPreference.get(:s3_secret),
    }
  attr_accessible :background
  validates_attachment_presence :background
  validates_attachment_size :background, :less_than => 200.kilobytes

  has_attached_file :preview,
    :styles         => {:small => "67x50>", :medium => "219x164>"},
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket),
    :path =>        "designs/:id/:style/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key),
      :secret_access_key => GlobalPreference.get(:s3_secret),
    }
  attr_accessible :preview
  validates_attachment_presence :preview
  validates_attachment_size :preview, :less_than => 500.kilobytes
end
