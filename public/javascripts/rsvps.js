var rsvps = {
	win_height: 0,
	win_width: 0,

	adjust_dialog_size: function() {
		var width = rsvps.win_width - 62;
		var height = rsvps.win_height - 63;

		if($("#background_holder").attr("strech") == "true") {
			$("#background_holder, #invitation").css("width",(width - 60) + "px");
			$("#background_holder, #invitation").css("height",(height - 30) + "px");
		} else {
			var ratio = width / height;
			if(ratio < 1.5) {
				if(width > 900) width = 900;
				$("#background_holder, #invitation").css("width", width + "px");
				$("#background_holder, #invitation").css("height", (width / 1.5) + "px");
			}else{
				if(height > 600) height = 600;
				$("#background_holder, #invitation").css("height", height + "px");
				$("#background_holder, #invitation").css("width", (height * 1.5) + "px");
			}
		}
	}
}

$(document).ready(function(){
	rsvps.win_height = $(window).height();
	rsvps.win_width = $(window).width();
	rsvps.adjust_dialog_size();
	if($(".envelope").length > 0) {
		$("a.nyroModal").nyroModal({closeButton:''});
		setTimeout(function(){
			$(".envelope").click();
			$("#toolbar").show();
		},1000);
	}
});
