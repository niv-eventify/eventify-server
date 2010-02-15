module DesignsHelper
  def full_postcard(design)
    haml_tag(:div, :style => "width:902px;height:602px;background: transparent url(#{design.background.url});overflow:hidden;position:relative;border:1px solid #666") do
      haml_concat image_tag(design.card.url)
      haml_tag(:div, "Internal Text", :style => "position:absolute;top:#{design.text_top_y}px;left:#{design.text_top_x}px;width:#{design.text_width}px;height:#{design.text_height}px;border:2px solid red")
    end
  end

  def more_designs_link(category)
    link_to content_tag(:span, _("MORE")), category_designs_path(category), :class => "btn-brown"
  end

  def select_design_link(category, design)
    link_to content_tag(:span, _("SELECT")), new_event_path(:design_id => design, :category_id => category), :class => "blue-btn-sml"
  end

  def select_design_link_lightbox(category, design)
    link_to content_tag(:span, _("SELECT")), new_event_path(:design_id => design, :category_id => category), :class => "blue-btn-mdl"
  end

end
