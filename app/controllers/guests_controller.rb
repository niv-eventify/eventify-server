class GuestsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event
  actions :index, :create, :update, :destroy, :edit
  respond_to :js, :only => [:create, :update, :destroy]

  # index
  # create
  # destroy
  # update

protected
  
  def begin_of_association_chain
    current_user
  end
end
