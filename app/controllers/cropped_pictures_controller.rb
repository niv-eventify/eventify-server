class CroppedPicturesController < InheritedResources::Base
  actions :create
  respond_to :js, :only => [:create]

  def create
    logger.debug("??1: #{Time.now}")
    remove_curr_window_cropped_pics
    logger.debug("2: #{Time.now}")
    uploaded_pic = UploadedPicture.find(params[:uploaded_picture])
    logger.debug("3: #{Time.now}")
    adjust_ratio(uploaded_pic)
    logger.debug("4: #{Time.now}")
    @cropped_picture = CroppedPicture.new(params[:cropped_picture])
    logger.debug("5: #{Time.now}")
    @cropped_picture.pic = uploaded_pic.pic
    logger.debug("6: #{Time.now}")
    @cropped_picture.event_id = params[:event]
    logger.debug("7: #{Time.now}")
    @cropped_picture.window_id = params[:window]
    logger.debug("8: #{Time.now}")
    if @cropped_picture.save
      logger.debug("9: #{Time.now}")
      if @cropped_picture.event_id.to_i == 0
        session[:cropped_picture_ids] = session[:cropped_picture_ids] || []
        session[:cropped_picture_ids] << @cropped_picture.id
      end
      logger.debug("10: #{Time.now}")
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
  def remove_curr_window_cropped_pics
    win = Window.find(params[:window])
    if params[:event].to_i > 0
      CroppedPicture.destroy_all("window_id = '#{params[:window]}' AND event_id = '#{params[:event]}'")
    else
      session_cropped_pics = win.cropped_pictures.find_all_by_id(session[:cropped_picture_ids])
      CroppedPicture.destroy(session_cropped_pics)
    end
  end
end
