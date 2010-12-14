class CancellationsController < InheritedResources::Base
  defaults :resource_class => Event, :instance_name => 'event', :route_instance_name => "cancellation"
  before_filter :require_user
  before_filter :event_by_user_or_host
  before_filter :verify_stats
  before_filter :check_payments

  actions :edit, :update

  def edit
    @event.set_cancellations(@invited_stats)
    edit!
  end

  def update
    update! do |success, failure|
      failure.html
      success.html do
        if @event.send_cancellation
          flash[:notice] = _("Notifications are being sent.")
          redirect_to summary_path(@event)
        else
          # TODO: redirect to sms payments
        end
      end
    end
  end

protected
  def verify_stats
    @invited_stats = @event.guests.invited_stats

    if @invited_stats[:total].zero? || !@event.canceled? || @event.cancellation_sent?
      flash[:notice] = _("Event cancelled - no guests to notify or guests are already notified.")
      redirect_to summary_path(@event)
      return false
    end
  end

  def check_payments
    redirect_to(new_event_payment_path(@event, :back => "cancellations")) if @event.payments_required?
  end
end
