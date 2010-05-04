class RsvpsController < InheritedResources::Base
  defaults :resource_class => Guest, :collection_name => 'guests', :instance_name => 'guest', :route_instance_name => "rsvp"
  actions :show, :update, :edit
  respond_to :js, :only => [:update, :edit]
  respond_to :iphone, :only => :show
  after_filter :clear_flash, :only => :update
  before_filter :adjust_format_for_iphone

  def update
    # only attendees_count, rsvp and message_to_host are changable here
    resource.rsvp = params[:guest][:rsvp] if params[:guest][:rsvp]
    resource.message_to_host = params[:guest][:message_to_host] if params[:guest][:message_to_host]
    resource.attendees_count = params[:guest][:attendees_count] if params[:guest][:attendees_count]
    resource.save!
  end

  def show
    if "true" == params[:more]
      render :action => "show_more"
    else
      render :action => "show", :layout => false
    end
  end

protected
  def resource
    @resource ||= get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_email_token(params[:id]))
  end
end
