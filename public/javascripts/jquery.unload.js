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
	$.fn.unload_monit_set = function() {
		was_changed = true;
	};
	$.fn.unload_monit_is_set = function() {
		return was_changed;
	};
	$.fn.unload_monit_set_message = function(new_message) {
	  if(!new_message) return;
		message = new_message;
	};
	$.fn.unload_monit = function(new_message) {
		$.fn.unload_monit_set_message(new_message);
		return this.change(function() {
			if(typeof console != 'undefined')
				console.log($(this)[0]);
			$.fn.unload_monit_set();
		});
	}
})(jQuery);
