class CroppedPicturesController < InheritedResources::Base
  actions :create, :destroy
  respond_to :js, :only => [:create]
  after_filter :clear_flash

  def create
    remove_curr_window_cropped_pics
    uploaded_pic = UploadedPicture.find(params[:uploaded_picture])
    adjust_ratio(uploaded_pic)
    @cropped_picture = CroppedPicture.new(params[:cropped_picture])
    @cropped_picture.pic = uploaded_pic.pic
    @cropped_picture.event_id = params[:event]
    @cropped_picture.window_id = params[:window]
    if @cropped_picture.save
      if @cropped_picture.event_id.to_i == 0
        session[:cropped_picture_ids] = session[:cropped_picture_ids] || []
        session[:cropped_picture_ids] << @cropped_picture.id
      end
      if "true" == params[:just_save]
        render :index
      else
        render(:update) do |page|
          if @cropped_picture.event_id.to_i == 0
            page.redirect_to new_event_path(:design_id => params[:design_id], :category_id => params[:category_id], :wizard => params[:wizard])
          else
            page.redirect_to edit_event_path(@cropped_picture.event_id, :wizard => params[:wizard])
          end
        end
      end
    else
      render :create
    end
  end

  def destroy
    destroy! do |format|
      format.js{render :nothing => true}
    end
  end
private
  def adjust_ratio(uploaded_pic)
    coords = params[:cropped_picture]
    ratio = uploaded_pic.pic_geometry(:original).width / params[:cropper_width].to_f

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
