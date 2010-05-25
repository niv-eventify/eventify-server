var rsvps = {
	dialog_height: 0,
	dialog_width: 0,

	adjust_dialog_size: function(invitation_id) {
		var width = jQuery(window).width() - 62;
		var height = jQuery(window).height() - 63;

		var ratio = width / height;
		if(ratio < 1.5) {
			if(width > 900) width = 900;
			rsvps.dialog_width = width;
			rsvps.dialog_height  = width / 1.5;
		}else{
			if(height > 600) height = 600;
			rsvps.dialog_height = height;
			rsvps.dialog_width = height * 1.5;
		}
		jQuery("#" + invitation_id + " .background_holder, #" + invitation_id).css("width",rsvps.dialog_width + "px");
		jQuery("#" + invitation_id + " .background_holder, #" + invitation_id).css("height",rsvps.dialog_height + "px");

		jQuery("#" + invitation_id + " .title_holder, #" + invitation_id + " .msg_holder").each(function(){
			var minimized_by = 900 / rsvps.dialog_width;
			jQuery(this).css("width", (parseInt(jQuery(this).css("width")) / minimized_by) + "px");
			jQuery(this).css("height", (parseInt(jQuery(this).css("height")) / minimized_by) + "px");
			jQuery(this).css("top", (parseInt(jQuery(this).css("top")) / minimized_by) + "px");
			jQuery(this).css("left", (parseInt(jQuery(this).css("left")) / minimized_by) + "px");
			jQuery(this).css("font-size", (parseInt(jQuery(this).css("font-size")) / minimized_by) + "px");
		});
	}
}
jQuery(document).ready(function(jQuery){
	jQuery(".toolbar").hide();
	jQuery("div[id ^= 'invitation']").each(function(){
		rsvps.adjust_dialog_size(jQuery(this).attr("id"));
	})
	jQuery('.toolbar_preview').appendTo('body');
	jQuery('a.preview.nyroModal').nyroModal({
		processHandler: function(settings){
			var change = false;
			if(jQuery('.title_holder').length > 1 && jQuery('#title').text() != jQuery('#invitation .title_holder').text()) {
				jQuery('#invitation .title_holder').html(jQuery('#title').html());
				change = true;
			}
			if(jQuery('.msg-holder .title').length > 0 && jQuery('#title').text() != jQuery('#invitation .msg_holder .title').text()) {
				jQuery('#invitation .msg_holder .title').html(jQuery('#title').html());
				change = true;
			}
			if(jQuery('#free_text').length > 0 && jQuery('#free_text').text() != jQuery('#invitation .msg_holder .msg').text()) {
				jQuery('#invitation .msg_holder .msg').html(jQuery('#free_text').html());
				change = true;
			}
			//if(change)
				//todo: handle font size changing
		},
		endShowContent: function(elts, settings){
			jQuery('.toolbar').show();
		},
		endRemove: function(elts, settings){
			jQuery('.toolbar').hide();
		}
	});
});
jQuery(window).load(function () {
	if(jQuery(".envelope").length > 0) {
		setTimeout(function(){
			jQuery(".envelope").nyroModalManual({closeButton:'', modal: true});
			jQuery(".toolbar").show();
		},2000);
	}
});
