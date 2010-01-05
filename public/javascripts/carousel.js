var carousel = {
	init: function() {
		var instanceOne = new ImageFlow();
		instanceOne.init(
    { 
      ImageFlowID: 'carousel',
	    reflections: false,
      slider: true,
      reflectionP: 0.1,
      aspectRatio: 3.32,
      imagesHeight: 0.77,
      imagesM: 0.9,
      captions: false,
      opacity: true,
      opacityArray: [10,10,10,10,10],
      imageFocusMax: 3,
      imageCursor: 'pointer',
      sliderCursor: 'pointer',
      xStep: 120,
      buttons: true,
      imageFocusM: 1.1
    });
	},
  show: function(category_id) {
    $(".promo-nav li").removeClass("active");
    $("#category_chooser" + category_id).parents("li").addClass("active");

    $.get("categories/" + category_id + "/designs",function(data){
      $("#carouselWrapper").html("<div id='carousel' class='imageflow'></div>");
      $("#carousel").html(data);
      carousel.init();
    });
  },
/*--- promo navigation ---*/
  promoNav: function (){
    var _speed = 1000;
    $('div.promo div.promo-nav').each(function(){
      var _hold = $(this);
      var btn_prev = _hold.find('a.prev');
      var btn_next = _hold.find('a.next');
      var list_hold = _hold.find('div.promo-nav-h > ul');
      var _list = list_hold.children();
      var list_w = 0;
      for(var i = 0; i < _list.length; i++){ list_w += _list.eq(i).outerWidth();}
      var hold_w = list_hold.parent().width();
      var _step = hold_w;
      var _m = 0;
      if(list_w > hold_w){
        btn_prev.click(function(){
          moveList(false);
          return false;
        });
        btn_next.click(function(){
          moveList(true);
          return false;
        });
      }
      else{
        btn_prev.click(function(){ return false;});
        btn_next.click(function(){ return false;});
      }
      
      function moveList(_f){
        if(_f){
          if(_m >= list_w - hold_w) _m = 0;
          else _m += _step;
        }
        else{
          if(_m > 0) _m -= _step;
          else _m = Math.ceil((list_w-hold_w)/_step)*_step;
        }
        if($('body').hasClass('hebrew')) list_hold.animate({left:_m},{queue: false, duration: _speed});
        else list_hold.animate({left:-_m},{queue: false, duration: _speed});
      }
    });
  }  
}

$(document).ready(function(){
	carousel.promoNav();
/*	$('select').customSelect();*/
	if ($(".promo-nav").get(0)) {
		var first_shown = false;
		var rebind_category = function(e){
			var cid = $(e).attr("id").substr(16);
			$(e).bind("click", {category_id: cid}, function(e){
				carousel.show(e.data.category_id);
			});
			if (!first_shown) {
				first_shown = true;
				carousel.show(cid);
				$(e).parents("li").addClass("active");
			}
		};
		$("a.category_chooser").each(function(i, e){
			rebind_category(e);
		});
		$(".promo-nav a.next").click(function(){
			var first = $(".promo-nav li:first").clone();
			$(".promo-nav li:first").remove();
			$(".promo-nav li:last").after(first);
			rebind_category($(".promo-nav li:last a"));
		});
		$(".promo-nav a.prev").click(function(){
			var last = $(".promo-nav li:last").clone();
			$(".promo-nav li:last").remove();
			$(".promo-nav li:first").before(last);
			rebind_category($(".promo-nav li:first a"));
		});
	}
});