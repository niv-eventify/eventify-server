class CategoriesController < InheritedResources::Base

  before_filter :require_admin
  actions :new, :edit, :create, :update, :index, :destroy

  def create
    create! do |success, failure|
      success.html { redirect_to(categories_path) }
      failure.html { render(:action => "new")}
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to(categories_path) }
      failure.html { render(:action => "edit")}
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.disabled_at = Time.now.utc
    @category.save
    redirect_to categories_path
  end

protected
  def collection
    @categories = end_of_association_chain.send("true" == params[:disabled] ? :disabled : :enabled)
  end
end
