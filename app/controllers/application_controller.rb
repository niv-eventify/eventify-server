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
  before_filter :checkie6

protected
  include ERB::Util # to use h() in flashes

  def all_enabled_categories
    @all_enabled_categories ||= Category.enabled.has_designs.all.sort_by(&:name)
  end
  helper_method :all_enabled_categories

  before_filter :setup_localization
  def setup_localization(opts = nil)
    opts ||= {:session_domain => true, :canonic_redirect => true}
    FastGettext.available_locales = AVAILABLE_LOCALES
    FastGettext.text_domain = 'app'
    super(opts)
  end

  alias :authenticate_translations_admin :require_admin

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

  def default_locale
    "he"
  end

  def detect_locale_from(source)
    case source
    when :params
      params[:locale]
    when :session
      logger.debug "Session: #{session.inspect}"
      session[:locale]
    when :cookie
      cookies[:locale]
    when :domain
      parse_host_and_port_for_locale[0]
    when :header, :default
      default_locale
    else
      raise "unknown source #{source}"
    end
  end

  def redirect_changes_disabled(event)
    if event.past?
      flash[:error] = _("This is a past event. You cannot change it.")
      redirect_to events_path(:past => true)
      true
    elsif event.canceled?
      flash[:error] = _("This is a cancelled event. You cannot change it.")
      redirect_to events_path(:cancelled => true)
      true
    end
  end

  def checkie6
    return false if request.user_agent.blank?

    a = Agent.new(request.user_agent)
    if :msie == a.engine && a.version.to_i < 7
      redirect_to page_path("ie6")
      return false
    end
  end

  def ssl_host_and_port
    host, port = request.host_with_port.split(':')
    parts = host.split(".")
    parts[0] = "www"
    {:host => parts.join("."), :port => port}
  end

  def event_by_user_or_host
    event_id = params[:event_id] || params[:id]
    host = Host.find_by_event_id_and_email(event_id, current_user.email)
    @event = (!host.nil? && host.event) || (current_user.is_super_admin && Event.find(event_id)) || current_user.events.find(event_id)
  end

  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
  end
end
