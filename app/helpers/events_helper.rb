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
      haml_tag :label, _("Date") + (:starting_at.eql?(attribute) ? "*" : "")
      haml_tag :div, :class => "input-bg-alt" do
        hidden_date_fields(f, attribute)
        haml_tag :input, :class => "input-text", :id => "#{attribute}_mock", :name => "#{attribute}_mock", :type => "text"
      end
      haml_concat f.inline_errors_for(attribute)
    end
    haml_tag(:li, :class => "#{attribute}_time_select") do
      haml_tag :label, _("Time") + (:starting_at.eql?(attribute) ? "*" : "")
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
    opts = {:label => label, :wrapper_html => {:class => "auto_width"}, :surround_html => {:tag => :div, :html => {:class => "textarea-bg"}},
      :required => nil, :hint => hint, :as => :text }
    haml_concat f.input(attribute, opts)
  end

  def form_divider
    content_tag(:div, "&nbsp;", :class => "divider")
  end

  def stage2_message_css(event)
    event.design.stage2_preview_dimensions.keys.map {|k| "#{k}:#{event.design.stage2_preview_dimensions[k]}"}.join(";")
  end

  def stage2_free_text_css(event)
    msg_params = {}
    msg_params["font-family"] = event.font unless event.font.blank?
    msg_params[:color] = event.msg_color unless event.msg_color.blank?
    msg_params["font-size"] = "#{(event.msg_font_size/1.6).to_int}px" unless event.msg_font_size.blank?
    msg_params["text-align"] = event.msg_text_align unless event.msg_text_align.blank?
    msg_params.keys.map {|k| "#{k}:#{msg_params[k]}"}.join(";")
  end

  def stage2_title_css(event)
    title_params = event.design.stage2_title_dimensions
    title_params["font-family"] = event.font if not event.font.blank?
    title_params[:color] = event.title_color if not event.title_color.blank?
    title_params["font-size"] = "#{(event.title_font_size/1.6).to_int}px" if not event.title_font_size.blank?
    title_params["text-align"] = event.title_text_align if not event.title_text_align.blank?
    title_params.keys.map {|k| "#{k}:#{title_params[k]}"}.join(";")
  end

  def set_windows(event)
    for window in event.design.windows
      haml_tag(:div, :class => "window", :window_id => window.id, :style => "#{window_css(window, 1.6)};") do
        if event.id.to_i == 0
          for cropped_pic in window.cropped_pictures.find_all_by_id(session[:cropped_picture_ids]) do
            haml_tag(:img, :src => cropped_pic.pic.url(:cropped))
          end
        else
          for cropped_pic in window.cropped_pictures.find_all_by_event_id(event.id.to_i) do
            haml_tag(:img, :src => cropped_pic.pic.url(:cropped))
          end
        end
      end
    end
  end

  def event_sent_status(event)
    4 == event.stage_passed ? _("(sent)") : link_to(_("(not sent)"), edit_invitation_path(event), :class => "not-sent")
  end

  def months_arr
    javascript_tag("stage2.months_arr = ['" + _("en.date.abbr_month_names").join("','") + "'];")
  end

  def add_fonts()
    if current_locale == "he"
      options_for_select(["כוס חלב","בלנדר","אינפרא","סימן קריאה","קריסטייל","ספידמן","קרטיב קרח","מכבי בלוק","פלסטיק","רענן","Arial","David","Times New Roman","Tahoma","Arial Black", "Miriam"])
    elsif current_locale == "en"
      options_for_select(["Arial","David","Times New Roman","Tahoma","Arial Black", "Miriam"])
    end
  end

protected
  def js_add_classes(attribute)
    <<-JAVASCRIPT
      jQuery(".#{attribute}_time_select select.short:first").addClass("marg");
    JAVASCRIPT
  end
end
