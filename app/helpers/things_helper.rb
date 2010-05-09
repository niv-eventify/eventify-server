module ThingsHelper
  def new_things_form
    form_remote_for(:thing, @thing ||= Thing.new, :builder => TableFormBuilder::Builder, 
      :url => event_things_path(@event), :html => {:id => "new_thing"},
      :before => "jQuery('#adding_thing').attr('disabled', 'true')") do |f|

      yield(f)

    end
  end

  def link_to_remove_thing(event, thing)
    link_to_remote "del", :url => event_thing_path(event, thing), :method => :delete, 
      :confirm => _("Are you sure?"), :html => {:class => "bin"}, :before => "$('##{dom_id(thing)}').hide()"
  end

  def taking_bar(taking)
    content_tag(:strong, h(taking.guest.name)) + "&nbsp;" + "x&nbsp;#{taking.amount}&nbsp;" + remove_taking_link(taking)
  end

  def remove_taking_link(taking)
    link_to_remote "x", :url => event_taking_path(taking.event_id, taking), :method => :delete, :html => {:class => "taking-remove"},
      :before => "jQuery('##{dom_id(taking)}').remove()"
  end

  def thing_edit_form(page, thing, attribute)
    page << <<-JAVASCRIPT
     jQuery('.inline_#{dom_id(thing)}_#{attribute}').parents('div.cell-bg').
      html(#{render(:partial => "inline", :locals => {:resource => thing, :attribute => attribute}).to_json}).
      find('.input-text:first').focus().keyup(function(e){
        if (27 == e.which) {
          jQuery.ajax({url: #{event_thing_path(thing.event_id, thing).to_json}, type:'get', dataType:'script'});
          return false;
        }
      });
    JAVASCRIPT
  end

  def thing_remote_form(thing, attribute)
    klass = ""
    klass << " short" if !thing.send(attribute).is_a?(String)
    fields_opts = {:input_css_class => klass, 
      :container_class => "inline_#{dom_id(thing)}_#{attribute}",
      :onblur => "jQuery(this).parents('form').get(0).onsubmit()"}
    form_remote_for :thing, thing, :builder => TableCellFormBuilder::Builder, :url => event_thing_path(thing.event_id, thing), :method => :put do |f|
      haml_concat f.text_field(attribute, fields_opts)
      haml_concat hidden_field_tag("attribute", attribute)
    end
  end

  def refresh_thing_row(page, thing)
    page << "jQuery('tr##{dom_id(thing)}').replaceWith(#{render(:partial => "thing", :object => thing).to_json});"
  end
end
