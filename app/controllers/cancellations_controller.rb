class CancellationsController < InheritedResources::Base
  defaults :resource_class => Event, :collection_name => 'events', :instance_name => 'event', :route_instance_name => "cancellation"
  before_filter :require_user
  before_filter :verify_stats

  actions :edit, :update

  def edit
    resource.set_cancellations(@invited_stats)
    edit!
  end

  def update
    update! do |success, failure|
      failure.html
      success.html do
        if resource.send_cancellation
          flash[:notice] = _("Notifications are being sent.")
          redirect_to summary_path(resource)
        else
          # TODO: redirect to sms payments
        end
      end
    end
  end

protected
  def begin_of_association_chain
    current_user
  end

  def verify_stats
    @invited_stats = resource.guests.invited_stats

    if @invited_stats[:total].zero? || !@event.canceled? || @event.cancellation_sent?
      flash[:notice] = _("Event cancelled - no guests to notify or guests are already notified.")
      redirect_to summary_path(resource)
      return false
    end
  end
end
