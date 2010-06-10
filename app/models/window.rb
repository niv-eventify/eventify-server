class Window < ActiveRecord::Base
  belongs_to :design

  validates_presence_of :design, :top_x, :top_y, :width, :height
  validates_numericality_of :top_x, :top_y, :width, :height

  attr_accessible :design_id, :top_x, :top_y, :width, :height
end
