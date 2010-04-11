class Design < ActiveRecord::Base
  belongs_to :category
  belongs_to :creator, :class_name => "User"

  validates_presence_of :category, :text_top_x, :text_top_y, :text_width, :text_height
  validates_numericality_of :text_top_x, :text_top_y, :text_width, :text_height
  validates_numericality_of :title_top_x, :title_top_y, :title_width, :title_height, :allow_nil => true
  
  attr_accessible :category_id, :text_top_x, :text_top_y, :text_width, :text_height, :title_top_x, :title_top_y, :title_width, :title_height, :font, :title_color, :message_color, :text_align, :no_repeat_background, :background_color

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
  validates_attachment_size :card, :less_than => 2.megabytes

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
  validates_attachment_size :background, :less_than => 2.megabytes

  has_attached_file :preview,
    :styles         => {:small => "67x50>", :stage2 => "561x374>", :list => "119x79>"},
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
  validates_attachment_size :preview, :less_than => 2.megabytes

  has_attached_file :preview_with_text,
    :styles         => {:medium => "218x145>", :lightbox => "666x444>", :carousel => "300x200>"},
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket),
    :path =>        "designs/:id/:style/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key),
      :secret_access_key => GlobalPreference.get(:s3_secret),
    }
  attr_accessible :preview_with_text
  validates_attachment_size :preview_with_text, :less_than => 2.megabytes

  def stage2_preview_dimensions
    ratio =   1.6     #fullsize/preview_size
    x_delta = 116.5   #delta between background and postcard ((900-667)/2)
    y_delta = 50      #delta between background and postcard ((600-500)/2)

    @stage2_preview_dimensions ||= {
      :top =>    "#{(text_top_y + y_delta)/ratio}px",
      :left =>   "#{(text_top_x + x_delta)/ratio}px",
      :width =>  "#{(text_width/ratio)}px",
      :height => "#{(text_height/ratio)}px",
      'text-align' => "#{text_align}",
      :color => "rgb(#{message_color})"
    }
  end

  def is_seperated_title?
    !title_width.blank?
  end
  
  def stage2_title_dimensions
    ratio =   1.6     #fullsize/preview_size
    x_delta = 116.5   #delta between background and postcard ((900-667)/2)
    y_delta = 50      #delta between background and postcard ((600-500)/2)

    res = {
      'text-align' => "#{text_align}",
      :color => "rgb(#{title_color})"
    }
    if !title_width.blank?
      res = res.merge({
        :top =>    "#{(title_top_y + y_delta)/ratio}px",
        :left =>   "#{(title_top_x + x_delta)/ratio}px",
        :width =>  "#{(title_width/ratio)}px",
        :height => "#{(title_height/ratio)}px"
      })
    end
    @stage2_title_dimensions ||= res
  end
end
