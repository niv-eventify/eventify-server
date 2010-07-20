class BouncesController < InheritedResources::Base
  defaults :resource_class => Guest, :collection_name => 'guests', :instance_name => 'guest', :route_instance_name => "bounce"
  before_filter :require_user
  belongs_to :event
  actions :index

  # index

protected
  
  def begin_of_association_chain
    current_user
  end

  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.bounced.all)
  end
end
