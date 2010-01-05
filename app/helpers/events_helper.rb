module EventsHelper
  def event_date_time_select(f, attribute, js_opts = {})
    haml_tag(:li, :class => "#{attribute}_date_select") do
      haml_tag :label, _("Date")
      haml_concat f.date_select(attribute, :order => [:month, :day, :year], :start_year => Time.now.utc.year, :date_separator => "", :use_short_month => true)
      haml_concat f.inline_errors_for(attribute)
    end
    haml_tag(:im, :class => "#{attribute}_time_select") do
      haml_tag :label, _("Time")
      haml_concat f.time_select(attribute, {:time_separator => "", :ignore_date => true}, :class => "short")
    end
    haml_concat javascript_tag(js_for_date_select(attribute, js_opts))
    yield if block_given?
  end

  def js_for_date_select(attribute, opts = {})
    js = js_add_classes(attribute)
    "(function(){#{js}})();"
  end

  def show_ending_at_block?(f)
    f.object && !f.object.ending_at.blank?
  end

  def toggle_ending_at_block
    "jQuery('.ending_at_block, .show_ending_at, .hide_ending_at').toggle()"
  end

  def event_text_input(f, attribute, label)
    opts = {:input_html => {:class => "input-text", :maxlength => "48", :size => "40"}, :label => label,
      :surround_html => {:tag => :div, :html => {:class => "input-bg-alt"}},
      :required => nil
      }

    if block_given?
      opts[:after_html] = capture_haml { yield }
    end
    haml_concat f.input(attribute, opts)
  end

  def event_input_text(f, attribute, label, hint)
    opts = {:label => label, :surround_html => {:tag => :div, :html => {:class => "textarea-bg"}},
      :required => nil, :hint => hint, :as => :text }
    haml_concat f.input(attribute, opts)
  end

  def form_divider
    content_tag(:div, "&nbsp;", :class => "divider")
  end

  def show_hide_ending_block_js(f)
    haml_concat javascript_tag("$('select').customSelect();")
    remove_ending_date = <<-JAVASCRIPT
      (function(){
        var ending_at_html = jQuery(".ending_at_block").html();
        jQuery(".hide_ending_at").click(function(){
          jQuery(".ending_at_block").html("");
        });
        jQuery(".show_ending_at").click(function(){
          jQuery(".ending_at_block").html(ending_at_html);
        });
      })();
    JAVASCRIPT
    haml_concat javascript_tag(remove_ending_date)
    unless show_ending_at_block?(f)
      haml_concat javascript_tag(toggle_ending_at_block + ";jQuery('.ending_at_block').html('')")
    end
  end
  
  def stage2_design_css(design)
    design.stage2_preview_dimentions.keys.map {|k| "#{k}:#{design.stage2_preview_dimentions[k]}"}.join(";")
  end

  protected
  def js_add_classes(attribute)
    <<-JAVASCRIPT
      var ds = jQuery(".#{attribute}_date_select select");
      jQuery(ds[0]).addClass("middle");
      jQuery(ds[1]).addClass("short");
      jQuery(ds[2]).addClass("middle-alt");
      jQuery(".#{attribute}_time_select select.short:first").addClass("marg");
    JAVASCRIPT
  end
end
