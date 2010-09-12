module MiddleBoxHelper
  def setting_row(name, value, edit_function, opts = {})
    haml_tag :div, :class => "settings-row" do
      haml_concat link_to_function(_("Edit"), edit_function, :class => "edit-link") unless opts[:no_edit]
      haml_tag :div, :class => "settings-info" do
        haml_tag :strong, name
        haml_tag :span, h(value)
      end
    end
  end

  def middle_box_section(section_dom_id = nil, &block)
    haml_tag(:div, :class => "settings-container", :id => section_dom_id) do
      haml_tag(:div, :class => "holder") do
        haml_tag(:div, :class => "frame") do
          yield
        end
      end
    end
  end

  def middle_box_container(section_dom_id = nil, &block)
    haml_tag(:div, :class => "stage-container", :id => section_dom_id) do
      haml_tag(:div, :class => "holder") do
        haml_tag(:div, :class => "frame") do
          yield
        end
      end
    end
  end
end