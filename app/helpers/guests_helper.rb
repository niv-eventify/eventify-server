module GuestsHelper
  def new_guest_form
    form_remote_for(:guest, @guest ||= Guest.new, :builder => TableFormBuilder::Builder,
      :url => event_guests_path(@event), :html => {:id => "new_guest"},
      :before => "jQuery('#adding_guest').attr('disabled', 'true')") do |f|

      yield(f)

    end
  end

  def link_to_remove_guest(guest)
    return nil if guest.invited?
    link_to_remote "del", :url => event_guest_path(guest.event_id, guest), :method => :delete, 
      :confirm => _("Are you sure?"), :html => {:class => "bin"}, :before => "$('tr##{dom_id(guest)}').remove();jQuery.fn.reload_search();"
  end

  def guest_remote_checkbox(attribute, guest)
    form_remote_for :guest, guest, :url => event_guest_path(guest.event_id, guest), :method => :put do |f|
      haml_concat f.check_box(attribute, :class => "input-check remote-checkbox guest_#{attribute}", :id => "#{dom_id(guest)}_#{attribute}")
    end
  end

  def rsvp_kinds_for_select
    returning([]) do |res|
      Guest::RSVP_TEXT.each_with_index do |name, v|
        res << [s_(name), v]
      end
    end
  end

  def guest_remote_form(guest, attribute)
    klass = ""
    klass << " short" if !guest.send(attribute).is_a?(String)
    fields_opts = {:input_css_class => klass, 
      :container_class => "inline_#{dom_id(guest)}_#{attribute}",
      :onblur => "jQuery(this).parents('form').get(0).onsubmit()"}
    form_remote_for :guest, guest, :builder => TableCellFormBuilder::Builder, :url => event_guest_path(guest.event_id, guest), :method => :put do |f|
      haml_concat f.text_field(attribute, fields_opts)
      haml_concat hidden_field_tag("attribute", attribute)
    end
  end

  def refresh_guest_row(page, guest)
    page << "jQuery('tr##{dom_id(guest)}').replaceWith(#{render(:partial => "guest", :object => guest).to_json});"
    page << "jQuery('tr##{dom_id(guest)} input:checkbox').customCheckbox(); jQuery.fn.reload_search();"
  end

  def render_edit_form(page, guest, attribute)
    page << <<-JAVASCRIPT
     jQuery('.inline_#{dom_id(guest)}_#{attribute}').parents('div.cell-bg').
      html(#{render(:partial => "inline", :locals => {:resource => guest, :attribute => attribute}).to_json}).
      find('.input-text:first').focus().keyup(function(e){
        if (27 == e.which) {
          jQuery.ajax({url: #{event_guest_path(guest.event_id, guest).to_json}, type:'get', dataType:'script'});
          return false;
        }
      });
    JAVASCRIPT
  end

  def guest_remote_rsvp(event, guest)
    form_remote_for :guest, guest, :builder => NoLabelFormBuilder::Builder, :url => event_guest_path(event, guest), :method => :put do |f|
      haml_tag :ul do
        haml_concat f.input(:rsvp, :as => :select, :collection => rsvp_kinds_for_select,
          :input_html => {:id => "#{dom_id(guest)}_rsvp", :class => "rspv_select", :guest_id => guest.id.to_s,
          :onchange => "jQuery.fn.rsvp_update_color(this);jQuery(this).parents('form').get(0).onsubmit();", :style => "display:none"}, 
          :wrapper_html => {:class => "guest_select_rsvp", :id => ""})
      end
    end    
  end

  def if_not_blank_editable_property(attribute, non_blank_attribute, guest)
    return haml_concat(guest.send(attribute).blank? ? "" : _("yes")) if guest.invited?

    if guest.send(non_blank_attribute).blank?
      haml_concat "&nbsp;"
    else
      guest_remote_checkbox(attribute, guest)
    end
  end

  def change_observers
    javascript_tag <<-JAVASCRIPT
      jQuery("#guest_email").keyup(function(){
        if ("" != jQuery(this).val()) {
          jQuery("#guest_send_email").attr("checked", "checked").redraw_customCheckbox();;
        }
        else {
          jQuery("#guest_send_email").removeAttr("checked").redraw_customCheckbox();
        }
      });
      jQuery("#guest_mobile_phone").keyup(function(){
        if ("" != jQuery(this).val()) {
          jQuery("#guest_send_sms").attr("checked", "checked").redraw_customCheckbox();
        }
        else {
          jQuery("#guest_send_sms").removeAttr("checked").redraw_customCheckbox();
        }
      });
    JAVASCRIPT
  end

  def show_errors_for(page, attribute, td_class)
    errors = @guest.errors.on(attribute)
    return if errors.blank?
    errors = [errors] unless errors.is_a?(Array)
    page << "jQuery('tr#new_guest_row td.#{td_class}').addClass('error');"
    page << "jQuery('tr#new_guest_row td.#{td_class} div.input-bg-uni').after(#{content_tag(:p, errors.join(", "), :class => "error-msg").to_json});"
  end
end
