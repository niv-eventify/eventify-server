class InvitationsController < InheritedResources::Base

  before_filter :require_user
  belongs_to :event

  def create
    @event = association_chain.last
     # TODO pass array of guest_ids to send_invitations
    if @event.send_invitations
      flash[:notice] = _("Invitations to %{event} are being sent") % {:event => h(@event.name)}
      redirect_to events_path
    else
      flash[:error] = _("Payments are not completed yet")
      redirect_to event_payments_path(@event)
    end
  end

protected

  def begin_of_association_chain
    current_user
  end
  
end
