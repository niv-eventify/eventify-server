class UploadedPicturesController < InheritedResources::Base
  actions :index, :show, :create, :new, :destroy
  respond_to :js, :only => [:index, :create, :destroy]
  after_filter :clear_flash

  def new
    @event = params[:event]
    @uploaded_picture = UploadedPicture.new()
    render :action => "new", :layout => false
  end

  def destroy
    destroy! do |format|
      format.js{render :nothing => true}
    end
  end

  def create
    @uploaded_picture = UploadedPicture.new(params[:uploaded_picture])
    @uploaded_picture.event_id = params[:event_id]
    respond_to do |format|
      if @uploaded_picture.save
        if @uploaded_picture.event_id.to_i == 0
          session[:uploaded_picture_ids] = session[:uploaded_picture_ids] || []
          session[:uploaded_picture_ids] << @uploaded_picture.id
          @uploaded_pictures = UploadedPicture.find_all_by_id(session[:uploaded_picture_ids])
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
