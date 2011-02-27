class EventMapsController < InheritedResources::Base

  def destroy
    if params[:event_id].to_i == 0
      map = UploadedMap.find_by_id(session[:uploaded_map_id])
      map.destroy unless map.blank?
      session[:uploaded_map_id] = nil
    else
      require_user
      event_by_user_or_host
      @event.map = nil
      @event.save
    end
    render :nothing => true
  end
  def show
    render :nothing => true
  end
end
