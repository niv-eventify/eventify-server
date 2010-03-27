class RemindersController < InheritedResources::Base
  before_filter :require_user
  after_filter :remove_flash
  belongs_to :event
  layout nil

  actions :new, :create, :update, :destroy, :edit
  respond_to :js, :except => [:new, :edit]

  # new
  # create
  def update
    return _update_activity if params[:reminder][:is_active]
    resource.is_active = true
    update!
  end
  # edit

  # destroy

protected
  def begin_of_association_chain
    current_user
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
