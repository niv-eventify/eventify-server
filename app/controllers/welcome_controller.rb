class WelcomeController < ApplicationController
  def index
    @popular_categories = Category.popular(2)
  end
end
