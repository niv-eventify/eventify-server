class UploadedPicturesController < InheritedResources::Base
  actions :index, :show, :create, :new
  respond_to :js, :only => [:index]
  def new
    @uploaded_picture = UploadedPicture.new()
    render :action => "new", :layout => false  
  end
end
