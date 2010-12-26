class PagesController < HighVoltage::PagesController

  skip_before_filter :checkie6
  layout :pages_layout
protected
  def current_page
    "pages/#{params[:id].to_s.downcase}_#{current_locale}"
  end
private
  def pages_layout
    params[:id].to_s.downcase == "analytics_cookie" ? false : "application"
  end
end
