class LandingPage < ActiveRecord::Base
  belongs_to :category
  validates_presence_of :category_id, :language, :friendly_url, :h1, :h2, :item1_header, :item1_body, :item2_header, :item2_body, :item3_header, :item3_body, :quote, :quoted_name, :quoted_city
  validates_uniqueness_of :friendly_url, :message => "must be unique"
  attr_accessible :category_id, :language, :friendly_url, :title, :meta_description, :meta_keywords, :h1, :h2, :item1_header, :item1_body, :item2_header, :item2_body, :item3_header, :item3_body, :quote, :quoted_name, :quoted_city
  
  has_attached_file :image,
    :styles         => {:lp => "416x305>"},
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket),
    :path =>        "landing_pages/:id/image/:style/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url => ':s3_domain_url'
  attr_accessible :image
  validates_attachment_presence :image
  
  has_attached_file :quoted,
    :styles         => {:thumb => "45x45>"},
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket),
    :path =>        "landing_pages/:id/quoted/:style/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url => ':s3_domain_url'
  attr_accessible :quoted

end
