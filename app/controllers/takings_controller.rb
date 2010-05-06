class TakingsController < InheritedResources::Base
  defaults :resource_class => Guest, :collection_name => 'guests', :instance_name => 'guest', :route_instance_name => "taking"

  actions :update, :destroy
  after_filter :clear_flash
  before_filter :require_user, :only => :destroy
  belongs_to :event, :optional => true

  # update

  def destroy
    resource.destroy
  end

protected
  def resource
    return @resource if @resource
    if params[:event_id]
      e = current_user.events.find(params[:event_id])
      @resource = e.takings.find(params[:id])
    else
      @resource = Guest.find_by_email_token(params[:id])
    end
  end
end
