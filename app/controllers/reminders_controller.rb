class RemindersController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event
  layout nil

  actions :new, :create, :update, :destroy, :edit
  respond_to :js, :except => [:new, :edit]

  # new
  # create
  # update
  # edit
  # destroy

protected
  def begin_of_association_chain
    current_user
  end
end
