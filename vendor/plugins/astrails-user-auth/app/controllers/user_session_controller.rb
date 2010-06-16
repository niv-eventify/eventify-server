class UserSessionController < InheritedResources::Base
  unloadable
  actions :new, :create, :destroy
  before_filter :require_user, :only => :destroy
  defaults :singleton => true

  def create
    create! do |success, failure|
      success.html do
        if current_user.disabled?
          flash[:error] = _("Your account has been disabled, please contact support.")
          flash.delete(:notice)
          current_user_session.destroy
          redirect_to login_path
        else
          redirect_back_or_default(home_path)
        end
      end
      failure.js do
        render(:update) do |page|
          flash[:notice] = nil
          page << <<-JAVASCRIPT
            jQuery('#login_form.bg-m').html(#{render(:partial => "user_session/new").to_json});
            jQuery('#login_form.bg-m input:checkbox').customCheckbox();
          JAVASCRIPT
        end
      end
      success.js do
        flash[:notice] = nil
        if current_user.disabled?
          flash[:error] = _("Your account has been disabled, please contact support.")
          flash.delete(:notice)
          current_user_session.destroy
        end
        render(:update) do |page|
          if params[:redirect_on_login]
            page.redirect_to(home_path)
          else
            page << "jQuery('.top-user-menu').html(#{render(:partial => "layouts/user_menu").to_json})"
            page << "jQuery('.not-logged-in-event-details').remove()"
          end
        end
      end
    end
  end

  def destroy
    destroy! do |wants|
      wants.html {redirect_to "/"}
    end
  end

  private
  def resource
    @object ||= current_user_session
  end

end
