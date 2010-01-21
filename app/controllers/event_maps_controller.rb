class EventMapsController < InheritedResources::Base
  before_filter :require_user

  def destroy
    event = current_user.events.find(params[:event_id])
    event.update_attribute(:map, nil)
    render :nothing => true
  end
end
