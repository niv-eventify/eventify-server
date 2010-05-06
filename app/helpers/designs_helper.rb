module DesignsHelper
  def title_holder(design, pos)
    haml_tag(:div, "Title goes here", :style => "position:#{pos};left:#{design.title_top_x}px; top:#{design.title_top_y}px; width:#{design.title_width}px; height:#{design.title_height}px; color:rgb(#{design.title_color}); text-align: #{design.text_align};border: 1px dashed green; font-size:30px")
  end

  def more_designs_link(category)
    link_to content_tag(:span, _("MORE")), category_designs_path(category), :class => "btn-brown"
  end

  def select_design_link(design, css_class = "blue-btn-sml")
    link_to content_tag(:span, _("SELECT")), new_event_path(:design_id => design, :category_id => design.category_id), :class => css_class
  end

  def update_design_link(event, design, css_class = "blue-btn-sml")
    return select_design_link(design, css_class) if !event || event.new_record?

    render(:partial => "designs/change_design_form", :locals => {:event => event, :design => design, :css_class => css_class})
  end
end
