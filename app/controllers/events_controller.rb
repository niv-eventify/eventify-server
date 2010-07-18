class EventsController < InheritedResources::Base
  before_filter :set_design_and_category, :only => :new

  before_filter :require_user, :except => [:create, :new]

  before_filter :set_event, :only => [:edit, :update, :show]
  around_filter :set_event_time_zone, :only => [:new, :edit, :update, :show]
  after_filter :set_uploaded_pictures, :only => :create

  actions :create, :new, :edit, :update, :index, :show

  # index

  def show
    if @event.stage_passed < 3 || @event.guests.count.zero?
      flash[:error] = _("Please add at least one guest")
      redirect_to event_guests_path(@event)
      return
    end

    show!
  end

  def create
    if !logged_in? && params[:event] && params[:event][:user_attributes]
      params[:event].trust(:user_attributes)
      params[:event][:user_attributes].trust(:email)
    end

    # will allow passing params[:event][:tz] in a future
    Time.use_zone(params[:event] && params[:event][:tz] || Event::DEFAULT_TIME_ZONE) do
      @event = Event.new(params[:event])
      if logged_in?
        @event.user = current_user
        @event.user_is_activated = !current_user.activated_at.nil?
      end
      @event.language = current_locale

      create! do |success, failure|
        success.html do
          flash[:notice] = nil
          redirect_to event_guests_path(@event, :wizard => true)
          unless logged_in?
            UserSession.create(@event.user)
            @event.user.deliver_activation_instructions!
          end
        end
        failure.html do
          _add_extra_error_messages
          render(:action => "new")
        end
      end
    end
  end

  def new
    @event = Event.new(:category => @category, :design => @design, :starting_at => Event.default_start_time)
    @event.build_user unless logged_in?
    new!
  end

  def update
    return _cancel_sms if "true" == params[:cancel_sms]

    update! do |success, failure|
      success.html do
        flash[:notice] = resource.reminders_disabled? ? _("Event updated, but some reminders disabled") : _("Event updated")
        return redirect_to(edit_event_path(@event, :wizard => params[:wizard])) if "true" == params[:update_design]

        redirect_to event_guests_path(@event, :wizard => params[:wizard])
      end
      success.js { render(:nothing => true) }
    end
  end

protected

  def _add_extra_error_messages
    if @event.user.new_record? && @event.user.errors.on(:email)
      if existing_user = User.find_by_email(@event.user.email)
        if existing_user.activated_at
          flash.now[:error] = _("You already have an account, please login with your email and password.")
        else
          flash.now[:error] = _("Instructions to activate your account have been emailed to you. Please check your email.")
        end
      end
    end
  end

  def collection
    period = past_events? ? :past : :upcoming
    current_user.events.send(period).with(:user, :design).paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def set_event
    @event = current_user.events.find(params[:id])
  end

  def set_event_time_zone
    if @event
      @event.with_time_zone { yield }
    else
      Event.new.with_time_zone { yield }
    end
  end

  def set_design_and_category
    @design = Design.available.find(params[:design_id])
    @category = Category.enabled.find(params[:category_id])
  end

  def set_uploaded_pictures
    UploadedPicture.find_all_by_id(session[:uploaded_picture_ids]).each do |pic|
      pic.update_attribute(:event, @event)
    end
    CroppedPicture.find_all_by_id(session[:cropped_picture_ids]).each do |pic|
      pic.update_attribute(:event, @event)
    end
  end

  def past_events?
    "true" == params[:past]
  end
  helper_method :past_events?

  def _cancel_sms
    @event.cancel_sms!
    redirect_to edit_invitation_path(@event)
  end
end
