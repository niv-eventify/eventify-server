class Admin::UsersController < InheritedResources::Base

  before_filter :require_admin
  actions :index, :update
  has_scope :by_created_at, :default => true

  def update
    todo = params['todo']
    logger.debug("todo: #{todo}")
    if todo == 'create_designer'
       render(:update) do |page|
         curr_designer = Designer.find_by_user_id(resource)
         if curr_designer
           page << "alert('already has a designer');window.location='#{edit_admin_designer_url(curr_designer)}'"
         end
         curr_designer = Designer.create(:user => resource)
         page << "window.location='#{edit_admin_designer_url(curr_designer)}'"
       end
    elsif todo == 'toggle_free'
      resource.is_free = !resource.is_free
      resource.save!
      render(:update) do |page|
        page << "jQuery('##{dom_id(resource)} td.is_free').html(#{resource.is_free?.to_s.to_json})"
      end
    end
  end
end
