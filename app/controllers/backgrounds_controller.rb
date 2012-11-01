class BackgroundsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event

end
