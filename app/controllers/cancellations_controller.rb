class CancellationsController < InheritedResources::Base
  defaults :resource_class => Event, :collection_name => 'events', :instance_name => 'event', :route_instance_name => "cancellation"
  before_filter :require_user
  before_filter :verify_stats

  actions :edit, :update

  def edit
    resource.cancel_by_email = resource.cancel_by_sms = true
    edit!
  end

  # update

protected
  def begin_of_association_chain
    current_user
  end

  def verify_stats
    @invited_stats = resource.guests.invited_stats
    if @invited_stats[:total].zero?
      redirect_to summary_path(resource)
      return false
    end
  end
end
