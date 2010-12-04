class UsersController < InheritedResources::Base
  before_filter :require_admin, :only => [:index, :destroy]
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_owner, :except => [:new, :create, :index]
  before_filter :set_default_domain, :only => :create

  def create
    user = build_resource
    user.is_admin = true if User.count.zero?
    if user.save_without_session_maintenance
      I18n.with_locale(current_locale){user.deliver_activation_instructions!}
      flash[:notice] = _("Your account has been created. Please check your e-mail for your account activation instructions!")
      respond_to do |wants|
        wants.html do
          redirect_to "/"
        end
        wants.js do
          render(:update) {|page| page.redirect_to "/"}
        end
      end
    else
      respond_to do |wants|
        wants.html { render :action => :new }
        wants.js do
          render(:update) do |page|
            page << "jQuery('#register_form.bg-m').html(#{render(:partial => "users/new").to_json});"
          end
        end
      end    
    end
  end

  def update
    @user = User.find(params[:id])
    unless @user.activated_at
      flash[:error] = "You cannot edit unactivated users"
      redirect_to users_path
      return
    end
    # manual update protected attributes
    if current_user.is_admin?
      @user.is_admin = params[:user].delete(:is_admin) if params[:user] && params[:user][:is_admin]
    end
    if "true" == params[:enable]
      @user.disabled_at = nil
      @user.save!
      flash[:notice] = "User #{@user.email} enabled"
      redirect_to users_path
    else
      update!
    end
  end

  def destroy
    @user = User.enabled.find(params[:id])
    if @user.id == current_user.id
      flash[:error] = "You cannot remove your own account"
      redirect_to users_path
      return
    end
    @user.update_attribute(:disabled_at, Time.now.utc)
    flash[:notice] = "User disabled"
    redirect_to users_path
  end

  protected

  def require_owner
    return false unless require_user
    return true unless resource # let it fail
    return true if current_user.try(:is_admin?)
    return true if resource == current_user # owner

    flash[:error] = "Only the owner can see this page"
    redirect_to "/"
    return false
  end

  def collection
    @users ||= end_of_association_chain.send("true" == params[:disabled] ? :disabled : :enabled).paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def resource
    @user ||= params[:id] ? User.find(params[:id]) : current_user
  end

  def build_resource
    params[:user].try(:trust, :email)
    super
  end

  # this will set global preference :domain to the current domain
  # when we create the first user.
  def set_default_domain
    if GlobalPreference.get(:domain).blank?
      GlobalPreference.set!(:domain, request.host_with_port)
    end
  end
end
