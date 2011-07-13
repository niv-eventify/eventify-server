class LobbyController < InheritedResources::Base
  actions :index
  
  def index
    @include_google_plusone = true
    @categories = all_enabled_categories
    @popular_categories = Category.enabled.popular(10)
  end
end
