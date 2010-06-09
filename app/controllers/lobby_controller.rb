class LobbyController < InheritedResources::Base
  actions :index
  
  def index
    @categories = all_enabled_categories
    @popular_categories = Category.enabled.popular(10)
  end
end
