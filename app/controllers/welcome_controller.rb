class WelcomeController < ApplicationController
  def index
    @popular_categories = Category.enabled.popular(2)
    @designs = Design.carousel
    @redirect_on_login = true

    respond_to do |format|
      format.html {logger.debug('html')}
      format.xml { render :template => "designs/carousel", :layout => false }
    end
  end
end
