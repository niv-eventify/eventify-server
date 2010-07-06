(function($) {
	var was_changed = false;
	var message = "";
	window.onbeforeunload = function(e) {
		if (was_changed) {
			if (e) e.returnValue = message;
			return message;
		}
	}
	$.fn.unload_monit_reset = function() {
		was_changed = false;
	};
	$.fn.unload_monit = function(new_message) {
		message = new_message;
		return this.change(function() {
			was_changed = true;
			console.log("changed!");
		});
	}
})(jQuery);
