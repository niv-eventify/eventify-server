class Window < ActiveRecord::Base
  belongs_to :design
  has_many :cropped_pictures
  validates_presence_of :design, :top_x, :top_y, :width, :height
  validates_numericality_of :top_x, :top_y, :width, :height

  attr_accessible :design_id, :top_x, :top_y, :width, :height

  def window_dimensions(ratio)
    @window_dimensions = {
      :top =>    "#{(top_y/ratio).ceil}px",
      :left =>   "#{(top_x/ratio).ceil}px",
      :width =>  "#{(width/ratio).ceil}px",
      :height => "#{(height/ratio).ceil}px"
    }
  end
end
