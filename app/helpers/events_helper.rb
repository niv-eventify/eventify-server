module EventsHelper

  def event_date_time_select_combo(f, attribute, js_opts = {})
    haml_tag(:li, :class => "#{attribute}_date_select") do
      haml_tag :label, _("Date")
      haml_tag :div, :class => "input-bg-alt" do
        hidden_date_fields(f, attribute)
        haml_tag :input, :class => "input-text", :id => "#{attribute}_mock", :name => "#{attribute}_mock", :type => "text"
      end
      haml_concat f.inline_errors_for(attribute)
    end
    haml_tag(:li, :class => "#{attribute}_time_select") do
      haml_tag :label, _("Time")
      haml_concat f.time_select(attribute, {:time_separator => "", :ignore_date => true, :prompt => {:hour => "&nbsp;", :minute => "&nbsp;"}, :minute_step => 15}, :class => "short")
      haml_concat javascript_tag(js_for_date_select(attribute, js_opts))
      yield
    end
  end

  def hidden_date_fields(f, attribute)
    [:year, :month, :day].each_with_index do |key, i|
      v = f.object.send(attribute).try(key)
      # change text_field_tag -> hidden_field_tag
      haml_concat hidden_field_tag("event[#{attribute}(#{1 + i}i)]", v, :id => "event_#{attribute}_#{key}")
    end
  end

  def js_for_date_select(attribute, opts = {})
    js = js_add_classes(attribute)
    "(function(){#{js}})();"
  end

  def toggle_ending_at_block
    "jQuery('.ending_at_block, .show_ending_at, .hide_ending_at').toggle();"
  end

  def event_text_input(f, attribute, label, extra_opts = {})
    opts = {:input_html => {:class => "input-text", :maxlength => "255", :size => "255"}, :label => label,
      :surround_html => {:tag => :div, :html => {:class => "input-bg-alt"}},
      :required => nil
      }

    if block_given?
      opts[:after_html] = capture_haml { yield }
    end
    haml_concat f.input(attribute, opts.merge(extra_opts))
  end

  def event_input_text(f, attribute, label, hint)
    opts = {:label => label, :surround_html => {:tag => :div, :html => {:class => "textarea-bg"}},
      :required => nil, :hint => hint, :as => :text }
    haml_concat f.input(attribute, opts)
  end

  def form_divider
    content_tag(:div, "&nbsp;", :class => "divider")
  end

  def stage2_message_css(design)
    design.stage2_preview_dimensions.keys.map {|k| "#{k}:#{design.stage2_preview_dimensions[k]}"}.join(";")
  end

  def stage2_title_css(design)
    design.stage2_title_dimensions.keys.map {|k| "#{k}:#{design.stage2_title_dimensions[k]}"}.join(";")
  end

  def event_sent_status(event)
    event.last_invitation_sent_at ? _("(sent)") : _("(not sent)")
  end

  def event_location(event)
    [event.location_name, event.location_address].compact_blanks.join(", ")
  end
  
  def months_arr
    javascript_tag("stage2.months_arr = ['" + _("en.date.month_names").join("','") + "'];")
  end
protected
  def js_add_classes(attribute)
    <<-JAVASCRIPT
      jQuery(".#{attribute}_time_select select.short:first").addClass("marg");
    JAVASCRIPT
  end
end
