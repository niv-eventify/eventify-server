var stage1 = {}

$(document).ready(function(){
	$("a.blue-btn-mdl").hide();
	var cropzoom = $('#crop_container').cropzoom({
		width:275,
		height:206,
		bgColor: '#CCC',
		enableRotation:true,
		enableZoom:true,
		zoomSteps:10,
		rotationSteps:10,
		selector:{
			x:0,
			y:0,
			w:200,
			h:100,
			aspcetRatio:false,
			centered:true,
			borderColor:'blue',
			borderColorHover:'yellow',
			bgInfoLayer: '#FFF',
			infoFontSize: 10,
			infoFontColor: 'blue',
			showPositionsOnDrag: false,
			showDimetionsOnDrag: false,
			maxHeight: null,
			maxWidth: null
		},
		image:{
			source:'/images/chicas512.jpg',
			width:256,
			height:192,
			minZoom:10,
			maxZoom:150
		}
	});
	$("#crop").click(function(){
		cropzoom.send('process.php','POST',{id:1},function(r){
			alert(r);
		});
	});
});