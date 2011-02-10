class EventsController < InheritedResources::Base
  before_filter :set_design_and_category, :only => :new

  before_filter :require_user, :except => [:create, :new]

  before_filter :event_by_user_or_host, :only => [:edit, :update, :show, :destroy]
  around_filter :set_event_time_zone, :only => [:new, :edit, :update, :show, :index]
  after_filter :set_uploaded_pictures, :only => :create

  actions :create, :new, :edit, :update, :index, :show, :destroy

  before_filter :redirect_disabled_events, :only => [:show, :edit, :update]

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
    redirect_to "/" and return unless params[:event_type].blank?
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

      set_garden_data unless params[:garden_id].blank?
      set_uploaded_map

      create! do |success, failure|
        success.html do
          unless @host.blank?
            @host.event = @event
            @host.save
          end
          flash[:notice] = nil
          if "true" == params[:just_save]
            redirect_to edit_event_path(@event, :wizard => true)
          else
            redirect_to event_guests_path(@event, :wizard => true)
          end
          unless logged_in?
            UserSession.create(@event.user)
            I18n.with_locale(current_locale){@event.user.deliver_activation_instructions!}
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
    unless params[:garden_id].blank?
      garden = Garden.find(params[:garden_id])
      @event.location_name = garden.name unless garden.name.blank?
      @event.location_address = garden.address unless garden.address.blank?
      @event.map_link = garden.url unless garden.url.blank?
      @map = garden.map unless garden.map.url.blank?
      @garden = garden
    end
    set_uploaded_map

    new!
  end

  def update
    return _cancel_sms if "true" == params[:cancel_sms]

    update! do |success, failure|
      success.html do
        flash[:notice] = resource.reminders_disabled? ? _("Event updated, but some reminders disabled") : _("Event updated")
        if "true" == params[:update_design]
          @event.remove_invitation_thumbnail
          if @event.design.windows.blank?
            return redirect_to(edit_event_path(@event, :wizard => params[:wizard]))
          else
            @event.set_invitation_thumbnail
            return redirect_to(event_design_path(@event, @event.design, :wizard => params[:wizard]))
          end
        end
        if "true" == params[:just_save]
          redirect_to edit_event_path(@event, :wizard => params[:wizard])
        else
          redirect_to event_guests_path(@event, :wizard => params[:wizard])
        end
      end
      success.js { render(:nothing => true) }
    end
  end

  def destroy
    @event.cancel!
    flash["notice"] = _("Event canceled.")
    redirect_to edit_cancellation_path(@event)
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
    period = past_events? ? :past : (cancelled_events? ? :cancelled : :upcoming)
    Event.by_user_id(current_user.id).send(period).with(:user, :design).by_created_at.paginate(:page => params[:page], :per_page => params[:per_page])
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
    cp = CroppedPicture.find_all_by_id(session[:cropped_picture_ids]).each do |pic|
      pic.update_attribute(:event, @event)
    end
    @event.set_invitation_thumbnail unless cp.blank?
  end

  def past_events?
    "true" == params[:past]
  end
  helper_method :past_events?

  def cancelled_events?
    "true" == params[:cancelled]
  end
  helper_method :cancelled_events?

  def _cancel_sms
    @event.cancel_sms!
    redirect_to edit_invitation_path(@event)
  end

  def redirect_disabled_events
    redirect_changes_disabled(@event)
  end

  def set_garden_data
    garden = Garden.find(params[:garden_id])
    @event.map = garden.map unless garden.map.url.blank?
    @host = Host.new(:user => @event.user, :name => garden.name, :email => garden.user.email, :garden => garden)
  end

  def set_uploaded_map
    uploaded_map = UploadedMap.find_by_id(session[:uploaded_map_id])
    @event.map = @map = uploaded_map.map unless uploaded_map.blank?
  end
end
