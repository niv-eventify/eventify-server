class InvitationsController < InheritedResources::Base

  before_filter :require_user, :only => :create
  before_filter :set_guest, :only => [:show, :update]
  belongs_to :event, :optional => true

  def create
     # TODO pass array of guest_ids to send_invitations
     @event = association_chain.last
    if @event.send_invitations
      flash[:notice] = _("Invitations to %{event} are being sent") % {:event => h(@event.name)}
      redirect_to events_path
    else
      flash[:error] = _("Payments are not completed yet")
      redirect_to event_payments_path(@event)
    end
  end

  def show
  end

  def update
    @guest.rsvp = Guest.sanitize_rsvp(params[:guest][:rsvp])
    @guest.save
  end

protected

  def begin_of_association_chain
    current_user
  end

  def set_guest
    @guest = Guest.find_by_email_token(params[:id]) || (raise ActiveRecord::RecordNotFound)
  end
end
