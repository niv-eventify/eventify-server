module LoginFormBuilder
  class Builder < ActionView::Helpers::FormBuilder

    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper
    include Haml::Helpers

    %w/password_field text_field/.each do |name|
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{name}(method, options = {})
          clean_field do
            errors_html = has_errors?(method) ? @template.content_tag(:p, merge_errors(method), :class => "error-msg") : ""
            html = content_tag(:div, content_tag(:span, super(method, options) + errors_html), :class => "txt")
            @template.content_tag(:div, options.delete(:label), :class => "form-row") + @template.content_tag(:div, html, :class => "form-row")
          end
        end
      RUBY
    end

    def label(*args)
      ""
    end

    include CommonForm
  end
end