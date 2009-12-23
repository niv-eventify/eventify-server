class ApplicationController < ActionController::Base
  include Astrails::Auth::Controller
  def home_path
    # this is where users is redirected after login
    "/"
  end
  helper_method :home_path

  helper :all
  protect_from_forgery
  filter_parameter_logging "password" unless Rails.env.development?

protected
  def all_enabled_categories
    @all_enabled_categories ||= Category.enabled.all
  end
  helper_method :all_enabled_categories

  def set_locale
    # FastGettext.available_locales = ['de','en',...]
    # FastGettext.text_domain = 'app'
    # session[:locale] = I18n.locale = FastGettext.set_locale(params[:locale] || session[:locale] || request.env['HTTP_ACCEPT_LANGUAGE'] || 'en')
  end

end
