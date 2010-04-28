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

  def link_to_guests_filter(title, filter, count, css_class)
    txt = content_tag(:strong, title + content_tag(:span, "(#{count})"))
    haml_tag(:li, :class => css_class) do
      haml_concat link_to_remote(txt, :url => other_guests_path(filter), :method => :get)
    end
  end

  def other_guests_path(filter)
    if params[:rsvp_id]
      rsvp_other_guests_path(params[:rsvp_id], :columns_count => @columns_count, :filter => filter)
    else
      event_other_guests_path(params[:event_id], :columns_count => @columns_count, :filter => filter)
    end
  end
end
