class UploadedPicture < ActiveRecord::Base
  belongs_to :event
  attr_accessible :event_id
  has_attached_file :pic,
    :styles         => {:small => "75x76>", :crop => "285x285>"},
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket) || "junk",
    :path =>        "uploaded_pictures/:id/:style/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url => ':s3_domain_url'
  attr_accessible :pic
  validates_attachment_presence :pic
  validates_attachment_size :pic, :less_than => 4.megabytes, :message => _("File size should be less than %{max_file_size}MB") % {:max_file_size => 4}

  def pic_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(pic.url(style))
  end
end
