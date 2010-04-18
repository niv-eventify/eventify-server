require "haml"

module MiddleBoxFormBuilder
  class Builder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper
    include Haml::Helpers

    %w/password_field text_field/.each do |name|
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{name}(method, options = {})
          outerdiv_class = options.delete(:outerdiv_class) || "settings-form-row"
          clean_field do
            html = label(method, options.delete(:label)) + 
              content_tag(:div, super(method, options), :class => "input-bg-contact") +
              (has_errors?(method) ? @template.content_tag(:p, merge_errors(method), :class => "error-msg") : "")
              
            @template.content_tag(:div, html, :class => outerdiv_class)
          end
        end
      RUBY
    end

    include CommonForm
  end
end