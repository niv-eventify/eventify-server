class ApplicationController < ActionController::Base
  include Astrails::Auth::Controller
  def home_path
    # this is where users is redirected after login
    events_path
  end
  helper_method :home_path

  helper :all
  protect_from_forgery
  filter_parameter_logging "password" unless Rails.env.development?

protected
  include ERB::Util # to use h() in flashes

  def all_enabled_categories
    @all_enabled_categories ||= Category.enabled.all
  end
  helper_method :all_enabled_categories

  before_filter :setup_localization
  def setup_localization
    FastGettext.available_locales = AVAILABLE_LOCALES
    FastGettext.text_domain = 'app'
    super(:session_domain => true, :canonic_redirect => true)
  end

  alias :authenticate_translations_admin :require_admin

  def remove_flash
    flash[:notice] = nil
  end

  def adjust_format_for_iphone
    request.format = :iphone if iphone_request?
  end

  def iphone_request?
    if request.accept =~ /(html)/
      logger.debug(request.user_agent)
      logger.debug(request.user_agent =~ /(iPhone|iPod|SonyEricssonW705)/)
      return request.user_agent =~ /(iPhone|iPod|SonyEricssonW705)/
    end

    false
  end
  helper_method :iphone_request?

  def clear_flash
    flash[:notice] = nil
  end
end
