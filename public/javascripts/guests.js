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
				jQuery("tr.guest").show();
				setTimeout(function(){ jQuery("tr.guest .selectArea").hide().show(); }, 0);
      }
      else {
        jQuery("tr.guest").hide().find(".selectArea").hide().show();
        jQuery(".rspv_select[selectedIndex=" + sel_index+ "]").each(function(){
					var that = jQuery(this);
          that.parents("tr.guest").show();
					setTimeout(function(){that.parents("tr.guest").find(".selectArea").hide().show(); }, 0);
        })
      }
    }
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
					setTimeout(function(){jQuery("#" + k + " .selectArea").hide().show();}, 0);
	      });
			}, 0);
    });
    jQuery("#cancel_search").click(function(){
      jQuery("tr.guest").show();
			setTimeout(function(){ jQuery("tr.guest .selectArea").hide().show(); }, 0);
    });
		var mass_update = function(attribute, is_true, ckeckboxes) {
			var ids = [];
			jQuery.each(ckeckboxes, function(i, c){
				ids.push(parseInt(jQuery(c).attr("id").substr(6)));
			});
	    var data = {
	      '_method': 'put',
	      'authenticity_token': window.AUTH_TOKEN,
	      'guest_ids': ids.join(","),
	      'value': is_true ? "1" : "0",
				'attr': attribute
	    };
	    jQuery.ajax({url: "/events/" + window.event_id + "/guests/mass_update", type:'post', dataType:'script', data: data});
		};
		jQuery("input.select_all_emails").change(function(){
			var checked = jQuery(this).attr("checked");
			jQuery("input.input-check.guest_send_email").attr("checked", checked).redraw_customCheckbox();
			mass_update("send_email", checked, jQuery("input.input-check.guest_send_email"));
		});
		jQuery("input.select_all_sms").change(function(){
			var checked = jQuery(this).attr("checked");
			jQuery("input.input-check.guest_send_sms").attr("checked", checked).redraw_customCheckbox();
			mass_update("send_sms", checked, jQuery("input.input-check.guest_send_sms"));
		});
		jQuery("input.remote-checkbox").change(function(){
			jQuery(this).parents('form').get(0).onsubmit();
		});
});