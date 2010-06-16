class Window < ActiveRecord::Base
  belongs_to :design
  has_many :cropped_pictures
  validates_presence_of :design, :top_x, :top_y, :width, :height
  validates_numericality_of :top_x, :top_y, :width, :height

  attr_accessible :design_id, :top_x, :top_y, :width, :height

  def window_dimensions(ratio)
    @window_dimensions ||= {
      :top =>    "#{(top_y/ratio).to_int}px",
      :left =>   "#{(top_x/ratio).to_int}px",
      :width =>  "#{(width/ratio).to_int}px",
      :height => "#{(height/ratio).to_int}px"
    }
  end
end
