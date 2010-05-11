module RsvpsHelper
  def title_position_css(event)
    design = event.design
    text_align = event.title_text_align.blank? ? design.text_align : event.title_text_align
    "left:#{design.title_top_x}px; top:#{design.title_top_y}px; width:#{design.title_width}px; height:#{design.title_height}px; color:rgb(#{design.title_color}); text-align: #{text_align}; font-size: #{event.title_font_size}px"
  end
  
  def message_position_css(event)
    design = event.design
    top_y = design.text_top_y
    text_align = event.msg_text_align.blank? ? design.text_align : event.msg_text_align
    "left:#{design.text_top_x}px; top:#{top_y}px; width:#{design.text_width}px; height:#{design.text_height}px; color:rgb(#{design.message_color}); text-align: #{text_align}; font-size: #{event.msg_font_size}px"
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

  def link_to_rsvp_update(text, value)
    link_to_remote text, :url => rsvp_path(resource.email_token, :guest => {:rsvp => value}), :method => :put, :before => "jQuery(this).parents('ul.link-box').hide();jQuery('#updating_rsvp_status').show()"
  end
end
