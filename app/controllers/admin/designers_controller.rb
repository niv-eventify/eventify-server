class Admin::DesignersController < InheritedResources::Base
  before_filter :require_admin

end
