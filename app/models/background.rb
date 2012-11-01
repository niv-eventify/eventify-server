class Background < ActiveRecord::Base
  belongs_to :event

  attr_accessible :event_id

  has_attached_file :rsvp,
                    :storage        => :s3,
                    :bucket         => GlobalPreference.get(:s3_bucket) || "junk",
                    :path =>        "backgrounds/:id/rsvp/:filename",
                    :default_url   => "",
                    :s3_credentials => {
                        :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
                        :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
                    },
                    :url => ':s3_domain_url'

  attr_accessible :rsvp
  validates_attachment_presence :rsvp
  validates_attachment_size :rsvp, :less_than => 4.megabytes
end
