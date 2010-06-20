jQuery(document).ready(function() {
    var guests_texts = {};
    jQuery.fn.reload_search = function() {
      guests_texts = {};
      jQuery("tr.guest").each(function(){
        var t = jQuery(this);
				var text = "";
				for (var i=1; i<4; i++) {
					text += t.find("td.t-col-" + i).text() + " ";
				}
        guests_texts[jQuery(this).attr("id")] = text;
      });
    }
    jQuery.fn.rsvp_filter_by = function(sel_index) {
      if (!sel_index) {
        jQuery("tr.guest").show().find(".selectArea.rspv_select-replaced").hide().show();
      }
      else {
        jQuery("tr.guest").hide();
        jQuery(".rspv_select[selectedIndex=" + sel_index+ "]").each(function(){
          jQuery(this).parents("tr.guest").show().find(".selectArea.rspv_select-replaced").hide().show();
        })
      }
    }
    jQuery(".rspv_select").customSelect();
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
	        jQuery("#" + k)[v.match(pattern) ? "show" : "hide"]().find(".selectArea.rspv_select-replaced").hide().show();
	      });
			}, 0);
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