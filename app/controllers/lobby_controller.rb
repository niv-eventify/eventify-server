class LobbyController < InheritedResources::Base
  actions :index
  
  def index
    @categories = Category.enabled.find_all()
    @popular_categories = Category.popular(10)
  end
end
