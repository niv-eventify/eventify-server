require "haml"

module TableFormBuilder
  class Builder < ActionView::Helpers::FormBuilder

    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper
    include Haml::Helpers

    def text_field(method, options = {})
      td_class = options.delete(:td_class)
      clean_field do
        html = content_tag(:div, 
          content_tag(:div, super(method, options.reverse_merge(:class => "input-text #{options[:input_css_class]}"))),
          :class => "input-bg-uni")
        if has_errors?(method)
          td_class << " error"
          html << @template.content_tag(:p, merge_errors(method), :class => "error-msg")
        end
        @template.content_tag(:td, @template.content_tag(:div, html, :class => "cell-bg"), :class => td_class)
      end
    end

    def check_box(method, options = {})
      clean_field do
        td_class = options.delete(:td_class)
        html = super(method, options.merge(:class => "input-check"))
        @template.content_tag(:td, @template.content_tag(:div, html, :class => "cell-bg"), :class => td_class)
      end
    end

  protected
    def clean_field
      # reset default "fieldWithErrors" wrapper
      field_error_proc, ActionView::Base.field_error_proc = ActionView::Base.field_error_proc, Proc.new{ |html_tag, instance| html_tag}
      yield
    ensure
      # revert default "fieldWithErrors" wrapper
      ActionView::Base.field_error_proc = field_error_proc if field_error_proc
    end

    def merge_errors(method)
      errors = has_errors?(method)
      errors = [errors] unless errors.is_a?(Array)
      errors.join(", ")
    end

    def has_errors?(method)
      return false unless @object.respond_to?(:errors)
      return @object.errors.on(method) if @object.errors.on(method)
      false
    end
  end
end