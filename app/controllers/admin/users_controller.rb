class Admin::UsersController < InheritedResources::Base

  before_filter :require_admin
  actions :index, :update

  def update
    resource.is_free = !resource.is_free
    resource.save!
    render(:update) do |page|
      page << "jQuery('##{dom_id(resource)} td.is_free').html(#{resource.is_free?.to_s.to_json})"
    end
  end
end
