class GuestsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event
  actions :index, :create, :update, :destroy, :edit, :show
  respond_to :js, :only => [:create, :update, :destroy, :edit]

  # index
  # create
  # destroy
  # update
  # edit
  # show

  def edit
    raise unless resource.has_attribute?(params[:attribute])
    edit!
  end

protected
  
  def begin_of_association_chain
    current_user
  end
end
