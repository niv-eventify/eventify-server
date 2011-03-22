class LandingPagesController < InheritedResources::Base
  actions :show
  
  def show
    @skip_feedback = true
    @landing_page = LandingPage.find_by_friendly_url_and_language(params[:friendly_url], current_locale);
    show!
  end
end
