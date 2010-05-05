class ThingsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event
  actions :index, :create, :update, :destroy
  respond_to :js, :only => [:create, :update, :destroy]

  after_filter :remove_flash

  # index
  # create
  # destroy
  # update

protected
  
  def begin_of_association_chain
    current_user
  end
end
