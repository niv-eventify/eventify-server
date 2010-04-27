module SummariesHelper
  def info_container(extra_class = nil)
    haml_tag(:div, :class => "info-container #{extra_class}") do
      haml_tag(:div, :class => "holder") do
        haml_tag(:div, :class => "frame") do
          yield
        end
      end
    end
  end

  def link_to_tab(title, count, css_class)
    txt = content_tag(:strong, title) + content_tag(:span, "(#{count})")
    haml_tag(:li, :class => css_class) do
      haml_concat link_to_function(txt, "alert('todo')")
    end
  end  
end
