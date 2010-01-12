module EventsHelper

  def event_date_time_select_mock(attribute)
    haml_tag(:li) do
      haml_tag :label, _("Date")
      haml_tag :div, :class => "input-bg-alt" do
        haml_tag :input, :class => "input-text", :id => "#{attribute}_mock", :name => "#{attribute}_mock", :type => "text"
      end
      yield
    end
  end

  def show_ending_at_block?(f)
    f.object && !f.object.ending_at.blank?
  end

  def toggle_ending_at_block
    "jQuery('.ending_at_block, .show_ending_at, .hide_ending_at').toggle()"
  end

  def event_text_input(f, attribute, label, extra_opts = {})
    opts = {:input_html => {:class => "input-text", :maxlength => "48", :size => "40"}, :label => label,
      :surround_html => {:tag => :div, :html => {:class => "input-bg-alt"}},
      :required => nil
      }

    if block_given?
      opts[:after_html] = capture_haml { yield }
    end
    haml_concat f.input(attribute, opts.merge(extra_opts))
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
end
