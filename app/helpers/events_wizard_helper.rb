module EventsWizardHelper

  STAGE_NAMES = [N_("Design your invite"), N_("Event details"), N_("Invite guests"), N_("Reminders &amp;<br/>RSVPs")]

  def events_content_section(stage_number, prev_link_opts, next_link_opts, event)
    haml_tag(:div, :class => "h-container") do
      haml_tag(:div, "&nbsp;", :class => "t")
      haml_tag(:div, :class => "c") do
        haml_tag(:div, :class => "h-container-content") do
          stages_tabs(stage_number, event)
          haml_tag(:div, :class => "content-section") do
            yield
          end
        end
      end
      haml_tag(:div, :class => "b") do
        haml_tag(:div, :class => "btns") do
          haml_concat send((prev_link_opts[:func] || :link_to_function), _("Previous"), prev_link_opts[:href], :class => "previous-btn")
          haml_concat send((next_link_opts[:func] || :link_to_function), _("Next"), next_link_opts[:href], :class => "next-btn")
        end
      end
    end
  end

  def stage_tab_class(stage_number, current_stage_number)
    if stage_number < current_stage_number
      "done"
    elsif stage_number == current_stage_number
      "active"
    else
      ""
    end
  end

  def stage_link(stage_number, event)
    case stage_number
    when 1
      # TODO link back to choose design
      nil
    when 2
      edit_event_path(event)
    when 3
      event_guests_path(event)
    else
      nil
    end
  end

  def stages_tabs(stage_number, event)
    stage_number -= 1 # 0 - based
    haml_tag :ul, :class => "tabset-nav" do
      STAGE_NAMES.each_with_index do |name, i|
        haml_tag :li, :class => stage_tab_class(i, stage_number) do
          text = content_tag(:span, content_tag(:strong, "#{i+1}") + content_tag(:em, s_(name)))
          link = stage_link(i+1, event) if i <= stage_number && event
          if link
            haml_concat link_to(text, link)
          else
            haml_concat link_to_function(text, link)
          end
        end
      end
    end
  end
end