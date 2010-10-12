class GuestsMessagesController < InheritedResources::Base
  before_filter :require_user
  after_filter :clear_flash
  belongs_to :event
  layout nil

  actions :new , :create
  respond_to :js , :only => [:new, :create]

end
