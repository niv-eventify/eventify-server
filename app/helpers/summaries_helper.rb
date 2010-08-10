module SummariesHelper
  def info_container(extra_class = nil)
    haml_tag(:div, :class => "info-container #{extra_class}") do
      haml_tag(:div, :class => "holder") do
        haml_tag(:div, :class => "frame") do
          yield
        end
      end
    end
  end

  def html_tabs_options(tab_index, active_tab_index)
    {:class => (tab_index == active_tab_index ? "active" : "")}
  end

  def link_to_guests_filter(title, filter, count, tab_index)
    txt = content_tag(:strong, title + content_tag(:span, "(#{count})"))
    haml_tag(:li, :class => "tab-#{tab_index}") do
      if 5 == tab_index
        query = params[:query] || params[:previous_query]
        haml_concat link_to_remote(txt, :url => other_guests_path(:query => query), :method => :get, :html => html_tabs_options(tab_index, active_tab_index))
      else
        haml_concat link_to_remote(txt, :url => other_guests_path(:filter => filter), :method => :get, :html => html_tabs_options(tab_index, active_tab_index))
      end
    end
  end

  def other_guests_path(opts)
    if !params[:query].blank?
      opts[:previous_query_entries_count] = collection.total_entries
      opts[:previous_query] = params[:query]
    elsif !params[:previous_query].blank?
      opts[:previous_query_entries_count] = params[:previous_query_entries_count]
      opts[:previous_query] = params[:previous_query]
    end

    if params[:rsvp_id]
      rsvp_other_guests_path(params[:rsvp_id], opts.merge(:columns_count => @columns_count))
    else
      event_other_guests_path(params[:event_id], opts.merge(:columns_count => @columns_count))
    end
  end

  def active_tab_index
    @active_tab_index ||= case params[:filter]
    when "not_responded"
      4
    when "no"
      3
    when "maybe"
      2
    else
      params[:query].blank? ? 1 : 5
    end
  end

  def event_status
    text = if @event.past?
      _("Passed")
    elsif @event.canceled?
      _("Canceled")
    end

    return nil if text.nil?

    haml_tag(:span, :class => "event-changes-disabled") do
      haml_concat("&nbsp;-&nbsp;")
      haml_concat(text)
    end
  end
end
