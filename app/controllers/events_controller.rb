class EventsController < InheritedResources::Base
  before_filter :set_design_and_category, :only => :new
  actions :create, :new

  def create
    if !logged_in? && params[:event] && params[:event][:user_attributes]
      params[:event].trust(:user_attributes)
      params[:event][:user_attributes].trust(:email)
    end

    @event = Event.new(params[:event])

    create! do |success, failure|
      success.html do
        redirect_to "/"
        UserSession.create(@event.user)
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
