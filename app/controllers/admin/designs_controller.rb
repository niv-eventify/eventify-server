class Admin::DesignsController < InheritedResources::Base
  before_filter :require_admin
  actions :new, :edit, :create, :update, :index, :destroy, :show

  def create
    @design = Design.new(params[:design])
    @design.creator_id = current_user.id
    create! do |success, failure|
      success.html {redirect_to(admin_designs_path)}
      failure.html {render(:action => "new")}
    end
  end

  def destroy
    @design = Design.find(params[:id])
    @design.disabled_at = Time.now.utc
    @design.save!
    flash[:notice] = "Design deleted"
    redirect_to(admin_designs_path)
  end

protected
  def collection
    @designs ||= Design.available.paginate(:page => params[:page], :per_page => params[:per_page])
  end
end
