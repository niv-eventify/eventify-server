module RsvpsHelper
  def title_position_css
    design = resource.event.design
    "left:#{design.title_top_x}px; top:#{design.title_top_y}px; width:#{design.title_width}px; height:#{design.title_height}px; color:rgb(#{design.title_color}); text-align: #{design.text_align};"
  end
  
  def message_position_css
    design = resource.event.design
    top_y = design.is_seperated_title? ? design.text_top_y - design.title_height : design.text_top_y
    "left:#{design.text_top_x}px; top:#{top_y}px; width:#{design.text_width}px; height:#{design.text_height}px; color:rgb(#{design.message_color}); text-align: #{design.text_align};"
  end

  def background_image_css
    "background-image:url('#{resource.event.design.background.url}');"
  end
  
  def postcard_image_css
    "background-image:url('#{resource.event.design.card.url}');"
  end
  
  def background_color_css
    "background-color:rgb(#{resource.event.design.background_color});"
  end
end
