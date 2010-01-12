class EventsController < InheritedResources::Base
  before_filter :set_design_and_category, :only => :new

  before_filter :require_user, :only => [:edit, :update, :index]

  before_filter :set_event, :only => [:edit, :update]

  actions :create, :new, :edit, :update, :index

  # index

  def create
    if !logged_in? && params[:event] && params[:event][:user_attributes]
      params[:event].trust(:user_attributes)
      params[:event][:user_attributes].trust(:email)
    end

    @event = Event.new(params[:event])
    @event.user = current_user if logged_in?

    create! do |success, failure|
      success.html do
        flash[:notice] = nil
        redirect_to event_guests_path(@event)
        UserSession.create(@event.user) unless logged_in?
      end
      failure.html { render(:action => "new") }
    end
  end


  def new
    @event = Event.new(:category => @category, :design => @design)
    @event.build_user unless logged_in?
    new!
  end

  # edit

  def update
    update! do |success, failure|
      success.html { redirect_to event_guests_path(@event) }
    end
  end

protected

  def collection
    period = past_events? ? :past : :upcoming
    current_user.events.send(period).with(:user, :design).paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def set_event
    @event = current_user.events.find(params[:id])
  end

  def set_design_and_category
    @design = Design.available.find(params[:design_id])
    @category = Category.enabled.find(params[:category_id])
  end

  def past_events?
    "true" == params[:past]
  end
  helper_method :past_events?
end
