class SummariesController < InheritedResources::Base
  defaults :resource_class => Event, :collection_name => 'events', :instance_name => 'event', :route_instance_name => "summary"
  before_filter :require_user
  actions :show

protected
  def begin_of_association_chain
    current_user
  end
end
