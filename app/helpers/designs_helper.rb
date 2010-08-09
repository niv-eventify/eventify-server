module DesignsHelper
  def title_holder(design, pos)
    haml_tag(:div, "Title goes here", :style => "position:#{pos};left:#{design.title_top_x}px; top:#{design.title_top_y}px; width:#{design.title_width}px; height:#{design.title_height}px; color:rgb(#{design.title_color}); text-align: #{design.text_align};border: 1px dashed green; font-size:30px")
  end

  def more_designs_link(category)
    link_to content_tag(:span, _("MORE")), category_designs_path(category), :class => "btn-brown"
  end

  def select_design_html(select_text)
    select_text || content_tag(:span, _("SELECT"))
  end

  def select_design_link(design, category, css_class = "blue-btn-sml", select_text = nil)
    if design.windows.blank?
      link_to select_design_html(select_text), new_event_path(:design_id => design, :category_id => category.id), :class => css_class
    else
      link_to select_design_html(select_text), event_design_path(0, :wizard => params[:wizard], :design_id => design, :category_id => category.id), :class => css_class
    end
  end

  def update_design_link(event, design, category, css_class = "blue-btn-sml", select_text = nil)
    return select_design_link(design, category, css_class, select_text) if !event || event.new_record?

    render(:partial => "designs/change_design_form", :locals => {:event => event, :design => design, :css_class => css_class, :select_text => select_text})
  end

  def design_zoom(event, design, category)
    event_id = event == nil ? 0 : event.id
    link_to '+', category_design_path(category, design, :event_id => event_id), :class => "plus nyroModal"
  end

  def design_zoomout(event, design, category)
    link_to_function "-", "jQuery(function(){if(typeof stage1 == 'undefined'){$.nyroModalRemove();}else{stage1.update_designs();}})", :class => "plus minus nyroModal"
  end

  def set_alert
  	still_cropping_msg = _("Saving in progress. Please wait")
  	delete_crop_alert = _("Are you sure you want to remove this picture?")
  	delete_uploaded_pic_alert = _("Are you sure you want to remove the picture you uploaded?")
    javascript_tag("stage1.still_cropping_msg = '#{still_cropping_msg.to_json}';\nstage1.delete_crop_alert = '#{delete_crop_alert.to_json}'\nstage1.delete_uploaded_pic_alert = '#{delete_uploaded_pic_alert.to_json}'")
  end

  def categories_list(design)
    design.categories.map{|c| "#{h c.name_en} / #{h c.name_he}"}.join("<br/>")
  end

  def link_to_add_category(form)
    link_to_function "Add a category" do |page|
      cat = render(:partial => "classification", :object => Classification.new, :locals => {:f => form})
      page << "jQuery('.categories-list').append(#{cat.to_json}); jQuery('.categories-list select').customSelect();"
    end
  end
end
