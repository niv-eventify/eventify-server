class RsvpsController < InheritedResources::Base
  defaults :resource_class => Guest, :collection_name => 'guests', :instance_name => 'guest', :route_instance_name => "rsvp"
  actions :show, :update, :edit
  respond_to :js, :only => [:update, :edit]
#  respond_to :iphone, :only => :show
  after_filter :clear_flash, :only => :update
#  before_filter :adjust_format_for_iphone
  around_filter :set_timezone, :only => :show

  # edit

  def update
    # only attendees_count, rsvp and message_to_host are changable here
    resource.rsvp = params[:guest][:rsvp] if params[:guest][:rsvp]
    resource.message_to_host = params[:guest][:message_to_host] if params[:guest][:message_to_host]
    resource.attendees_count = params[:guest][:attendees_count] if params[:guest][:attendees_count]
    resource.save!

    redirect_opts = {:action => "show", :id => resource.email_token, :more => "true"}
    respond_to do |wants|
      wants.html {redirect_to(redirect_opts) }
      wants.js do
        render(:update) { |page| page.redirect_to(redirect_opts) }
      end
    end
  end

  def show
    respond_to do |format|
      format.html{
        resource.update_attribute(:first_viewed_invitation_at, Time.now) unless resource.first_viewed_invitation_at
        if "true" == params[:more]
          resource.attendees_count ||= 1
          render :action => "show_more"
        else
          if current_locale != resource.event.language
            return redirect_to rsvp_path(:id => params[:id], :locale => resource.event.language)
          end

          render :action => "show", :layout => false
        end
      }
      format.pdf{
        @event = resource.event
        render :pdf => @event.name,
               :template => 'rsvps/show.pdf.erb',
               :show_as_html => !params[:debug].blank?,
               :layout => 'pdf.html',
               :dpi => '300',
               :lowquality => false,
               :disable_smart_shrinking => false,
               :orientation => 'Portrait'
      }
    end
  end

protected
  def resource
    @resource ||= get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_email_token(params[:id])) || set_resource_ivar(end_of_association_chain.find_by_id(params[:id]))
    raise ActiveRecord::RecordNotFound unless @resource
    @resource
  end

  def set_timezone
    resource.event.with_time_zone { yield }
  end
end
