class DesignsController < InheritedResources::Base
  actions :index

  def index
    super do |format|
      format.html
      format.js { render :template => "designs/carousel", :layout => false }
    end
  end

protected

  def category
    @category ||= Category.enabled.find(params[:category_id])
  end

  def collection
    respond_to do |format|
      format.html { @collection ||= category.designs.paginate(:page => params[:page], :per_page => (params[:per_page] || 12)) }
      format.js { @collection ||= category.designs }
    end
  end
end
