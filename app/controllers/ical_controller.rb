class IcalController < InheritedResources::Base
  defaults :resource_class => Event, :collection_name => 'events', :instance_name => 'event', :route_instance_name => "ical"
  belongs_to :event, :polymorphic => true
  belongs_to :rsvp, :polymorphic => true

  actions :show, :create

  def create
    guest = Guest.find_by_id(params[:email_recipient])
    @parent = guest.blank? ? parent : (guest.try(:event) || raise(ActiveRecord::RecordNotFound))
    send_to = guest || current_user
    Notifier.deliver_ical_attachment(@parent, send_to)
    flash[:notice] = _("Event details sent to your email")
    if guest
      redirect_to rsvp_path(guest.email_token, :more => true)
    else
      redirect_to summary_path(parent)
    end
  end

  def show
    should_convert = "true" == params[:convert]
    send_data parent.to_ical(should_convert), :disposition=>'inline', :filename=> parent.ical_filename(should_convert), :type => "text/calendar; charset=UTF-8"
  end

protected
  def parent
    @parent ||= params[:event_id] ? event_by_user_or_host : (Guest.find_by_email_token(params[:rsvp_id]).try(:event) || raise(ActiveRecord::RecordNotFound))
  end
end
