class EventMapsController < InheritedResources::Base
  before_filter :require_user

  def destroy
    event = current_user.events.find(params[:event_id])
    event.map = nil
    event.map_link = nil
    event.save
    render :nothing => true
  end
end
