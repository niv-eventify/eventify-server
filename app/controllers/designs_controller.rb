class DesignsController < InheritedResources::Base
   # before_filter :require_user, :only => :show

  actions :index, :show
  belongs_to :event, :optional => true

  def index
    super do |format|
      format.html
      format.js { render :template => "designs/carousel", :layout => false }
    end
  end

  # events/0,1,2,.../designs
  def show
    if params[:event_id].to_i > 0
      @event = current_user.events.find(params[:event_id])
      @design = @event.design
      @category = @event.category
      @uploaded_pictures = UploadedPicture.find_all_by_event_id(@event.id)
    else
      @design = Design.find(params[:design_id])
      @category = Category.find(params[:category_id])
      @event = Event.new(:category => @category, :design => @design)
      @uploaded_pictures = UploadedPicture.find_all_by_id(session[:uploaded_picture_ids] || [])
    end
  end

protected

  def category
    @category ||= Category.enabled.find(params[:category_id])
  end

  def collection
    @collection ||= category.designs.paginate(:page => params[:page], :per_page => (params[:per_page] || 6))
  end

  def carusel_collection
    @carusel_collection ||= category.designs
  end
  helper_method :carusel_collection
end
