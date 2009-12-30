class EventsController < InheritedResources::Base
  before_filter :set_design_and_category, :only => :new
  actions :create, :new

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

protected
  def set_design_and_category
    @design = Design.available.find(params[:design_id])
    @category = Category.enabled.find(params[:category_id])
  end
end
