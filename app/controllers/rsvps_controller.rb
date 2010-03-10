class RsvpsController < InheritedResources::Base
  defaults :resource_class => Guest, :collection_name => 'guests', :instance_name => 'guest', :route_instance_name => "rsvp"
  actions :show, :update
  respond_to :js, :only => :update
  after_filter :clear_flash, :only => :update

  # show

  # update

protected
  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_email_token(params[:id]))
  end

  def clear_flash
    flash[:notice] = nil
  end
end
