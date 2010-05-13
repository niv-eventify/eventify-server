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

  def link_to_guests_filter(title, filter, count, tab_index)
    txt = content_tag(:strong, title + content_tag(:span, "(#{count})"))
    haml_tag(:li, :class => "tab-#{tab_index}") do
      if 5 == tab_index
        haml_concat link_to_function(txt, "", :class => (tab_index == active_tab_index ? "active" : ""))
      else
        haml_concat link_to_remote(txt, :url => other_guests_path(filter), :method => :get, :html => {:class => (tab_index == active_tab_index ? "active" : "")})
      end
    end
  end

  def other_guests_path(filter)
    if params[:rsvp_id]
      rsvp_other_guests_path(params[:rsvp_id], :columns_count => @columns_count, :filter => filter)
    else
      event_other_guests_path(params[:event_id], :columns_count => @columns_count, :filter => filter)
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
end
