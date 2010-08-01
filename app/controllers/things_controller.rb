class ThingsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event
  actions :index, :create, :update, :destroy, :edit, :update
  respond_to :js, :only => [:create, :update, :destroy, :edit]

  after_filter :clear_flash

  def index
    index! do |success|
      success.html {redirect_past if @event.past?}
    end
  end

  # create
  # destroy
  # update

  def edit
    raise unless resource.has_attribute?(params[:attribute])
    edit!
  end

  def update
    update! do |success, failure|
      success.js do
        if params[:attribute]
          render(:update) {|page| refresh_thing_row(page, resource) }
        else
          render(:nothing => true)
        end
      end
      failure.js do
        if params[:attribute]
          render(:update) {|page| resource_edit_form(page, resource, params[:attribute])}
        else
          render(:nothing => true)
        end
      end
    end
  end

protected
  
  def begin_of_association_chain
    current_user
  end

  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.all)
  end
end
