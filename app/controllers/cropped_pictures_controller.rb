class CroppedPicturesController < InheritedResources::Base
  actions :create
  respond_to :js, :only => [:create]

  def create
    if params[:event].to_i > 0
      CroppedPicture.delete_all(:conditions => "window_id = '#{params[:window]}' AND event_id = '#{params[:event]}'")
    end
    uploaded_pic = UploadedPicture.find(params[:uploaded_picture])
    logger.debug(params[:cropped_picture])
    adjust_ratio(uploaded_pic)
    logger.debug(params[:cropped_picture])
    @cropped_picture = CroppedPicture.new(params[:cropped_picture])
    @cropped_picture.pic = uploaded_pic.pic
    @cropped_picture.event_id = params[:event]
    @cropped_picture.window_id = params[:window]
    if @cropped_picture.save
      if @cropped_picture.event_id.to_i == 0
        session[:cropped_picture_ids] = session[:cropped_picture_ids] || []
        session[:cropped_picture_ids] << @cropped_picture.id
      end
      render :index
    else
      render :create
    end
  end
private
  def adjust_ratio(uploaded_pic)
    coords = params[:cropped_picture]
    ratio = uploaded_pic.pic_geometry(:original).width / uploaded_pic.pic_geometry(:crop).width
    for attribute in [:crop_x, :crop_y, :crop_w, :crop_h] do
      params[:cropped_picture][attribute] = (params[:cropped_picture][attribute].to_i * ratio).to_i
    end
  end
end
