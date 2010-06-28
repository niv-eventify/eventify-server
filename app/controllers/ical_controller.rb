class IcalController < InheritedResources::Base
  defaults :resource_class => Event, :collection_name => 'events', :instance_name => 'event', :route_instance_name => "ical"
  belongs_to :event, :polymorphic => true
  belongs_to :rsvp, :polymorphic => true

  actions :show, :create

  def create
    Notifier.deliver_ical_attachment(parent)
    flash[:notice] = _("Event details sent to your email")
  end

  def show
    should_convert = "true" == params[:convert]
    send_data parent.to_ical(should_convert), :disposition=>'inline', :filename=> parent.ical_filename(should_convert), :type => "text/calendar; charset=UTF-8"
  end

protected
  def parent
    @parent ||= params[:event_id] ? current_user.events.find(params[:event_id]) : (Guest.find_by_email_token(params[:rsvp_id]).try(:event) || raise(ActiveRecord::RecordNotFound))
  end
end
