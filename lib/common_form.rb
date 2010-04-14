module CommonForm
  protected
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

    def clean_field
      # reset default "fieldWithErrors" wrapper
      field_error_proc, ActionView::Base.field_error_proc = ActionView::Base.field_error_proc, Proc.new{ |html_tag, instance| html_tag}
      yield
    ensure
      # revert default "fieldWithErrors" wrapper
      ActionView::Base.field_error_proc = field_error_proc if field_error_proc
    end
end