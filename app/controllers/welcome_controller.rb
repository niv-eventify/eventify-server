class WelcomeController < ApplicationController
  def index
    @popular_categories = Category.enabled.popular(2)
  end
end
