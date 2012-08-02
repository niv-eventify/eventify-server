class DesignersController< InheritedResources::Base
  before_filter :require_user, :except => [:show, :download]
  actions :edit, :update, :show

  def edit
    @designer = Designer.find_by_user_id(current_user.id)
    if @designer.blank?
      redirect_to profile_path
      return
    end
    edit!
  end

  def update
    @designer = Designer.find(params[:id])
    @designer.avatar = nil if params[:delete_avatar] == true
    @designer.work1 = nil if params[:delete_work1] == true
    @designer.work2 = nil if params[:delete_work2] == true
    @designer.work3 = nil if params[:delete_work3] == true
    update!
  end

  def show
    @designer = Designer.find_by_friendly_url(params[:friendly_url])
    if not @designer.blank?
      show!
    elsif not (@designer = Designer.find_by_id(params[:friendly_url])).blank?
      redirect_to "/designers/#{@designer.friendly_url}"
    else
      render :file => "#{Rails.root}/public/404.html?#{params[:friendly_url]}", :layout => false, :status => 404
    end
  end

  def download
    send_file "#{RAILS_ROOT}/private/#{params[:file]}.txt", :type=>"text/plain"
  end
end
