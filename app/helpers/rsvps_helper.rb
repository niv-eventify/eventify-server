module RsvpsHelper
  def title_position_css(event, position_fix_ratio = 1.6)
    design = event.design
    text_align = event.title_text_align.blank? ? design.text_align : event.title_text_align
    color = event.title_color.blank? ? "rgb(#{design.title_color})" : event.title_color
    font = event.font_title.blank? ? design.font_title : event.font_title
    width_part = design.title_width.blank? ? "" : "width:#{(design.title_width/1.6).to_int}px"
    height_part = design.title_height.blank? ? "" : "height:#{(design.title_height/1.6).to_int}px"
    top_part = design.title_top_y.blank? ? "" : "top:#{(design.title_top_y/position_fix_ratio).to_int}px"
    left_part = design.title_top_x.blank? ? "" : "left:#{(design.title_top_x/position_fix_ratio).to_int}px"
    "#{left_part}; #{top_part}; #{width_part}; #{height_part}; color:#{color}; text-align: #{text_align}; font-size: #{event.title_font_size}px; font-family: #{font}"
  end
  
  def message_position_css(event, position_fix_ratio = 1.6)
    design = event.design
    top_y = design.text_top_y
    text_align = event.msg_text_align.blank? ? design.text_align : event.msg_text_align
    color = event.msg_color.blank? ? "rgb(#{design.message_color})" : event.msg_color
    font = event.font_body.blank? ? design.font_body : event.font_body
    width = (design.text_width/1.6).to_int
    height = (design.text_height/1.6).to_int
    left = (design.text_top_x/position_fix_ratio).to_int
    top = (design.text_top_y/position_fix_ratio).to_int
    "left:#{left}px; top:#{top}px; width:#{width}px; height:#{height}px; color:#{color}; text-align: #{text_align}; font-size: #{event.msg_font_size}px; font-family: #{font}"
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
