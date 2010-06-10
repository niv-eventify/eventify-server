var stage1 = {
	curr_cropped_width: 0,
	curr_cropped_height: 0,
	showPreview: function(coords){
		if (parseInt(coords.w) > 0){
			var rx = 100 / coords.w;
			var ry = 100 / coords.h;

			jQuery('#preview').css({
				width: Math.round(rx * stage1.curr_cropped_width) + 'px',
				height: Math.round(ry * stage1.curr_cropped_height) + 'px',
				marginLeft: '-' + Math.round(rx * coords.x) + 'px',
				marginTop: '-' + Math.round(ry * coords.y) + 'px'
			});
		}
	},
	initDragAndDrop: function() {
		$(".pic_thumb").draggable({
			opacity: 0.7,
			helper: 'clone',
			appendTo: 'body'
		});
		$(".window").droppable({
			drop: function(event, ui) {
				$(this).addClass('green');
			}
		});
	}
}

$(document).ready(function(){
	$("a.blue-btn-mdl").hide();
	$("a.nyroModal.uploadLink").nyroModal({
		minHeight: 270
	});
	stage1.initDragAndDrop();
//    $.get("/uploaded_pictures",function(data){
//    	alert(data);
//	});
//stage1.curr_cropped_width = $("img#cropbox").width();
//stage1.curr_cropped_height = $("img#cropbox").height();
//$(".crop_preview").append("<img src=" + $("img#cropbox").attr("src") + " id='preview' />")
});
$(window).load(function(){
	$('#cropbox').Jcrop({
		onChange: stage1.showPreview,
		onSelect: stage1.showPreview,
		aspectRatio: 1
	});
});

