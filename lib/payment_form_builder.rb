require "haml"

module PaymentFormBuilder
  class Builder < ActionView::Helpers::FormBuilder

    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper
    include Haml::Helpers

    def text_field(method, options = {})
      container_class = options.delete(:container_class) || "text"
      label_class = options.delete(:label_class) || "label5"
      label = options.delete(:label)
      extra_html = options.delete(:extra_html) || ""

      clean_field do
        errors = ""

        if has_errors?(method)
          container_class << " error"
          errors = @template.content_tag(:p, merge_errors(method), :class => "error-msg")
        end

        content_tag(:div,
          label(method, label, :class => label_class) +
          content_tag(:div, super(method, options), :class => container_class) +
          extra_html +
          errors,
          :class => "row")
      end
    end
    include CommonForm
  end
end