module EventsHelper
  def invitation_preview(event)
    haml_tag(:div, :id => "invitation#{event.id}", :style => "display:none;") do
      haml_tag(:div, :class => "background_holder") do
        yield
      end
    end
  end

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

  def summary_kinds_for_select
    Event::SUMMARY_DEFAULTS.keys.map{|k| [s_(Event::SUMMARY_DEFAULTS[k]), k]}
  end

  def event_rsvp_summary_select(event)
    form_remote_for :event, event, :url => event_path(event), :method => :put do |f|
      haml_concat f.label :rsvp_summary_send_every, _("Send RSVPs summary email")
      haml_concat f.select(:rsvp_summary_send_every, summary_kinds_for_select, {}, :onchange => "jQuery(this).parents('form').get(0).onsubmit();")
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
    return _("(sent)") if event.invitations_to_send_counts[:total].zero? && event.last_invitation_sent_at
    link_to _("(not sent)"), edit_invitation_path(event), :class => "not-sent"
  end

  def months_arr
    javascript_tag("stage2.months_arr = ['" + _("en.date.abbr_month_names").join("','") + "'];")
  end
protected
  def js_add_classes(attribute)
    <<-JAVASCRIPT
      jQuery(".#{attribute}_time_select select.short:first").addClass("marg");
    JAVASCRIPT
  end
end
