class EventMapsController < InheritedResources::Base
  before_filter :require_user

  def destroy
    event_by_user_or_host
    @event.map = nil
    @event.map_link = nil
    @event.save
    render :nothing => true
  end
end
