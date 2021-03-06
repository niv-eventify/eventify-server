module RsvpsHelper
  def title_position_css(event, position_fix_ratio = 1.6, max_fix_top_left = false)
    title_params = event.design.stage2_title_dimensions(current_locale).merge(event.stage2_title_dimensions(current_locale, position_fix_ratio))
    if max_fix_top_left
      title_params[:left] = "#{(title_params[:left].to_f * 1.6).to_i}px"
      title_params[:top] = "#{(title_params[:top].to_f * 1.6).to_i}px"
    end
    title_params.keys.map {|k| "#{k}:#{title_params[k]}"}.join(";")
  end

  def message_position_css(event, position_fix_ratio = 1.6, max_fix_top_left = false)
    msg_params = event.design.stage2_preview_dimensions(current_locale).merge(event.stage2_preview_dimensions(current_locale, position_fix_ratio))
    if max_fix_top_left
      msg_params[:left] = "#{(msg_params[:left].to_f * 1.6).to_i}px"
      msg_params[:top] = "#{(msg_params[:top].to_f * 1.6).to_i}px"
    end
    msg_params.keys.map {|k| "#{k}:#{msg_params[k]}"}.join(";")
  end

  def rsvp_status_class(rsvp)
    case rsvp
    when 0 # no
      "rsvp-no"
    when 1 # yes
      "rsvp-yes"
    when 2 # maybe
      "rsvp-maybe"
    end
  end

  def rsvp_item_class(rsvp)
    case rsvp
    when 0 # no
      "item-3"
    when 1 # yes
      "item-1"
    when 2 # maybe
      "item-2"
    end
  end

  def link_to_rsvp_update(text, value)
    link_to_remote text, :url => rsvp_path(resource.email_token, :guest => {:rsvp => value}), :method => :put, :before => "jQuery(this).parents('ul.link-box').hide();jQuery('#updating_rsvp_status').show()"
  end

  def takings_height(count)
    count > 5 ? "" : "short-container"
  end

  def link_to_banner
    if current_locale == "he"
      link_to image_tag("banner2.png", :alt => ""), url_for(lobby_path)
    elsif current_locale == "en"
      link_to image_tag("banner2.png", :alt => ""), url_for(lobby_path)
    end
  end

  def show_map_when_needed(next_to_location)
    if next_to_location && !resource.event.location_address.blank?
      return ""
    end
    if resource.event.map && !resource.event.map.url.blank?
      link_to content_tag(:span, _("show map")), resource.event.map.url, :target => "_blank"
    elsif !resource.event.map_link.blank?
      link_to content_tag(:span, _("show map")), resource.event.map_link, :target => "_blank"
    elsif !resource.event.location_address.blank?
      link_to content_tag(:span, _("find address")), "http://maps.google.com/?hl=he&t=m&q=#{resource.event.location_address}", :target => "_blank", :id => "find_address", :class => "query_address_link"
    end
  end
end

  def google_calendar_url(event_id)
    event = Event.find(event_id)
    event.with_time_zone do
      start_at = event.starting_at.utc.strftime('%4Y%2m%2dT%2H%2M%2SZ')
      ending_at_date_time = event.ending_at.blank? ? event.starting_at + 2.hours : event.ending_at
      end_at = ending_at_date_time.utc.strftime('%4Y%2m%2dT%2H%2M%2SZ')
      "http://www.google.com/calendar/event?action=TEMPLATE&text=#{event.name}&dates=#{start_at}/#{end_at}&details=#{event.invitation_title}&location=#{event.location_address}&trp=false&sprop=www.eventify.co.il&sprop=name:Eventify"
    end
  end
