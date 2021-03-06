class RemindersController < InheritedResources::Base
  before_filter :require_user
  after_filter :clear_flash
  belongs_to :event
  layout nil

  actions :index, :new, :create, :update, :destroy, :edit
  respond_to :js, :except => [:new]

  def new
    new! do |success|
      resource.set_default_values
      success.html
    end
  end

  # create
  def update
    return _update_activity if params[:reminder][:is_active]
    resource.is_active = true
    update!
  end
  # edit

  # destroy

protected
  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.find(:all))
  end

  def begin_of_association_chain
    event_by_user_or_host
  end

  def _update_activity
    if resource.update_attributes(params[:reminder])
      render :nothing => true
    else
      # open edit reminder
      render(:update) do |page|
        page << "jQuery('a.link_to_edit_#{dom_id(resource)}').click()"
        rerender_reminders(page)
      end
    end
  end
end
