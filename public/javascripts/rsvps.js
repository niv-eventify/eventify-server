var rsvps = {
	dialog_height: 0,
	dialog_width: 0,

	adjust_dialog_size: function(invitation_id) {
		var width = $(window).width() - 62;
		var height = $(window).height() - 63;

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
		$("#" + invitation_id + " .background_holder, #" + invitation_id).css("width",rsvps.dialog_width + "px");
		$("#" + invitation_id + " .background_holder, #" + invitation_id).css("height",rsvps.dialog_height + "px");

		$("#" + invitation_id + " .title_holder, #" + invitation_id + " .msg_holder").each(function(){
			var minimized_by = 900 / rsvps.dialog_width;
			$(this).css("width", (parseInt($(this).css("width")) / minimized_by) + "px");
			$(this).css("height", (parseInt($(this).css("height")) / minimized_by) + "px");
			$(this).css("top", (parseInt($(this).css("top")) / minimized_by) + "px");
			$(this).css("left", (parseInt($(this).css("left")) / minimized_by) + "px");
		});
	}
}
$(document).ready(function(){
	$("div[id ^= 'invitation']").each(function(){
		rsvps.adjust_dialog_size($(this).attr("id"));
	})
});
$(window).load(function () {
	if($(".envelope").length > 0) {
		$("a.nyroModal").nyroModal({closeButton:'', modal: true});
		$(".envelope").click();
		$("#toolbar").show();
	}
});
