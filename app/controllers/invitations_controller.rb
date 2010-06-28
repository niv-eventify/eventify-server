class InvitationsController < InheritedResources::Base

  defaults :resource_class => Event, :collection_name => 'events', :instance_name => 'event', :route_instance_name => "invitation"

  before_filter :require_user
  actions :edit, :update, :show

  before_filter :sms_message, :only => :edit
  before_filter :check_event, :only => [:edit, :update]
  before_filter :check_guests, :only => [:edit, :update]
  before_filter :set_invitations, :only => [:edit, :update]
  before_filter :check_invitations, :only => :edit

  # show

  # edit

  def update
    resource.send_invitations_now = true

    update! do |success, failure|
      success.html {flash[:notice] = nil; redirect_to(invitation_path(resource))}
      failure.html { render(:action => "edit") }
    end
  end

protected
  def begin_of_association_chain
    current_user
  end

  def sms_message
    resource.sms_message = resource.default_sms_message
    resource.sms_resend_message = resource.default_sms_message_for_resend
  end

  def check_event
    if resource.starting_at < Time.now.utc
      flash[:error] = _("Event start time is passed.")
      redirect_to edit_event_path(resource)
      return false
    end
  end

  def check_guests
    return true unless resource.guests.count.zero?
    flash[:error] = _("Please add at least one guest")
    redirect_to event_guests_path(resource)
  end

  def set_invitations
    @invitations_to_send = resource.invitations_to_send_counts
  end

  def check_invitations

    return unless @event.user.activated_at

    if 4 == resource.stage_passed
      redirect_to summary_path(resource)
      return false
    elsif 3 == resource.stage_passed && @invitations_to_send[:total].zero?
      resource.stage_passed = 4
      resource.save!
      redirect_to summary_path(resource)
      return false
    end
  end
end
