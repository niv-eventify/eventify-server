class LobbyController < InheritedResources::Base
  actions :index
  
  def index
  	@categories = Category.enabled.find_all()
  	@popular_categories = Category.popular(2)
  end
end
