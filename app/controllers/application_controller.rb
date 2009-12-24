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

  before_filter :set_localization_options
  def set_localization_options
    FastGettext.available_locales = AVAILABLE_LOCALES
    FastGettext.text_domain = 'app'
    super(:session_domain => true, :canonic_redirect => true)
  end

  alias :authenticate_translations_admin :require_admin

end
