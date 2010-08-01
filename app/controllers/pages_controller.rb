class PagesController < HighVoltage::PagesController

  skip_before_filter :checkie6

protected
  def current_page
    "pages/#{params[:id].to_s.downcase}_#{current_locale}"
  end

end
