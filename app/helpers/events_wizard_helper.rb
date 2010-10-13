module EventsWizardHelper

  STAGE_NAMES = [N_("Design"), N_("Event details"), N_("Invite guests"), N_("Reminders|tab"), N_("Summary")]

  def wizard_next_link(opts)
    if opts[:func]
      link_to_function(_("Next"), opts[:func], :class => "next-btn")
    else
      link_to(_("Next"), opts[:href], :class => "next-btn")
    end
  end

  def wizard_prev_link(opts)
    if opts[:func]
      link_to_function(_("Previous"), opts[:func], :class => "previous-btn")
    else
      link_to(_("Previous"), opts[:href], :class => "previous-btn")
    end
  end

  def events_content_section(stage_number, event, prev_next_opts = {}, opts = {})
    next_link_opts = prev_next_opts[:next]
    prev_link_opts = prev_next_opts[:prev]

    haml_tag(:div, :class => "h-container") do
      haml_tag(:div, "&nbsp;", :class => "t")
      haml_tag(:div, :class => "c") do
        haml_tag(:div, :class => "h-container-content") do
          stages_tabs(stage_number, event)
          haml_tag(:div, :class => "content-section #{opts[:content_section_class]}") do
            yield
          end
        end
      end

      if 5 == stage_number
        haml_tag(:div, :class => "b")
      else        
        haml_tag(:div, :class => "b") do
          haml_tag(:div, :class => "btns #{extra_buttons_class(stage_number)}") do
            if prev_lnk = prev_link_opts || (stage_link(stage_number - 1, event) && {:href => stage_link(stage_number - 1, event)})
              haml_concat wizard_prev_link(prev_lnk)
            end
          
            if 2 == stage_number
              haml_concat link_to(_("Preview"), '#invitation', :class => "preview-btn preview nyroModal")
              haml_concat link_to_function(_("Save"), 'jQuery("#where_to").val("edit");on_next_clicked();', :class => "preview-btn")
            end
            if 4 == stage_number #last
              haml_concat link_to(_("Preview"), '#invitation', :class => "preview-btn preview nyroModal")
              haml_concat link_to(_("Finish"), edit_invitation_path(event), :class => "finish-btn")
            else
              if next_link = next_link_opts || (stage_link(stage_number + 1, event) && {:href => stage_link(stage_number + 1, event)})
                haml_concat wizard_next_link(next_link)
              end
            end
          end
        end
      end
    end
  end

  def extra_buttons_class(stage_number)
    case stage_number
    when 4
      "three-btns"
    when 2
      "tree-buttons-preview"
    else
      ""
    end
  end

  def stage_tab_class(stage_number, current_stage_number)
    if "true" == params[:wizard]
      if stage_number < current_stage_number
        "done"
      elsif stage_number == current_stage_number
        "active"
      end
    else
      stage_number == current_stage_number ? "active" : "done"
    end
  end

  def stage_link(stage_number, event)
    case stage_number
    when 1
      unless event.new_record?
        event_design_path(event, :wizard => params[:wizard])
      else
        event_design_path(0, :wizard => params[:wizard], :design_id => params[:design_id], :category_id => params[:category_id])
      end
    when 2
      unless event.new_record?
        edit_event_path(event, :wizard => params[:wizard])
      else
        new_event_path(:design_id => params[:design_id], :category_id => params[:category_id], :wizard => params[:wizard])
      end
    when 3
      event_guests_path(event, :wizard => params[:wizard])
    when 4
      event_path(event, :wizard => params[:wizard])
    when 5
      summary_path(event, :wizard => params[:wizard])
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
          link = stage_link(i+1, event) if i <= event.stage_passed.to_i
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