class Admin::LandingPagesController < InheritedResources::Base
  before_filter :require_admin

  def create
    create!{admin_landing_pages_path}
  end
  def update
    update!{admin_landing_pages_path}
  end
end
