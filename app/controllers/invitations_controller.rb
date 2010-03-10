class InvitationsController < InheritedResources::Base

  defaults :resource_class => Event, :collection_name => 'events', :instance_name => 'event', :route_instance_name => "invitation"

  before_filter :require_user
  actions :edit, :update, :show

  # show

  # edit

  # TODO pass array of guest_ids to send_invitations
  def update
    update! do |success, failure|
      success.html {flash[:notice] = nil; redirect_to(invitation_path(resource))}
      failure.html {render(:action => "edit")}
    end
  end

protected
  def begin_of_association_chain
    current_user
  end
end
