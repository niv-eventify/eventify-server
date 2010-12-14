class Garden < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :address, :url, :user_id
  has_attached_file :map,
    :styles         => {:small => "75x76>"},
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket) || "junk",
    :path =>        "garden/:id/:style/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url => ':s3_domain_url'
  attr_accessible :map
end
