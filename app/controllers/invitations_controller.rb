class InvitationsController < InheritedResources::Base

  defaults :resource_class => Event, :collection_name => 'events', :instance_name => 'event'

  before_filter :require_user
  actions :edit, :update, :show
  after_filter :clear_flash, :only => :update

  # show

  # edit

  # TODO pass array of guest_ids to send_invitations
  # update

protected
  def begin_of_association_chain
    current_user
  end

  def clear_flash
    flash[:notice] = nil
  end
end
