class PaymentsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event
  before_filter :ssl_redirect, :only => :edit
  before_filter :ssl_required, :only => :update

  actions :new, :edit, :update, :create

  def new
    build_resource
    resource.calc_defaults
    @guests_count = resource.event.guests.count
  end

  def edit
    debugger
    edit!
  end

  def create
    build_resource
    debugger
    if resource.save
      redirect_to edit_resource_path(resource)
    else # shouldn't happen unless someone hacks form html manually
      resource.calc_defaults
      @guests_count = resource.event.guests.count
      flash.now[:error] = _("Please choose a package that reflects your event")
      render :action => "new"
    end
  end

protected

  def begin_of_association_chain
    current_user
  end

  def ssl_redirect
    redirect_to(:protocol => "https://") if Rails.env == "production" && !request.ssl?
  end
end
