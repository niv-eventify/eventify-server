class WelcomeController < ApplicationController
  def index
    @popular_categories = Category.enabled.popular(2)
    @designs = Design.carousel.by_ordering
    @redirect_on_login = true
    @include_google_plusone = true


    respond_to do |format|
      format.html {logger.debug('html')}
      format.xml { render :template => "designs/carousel", :layout => false }
    end
  end
end
