module InlineErrorFormBuilder
  class Builder < ActionView::Helpers::FormBuilder
    def inline_errors_for(method)
      return "" unless has_errors?(method)

      @template.content_tag(:p, merge_errors(method), :class => "error-msg")
    end

    include CommonForm
  end
end