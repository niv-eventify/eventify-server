module GuestsHelper
  def new_guest_form
    form_remote_for(:guest, @guest ||= Guest.new, :builder => TableFormBuilder::Builder, 
      :url => event_guests_path(@event), :html => {:id => "new_guest"},
      :before => "jQuery('#adding_guest').attr('disabled', 'true')") do |f|

      yield(f)

    end
  end

  def link_to_remove_guest(event, guest)
    return nil if guest.invited?
    link_to_remote "del", :url => event_guest_path(event, guest), :method => :delete, 
      :confirm => _("Are you sure?"), :html => {:class => "bin"}, :before => "$('##{dom_id(guest)}').hide()"
  end

  def guest_remote_checkbox(attribute, event, guest)
    form_remote_for :guest, guest, :url => event_guest_path(event, guest), :method => :put do |f|
      haml_concat f.check_box(attribute, :class => "input-check", :onchange => "jQuery(this).parents('form').get(0).onsubmit()", :id => "#{dom_id(guest)})_#{attribute}")
    end
  end

  def rsvp_kinds_for_select
    returning([]) do |res|
      Guest::RSVP_TEXT.each_with_index do |name, v|
        res << [s_(name), v]
      end
    end
  end

  def guest_remote_rsvp(event, guest)
    form_remote_for :guest, guest, :builder => NoLabelFormBuilder::Builder, :url => event_guest_path(event, guest), :method => :put do |f|
      haml_concat f.input(:rsvp, :as => :select, :collection => rsvp_kinds_for_select,
        :input_html => {:id => "#{dom_id(guest)}_rsvp", :class => "rspv_select",
        :onchange => "jQuery.fn.rsvp_update_color(this);jQuery(this).parents('form').get(0).onsubmit();"}, :wrapper_html => {:class => "guest_select_rsvp", :id => ""})
    end    
  end

  def if_not_blank_editable_property(attribute, non_blank_attribute, event, guest)
    if guest.send(non_blank_attribute).blank?
      haml_concat "&nbsp;"
    else
      guest_remote_checkbox(attribute, event, guest)
    end
  end

  def change_observers
    javascript_tag <<-JAVASCRIPT
      jQuery("#guest_email").keyup(function(){
        if ("" != jQuery(this).val()) {
          jQuery("#guest_send_email").attr("checked", "checked").get(0)._replaced.removeClass().addClass("checkboxAreaChecked");
        }
        else {
          jQuery("#guest_send_email").removeAttr("checked").get(0)._replaced.removeClass().addClass("checkboxArea");
        }
      });
      jQuery("#guest_mobile_phone").keyup(function(){
        if ("" != jQuery(this).val()) {
          jQuery("#guest_send_sms").attr("checked", "checked").get(0)._replaced.removeClass().addClass("checkboxAreaChecked");
        }
        else {
          jQuery("#guest_send_sms").removeAttr("checked").get(0)._replaced.removeClass().addClass("checkboxArea");
        }
      });
    JAVASCRIPT
  end

  def guests_rsvp_javascript
    javascript_include_tag("jquery.select_skin") +
    javascript_tag(<<-JAVASCRIPT
      jQuery(document).ready(function() {
          jQuery.fn.rsvp_update_color = function(el) {
            var s = jQuery(el);
            var colors = ["#000", "#e82303", "#28b20a", "#c6770d"]
            var color_index = parseInt(s.val() || -1) + 1;
            s.prev().css({color: colors[color_index]});
          };
          jQuery(".rspv_select").select_skin();
          jQuery(".rspv_select").each(function(){
            jQuery.fn.rsvp_update_color(this);
          });
      });
    JAVASCRIPT
    )
  end
end
