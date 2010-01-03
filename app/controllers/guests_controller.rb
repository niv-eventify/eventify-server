class GuestsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event
  actions :index, :create
  respond_to :js, :only => :create

  # index
  # create

protected
  
  def begin_of_association_chain
    current_user
  end
end
