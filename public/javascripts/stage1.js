var stage1 = {
	curr_cropped_width: 0,
	curr_cropped_height: 0,
	curr_window_height: 0,
	curr_window_width: 0,

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
				}).html("<img src=" + imgSrc + " id='preview' />")
				if($('#cropbox img').length > 0)
					$.Jcrop('#cropbox img').destroy();
				$("#cropbox").html("<img src='" + imgSrc + "' />");
				$("#uploaded_picture").val($(ui.draggable).attr("pic_id"));
				$("#window").val($(this).attr("window_id"));
				$("#cropbox img").load(stage1.initCrop);
				stage1.curr_window_height = $(this).height();
				stage1.curr_window_width = $(this).width();
				$(this).removeClass("empty");
			}
		});
	},
	initCrop: function() {
		stage1.curr_cropped_width = $("#cropbox img").width();
		stage1.curr_cropped_height = $("#cropbox img").height();
		var ratio = stage1.curr_window_width / stage1.curr_window_height;
		$('#cropbox img').Jcrop({
			onChange: stage1.showPreview,
			onSelect: stage1.showPreview,
			aspectRatio: ratio,
			setSelect: [0, 0, stage1.curr_window_width, stage1.curr_window_height]
		});
		$('body').css("cursor", "");
		$("#crop").show();
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
});
