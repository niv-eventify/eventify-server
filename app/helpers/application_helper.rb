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
    caption = ""

    haml_tag(:div, :class => "nav-bar") do
      haml_tag(:ul) do
        [[_("Future events"), [nil, nil]], [_("Past events"), [true, nil]], [_("Cancelled events"), [nil, true]]].each do |e|
          if active = (past_events? && e.last.first) || (cancelled_events? && e.last.last) || (e.last.last.nil? && e.last.first.nil? && !cancelled_events? && !past_events?)
            caption = e.first
          end

          haml_tag(:li, :class => (active ? "active" : "")) do
            haml_concat link_to(e.first, url_for(params.merge(:past => e.last.first, :cancelled => e.last.last)))
          end          
        end
      end
    end
    haml_tag(:div, :class => "events-holder") do
      haml_tag(:h3, caption)
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
      :method => :get, :html => {:title => object.send(attribute).to_s, :class => "link_to_edit #{extra_class}"})
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
    haml_concat link_to(h(@next_event.name).utf_snippet(16), summary_path(@next_event), :title => h(@next_event.name))
  end

  def show_errors_for(page, errors, selector_prefix)
    return if errors.blank?
    errors = [errors] unless errors.is_a?(Array)
    page << "jQuery('#{selector_prefix}').addClass('error');"
    page << "jQuery('#{selector_prefix} div.input-bg-uni').after(#{content_tag(:p, errors.join(", "), :class => "error-msg").to_json});"
  end

  def inline_helper(helper_name, *args)
    render(:inline => Haml::Engine.new("- send(helper_name, *args)").render(self, :helper_name => helper_name, :args => args))
  end

  def resource_edit_form(page, resource, attribute, hidden_true_attribute = nil)
    html = inline_helper(:resource_remote_form, resource, attribute, true, hidden_true_attribute)

    page << <<-JAVASCRIPT
      var h = jQuery('.inline_#{dom_id(resource)}_#{attribute}').parents('div.cell-bg').html(#{html.to_json});
      var allow_submit = true;
      var focused = false;
      h.find('.input-text:first').blur(function(e){
        focused = false;
        var form = jQuery(this).parents('form').get(0);
        setTimeout(function(){
          if (!focused && allow_submit) {
            form.onsubmit();
          }
        },500);
      }).focus(function(){
        focused = true;
      }).keyup(function(e){
        if (27 == e.which) {
          jQuery.ajax({url: #{send("event_#{resource.class.name.downcase}_path", resource.event_id, resource).to_json}, type:'get', dataType:'script'});
          e.stopPropagation();
          allow_submit = false;
          return false;
        }
      });
    JAVASCRIPT

    if "email" == attribute
      page << <<-JAVASCRIPT
        jQuery(".inline_guest_#{resource.id}_email input[name=guest[email]]").autocomplete({source:#{current_user.contacts.collect(&:email).to_json}});
      JAVASCRIPT
    end
  end

  def resource_remote_form(resource, attribute, short_css_class = true, hidden_true_attribute = nil)
    klass = ""
    klass << " short" if short_css_class && !resource.send(attribute).is_a?(String)
    fields_opts = {:input_css_class => klass, 
      :container_class => "inline_#{dom_id(resource)}_#{attribute}"}
    form_remote_for resource, :builder => ShortTableCellFormBuilder::Builder, :url => send("event_#{resource.class.name.downcase}_path", resource.event_id, resource), :method => :put do |f|
      haml_concat f.text_field(attribute, fields_opts.merge(:autocomplete => :off))
      haml_concat hidden_field_tag("attribute", attribute)
      if hidden_true_attribute
        haml_concat f.hidden_field(hidden_true_attribute, :value => true)
        haml_concat hidden_field_tag :true_attribute, hidden_true_attribute
      end
    end
  end

  def each_import_source(skip = nil)
    ContactImporter::SOURCES.each do |key, value|
      next if skip == key
      yield(key, value)
    end
  end
end
