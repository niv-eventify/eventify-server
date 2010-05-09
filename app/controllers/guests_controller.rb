class GuestsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event
  actions :index, :create, :update, :destroy, :edit, :show
  respond_to :js, :only => [:create, :update, :destroy, :edit]

  after_filter :clear_flash

  # index
  # create
  # destroy
  def update
    update! do |success, failure|
      success.js do
        if params[:attribute]
          render(:update) {|page| refresh_guest_row(page, resource) }
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
  # edit
  # show

  def edit
    raise unless resource.has_attribute?(params[:attribute])
    edit!
  end

protected
  
  def begin_of_association_chain
    current_user
  end
end
