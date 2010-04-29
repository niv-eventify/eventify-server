class IcalController < InheritedResources::Base
  defaults :resource_class => Event, :collection_name => 'events', :instance_name => 'event', :route_instance_name => "ical"
  belongs_to :event, :polymorphic => true
  belongs_to :rsvp, :polymorphic => true

  actions :show

  def show
    send_data parent.to_ical, {:disposition=>'inline', :filename=> parent.ical_filename, :type => "text/calendar"}
  end

protected
  def parent
    @parent ||= params[:event_id] ? current_user.events.find(params[:event_id]) : (Guest.find_by_email_token(params[:rsvp_id]).try(:event) || raise(ActiveRecord::RecordNotFound))
  end
end
