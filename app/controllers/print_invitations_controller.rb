class PrintInvitationsController < InheritedResources::Base
  defaults :resource_class => Event, :collection_name => 'events', :instance_name => 'event', :route_instance_name => "summary"
  respond_to :pdf
  actions :show

  def show
    show! do |success|
      success.pdf do
        render :pdf => @event.name,
               :template => '/print_invitations/show.pdf.erb',
               :show_as_html => !params[:debug].blank?,
               :layout => 'pdf.html',
               :dpi => '300',
               :lowquality => false,
               :disable_smart_shrinking => false,
               :orientation => 'Portrait'
      end
    end
  end
end
