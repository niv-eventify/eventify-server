class SummariesController < InheritedResources::Base
  defaults :resource_class => Event, :collection_name => 'events', :instance_name => 'event', :route_instance_name => "summary"
  before_filter :require_user, :check_invitations
  actions :show

protected
  def begin_of_association_chain
    current_user
  end

  def check_invitations
    return redirect_to(edit_invitation_path(resource)) unless resource.invitations_to_send_counts[:total].zero?
  end
end
