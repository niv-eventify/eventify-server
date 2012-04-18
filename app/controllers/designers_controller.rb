class DesignersController< InheritedResources::Base
    before_filter :require_user, :except => :show
    before_filter :require_admin, :only => [:create, :delete]

end
