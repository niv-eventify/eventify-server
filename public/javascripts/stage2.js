﻿var stage2 = {
  location: "",
  startDate: "",
  startTime: "",
  message: "",
  max_title_font_size: 0,
  max_free_text_font_size: 0,
  curr_title_font_size: 0,
  curr_free_text_font_size: 0,
  title_scroll_width: 0,
  free_text_scroll_width: 0,
  months_arr: [],
  del_date_alert: "",
  del_time_alert: "",
  seperated_title: false,
  prev_text: "",
  
  calcFontSize: function() {
    var loop_protection = 0;
    stage2.curr_free_text_font_size = parseInt(jQuery("#free_text").css("font-size"));
    stage2.curr_title_font_size = parseInt(jQuery("#title").css("font-size"));
    if(!stage2.seperated_title) {
      while(loop_protection < 100 && (stage2.curr_free_text_font_size < stage2.max_free_text_font_size || stage2.curr_title_font_size < stage2.max_title_font_size) && (jQuery(".msg-holder").height() > (jQuery("#free_text").height() + jQuery("#title").height() + parseInt(jQuery("#free_text").css("line-height"))))) {
        loop_protection++;
        if(stage2.curr_free_text_font_size < stage2.max_free_text_font_size)
            stage2.change_font_size_by(1, "free_text");
        if(stage2.curr_title_font_size < stage2.max_title_font_size)
            stage2.change_font_size_by(1, "title");
      }
      while(loop_protection < 100 && jQuery(".msg-holder").height() < (jQuery("#free_text").height() + jQuery("#title").height())) {
        loop_protection++;
        stage2.change_font_size_by(-1, "free_text");
        stage2.change_font_size_by(-1, "title");
      }
    } else {
      while(loop_protection < 100 && stage2.curr_free_text_font_size < stage2.max_free_text_font_size && jQuery(".msg-holder").height() > jQuery("#free_text").height()) {
        loop_protection++;
        stage2.change_font_size_by(1, "free_text");
      }
      while(loop_protection < 100 && stage2.curr_title_font_size < stage2.max_title_font_size && jQuery(".title-holder").height() > jQuery("#title").height()) {
        loop_protection++;
        stage2.change_font_size_by(1, "title");
      }
      while(loop_protection < 100 && jQuery(".msg-holder").height() < jQuery("#free_text").height()) {
        loop_protection++;
        stage2.change_font_size_by(-1, "free_text");
      }
      while(loop_protection < 100 && jQuery(".title-holder").height() < jQuery("#title").height()) {
        loop_protection++;
        stage2.change_font_size_by(-1, "title");
      }
    }
    while(loop_protection < 100 && (stage2.curr_title_font_size > stage2.max_title_font_size || jQuery("#title")[0].scrollWidth > stage2.title_scroll_width)) {
      loop_protection++;
      stage2.change_font_size_by(-1,"title");
    }
    while(loop_protection < 100 && (stage2.curr_free_text_font_size > stage2.max_free_text_font_size || jQuery("#free_text")[0].scrollWidth > stage2.free_text_scroll_width)) {
      loop_protection++;
      stage2.change_font_size_by(-1, "free_text");
    }
  },
  change_font_size_by: function(delta, id) {
    var new_font_size = parseInt(jQuery("#" + id).css("font-size")) + delta;
    jQuery("#" + id).css("font-size", new_font_size + "px");
    if(id == "title") {
      jQuery("#event_title_font_size").val(Math.floor(new_font_size * 1.6));
      jQuery(".background_holder .title_holder, .background_holder .title").css("font-size", Math.floor(new_font_size * 1.6) + "px");
    } else {
      jQuery("#event_msg_font_size").val(Math.floor(new_font_size * 1.6));
      jQuery(".background_holder .msg").css("font-size", Math.floor(new_font_size * 1.6) + "px");
    }
    stage2["curr_" + id + "_font_size"] = parseInt(jQuery("#" + id).css("font-size"));
  },

  is_good_font_size: function(id) {
    return jQuery("#" + id)[0].scrollWidth <= stage2[id + "_scroll_width"]
  },

  preview_text: function(sourceId, targetId) {
    var text = jQuery("#" + sourceId).val();
    if(stage2.prev_text == text) return;
    stage2.prev_text = text;
    text = text.replace(/\n/g,"<BR/>");
    jQuery("#" + targetId).html(text);
    stage2.calcFontSize();
  },
  setDateInMessage: function() {
    stage2.setFieldValueInMessage(jQuery("#starting_at_mock").val(), "startDate");
  },
  setTimeInMessage: function() {
    var time = "";
    if(jQuery("#event_starting_at_4i").val() == "" || jQuery("#event_starting_at_5i").val() == "") {
      if(stage2.startTime == "")
        return;
    } else {
      time = jQuery("#event_starting_at_4i").val() + ":" + jQuery("#event_starting_at_5i").val();
    }
    
    stage2.setFieldValueInMessage(time, "startTime");
  },
  setFieldValueInMessage: function(newVal, varName) {
    if(newVal != stage2[varName]) {
      var newVal = " " + newVal;
      var message = jQuery("#event_guest_message").val();
      if(stage2[varName].length > 0) {
        jQuery("#event_guest_message").val(message.replace(stage2[varName], newVal));
      } else if(message.length == 0){
        jQuery("#event_guest_message").val(newVal);
      } else {
        jQuery("#event_guest_message").val(message + "\r" + newVal);
      }
      stage2[varName] = newVal;
      stage2.message = jQuery("#event_guest_message").val();
      stage2.preview_text("event_guest_message", "free_text");
    }
  },
  selectAllSafeValue: function(safeVal) {
    var textStart = jQuery("#event_guest_message").val().search(safeVal);
    var textEnd = textStart >= 0 ? (textStart + safeVal.length) : -1;
    if(jQuery("#event_guest_message").getSelection().start > textStart && jQuery("#event_guest_message").getSelection().start < textEnd)
      jQuery("#event_guest_message").setSelection(textStart, textEnd);
  },
  setToolbarsPosition: function() {
    var toolbarHeight = 22;
    if(stage2.seperated_title){
      var hebrewOffsetTitle = jQuery('#toolbar_title').width() + 10 - jQuery('.title-holder').width();
      var hebrewOffsetMsg = jQuery('#toolbar_msg').width() + 10 - jQuery('.msg-holder').width();
      jQuery("#toolbar_title").css("top",jQuery(".title-holder").offset().top - toolbarHeight + "px");
      jQuery("#toolbar_msg").css("top",jQuery(".msg-holder").offset().top - toolbarHeight + "px");
      if(jQuery('.hebrew').length > 0) {
        jQuery("#toolbar_title").css("left",jQuery(".title-holder").offset().left - hebrewOffsetTitle + "px");
        jQuery("#toolbar_msg").css("left",jQuery(".msg-holder").offset().left - hebrewOffsetMsg + "px");
      } else {
        jQuery("#toolbar_title").css("left",jQuery(".title-holder").offset().left + "px");
        jQuery("#toolbar_msg").css("left",jQuery(".msg-holder").offset().left + "px");
      }
    }else{
      var hebrewOffset = jQuery('#toolbar_title').width() + 10 - jQuery('.msg-holder').width();
      jQuery("#toolbar_title").css("top",jQuery(".msg-holder").offset().top - toolbarHeight + "px");
      jQuery("#toolbar_msg").css("top",jQuery(".msg-holder").offset().top + jQuery("#title").height() - toolbarHeight + "px");
      if(jQuery('.hebrew').length > 0) {
        jQuery("#toolbar_title").css("left",jQuery(".msg-holder").offset().left - hebrewOffset + "px");
        jQuery("#toolbar_msg").css("left",jQuery(".msg-holder").offset().left - hebrewOffset + "px");
      } else {
        jQuery("#toolbar_title").css("left",jQuery(".msg-holder").offset().left + "px");
        jQuery("#toolbar_msg").css("left",jQuery(".msg-holder").offset().left + "px");
      }
    }
  },

  initToolbars: function() {
    jQuery('#toolbar_title li.a-l a').click(function(){
        jQuery('#title').css('text-align','left');
        jQuery('#event_title_text_align').val('left');
        jQuery(".background_holder .title_holder, .background_holder .title").css("text-align","left");
        return false;
    });
    jQuery('#toolbar_title li.a-c a').click(function(){
        jQuery('#title').css("text-align","center");
        jQuery('#event_title_text_align').val('center');
        jQuery(".background_holder .title_holder, .background_holder .title").css("text-align","center");
        return false;
    });
    jQuery('#toolbar_title li.a-r a').click(function(){
        jQuery('#title').css("text-align","right");
        jQuery('#event_title_text_align').val('right');
        jQuery(".background_holder .title_holder, .background_holder .title").css("text-align","right");
        return false;
    });
    jQuery('#toolbar_msg li.a-l a').click(function(){
        jQuery('#free_text').css("text-align","left");
        jQuery('#event_msg_text_align').val('left');
        jQuery(".msg").css("text-align","left");
        return false;
    });
    jQuery('#toolbar_msg li.a-c a').click(function(){
        jQuery('#free_text').css("text-align","center");
        jQuery('#event_msg_text_align').val('center');
        jQuery(".msg").css("text-align","center");
        return false;
    });
    jQuery('#toolbar_msg li.a-r a').click(function(){
        jQuery('#free_text').css("text-align","right");
        jQuery('#event_msg_text_align').val('right');
        jQuery(".msg").css("text-align","right");
        return false;
    });
    jQuery('#toolbar_title a.font-plus').click(function(){
        stage2.max_title_font_size++;
        var curr = stage2.curr_title_font_size;
        stage2.calcFontSize();
        if(curr == stage2.curr_title_font_size)
            stage2.max_title_font_size--;
        return false;
    });
    jQuery('#toolbar_title a.font-minus').click(function(){
        stage2.max_title_font_size--;
        stage2.calcFontSize();
        return false;
    });
    jQuery('#toolbar_msg a.font-plus').click(function(){
        stage2.max_free_text_font_size++;
        var curr = stage2.curr_free_text_font_size;
        stage2.calcFontSize();
        if(curr == stage2.curr_free_text_font_size)
            stage2.max_free_text_font_size--;
        return false;
    });
    jQuery('#toolbar_msg a.font-minus').click(function(){
        stage2.max_free_text_font_size--;
        stage2.calcFontSize();
        return false;
    });
    jQuery('.selectOptions.select_title a, .selectOptions.select_msg a, #toolbar_title .selectArea .center, #toolbar_msg .selectArea .center').each(function(){
        jQuery(this).css("font-family", jQuery(this).html());
    });
    jQuery("#select_title").change(function(){
        var currSelected = jQuery("#toolbar_title .selectArea .center");
        currSelected.css("font-family",currSelected.html());
        jQuery('#free_text, .msg, .background_holder .title_holder, .background_holder .title, #title').css("font-family",currSelected.html());
        jQuery("#event_font").val(currSelected.html());
        jQuery('.selectOptions.select_msg a').each(function(){
            if(jQuery(this).html() == jQuery("#toolbar_title .selectArea .center").html()){
                if(jQuery(this).parent("li").hasClass("selected"))
                    return;
                jQuery('.selectOptions').hide();
                jQuery(this).click();
                return;
            }
        });
    });
    jQuery("#select_msg").change(function(){
        var currSelected = jQuery("#toolbar_msg .selectArea .center");
        currSelected.css("font-family",currSelected.html());
        jQuery('#free_text, .msg, .background_holder .title_holder, .background_holder .title, #title').css("font-family",currSelected.html());
        jQuery("#event_font").val(currSelected.html());
        jQuery('.selectOptions.select_title a').each(function(){
            if(jQuery(this).html() == jQuery("#toolbar_msg .selectArea .center").html()){
                if(jQuery(this).parent("li").hasClass("selected"))
                    return;
                jQuery('.selectOptions').hide();
                jQuery(this).click();
                return;
            }
        });
    });
    var currFont = jQuery("#free_text").css("font-family");
    jQuery('.selectOptions.select_msg a').each(function(){
        if(jQuery(this).html() == currFont)
            jQuery(this).click();
    });
    jQuery("#pallete_title").change(function(){
        jQuery('.background_holder .title_holder, .background_holder .title, #title').css("color",jQuery(this).val());
        jQuery("#event_title_color").val(jQuery(this).val());
    });
    jQuery("#pallete_title").colorPicker();
    if(jQuery("#event_title_color").val().length > 0)
        jQuery("#pallete_title").val(jQuery("#event_title_color").val()).change();

    jQuery("#pallete_msg").change(function(){
        jQuery('#free_text, .msg').css("color",jQuery(this).val());
        jQuery("#event_msg_color").val(jQuery(this).val());
    });
    jQuery("#pallete_msg").colorPicker();
    if(jQuery("#event_msg_color").val().length > 0)
        jQuery("#pallete_msg").val(jQuery("#event_msg_color").val()).change();
  }
}
jQuery(document).ready(function(){
  jQuery('select').customSelect();
  stage2.seperated_title = (jQuery(".title-holder").length == 1);
  stage2.initToolbars();

  if(jQuery("#event_starting_at_day").val() != "" && jQuery("#event_starting_at_month").val() != "" && jQuery("#event_starting_at_year").val() != "") {
    jQuery("#starting_at_mock").val(jQuery("#event_starting_at_day").val() + "." + jQuery("#event_starting_at_month").val() + "." + jQuery("#event_starting_at_year").val());
  }
  if(jQuery("#event_ending_at_day").val() != "" && jQuery("#event_ending_at_month").val() != "" && jQuery("#event_ending_at_year").val() != "") {
    jQuery("#ending_at_mock").val(jQuery("#event_ending_at_day").val() + "." + jQuery("#event_ending_at_month").val() + "." + jQuery("#event_ending_at_year").val());
  }
  if(jQuery("#ending_at_mock").val() == "" && jQuery("#event_ending_at_4i").val() == "" && jQuery("#event_ending_at_5i").val() == "")
    jQuery('.ending_at_block, .show_ending_at, .hide_ending_at').toggle();
  stage2.max_title_font_size = parseInt(jQuery("#title").css("font-size"));
  stage2.max_free_text_font_size = parseInt(jQuery("#free_text").css("font-size"));
  stage2.title_scroll_width = jQuery("#title")[0].scrollWidth;
  stage2.free_text_scroll_width = jQuery("#free_text")[0].scrollWidth;
  stage2.location = jQuery("#event_location_name").val();
  if(jQuery("#event_guest_message").html().length == 0){
    stage2.setDateInMessage();
    stage2.setTimeInMessage();
  }
  stage2.startDate = jQuery("#starting_at_mock").val();
  stage2.startTime = (jQuery("#event_starting_at_4i").val().length > 0 && jQuery("#event_starting_at_5i").val().length > 0) ? jQuery("#event_starting_at_4i").val() + ":" + jQuery("#event_starting_at_5i").val() : "";
  stage2.message = jQuery("#event_guest_message").val();
  stage2.preview_text("event_guest_message", "free_text");
  stage2.preview_text("event_name", "title");
  jQuery("#event_name").keyup(function(){
    stage2.preview_text("event_name", "title");
  });
  jQuery("#event_guest_message").click(function(){
    stage2.selectAllSafeValue(stage2.startDate);
    stage2.selectAllSafeValue(stage2.startTime);
  });

  jQuery("#event_guest_message").keyup(function(){
    if(stage2.startDate.length > 0 && jQuery(this).val().search(stage2.startDate) < 0) {
      alert(stage2.del_date_alert);
      jQuery(this).val(stage2.message);
    } else if(stage2.startTime.length > 0 && jQuery(this).val().search(stage2.startTime) < 0) {
      alert(stage2.del_time_alert);
      jQuery(this).val(stage2.message);
    } else {
      stage2.message = jQuery(this).val();
      stage2.preview_text("event_guest_message", "free_text");
    }
  });
  stage2.months_arr = stage2.months_arr.splice(1,13);
  jQuery("#event_starting_at_4i,#event_starting_at_5i").change(stage2.setTimeInMessage);
  cal1 = new Calendar({ starting_at_mock: {starting_at_mock: 'j.n.Y', event_starting_at_year: 'Y', event_starting_at_month: 'm', event_starting_at_day: 'd' } }, { classes: ['i-heart-ny','prev_month','next_month'], direction: 0.5, months: stage2.months_arr, onHideStart: stage2.setDateInMessage });
  cal2 = new Calendar({ ending_at_mock: {ending_at_mock: 'j.n.Y', event_ending_at_year: 'Y', event_ending_at_month: 'm', event_ending_at_day: 'd' } }, { classes: ['i-heart-ny','prev_month','next_month'], direction: 0.5, months: stage2.months_arr });
  jQuery("#event_guest_message").focus(function(){
    if(stage2.seperated_title)
      jQuery(".msg-holder").css("border", "1px dashed red");
    else
      jQuery("#free_text").css("border", "1px dashed red");
    stage2.setToolbarsPosition();
    jQuery('#toolbar_msg').css("visibility", "visible");
  });
  jQuery("#event_guest_message").blur(function(){
    if(stage2.seperated_title)
      jQuery(".msg-holder").css("border", "");
    else
      jQuery("#free_text").css("border", "");
  });
  jQuery("#event_name").focus(function(){
    if(stage2.seperated_title)
      jQuery(".title-holder").css("border", "1px dashed red");
    else
      jQuery("#title").css("border", "1px dashed red");
    stage2.setToolbarsPosition();
    jQuery('#toolbar_title').css("visibility", "visible");
  });
  jQuery("#event_name").blur(function(){
    if(stage2.seperated_title)
      jQuery(".title-holder").css("border", "");
    else
      jQuery("#title").css("border", "");
  });
  jQuery("#title,#free_text").css("cursor", "pointer");
  jQuery("#title").click(function(){
    jQuery("#event_name").focus();
  });
  jQuery("#free_text").click(function(){
    jQuery("#event_guest_message").focus();
  });
  jQuery(document).bind('mousedown', function(e){
    e = e || event;
    var t = e.target || e.srcElement;
    t = jQuery(t);
    var clickedColorPallete = t.parents("#color_selector").length > 0;
    var clickedElsewhere = (jQuery.inArray(t.attr("id"), ['toolbar_msg', 'event_guest_message', 'free_text']) == -1) && t.parents('#toolbar_msg, #event_guest_message, #free_text, .selectOptions.select_msg').length == 0;
    if(!clickedColorPallete) {
        if(clickedElsewhere && jQuery('#toolbar_msg').css("visibility") == "visible"){
            jQuery('#toolbar_msg').css("visibility", "hidden");
        }else if(!clickedElsewhere && jQuery('#toolbar_msg').css("visibility") == "hidden"){
            stage2.setToolbarsPosition();
            jQuery('#toolbar_msg').css("visibility", "visible");
        }
    }
    var clickedElsewhere = (jQuery.inArray(t.attr("id"),['toolbar_title', 'event_name', 'title']) == -1) && t.parents('#toolbar_title, #event_name, #title, .selectOptions.select_title').length == 0;;
    if(!clickedColorPallete) {
        if(clickedElsewhere && jQuery('#toolbar_title').css("visibility") == "visible"){
            jQuery('#toolbar_title').css("visibility", "hidden");
        }else if (!clickedElsewhere && jQuery('#toolbar_title').css("visibility") == "hidden"){
            stage2.setToolbarsPosition();
            jQuery('#toolbar_title').css("visibility", "visible");
        }
    }
  });
  jQuery(".form input:first").focus();
	jQuery("#event_map_link").focus(function(){
		if ("" == jQuery(this).val()) {
			jQuery(this).val("http://");
		}
		return true;
	})
  jQuery('#find_address').click(function(){
	var addr = jQuery('#event_location_address').val();
	if(addr.length == 0 || addr == jQuery(this).attr('ex_text')){
		alert(jQuery(this).attr('alert'));
		return false;}
	jQuery(this).attr('href','http://maps.google.com/?hl=he&q=' + addr)
  });
});
