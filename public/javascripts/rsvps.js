var rsvps = {
	set_no_repeat_bg_size: function() {
		var win_height = $(window).height();
		var win_width = $(window).width();
		if(win_height > 600 && win_width > 900) return;
		var ratio = win_width / win_height;
		if(ratio < 1.5) {
			$("#background_holder").css("width", win_width + "px");	
			$("#background_holder").css("height", (win_width / 1.5) + "px");	
		}else{
			$("#background_holder").css("height", win_height + "px");	
			$("#background_holder").css("width", (win_height * 1.5) + "px");	
		}
	}
}

$(document).ready(function(){
	if($("#background_holder").length > 0) {
		$(window).bind('resize', rsvps.set_no_repeat_bg_size);
		rsvps.set_no_repeat_bg_size();
	}
});
