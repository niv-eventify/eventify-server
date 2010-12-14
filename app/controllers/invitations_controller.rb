class InvitationsController < InheritedResources::Base

  defaults :resource_class => Event, :collection_name => 'events', :instance_name => 'event', :route_instance_name => "invitation"

  before_filter :require_user
  actions :edit, :update, :show
  before_filter :event_by_user_or_host
  before_filter :sms_message, :only => :edit
  before_filter :check_event, :only => [:edit, :update]
  before_filter :check_guests, :only => [:edit, :update]
  before_filter :set_invitations, :only => [:edit, :update]
  before_filter :check_payments, :only => [:edit, :update]
  before_filter :check_invitations, :only => :edit

  # show

  # edit

  def update
    @event.send_invitations_now = true

    update! do |success, failure|
      success.html {flash[:notice] = nil; redirect_to(invitation_path(@event))}
      failure.html { render(:action => "edit") }
    end
  end

protected
  def sms_message
    @event.sms_message ||= @event.default_sms_message
    @event.sms_resend_message ||= @event.default_sms_message_for_resend
  end

  def check_event
    if @event.starting_at < Time.now.utc
      flash[:error] = _("Event start time is passed.")
      redirect_to edit_event_path(@event)
      return false
    end

    if @event.canceled?
      redirect_to summary_path(@event)
      return false
    end
  end

  def check_guests
    return true unless @event.guests.count.zero?
    flash[:error] = _("Please add at least one guest")
    redirect_to event_guests_path(@event)
  end

  def set_invitations
    @invitations_to_send = @event.invitations_to_send_counts
  end

  def check_invitations

    return unless @event.user.activated_at

    if 4 == @event.stage_passed
      redirect_to summary_path(@event)
      return false
    elsif 3 == @event.stage_passed && @invitations_to_send[:total].zero?
      @event.stage_passed = 4
      @event.save!
      redirect_to summary_path(@event)
      return false
    end
  end

  def check_payments
    redirect_to(new_event_payment_path(@event, :back => "invitations")) if @event.payments_required?
  end
end
