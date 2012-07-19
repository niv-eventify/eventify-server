class GuestsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event
  actions :index, :create, :update, :destroy, :edit, :show
  respond_to :js, :only => [:create, :update, :destroy, :edit]
  has_scope :rsvp_yes
  has_scope :rsvp_no
  has_scope :rsvp_maybe
  has_scope :bounced
  has_scope :rsvp_not_rsvped
  has_scope :rsvp_not_opened_invite
  has_scope :no_invitation_sent
  has_scope :by_name

  before_filter :add_by_name, :only => :index

  after_filter :clear_flash

  def mass_update
    raise "wrong attribute #{params[:attr]}" unless Guest::MASS_UPDATABLE.member?(params[:attr])

    event_by_user_or_host
    params[:guest_ids].split(/,/).each do |gid|
      guest = @event.guests.find(gid)
      guest.update_attribute(params[:attr], params[:value])
    end

    render :nothing => true
  end

  def index
    index! do |success|
      @guests_count = @event.guests.count
      @has_filter = !params[:query].blank? || _any_scope?
      success.html { redirect_changes_disabled(@event) }
    end
  end

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
          render(:update) {|page| resource_edit_form(page, resource, params[:attribute], params[:true_attribute])}
        else
          render(:nothing => true)
        end
      end
    end
  end
  # show

  def edit
    raise unless resource.has_attribute?(params[:attribute])
    edit!
  end

protected

  def begin_of_association_chain
    event_by_user_or_host
  end

  def collection
    get_collection_ivar || set_collection_ivar(_load_collection)
  end

  def _load_collection
    if params[:query].blank?
      end_of_association_chain.paginate(_page_opts.merge(:include => :sms_messages))
    else
      event_by_user_or_host
      Guest.search(params[:query], :with => {:event_id => @event.id}, :allow_star => true).paginate(_page_opts)
    end
  end

  def _page_opts
    {:page => params[:page], :per_page => (params[:per_page] || 40)}
  end

  def _is_scoped_by?(key)
    (params.keys.collect(&:to_sym) & scopes_configuration.keys).first == key
  end
  helper_method :_is_scoped_by?

  def _any_scope?
    scope_keys = scopes_configuration.keys
    scope_keys.delete(:by_name)
    !(params.keys.collect(&:to_sym) & scope_keys).blank?
  end
  helper_method :_any_scope?

  def add_by_name
    params[:by_name] = true
  end
end
