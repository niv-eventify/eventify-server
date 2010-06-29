class Design < ActiveRecord::Base
  has_many :classifications
  has_many :categories, :through => :classifications
  belongs_to :creator, :class_name => "User"
  has_many :windows

  accepts_nested_attributes_for :classifications, :allow_destroy => true

  validates_presence_of :text_top_x, :text_top_y, :text_width, :text_height
  validates_numericality_of :text_top_x, :text_top_y, :text_width, :text_height
  validates_numericality_of :title_top_x, :title_top_y, :title_width, :title_height, :allow_nil => true
  
  attr_accessible :category_id, :text_top_x, :text_top_y, :text_width, :text_height,
    :title_top_x, :title_top_y, :title_width, :title_height, :font, :title_color,
    :message_color, :text_align, :in_carousel,
    :classification_attributes

  def classification_attributes=(vals)
    vals.each do |c|
      unless c[:id].blank?
        classification = classifications.find(c[:id])
        if "true" == c[:_delete]
          classification.destroy
        else
          classification.category_id = c[:category_id]
          classification.save
        end
      else
        classifications.build(:category_id => c[:category_id]) unless "true" == c[:_delete]
      end
    end
  end

  named_scope :available, {:conditions => "designs.disabled_at IS NULL"}
  named_scope :carousel, {:conditions => "designs.in_carousel IS true"}
  after_create :assign_root_classification

  has_attached_file :card,
    :styles         => {:small => "67x50>", :stage2 => "561x374>", :list => "119x79>"},
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket),
    :path =>        "designs/:id/:style/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url => ':s3_domain_url'
  attr_accessible :card
  validates_attachment_presence :card
  validates_attachment_size :card, :less_than => 2.megabytes

  has_attached_file :preview,
    :styles         => {:medium => "218x145>", :lightbox => "666x444>", :carousel => "400x267>"},
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket),
    :path =>        "designs/:id/:style/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url => ':s3_domain_url'
  attr_accessible :preview
  validates_attachment_size :preview, :less_than => 2.megabytes

  has_attached_file :carousel,
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket) || "junk",
    :path =>        "assets/:id/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url => ':s3_domain_url'
  attr_accessible :carousel
  validates_attachment_size :carousel, :less_than => 2.megabytes

  def validate
    errors.add(:base, "select at least one category") if classifications.blank?
  end

  def stage2_preview_dimensions
    ratio =   1.6     #fullsize/preview_size

    @stage2_preview_dimensions ||= {
      :top =>    "#{(text_top_y/ratio).to_int}px",
      :left =>   "#{(text_top_x/ratio).to_int}px",
      :width =>  "#{(text_width/ratio).to_int}px",
      :height => "#{(text_height/ratio).to_int}px",
      'text-align' => "#{text_align}",
      :color => "rgb(#{message_color})",
      "font-family" => "#{font}"
    }
  end

  def is_seperated_title?
    !title_width.blank?
  end
  
  def stage2_title_dimensions
    ratio =   1.6     #fullsize/preview_size

    res = {
      'text-align' => "#{text_align}",
      :color => "rgb(#{title_color})",
      "font-family" => "#{font}"
    }
    if !title_width.blank?
      res = res.merge({
        :top =>    "#{(title_top_y/ratio).to_int}px",
        :left =>   "#{(title_top_x/ratio).to_int}px",
        :width =>  "#{(title_width/ratio).to_int}px",
        :height => "#{(title_height/ratio).to_int}px"
      })
    end
    @stage2_title_dimensions ||= res
  end

  def assign_root_classification
    Classification.create(:design_id => self.id, :category_id => Category.root.id)
  end
end
