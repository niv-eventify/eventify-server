class RsvpsController < InheritedResources::Base
  defaults :resource_class => Guest, :collection_name => 'guests', :instance_name => 'guest', :route_instance_name => "rsvp"
  actions :show, :update
  respond_to :js, :only => :update
  after_filter :clear_flash, :only => :update
  before_filter :iphone_request?

  def show
    if "true" == params[:more]
      render :action => "show_more"
    else
  	  render :action => (resource.event.design.no_repeat_background ?  "show_no_repeat_background" : "show"), :layout => false
  	end
  end

  # update

protected
  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_email_token(params[:id]))
  end

  def clear_flash
    flash[:notice] = nil
  end
end
