class PagesController < HighVoltage::PagesController

protected
  def current_page
    "pages/#{params[:id].to_s.downcase}.#{current_locale}"
  end

end
