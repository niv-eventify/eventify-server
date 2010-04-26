var rsvps = {
	dialog_height: 0,
	dialog_width: 0,

	adjust_dialog_size: function(invitation_id) {
		var width = $(window).width() - 62;
		var height = $(window).height() - 63;

		if($("#" + invitation_id + " .background_holder").attr("strech") == "true") {
			rsvps.dialog_width = width - 60;
			rsvps.dialog_height = height - 30;
		} else {
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
		}
		$("#" + invitation_id + " .background_holder, #" + invitation_id).css("width",rsvps.dialog_width + "px");
		$("#" + invitation_id + " .background_holder, #" + invitation_id).css("height",rsvps.dialog_height + "px");
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
