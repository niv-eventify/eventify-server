class PaymentsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event
  before_filter :ssl_redirect, :only => :edit
  before_filter :ssl_required, :only => :update
  before_filter :verify_paid, :only => :update

  skip_before_filter :setup_localization, :only => [:edit, :update]
  before_filter      :setup_localization_skip_domain, :only => [:edit, :update]


  actions :new, :edit, :update, :create

  filter_parameter_logging :cc, :expiration_month, :expiration_year, :ccv2, :user_ident

  def new
    build_resource
    reload_payment
    new!
  end

  def edit
    resource.set_names_from_user
    edit!
  end

  def update
    resource.load_payment_details(params[:payment])

    begin
      resource.pay!
      flash[:notice] = _("Paid successfully.")
      redirect_to_back_page
    rescue ActiveRecord::RecordInvalid
      render :action => :edit
    rescue PaymentError
      flash.now[:error] = _("A problem occured: %{error_description}") % {:error_description => resource.payment_status_description}
      render :action => :edit
    end
  end

  def create
    build_resource
    resource.user_id = current_user.id
    if resource.save
      redirect_to edit_resource_url(resource, ssl_host_and_port.merge(:back => params[:back]))
    else # shouldn't happen unless someone hacks form html manually
      reload_payment
      flash.now[:error] = _("Please choose a package that reflects your event")
      render :action => "new"
    end
  end

protected
  def verify_paid
    redirect_to_back_page unless resource.paid_at.nil?
  end

  def redirect_to_back_page
    case params[:back]
    when "cancellations"
      redirect_to edit_cancellation_url(resource.event_id, :locale => current_locale, :protocol => "http://")
    else # any or 'invitations'
      redirect_to edit_invitation_url(resource.event_id, :locale => current_locale, :protocol => "http://")
    end
  end

  def begin_of_association_chain
    current_user
  end

  def ssl_redirect
    redirect_to(:protocol => "https://")  if Rails.env == "production" && !request.ssl?
  end

  def ssl_required
    return false if Rails.env == "production" && !request.ssl?
  end

  def setup_localization_skip_domain
    @disable_language_change = true
    setup_localization({})
  end

  def reload_payment
    resource.calc_defaults
    @invitations_count = resource.event.total_invitations_count
  end
end
