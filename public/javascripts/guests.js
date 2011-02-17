jQuery(document).ready(function() {
    var showTable = jQuery("table#guests tbody tr").length > 1;
    jQuery('.add_manually').toggle(!showTable)
    jQuery(".guest_list").toggle(showTable);
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
		jQuery("input.select_all_emails").live("change", function(){
			var checked = jQuery(this).attr("checked");
			jQuery("input.input-check.guest_send_email").attr("checked", checked).redraw_customCheckbox();
			mass_update("send_email", checked, jQuery("input.input-check.guest_send_email"));
		});
		jQuery("input.select_all_sms").live("change", function(){
			var checked = jQuery(this).attr("checked");
			jQuery("input.input-check.guest_send_sms").attr("checked", checked).redraw_customCheckbox();
			mass_update("send_sms", checked, jQuery("input.input-check.guest_send_sms"));
		});
		jQuery("input.remote-checkbox").change(function(){
			jQuery(this).parents('form').get(0).onsubmit();
		});
});