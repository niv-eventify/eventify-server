jQuery(document).ready(function() {
		jQuery.fn.rsvp_update_color = function(el) {
      var s = jQuery(el);
      var colors = ["#000", "#e82303", "#28b20a", "#c6770d"]
      var color_index = parseInt(s.val() || -1) + 1;
      s.prev().css({color: colors[color_index]});
    };
    var guests_texts = {};
    jQuery.fn.reload_search = function() {
      guests_texts = {};
      jQuery("tr.guest").each(function(){
        var t = jQuery(this);
        var text = t.find("td.t-col-1 label[for='name-1'] a.link_to_edit").html() + " ";
        text += t.find("td.t-col-2 a.link_to_edit").html() + " ";
        text += t.find("td.t-col-3 div.cell-bg a.link_to_edit").html();
        guests_texts[jQuery(this).attr("id")] = text.replace(" edit", "");
      });
    }
    jQuery.fn.rsvp_filter_by = function(sel_index) {
      if (!sel_index) {
        jQuery("tr.guest").show();
      }
      else {
        jQuery("tr.guest").hide();
        jQuery(".rspv_select[selectedIndex=" + sel_index+ "]").each(function(){
          jQuery(this).parents("tr.guest").show();
        })
      }
    }
    jQuery(".rspv_select").show().select_skin();
    jQuery(".rspv_select").each(function(){
      jQuery.fn.rsvp_update_color(this);
    });
    jQuery("#filter_all").click(function(){
      jQuery.fn.rsvp_filter_by(null);
    });
    jQuery("#filter_yes").click(function(){
      jQuery.fn.rsvp_filter_by(1 + 1);
    });
    jQuery("#filter_no").click(function(){
      jQuery.fn.rsvp_filter_by(0 + 1);
    });
    jQuery("#filter_maybe").click(function(){
      jQuery.fn.rsvp_filter_by(2 + 1);
    });
    jQuery.fn.reload_search();
    jQuery("#search_guests").keyup(function(){
			setTimeout(function(){
	      var pattern = new RegExp(jQuery("#search_guests").val(), "i");
	      jQuery.each(guests_texts, function(k, v){
	        jQuery("#" + k)[v.match(pattern) ? "show" : "hide"]();
	      });
			}, 0);
    });
    jQuery("#cancel_search").click(function(){
      jQuery("tr.guest").show();
      jQuery("#search_guests").val("");
    });
		jQuery("input.select_all_emails").change(function(){
			var checked = jQuery(this).attr("checked");
			jQuery("input.input-check.guest_send_email").attr("checked", checked).redraw_customCheckbox().trigger("change");
		});
		jQuery("input.select_all_sms").change(function(){
			var checked = jQuery(this).attr("checked");
			jQuery("input.input-check.guest_send_sms").attr("checked", checked).redraw_customCheckbox().trigger("change");
		});
		jQuery("input.remote-checkbox").change(function(){
			jQuery(this).parents('form').get(0).onsubmit();
		});
});