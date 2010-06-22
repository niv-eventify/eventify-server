require "haml"

module ShortTableCellFormBuilder
  class Builder < ActionView::Helpers::FormBuilder

    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper
    include Haml::Helpers

    def text_field(method, options = {})
      container_class = options.delete(:container_class)
      clean_field do
        html = content_tag(:div, 
          content_tag(:div, super(method, options.reverse_merge(:class => "input-text #{options[:input_css_class]}"))),
          :class => "input-bg-uni")
        if has_errors?(method)
          container_class << " error"
          html << @template.content_tag(:p, merge_errors(method), :class => "error-msg")
        end
        @template.content_tag(:div, html, :class => container_class)
      end
    end
    include CommonForm
  end
end