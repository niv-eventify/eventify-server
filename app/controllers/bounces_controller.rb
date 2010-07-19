class BouncesController < InheritedResources::Base
  actions :index, :destroy

  def index
    super do |format|
      format.html do
        render :index, :layout => false
      end
    end
  end
end
