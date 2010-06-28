class TakingsController < InheritedResources::Base
  defaults :resource_class => Guest, :collection_name => 'guests', :instance_name => 'guest', :route_instance_name => "taking"

  actions :index, :update, :destroy
  after_filter :clear_flash
  before_filter :require_user, :only => :destroy
  belongs_to :event, :rsvp, :optional => true

  # update

  def index
    respond_to do |wants|
      wants.js
    end
  end

  def destroy
    resource.destroy
  end


protected
  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.all)
  end

  def resource
    return @resource if @resource
    if params[:event_id]
      e = current_user.events.find(params[:event_id])
      @resource = e.takings.find(params[:id])
    else
      @resource = Guest.find_by_email_token(params[:id] || params[:rsvp_id])
    end
  end
end
