class Design < ActiveRecord::Base
  belongs_to :category
  belongs_to :creator, :class_name => "User"

  validates_presence_of :category, :text_top_x, :text_top_y, :text_width, :text_height
  validates_numericality_of :text_top_x, :text_top_y, :text_width, :text_height
  attr_accessible :category_id, :text_top_x, :text_top_y, :text_width, :text_height

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
    :styles         => {:small => "67x50>", :medium => "218x145>", :carousel => "300x200>", :stage2 => "561x374>", :list => "119x79>"},
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

  def stage2_preview_dimentions
    ratio =   1.6     #fullsize/preview_size
    x_delta = 116.5   #delta between background and postcard ((900-667)/2)
    y_delta = 50      #delta between background and postcard ((600-500)/2)

    @stage2_preview_dimentions ||= {
      :top =>    "#{(text_top_y + y_delta)/ratio}px",
      :left =>   "#{(text_top_x + x_delta)/ratio}px",
      :width =>  "#{(text_width/ratio)}px",
      :height => "#{(text_height/ratio)}px"
    }
  end
end
