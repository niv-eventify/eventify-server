class UploadedPicturesController < InheritedResources::Base
  actions :index, :show, :create, :new
  respond_to :js, :only => [:index, :create]
  def new
    @event = params[:event]
    @uploaded_picture = UploadedPicture.new()
    render :action => "new", :layout => false
  end

  def create
    @uploaded_picture = UploadedPicture.new(params[:uploaded_picture])
    @uploaded_picture.event_id = params[:uploaded_picture][:event_id]
    respond_to do |format|
      if @uploaded_picture.save
        flash[:notice] = _("Picture was successfully uploaded")
        if @uploaded_picture.event_id.to_i == 0
          session[:uploaded_picture_ids] = session[:uploaded_picture_ids] || []
          session[:uploaded_picture_ids] << @uploaded_picture.id
          @uploaded_pictures = UploadedPicture.find(session[:uploaded_picture_ids])
        else
          @uploaded_pictures = UploadedPicture.find_all_by_event_id(@uploaded_picture.event_id)
        end
        format.js do
          responds_to_parent do
            render :index
          end
        end
      else
        format.js do
          responds_to_parent do
            render :create
          end
        end
      end
    end
  end
end
