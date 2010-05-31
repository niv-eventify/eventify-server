module ApplicationHelper

  include MiddleBoxHelper

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
    "#{current_locale == "he" ? "hebrew" : ""} #{@extra_body_class}"
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
        # haml_tag :li, link_to(_("My Events"), events_path(:past => params[:past])), :class => (only_my_events ? "active" : "")
        # haml_tag :li, link_to_function(_("Friend’s events"), "alert('todo')"), :class => (only_my_events ? "" : "active")
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

  def info_table_column(column_id = nil)
    css_class = column_id ? "t-col-#{column_id}" : "last"
    haml_tag(:td, :class => css_class) do
      haml_tag(:div, :class => "cell-bg") do
        yield
      end
    end
  end

  def link_to_inline_edit(object, attribute, extra_class = "")
    haml_tag(:div, :class => "inline_#{dom_id(object)}_#{attribute}", :style => "display:none")
    haml_concat link_to_remote(h(object.send(attribute).blank? ? _("edit") : object.send(attribute)), 
      :url => send("edit_event_#{object.class.name.downcase}_path", object.event_id, object, :attribute => attribute),
      :method => :get, :html => {:class => "link_to_edit #{extra_class}"})
  end

  def login_register_button(text)
    link_to_function(content_tag(:span, text) + "<em></em>", :class => "opener")
  end

  def popup_title(text)
    haml_tag(:div, :class => "popup-heading popup-heading-alt") do
      haml_tag(:strong, text)
    end
  end

  def link_to_next_event
    @next_event ||= current_user.events.upcoming.by_starting_at.first
    return haml_concat("&nbsp;") unless @next_event
    haml_concat _("Next event:")
    haml_concat link_to(h(@next_event.name).utf_snippet(12), summary_path(@next_event))
  end

  def show_errors_for(page, errors, selector_prefix)
    return if errors.blank?
    errors = [errors] unless errors.is_a?(Array)
    page << "jQuery('#{selector_prefix}').addClass('error');"
    page << "jQuery('#{selector_prefix} div.input-bg-uni').after(#{content_tag(:p, errors.join(", "), :class => "error-msg").to_json});"
  end

  def resource_edit_form(page, resource, attribute)
    page << <<-JAVASCRIPT
     jQuery('.inline_#{dom_id(resource)}_#{attribute}').parents('div.cell-bg').
      html(#{render(:partial => "inline", :locals => {:resource => resource, :attribute => attribute}).to_json}).
      find('.input-text:first').focus().keyup(function(e){
        if (27 == e.which) {
          jQuery.ajax({url: #{send("event_#{resource.class.name.downcase}_path", resource.event_id, resource).to_json}, type:'get', dataType:'script'});
          return false;
        }
      });
    JAVASCRIPT
  end

  def resource_remote_form(resource, attribute, short_css_class = true)
    klass = ""
    klass << " short" if short_css_class && !resource.send(attribute).is_a?(String)
    fields_opts = {:input_css_class => klass, 
      :container_class => "inline_#{dom_id(resource)}_#{attribute}",
      :onblur => "jQuery(this).parents('form').get(0).onsubmit()"}
    form_remote_for resource, :builder => TableCellFormBuilder::Builder, :url => send("event_#{resource.class.name.downcase}_path", resource.event_id, resource), :method => :put do |f|
      haml_concat f.text_field(attribute, fields_opts)
      haml_concat hidden_field_tag("attribute", attribute)
    end
  end
end
