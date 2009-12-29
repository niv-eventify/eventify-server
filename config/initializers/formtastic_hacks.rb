module Formtastic #:nodoc:

  class SemanticFormBuilder < ActionView::Helpers::FormBuilder

    def input_simple(type, method, options)
      html_options = options.delete(:input_html) || {}
      html_options = default_string_options(method, type).merge(html_options) if STRING_MAPPINGS.include?(type)
      after_html = options.delete(:after_html)

      returning("") do |res|
        res << self.label(method, options_for_label(options))
        html = self.send(INPUT_MAPPINGS[type], method, html_options)
        if surround = options.delete(:surround_html)
          res << template.content_tag(surround[:tag], html, (surround[:html] || {}))
        else
          res << html
        end

        res << after_html if after_html
      end
    end

  end
end