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
          redirect_to home_path
        end
      end
      failure.js do
        render(:update) do |page|
          page << <<-JAVASCRIPT
            jQuery('#login_form.bg-m').html(#{render(:partial => "user_session/new").to_json});
            jQuery('#login_form.bg-m input:checkbox').customCheckbox();
          JAVASCRIPT
        end
      end
      success.js do
        if current_user.disabled?
          flash[:error] = _("Your account has been disabled, please contact support.")
          flash.delete(:notice)
          current_user_session.destroy
        end
        render(:update) {|page| page.redirect_to(home_path)}
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
