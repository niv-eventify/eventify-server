class TakingsController < InheritedResources::Base
  defaults :resource_class => Guest, :collection_name => 'guests', :instance_name => 'guest', :route_instance_name => "taking"

  actions :update

  after_filter :clear_flash

  # update

protected
  def resource
    @resource ||= Guest.find_by_email_token(params[:id])
  end
end
