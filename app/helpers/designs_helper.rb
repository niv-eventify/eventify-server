module DesignsHelper
  def full_postcard(design)
    haml_tag(:div, :style => "width:900px;height:600px;background: transparent url(#{design.background.url});overflow:hidden") do
      haml_concat image_tag(design.card.url)
    end
  end
end
