class DesignsController < InheritedResources::Base
   # before_filter :require_user, :only => :show

  actions :index, :show
  belongs_to :event, :optional => true

  def index
    super do |format|
      format.html
      format.js do
        if params[:change_design]
          @event = params[:event_id].to_i > 0 ? current_user.events.find(params[:event_id]) : Event.new
          render(:update) do |page|
            page << "stage1.page_num = #{params[:page]}"
            page << "jQuery.nyroModalManual({endShowContent: function(){jQuery('.category-selector select').customSelect();}, content: #{render(:partial => "designs/change_design").to_json}, width: 825, minHeight: 550});"
          end
        else
          render :template => "designs/carousel", :layout => false
        end
      end
    end
  end

  # events/0,1,2,.../designs
  def show
    respond_to do |format|
      format.html {
        if params[:event_id].to_i > 0
          return unless require_user
          @event = current_user.events.find(params[:event_id])
          return if redirect_changes_disabled(@event)
          @design = @event.design
          @category = @event.category
          @uploaded_pictures = UploadedPicture.find_all_by_event_id(@event.id)
        else
          @design = Design.find(params[:design_id])
          @category = Category.find(params[:category_id])
          @event = Event.new(:category => @category, :design => @design)
          @uploaded_pictures = UploadedPicture.find_all_by_id(session[:uploaded_picture_ids] || [])
        end
      }
      format.js {
        @design = Design.find(params[:id])
        @category = Category.find(params[:category_id])
        if params[:event_id].to_i > 0
          @event = Event.find(params[:event_id])
        end
        render :partial => "designs/zoom"
      }
    end
  end

protected

  def category
    @category ||= Category.enabled.find(params[:category_id])
  end

  def collection
    @collection ||= category.designs.paginate(:page => params[:page], :per_page => (params[:per_page] || 9))
  end

  def carusel_collection
    @carusel_collection ||= category.designs
  end
  helper_method :carusel_collection
end
