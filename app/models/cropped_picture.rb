class CroppedPicture < ActiveRecord::Base
  belongs_to :event
  belongs_to :window

  attr_accessor :crop_x, :crop_y, :crop_h, :crop_w
  attr_accessible :event_id, :window_id, :crop_x, :crop_y, :crop_h, :crop_w
  validates_presence_of :crop_x, :crop_y, :crop_h, :crop_w

  has_attached_file :pic,
    :styles         => {:original => "275x275>"},
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket) || "junk",
    :path =>        "cropped_pictures/:id/:style/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url => ':s3_domain_url',
    :processors => [:cropper]

  attr_accessible :pic
  validates_attachment_presence :pic
  validates_attachment_size :pic, :less_than => 4.megabytes
end
