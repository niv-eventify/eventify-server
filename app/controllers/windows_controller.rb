class WindowsController < InheritedResources::Base
  actions :new, :edit, :create, :update, :index, :destroy, :show

  def create
    @window = Window.new(params[:window])
    @window.design_id = params[:design_id]
    create! do |success, failure|
      success.html {redirect_to(admin_design_path(params[:design_id]))}
      failure.html {
        render(:action => "new")
      }
    end
  end

  def new
    @design = Design.find(params[:design_id])
    new!
  end  

  def edit
    @design = Design.find(params[:design_id])
    edit!
  end  

  def update
    update! do |success, failure|
      success.html {redirect_to(admin_design_path(params[:design_id]))}
      failure.html {
        render(:action => "new")
      }
    end
  end
  
  def destroy
    destroy! do |format|
      format.html{redirect_to(admin_design_path(params[:design_id]))}
    end
  end
end
