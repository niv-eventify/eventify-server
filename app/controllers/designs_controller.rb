class DesignsController < InheritedResources::Base
  actions :index
  
  #index

protected

  def category
    @category ||= Category.enabled.find(params[:category_id])
  end

  def collection
    @collection ||= category.designs.paginate(:page => params[:page], :per_page => (params[:per_page] || 12))
  end
end
