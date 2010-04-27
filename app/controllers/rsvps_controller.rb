class RsvpsController < InheritedResources::Base
  defaults :resource_class => Guest, :collection_name => 'guests', :instance_name => 'guest', :route_instance_name => "rsvp"
  actions :show, :update
  respond_to :js, :only => :update
  respond_to :iphone, :only => :show
  after_filter :clear_flash, :only => :update
  before_filter :adjust_format_for_iphone

  def show
    if "true" == params[:more]
      render :action => "show_more"
    else
      render :action => "show", :layout => false
    end
  end

  # update

protected
  def resource
    @resource ||= get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_email_token(params[:id]))
  end

  def clear_flash
    flash[:notice] = nil
  end
end
