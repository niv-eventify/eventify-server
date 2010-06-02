class WelcomeController < ApplicationController
  def index
    @popular_categories = Category.enabled.popular(2)
    @designs = Design.carousel
    respond_to do |format|
      format.html {logger.debug('html')}
      format.xml { render :template => "designs/carousel", :layout => false }
    end
  end
end
