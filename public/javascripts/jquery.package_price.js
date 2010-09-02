(function($) {
	$.fn.package_price = function(base_price, base_count, batch_size, unit_price) {

		return this.each(function() {
			var obj = $(this);
			var fld = obj.find("input[name=sms_plan]");
			var price = obj.find("span.price strong");
			var count = obj.find(".controls span.count");
			obj.find(".controls a.btn-plus").click(function(){
				var new_count = parseInt(count.html()) + batch_size;
				count.html(new_count);
				fld.val(new_count);
				var new_price = parseInt(parseFloat(price.html()) * 100 + unit_price * batch_size);
				price.html((new_price/100).toFixed(2));
			});
			obj.find(".controls a.btn-minus").click(function(){
				var current_count = parseInt(count.html());
				if (current_count - batch_size >= base_count) {
					current_count -= batch_size;
					count.html(current_count);
					fld.val(current_count);
					var new_price = parseInt(parseFloat(price.html()) * 100 - unit_price * batch_size);
					price.html((new_price/100).toFixed(2));
				}
			});
		});
	}
})(jQuery);