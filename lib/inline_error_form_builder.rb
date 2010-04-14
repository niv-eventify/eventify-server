module InlineErrorFormBuilder
  class Builder < ActionView::Helpers::FormBuilder
    def inline_errors_for(method)
      has_errors?(method) ?
        @template.content_tag(:p, merge_errors(method), :class => "error-msg") :
        @template.content_tag(:p, "&nbsp;", :class => "error-msg")
    end

    include CommonForm
  end
end