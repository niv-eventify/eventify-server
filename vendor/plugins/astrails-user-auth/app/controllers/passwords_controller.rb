class PasswordsController < InheritedResources::Base
  unloadable
  defaults :resource_class => User, :instance_name => :user

  actions :new, :update, :edit

  before_filter :require_no_user, :except => [:edit, :update]
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  # new! + new.html.haml

  def create
    @user = User.find_by_email(params[:user][:email])
    if @user
      I18n.with_locale(current_locale){@user.deliver_password_reset_instructions!}
      if @user.activated_at
        # user is already active
        flash[:notice] = _("Instructions to reset your password have been emailed to you. Please check your email.")
      else
        flash[:notice] = _("Instructions to activate your account have been emailed to you. Please check your email.")
      end
      respond_to do |wants|
        wants.html {redirect_to "/"}
        wants.js {render(:update){|page| page.redirect_to("/")}}
      end
      
    else
      flash[:error] = _("No user was found with that email address")
      respond_to do |wants|
        wants.html {render :action => :new}
        wants.js {render(:update){|page| page.redirect_to("/")}}
      end
    end
  end

  #edit! + edit.html.haml

  def update
    unless resource.activated_at
      resource.activated_at = Time.now
      @activated = true
    end

    update! do |success, failure|
      if resource.errors.empty?
        I18n.with_locale(current_locale){@user.send(@activated ? :deliver_activation_confirmation! : :deliver_password_reset_confirmation!)}
      else
        resource.activated_at = nil if @activated # need to revert so that the password_edit_title will set right title
      end

      success.html do
        if @activated && !resource.events.count.zero?
          redirect_to edit_invitation_path(resource.events.first)
        else
          redirect_to profile_path
        end
      end
      failure.html {render(:action => "edit")}
    end

  end

  private

  def build_resource
    @user ||= User.new
  end

  def resource
    @user ||= params[:id] ? User.find_using_perishable_token(params[:id]) : current_user
  end

  def load_user_using_perishable_token
    unless resource
      flash[:error] = _("We're sorry, but we could not locate your account. If you are having issues try copying and pasting the URL from your email into your browser or restarting the reset password process.")
      redirect_to new_password_path
    end
  end
end
