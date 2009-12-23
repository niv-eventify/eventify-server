module DesignsHelper
  def full_postcard(design)
    haml_tag(:div, :style => "width:902px;height:602px;background: transparent url(#{design.background.url});overflow:hidden;position:relative;border:1px solid #666") do
      haml_concat image_tag(design.card.url)
      haml_tag(:div, "Internal Text", :style => "position:absolute;top:#{design.text_top_y}px;left:#{design.text_top_x}px;width:#{design.text_width}px;height:#{design.text_height}px;border:2px solid red")
    end
  end

  def more_designs_link(category)
    link_to_function content_tag(:span, "MORE"), "alert('more designs from same category')", :class => "btn-brown"
  end

  def select_design_link(design)
    link_to_function content_tag(:span, "SELECT"), "alert('select design and create event')", :class => "blue-btn-sml"
  end
end
