class EventsController < InheritedResources::Base
  before_filter :set_design_and_category, :only => :new

  def new
    @event = Event.new(:category => @category, :design => @design)
    new!
  end

protected
  def set_design_and_category
    @design = Design.available.find(params[:design_id]) unless params[:design_id].blank?
    @category = Category.enabled.find(params[:category_id]) unless params[:category_id].blank?
  end
end
