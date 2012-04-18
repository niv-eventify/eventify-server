class LandingPagesController < InheritedResources::Base
  actions :show

  def show
    @skip_feedback = true
    @landing_page = LandingPage.find_by_friendly_url_and_language(params[:friendly_url], current_locale)

    if @landing_page
      @include_google_plusone = true
      @page_title = @landing_page.title
      @meta_keywords = @landing_page.meta_keywords
      @meta_description = @landing_page.meta_description
      show!
    elsif !(@links_page = LinksPage.find_by_friendly_url_and_language(params[:friendly_url], current_locale)).blank?
      render "links_pages/show"
    else
      render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
    end
  end
end
