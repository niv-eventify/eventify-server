class SummariesController < InheritedResources::Base
  defaults :resource_class => Event, :collection_name => 'events', :instance_name => 'event', :route_instance_name => "summary"
  before_filter :require_user, :check_invitations
  around_filter :set_time_zone
  actions :show

protected
  def resource
    event_by_user_or_host
  end

  # don't allow access summaries until all invitations are sent
  def check_invitations
    return redirect_to(edit_invitation_path(resource)) if resource.stage_passed < 4 && !resource.canceled?
  end

  def set_time_zone
    resource.with_time_zone { yield }
  end
end
