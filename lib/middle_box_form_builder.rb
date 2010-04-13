require "haml"

module MiddleBoxFormBuilder
  class Builder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper
    include Haml::Helpers

    %w/password_field text_field/.each do |name|
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{name}(method, options = {})
          clean_field do
            html = label(method, options.delete(:label)) + 
              content_tag(:div, super(method, options), :class => "input-bg-contact") +
              (has_errors?(method) ? @template.content_tag(:p, merge_errors(method), :class => "error-msg") : "")
              
            @template.content_tag(:div, html, :class => "settings-form-row")
          end
        end
      RUBY
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