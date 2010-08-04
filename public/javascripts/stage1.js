var stage1 = {
	curr_cropped_width: 0,
	curr_cropped_height: 0,
	curr_window_height: 0,
	curr_window_width: 0,
	is_cropping: false,
	still_cropping_msg: "Saving in progress. Please wait",
	delete_crop_alert: "Are you sure you want to remove this picture?",
	delete_uploaded_pic_alert: "Are you sure you want to remove the picture you uploaded?",

	showPreview: function(coords){
		if (parseInt(coords.w) > 0){
			var rx = stage1.curr_window_width / coords.w;
			var ry = stage1.curr_window_height / coords.h;
			jQuery('#preview').css({
				width: Math.round(rx * stage1.curr_cropped_width) + 'px',
				height: Math.round(ry * stage1.curr_cropped_height) + 'px',
				marginLeft: '-' + Math.round(rx * coords.x) + 'px',
				marginTop: '-' + Math.round(ry * coords.y) + 'px'
			});
			$("#crop_x").val(coords.x);
			$("#crop_y").val(coords.y);
			$("#crop_w").val(coords.w);
			$("#crop_h").val(coords.h);
		}
	},
	initDragAndDrop: function() {
		$(".pic_thumb").draggable({
			opacity: 0.7,
			helper: 'clone',
			appendTo: 'body',
			zIndex: 200
		});
		$(".window").droppable({
			drop: function(event, ui) {
				$('body').css("cursor", "wait");
				var imgSrc = $(ui.draggable).attr("crop_src");
				$(".crop_preview").css({
					top: $(this).css('top'),
					left: $(this).css('left'),
					width: $(this).css('width'),
					height: $(this).css('height')
				}).show().html("<img src=" + imgSrc + " id='preview' />")
				if($('#cropbox img').length > 0)
					$.Jcrop('#cropbox img').destroy();
				$("#cropbox").html("<img src='" + imgSrc + "' />");
				$("#uploaded_picture").val($(ui.draggable).attr("pic_id"));
				$("#window").val($(this).attr("window_id"));
				$("#cropbox img").load(stage1.initCrop);
				stage1.curr_window_height = $(this).height();
				stage1.curr_window_width = $(this).width();
				$(this).removeClass("empty");
				jQuery.fn.unload_monit_set();
			}
		});
		$(".window, .crop_preview").draggable({
			opacity: 0.7,
			helper: 'clone',
			appendTo: 'body',
			zIndex: 200
		});
		$('body').droppable({
			drop: function(event, ui) {
				if(ui.draggable.hasClass('window')){
					if(!confirm(stage1.delete_crop_alert)) return;
					ui.draggable.find('a').click();
				}else if(ui.draggable.hasClass('crop_preview')) {
					$('#cancel_crop').click();
				}else if(ui.draggable.hasClass('pic_thumb')) {
					if(!confirm(stage1.delete_uploaded_pic_alert)) return;
					ui.draggable.next('a').click();
				}
				ui.draggable.html("");
			}
		});
		$('.visual-box').droppable({
			greedy: true,
			drop: function(event, ui) {
			}
		});
		$('.sml-gallery').droppable({
			greedy: true,
			accept: ".window",
			drop: function(event, ui) {
				if(!confirm(stage1.delete_crop_alert)) return;
				ui.draggable.find('a').click();
				ui.draggable.html("");
			}
		});
		$('.visual-box').mousedown(function(ev){
			ev.stopPropagation();
			$('.crop_preview').each(function(){
				var X = $(this).offset().left;
				var Y = $(this).offset().top;
				var W = $(this).width();
				var H = $(this).height();
				if(ev.pageX >= X && ev.pageX <= (X+W) && ev.pageY >= Y && ev.pageY <= (Y+H)){
					$(this).trigger(ev);
				}
			});
			$('.window').each(function(){
				var X = $(this).offset().left;
				var Y = $(this).offset().top;
				var W = $(this).width();
				var H = $(this).height();
				if(ev.pageX >= X && ev.pageX <= (X+W) && ev.pageY >= Y && ev.pageY <= (Y+H)){
					$(this).trigger(ev);
				}
			});
		});
		$('.crop_preview, .window').mousedown(function(ev){
			ev.stopPropagation();
		});
	},
	initCrop: function() {
		stage1.curr_cropped_width = $("#cropbox img").width();
		stage1.curr_cropped_height = $("#cropbox img").height();
		var ratio = stage1.curr_window_width / stage1.curr_window_height;
		var cropX = Math.floor(($('#cropbox img').width() - stage1.curr_window_width) / 2);
		var cropY = Math.floor(($('#cropbox img').height() - stage1.curr_window_height) / 2);
		$('#cropper_width').val(stage1.curr_cropped_width);
		$('#cropbox img').Jcrop({
			onChange: stage1.showPreview,
			onSelect: stage1.showPreview,
			aspectRatio: ratio,
			setSelect: [cropX, cropY, cropX + stage1.curr_window_width, cropY + stage1.curr_window_height]
		});
		$('body').css("cursor", "");
		$("#crop,#cancel_crop").show();
	},
	update_designs: function() {
		var url;
		if (stage1.event_designs_path) {
			url = stage1.event_designs_path + "&change_design=true&category_id=" + stage1.cetagory_id;
		}
		else {
			url = "/categories/" + stage1.cetagory_id + "/designs?change_design=true";
		}
		jQuery.ajax({url:url, type:'get', dataType:'script'})		
	}
}

$(document).ready(function(){
	$("a.blue-btn-mdl").hide();
	$("a.nyroModal.uploadLink").nyroModal({
		minHeight: 270
	});
	stage1.initDragAndDrop();
	$(".window").each(function(){
		if($(this).children('img').length == 0)
			$(this).addClass("empty");
	});
	$("a.next-btn").click(function(){
		if(stage1.is_cropping) {
			alert(stage1.still_cropping_msg);
			return false;
		}
		jQuery('body').css('cursor', 'wait');
	});
	jQuery("a.change-design").click(function(e){
		stage1.update_designs();
		return false;
	});
	$("#crop,#cancel_crop").click(function(){
		jQuery.fn.unload_monit_reset();
	});
});
