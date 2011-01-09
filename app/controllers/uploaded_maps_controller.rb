class UploadedMapsController < InheritedResources::Base
  actions :new, :create, :show
  respond_to :html, :except => :create
  respond_to :js, :only => :create
  def new
    @event = params[:event]
    @uploaded_map = UploadedMap.new()
    render :new, :layout => false
  end
  
  def create
    if params[:event_id].to_i == 0
      @uploaded_map = UploadedMap.new(:map => params[:uploaded_picture][:pic])
      if status = @uploaded_map.save
        session[:uploaded_map_id] = @uploaded_map.id
        @map = @uploaded_map.map
      end
    else
      @event = Event.find(params[:event_id])
      @event.map = params[:uploaded_picture][:pic]
      if status = @event.save
        @map = @event.map
      end
    end
    if status
      responds_to_parent{render :show}
    else
      responds_to_parent{render :create}
    end
  end
end
