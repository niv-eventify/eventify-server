module ApplicationHelper

  USER_NAVIGATION = [
    {:title => N_("Events"), :id => :events, :url => "/events"},
    {:title => N_("Address Book"), :id => :contacts, :url => "/contacts"},
    {:title => N_("Settings"), :id => :settings, :url => "/profile"},
  ]

  def page_title(title=nil)
    if title.nil?
      @page_title ||= ""
    else
      @page_title = title
    end
  end

  def body_class
    "#{current_locale == "he" ? "hebrew" : ""}"
  end

  def tabs_navigation(current_tab)
    haml_tag(:ul, :class => "tabs") do
      USER_NAVIGATION.each do |t|
        opts = {}
        opts[:class] = "active" if current_tab == t[:id]
        haml_tag(:li, opts) do
          haml_concat link_to(s_(t[:title]), t[:url])
        end
      end
    end
  end

  def events_navigation(only_my_events)
    haml_tag(:div, :class => "nav-bar") do
      haml_tag(:ul) do
        haml_tag(:li, :class => (past_events? ? "" : "active")) do
          haml_concat link_to(_("Future events"), url_for(params.merge(:past => nil)))
        end
        haml_tag(:li, :class => (past_events? ? "active" : "")) do
          haml_concat link_to(_("Past events"), url_for(params.merge(:past => true)))
        end
      end
    end
    haml_tag(:div, :class => "events-holder") do
      haml_tag(:h3, past_events? ? _("Past events") : _("Future events"))
      haml_tag(:ul, :class => "choice") do
        haml_tag :li, link_to(_("My Events"), events_path(:past => params[:past])), :class => (only_my_events ? "active" : "")
        haml_tag :li, link_to_function(_("Friend’s events"), "alert('todo')"), :class => (only_my_events ? "" : "active")
      end
      yield
    end
  end

  def page_with_tabs(current_tab)
    haml_tag(:div, :class => "columns-holder") do
      haml_tag(:div, :class => "boxu") do
        haml_tag(:div, :class => "boxu-top") do
          haml_tag(:div, :class => "boxu-btm") do
            tabs_navigation(current_tab)
            yield
          end
        end
      end
      haml_concat render(:partial => "events/sidebar")
    end
  end
end
