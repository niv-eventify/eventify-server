module EventsHelper
  def invitation_preview(event)
    haml_tag(:div, :id => "invitation#{event.id}", :style => "display:none;") do
      haml_tag(:div, :class => "background_holder") do
        yield
      end
    end
  end

  def event_date_time_select_combo(f, attribute)
    hidden_date_fields(f, attribute)
    haml_tag(:li, :class => "#{attribute}_date_select") do
      haml_tag :label, _("Date") + (:starting_at.eql?(attribute) ? "*" : "")
      haml_tag :div, :class => "input-bg-alt" do
        haml_tag :input, :class => "input-text", :id => "#{attribute}_mock", :name => "#{attribute}_mock", :type => "text"
      end
      haml_concat f.inline_errors_for(attribute)
    end
    haml_tag(:li, :class => "#{attribute}_time_select") do
      haml_tag :label, _("Time") + (:starting_at.eql?(attribute) ? "*" : "")
      haml_concat f.time_select(attribute, {:time_separator => "", :ignore_date => true, :prompt => {:hour => "&nbsp;", :minute => "&nbsp;"}, :minute_step => 15}, :class => "short")
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

  def event_text_input(f, attribute, label, extra_opts = {}, def_value = nil)
    opts = {:input_html => {:class => "input-text", :maxlength => "255", :size => "255"}, :label => label,
      :surround_html => {:tag => :div, :html => {:class => "input-bg-alt"}},
      :required => nil
      }
    unless def_value.blank? then
      opts[:input_html][:def_value] = def_value
      opts[:input_html][:title] = def_value
    end
    if block_given?
      opts[:after_html] = capture_haml { yield }
    end
    haml_concat f.input(attribute, opts.merge(extra_opts))
  end

  def event_input_text(f, attribute, label, hint, def_value = nil)
    opts = {:label => label, :wrapper_html => {:class => "auto_width"}, :surround_html => {:tag => :div, :html => {:class => "textarea-bg"}},
      :required => nil, :hint => hint, :as => :text, :input_html => {} }
    unless def_value.blank? then
      opts[:input_html][:def_value] = def_value
      opts[:input_html][:title] = def_value
    end
    haml_concat f.input(attribute, opts)
  end

  def form_divider
    content_tag(:div, "&nbsp;", :class => "divider")
  end

  def set_windows(event, ratio)
    for window in event.design.windows
      haml_tag(:div, :class => "window", :window_id => window.id, :style => "#{window_css(window, ratio)};") do
        if event.id.to_i == 0
          for cropped_pic in window.cropped_pictures.find_all_by_id(session[:cropped_picture_ids] || []) do
            haml_tag(:img, :src => cropped_pic.pic.url(:original))
            haml_concat link_to_remote "Delete", :update => "delete_updates_me", :url => cropped_picture_path(cropped_pic), :method => :delete
          end
        else
          for cropped_pic in window.cropped_pictures.find_all_by_event_id(event.id.to_i) do
            haml_tag(:img, :src => cropped_pic.pic.url(:original))
            haml_concat link_to_remote "Delete", :update => "delete_updates_me", :url => cropped_picture_path(cropped_pic), :method => :delete
          end
        end
      end
    end
  end

  def event_sent_status(event)
    4 == event.stage_passed ? _("(sent)") : link_to(_("(not sent)"), edit_invitation_path(event), :class => "not-sent")
  end

  def months_arr
    javascript_tag("stage2.months_arr = #{_("en.date.abbr_month_names").map(&:to_s).to_json};")
  end

  def categories_for_select
    other = s_('category|Other')
    all_enabled_categories.map { |c| [c.root? ? other : c.name, c.id] }
  end

  def categories_for_admin_designs
    Category.enabled.all.sort_by(&:name).map{|c| [c.name, c.id]}
  end

  def add_fonts()
    if current_locale == "he"
      options_for_select(["כוס חלב","בלנדר","אינפרא","סימן קריאה","קריסטייל","ספידמן","קרטיב קרח","מכבי בלוק","פלסטיק","רענן","Arial","David","Times New Roman","Tahoma","Arial Black", "Miriam"])
    elsif current_locale == "en"
      options_for_select(["Arial","David","Times New Roman","Tahoma","Arial Black", "Miriam"])
    end
  end

  def event_hosts(event)
    other_hosts = event.hosts.map{|h| ", " + h.name }
    "#{event.user.name}#{other_hosts.to_s}"
  end
end
