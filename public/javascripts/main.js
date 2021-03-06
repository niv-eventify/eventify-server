/*---- clear inputs ---*/
function clearInputs(id, coupledIds){
  jQuery('#' + id).each(function(){
    jQuery(this).bind('focus', function(){
      clearField(jQuery(this));
      if(!coupledIds) return;
      for(var i = 0; i < coupledIds.length; i++) {
        clearField(jQuery('#' + coupledIds[i]));
      }
    }).bind('blur', function(){
      var fields = [jQuery(this)];
      if(coupledIds) {
        for(var i = 0; i < coupledIds.length; i++) {
          fields.push(jQuery('#' + coupledIds[i]));
        }
      }
      fillFields(fields)
    }).blur();
  });
}
function clearField(elem){
  var default_val = elem.attr('def_value');
  if(elem.val().replace(/[\n\r]/g,"") == default_val.replace(/[\n\r]/g,"")) elem.val('');
  elem.css('color','#523733')
}
function fillFields(fields) {
  var allEmpty = true;
  jQuery.each(fields, function(index, elem) {
    if(elem.val() != "") allEmpty = false;
  });
  if(!allEmpty) return;
  jQuery.each(fields, function(index, elem) {
    var default_val = elem.attr('def_value');
    if(elem.val() == '') {
      elem.val(default_val);
      elem.css('color','#a3948f');
    }
  });
}
function isInputFieldWithDefaultVal(id) {
  var el = jQuery('#' + id);
  return el.val().replace(/[\n\r]/g,"") == el.attr('def_value').replace(/[\n\r]/g,"")
}
function clearInputsBeforeFormSubmission(id){
	if(jQuery('#' + id).length == 0) return;
	if(jQuery('#' + id).val().replace(/[\n\r]/g,"") == jQuery('#' + id).attr('def_value').replace(/[\n\r]/g,""))
		jQuery('#' + id).val("")
}
/*--- IE6 hover ---*/
function ieHover(h_list, h_class){
	if(jQuery.browser.msie && jQuery.browser.version < 7){
		if(!h_class) var h_class = 'hover';
		jQuery(h_list).hover(function(){
			if(jQuery(this).hasClass('img-box')){
				jQuery(this).addClass('img-box-hover');
			}
			jQuery(this).addClass(h_class);
		}, function(){
			if(jQuery(this).hasClass('img-box-hover')){
				jQuery(this).removeClass('img-box-hover');
			}
			jQuery(this).removeClass(h_class);
		});
	}
}

/*--- slide blocks ---*/
function initSlide(){
	var t_box = false;
	var t_box1 = false;
	var t_box2 = false;
	jQuery('#top-nav > li:has("div.popup")').each(function(){
		var _hold = jQuery(this);
		_hold.addClass('width-popup');
		var _btn = _hold.children('a');
		var _box = _hold.children('div.popup');
		if(_btn.length && _box.length){
			var _t;
			var _speed = (jQuery.browser.msie)?(0):(300);
			if(_hold.hasClass('active')){
				_box.css({display:'block', opacity: 'auto'});
				t_box1 = _box;
			}
			else{
				_box.css({display:'none', opacity: 0});
				t_box1 = false;
			}
			_hold.mouseenter(function(){
				if(_t) clearTimeout(_t);
			}).mouseleave(function(){
				if(_t) clearTimeout(_t);
				_t = setTimeout(function(){
					if(_hold.hasClass('active')){
						_box.stop().animate({opacity: 0}, _speed, function(){
							jQuery(this).hide();
							_hold.removeClass('active');
						});
						t_box1 = false;
					}
				}, 2000);
			});
			_btn.click(function(){
				if(_hold.hasClass('active')){
					_box.stop().animate({opacity: 0}, _speed, function(){
						jQuery(this).hide();
						_hold.removeClass('active');
					});
					t_box1 = false;
				}
				else{
					_hold.addClass('active');
					_box.stop().show().animate({opacity: 1}, _speed, function(){
						jQuery(this).css('opacity', 'auto');
					});
					t_box1 = _box;
				}
				return false;
			});
			_box.find('a.close').click(function(){
				_box.stop().animate({opacity: 0}, _speed, function(){
					jQuery(this).hide();
					_hold.removeClass('active');
				});
				t_box1 = false;
				return false;
			});
		}
	});
	jQuery('div.personal-menu-h').each(function(){
		var _hold = jQuery(this);
		var _btn = _hold.find('div.opener a');
		var _box = _hold.find('div.menu-list');
		if(_btn.length && _box.length){
			var _t;
			var _h = _box.outerHeight();
			if(_hold.hasClass('open')){
				_box.show();
				t_box2 = _box;
			}
			else{
				_box.hide();
				t_box2 = false;
			}
			_btn.click(function(){
				if(_hold.hasClass('open')){
					_hold.removeClass('open');
					_box.stop().animate({height:0}, 300, function(){
						jQuery(this).css({display:'none', height:'auto'});
					});
					t_box2 = false;
				}
				else{
					if(_box.is(':hidden')){
						_box.show();
						_h = _box.outerHeight();
						_box.height(0);
					}
					_hold.addClass('open');
					_box.stop().animate({height: _h}, 300, function(){ jQuery(this).height('auto');});
					t_box2 = _box;
				}
				return false;
			});
			_hold.mouseenter(function(){
				if(_t) clearTimeout(_t);
			}).mouseleave(function(){
				_t = setTimeout(function(){
					if(_hold.hasClass('open')){
						_hold.removeClass('open');
						_box.stop().animate({height:0}, 300, function(){
							jQuery(this).css({display:'none', height:'auto'});
						});
						t_box2 = false;
					}
				}, 2000);
			});
		}
	});
	
	jQuery('div.edit').each(function(){
		var _hold = jQuery(this);
		var _t;
		var _btn = _hold.find('a.open, a.open-edit');
		var _box = _hold.find('div.drop');
		if(_btn.length && _box.length){
			_btn.click(function(){
				if(_hold.hasClass('edit-drop')){
					t_box = false;
					_hold.removeClass('edit-drop');
					if(_hold.hasClass('drop2')) _btn.css('visibility', 'visible');
				}
				else{
					t_box = _hold;
					_hold.addClass('edit-drop');
					if(_hold.hasClass('drop2')) _btn.css('visibility', 'hidden');
				}
				return false;
			});
		}
		_hold.mouseenter(function(){
			if(_t) clearTimeout(_t);
		}).mouseleave(function(){
			_t = setTimeout(function(){
				if(_hold.hasClass('edit-drop')){
					_hold.removeClass('edit-drop');
					if(_hold.hasClass('drop2')) _btn.css('visibility', 'visible');
					t_box = false;
				}
			}, 1000);
		});
	});
	jQuery('body').bind('mousedown', function(e){
		if(t_box){
			e = e || event;
			var t = e.target || e.srcElement;
			t = jQuery(t);
			if(t.parents('div.edit').length == 0){
				t_box.removeClass('edit-drop');
				if(t_box.hasClass('drop2')) t_box.find('a.open').css('visibility', 'visible');
				t_box = false;
			}
		}
		if(t_box1){
			e = e || event;
			var t = e.target || e.srcElement;
			t = jQuery(t);
			if(t.parents('li.width-popup').length == 0){
				var _speed = (jQuery.browser.msie)?(0):(300);
				t_box1.stop().animate({opacity: 0}, _speed, function(){
					jQuery(this).hide();
					jQuery(this).parent().removeClass('active');
				});
				t_box1 = false;
			}
		}
		if(t_box2){
			e = e || event;
			var t = e.target || e.srcElement;
			t = jQuery(t);
			if(t.parents('div.personal-menu-h').length == 0){
				t_box2.parents('div.personal-menu-h:eq(0)').removeClass('open');
				t_box2.stop().animate({height:0}, 300, function(){
					jQuery(this).css({display:'none', height:'auto'});
				});
				t_box2 = false;
			}
		}
	});
}

/*--- promo navigation ---*/
function promoNav(){
	var _speed = 1000;
	jQuery('div.promo div.promo-nav').each(function(){
		var _hold = jQuery(this);
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
			if(jQuery('body').hasClass('hebrew')) list_hold.animate({left:_m},{queue: false, duration: _speed});
			else list_hold.animate({left:-_m},{queue: false, duration: _speed});
		}
	});
}
/*--- custom select ---*/
jQuery.fn.customSelect = function(_options){
var _options = jQuery.extend({
	selectStructure: '<div class="selectArea"><div class="left"></div><div class="center"></div><a href="#" class="selectButton">&nbsp;</a><div class="disabled"></div></div>',
	selectText: '.center',
	selectBtn: '.selectButton',
	selectDisabled: '.disabled',
	optStructure: '<div class="selectOptions"><div class="bg-t"><div class="l"></div><div class="r"></div></div><ul></ul><div class="bg-b"><div class="l"></div><div class="r"></div></div></div>',
	optList: 'ul'
}, _options);
return this.each(function(){
	var select = jQuery(this);
	if(!select.hasClass('outtaHere')){
		if(select.is(':visible')){
			var replaced = jQuery(_options.selectStructure);
			var selectText = replaced.find(_options.selectText);
			var selectBtn = replaced.find(_options.selectBtn);
			var selectDisabled = replaced.find(_options.selectDisabled).hide();
			var optHolder = jQuery(_options.optStructure);
			optHolder.addClass(select.attr("id"));
			var optList = optHolder.find(_options.optList);
			if(select.attr('disabled')) selectDisabled.show();
			select.find('option').each(function(){
				var selOpt = jQuery(this);
				var _opt = jQuery('<li><a href="#">' + selOpt.html() + '</a></li>');
				if(selOpt.attr('selected')) {
					selectText.html(selOpt.html());
					_opt.addClass('selected');
				}
				_opt.children('a').click(function(){
					optList.find('li').removeClass('selected');
					select.find('option').removeAttr('selected');
					jQuery(this).parent().addClass('selected');
					selOpt.attr('selected', 'selected');
					selectText.html(selOpt.html());
					select.change();
					optHolder.hide();
					return false;
				});
				optList.append(_opt);
			});
			replaced.width(select.outerWidth());
			if(select.attr('class') != '') replaced.addClass(select.attr('class')+'-replaced');
			replaced.insertBefore(select);
			optHolder.css({
				width: select.outerWidth(),
				display: 'none',
				position: 'absolute'
			});
			jQuery(document.body).append(optHolder);
			
			var optTimer;
			replaced.hover(function() {
				if(optTimer) clearTimeout(optTimer);
			}, function() {
				optTimer = setTimeout(function() {
					optHolder.hide();
				}, 200);
			});
			optHolder.hover(function(){
				if(optTimer) clearTimeout(optTimer);
			}, function() {
				optTimer = setTimeout(function() {
					optHolder.hide();
				}, 200);
			});
			selectBtn.click(function() {
				if(optHolder.is(':visible')) {
					optHolder.hide();
				}
				else{
					optHolder.children('ul').css({height:'auto', overflow:'hidden'});
					optHolder.css({
						top: replaced.offset().top + replaced.outerHeight(),
						left: replaced.offset().left,
						display: 'block'
					});
					if(optHolder.children('ul').height() > 200) optHolder.children('ul').css({height:200, overflow:'auto'});
					else optHolder.children('ul').css({height:'auto', overflow:'hidden'});
				}
				return false;
			});
			select.addClass('outtaHere');
		}
	}
});
}
/*------------------------ CUSTOM RADIO'S -----------------------------*/
jQuery.fn.customRadio = function(_options){
	var _options = jQuery.extend({
		radioStructure: '<div></div>',
		radioDisabled: 'disabled',
		radioDefault: 'radioArea',
		radioChecked: 'radioAreaChecked'
	}, _options);
	return this.each(function(){
		var radio = jQuery(this);
		if(!radio.hasClass('outtaHere') && radio.is(':radio')){
			var replaced = jQuery(_options.radioStructure);
			this._replaced = replaced;
			replaced.insertBefore(radio);
			radio.addClass('outtaHere');
			if(radio.is(':disabled')) replaced.addClass(_options.radioDisabled);
			else if (radio.is(':checked')) {
				replaced.addClass(_options.radioChecked);
				replaced.parent().addClass("selected");
			}
			else 
				replaced.addClass(_options.radioDefault);
			replaced.click(function(){
				if(jQuery(this).hasClass(_options.radioDefault)){
					radio.attr('checked', 'checked');
					changeRadio(radio.get(0));
				}
			});
			radio.click(function(){
				changeRadio(this);
			});
			
		}
	});
	function changeRadio(_this){
		jQuery(_this).change();
		jQuery('input:radio[name='+jQuery(_this).attr("name")+']').not(_this).each(function(){
			if (this._replaced && !jQuery(this).is(':disabled')) {
				this._replaced.removeClass().addClass(_options.radioDefault);
				this._replaced.parent().removeClass("selected");
			}
		});
		_this._replaced.removeClass().addClass(_options.radioChecked);
		_this._replaced.parent().removeClass("selected").addClass("selected");
	}
}
/*------------------------ CUSTOM CHECKBOX'S -----------------------------*/
jQuery.fn.customCheckbox = function(_options){
	var _options = jQuery.extend({
		checkboxStructure: '<div></div>',
		checkboxDisabled: 'disabled',
		checkboxDefault: 'checkboxArea',
		checkboxChecked: 'checkboxAreaChecked'
	}, _options);
	return this.each(function(){
		var checkbox = jQuery(this);
		if(!checkbox.hasClass('outtaHere') && checkbox.is(':checkbox')){
			var replaced = jQuery(_options.checkboxStructure);
			this._replaced = replaced;
			replaced.insertBefore(checkbox);
			checkbox.addClass('outtaHere');
			if(checkbox.is(':disabled')) replaced.addClass(_options.checkboxDisabled);
			else if (checkbox.is(':checked')) {
				replaced.addClass(_options.checkboxChecked);
				replaced.parent().addClass("selected");
			}
			else 
				replaced.addClass(_options.checkboxDefault);
			
			replaced.click(function(){
				if(checkbox.is(':checked')) checkbox.removeAttr('checked');
				else checkbox.attr('checked', 'checked');
				changeCheckbox(checkbox);
				checkbox.trigger("change");
			});
			checkbox.click(function(){
				changeCheckbox(checkbox);
			});
		}
	});
	function changeCheckbox(_this){
		if (_this.is(':checked')) {
			_this.get(0)._replaced.removeClass().addClass(_options.checkboxChecked).parent().addClass("selected");
		}
		else 
			_this.get(0)._replaced.removeClass().addClass(_options.checkboxDefault).parent().removeClass("selected");
	}
}

jQuery.fn.redraw_customCheckbox = function() {
  return this.each(function(){
    var checkbox = jQuery(this);
    if(checkbox.is(':checked')) checkbox.get(0)._replaced.removeClass().addClass("checkboxAreaChecked");
    else checkbox.get(0)._replaced.removeClass().addClass("checkboxArea");
  });
};

/*------------------------ SlideEffect -----------------------------*/
function initSlideEffect(){
    var _parentSlide = 'div.slider';
    var _linkSlide = 'a.open-link';
    var _slideBlock = 'div.slide';
    var _openClassS = 'open-slide';
    var _durationSlide = 500;

	if (jQuery(_parentSlide).hasClass('open-slide')) jQuery(_slideBlock).css('display','block');
    jQuery(_parentSlide).each(function(){
		if (!jQuery(this).is('.'+_openClassS)) {
			jQuery(this).find(_slideBlock).css('display','none');
		}
    });
    jQuery(_linkSlide,_parentSlide).click(function(){
		if (jQuery(this).parents(_parentSlide).is('.'+_openClassS)) {
			jQuery(this).parents(_parentSlide).removeClass(_openClassS);
			jQuery(this).parents(_parentSlide).find(_slideBlock).slideUp(_durationSlide);
		} else {
			jQuery(this).parents(_parentSlide).addClass(_openClassS);
			jQuery(this).parents(_parentSlide).find(_slideBlock).slideDown(_durationSlide);
		}
		return false;
    });
}

function initDrop() {
	jQuery('.subnav').each(function(){
		var _drop = jQuery('.subnav > li > .menu-list');
		var links_opener = jQuery('.subnav > li > a.opener');
		links_opener.click(function(){
			var this_item = jQuery(this).parent('li');
			var _items = links_opener.parent('li');
			if(this_item.hasClass('hover2')){
				_items.removeClass('hover2');
			}else{
				_items.removeClass('hover2');
				this_item.addClass('hover2');
			}
			return false;
		});
		jQuery(document).bind('mousedown', function(e){
			if(_drop && _drop.is(':visible')){
				e = e || event;
				var t = e.target || e.srcElement;
				t = jQuery(t);
				if(t.parents('.subnav').length == 0){
				_drop.parent().removeClass('hover2');
			}}
		});
	})
}

function set_sms_counters() {
	jQuery(".sms-message-body").charCounter(140, {
		container: "<em></em>",
		classname: "counter",
		format: window.sms_counter_format || "%1",
		pulse: false,
		delay: 100
	});
}

function set_counter(textAreaId, containerId, max) {
	jQuery(textAreaId).charCounter(max, {
		container: containerId,
		classname: "counter",
		format: window.sms_counter_format || "%1",
		pulse: false,
		delay: 100
	});
}

jQuery(document).ready(function(){
	initSlideEffect();
	ieHover('.img-box, .edit-bg');
	initSlide();
	promoNav();
	jQuery('select').customSelect();
	jQuery('input:checkbox').customCheckbox();
	initDrop();
	set_sms_counters();
});


var transparentImage = "/images/none.gif";
function fixTrans()
{
	if (typeof document.body.style.maxHeight == 'undefined') 
	{
		var imgs = document.getElementsByTagName("img");
		for (i = 0; i < imgs.length; i++)
		{	
			if (imgs[i].src.indexOf(transparentImage) != -1)
			{
				return;
			}
			if (imgs[i].src.indexOf(".png") != -1)
			{
				var src = imgs[i].src;
				imgs[i].src = transparentImage;
				imgs[i].runtimeStyle.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + src + "',sizingMethod='scale')";
				imgs[i].style.display = "inline-block";
			}
		}	
	}
}

if (document.all && !window.opera)
	attachEvent("onload", fixTrans);

function show_nyro_loading(func) {
		  var opts = {
		    content: '<div id="nyroModalLoading" style="position: absolute; top: 50%; left: 50%; margin-top: -155px; margin-left: -106px; width: 210px; border:1px solid #fff; height: 308px;"><a class="nyroModalClose" href="#">Cancel</a></div>'
		  };
		  if (func)
		      opts.endShowContent = func;
		  jQuery.nyroModalManual(opts);
}
