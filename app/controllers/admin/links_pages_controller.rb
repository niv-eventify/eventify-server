class Admin::LinksPagesController < InheritedResources::Base
  before_filter :require_admin

  def create
    create!{admin_links_pages_path}
  end
  def update
    update!{admin_links_pages_path}
  end
end
