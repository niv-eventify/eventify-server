class My::PaymentsController < InheritedResources::Base
  before_filter :require_user
  actions :index

  # index

protected
  def begin_of_association_chain
    current_user
  end

  def collection
    get_collection_ivar ||
      set_collection_ivar(end_of_association_chain.paid.for_list.paginate(:page => params[:page], :per_page => params[:per_page]))
  end
end
