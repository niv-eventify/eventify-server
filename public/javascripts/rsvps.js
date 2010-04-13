var rsvps = {
	win_height: 0,
	win_width: 0,
	
	set_no_repeat_bg_size: function() {
		if(rsvps.win_height > 600 && rsvps.win_width > 900) return;
		var ratio = rsvps.win_width / rsvps.win_height;
		if(ratio < 1.5) {
			$("#background_holder").css("width", rsvps.win_width + "px");	
			$("#background_holder").css("height", (rsvps.win_width / 1.5) + "px");	
		}else{
			$("#background_holder").css("height", rsvps.win_height + "px");	
			$("#background_holder").css("width", (rsvps.win_height * 1.5) + "px");	
		}
	}	
}

$(document).ready(function(){
	rsvps.win_height = $(window).height();
	rsvps.win_width = $(window).width();
	if($("#background_holder").length > 0) {
		$(window).bind('resize', rsvps.set_no_repeat_bg_size);
		rsvps.set_no_repeat_bg_size();
	}
});
