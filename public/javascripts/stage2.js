var stage2 = {
  max_title_font_size: 0,
  max_free_text_font_size: 0,
  curr_title_font_size: 0,
  curr_free_text_font_size: 0,
  months_arr: [],
  prev_event_invitation_title: "",
  prev_event_guest_message: "",
  title_first_font_change: false,
  msg_first_font_change: false,
  workingOnTitle: false,
  workingOnMsg: false,
  justChangedTitle: false,
  justChangedMsg: false,
  delayedShowMsgBorder: null,
  delayedShowTitleBorder: null,
  cancelTitleBlur: false,
  cancelMsgBlur: false,

  isTextOverflow: function() {
    var overflow = false;
    stage2.curr_free_text_font_size = parseInt(jQuery("#free_text").css("font-size"));
    stage2.curr_title_font_size = parseInt(jQuery("#title").css("font-size"));
    stage2.title_clone.scrollTop(1);
    if(stage2.title_clone.scrollTop() == 1) {
      overflow = true;
    }
    stage2.free_text_clone.scrollTop(1);
    if(stage2.free_text_clone.scrollTop() == 1) {
      overflow = true;
    }
    stage2.free_text_clone.scrollLeft(-1);
    if(stage2.free_text_clone.scrollLeft() == -1) {
      overflow = true;
    }
    stage2.title_clone.scrollLeft(-1);
    if(stage2.title_clone.scrollLeft() == -1) {
      overflow = true;
    }
    return overflow;
  },
  change_font_size_by: function(delta, id) {
    var new_font_size = parseInt(jQuery("#" + id).css("font-size")) + delta;
    jQuery("#" + id).css("font-size", new_font_size + "px");
    if(id == "title") {
      jQuery("#event_title_font_size").val(new_font_size);
      jQuery(".background_holder .title_holder").css("font-size", new_font_size + "px");
      stage2.cloneTextBoxes('.title-holder', 'title');
    } else {
      jQuery("#event_msg_font_size").val(new_font_size);
      jQuery(".background_holder .msg_holder").css("font-size", new_font_size + "px");
      stage2.cloneTextBoxes('.msg-holder', 'free_text');
    }
    stage2["curr_" + id + "_font_size"] = parseInt(jQuery("#" + id).css("font-size"));
  },

  preview_text: function(sourceId, targetId, allowOverFlow) {
    var text = jQuery("#" + sourceId).val();
    if(stage2["prev" + sourceId] == text) return;
    stage2["prev" + sourceId] = text;
    var findReplace = [[/&/g, "&amp;"], [/</g, "&lt;"], [/>/g, "&gt;"], [/ /g, "&nbsp;"], [/\n/g, "<BR />"]]
    for(var i = 0; i < findReplace.length; i++)//it's important to do the replaces in the order of the array
      text = text.replace(findReplace[i][0], findReplace[i][1]);
    jQuery("#" + targetId).html(text);
    stage2[targetId + "_clone"].html(text);
    if(!allowOverFlow) {
      protectionCounter = 0;
      while(stage2.isTextOverflow() && protectionCounter < 20) {
        stage2.change_font_size_by(-1, targetId);
        protectionCounter++;
      }
    }
    stage2.setOverflowWarning();
    stage2.setToolbarsPosition();
  },
  setToolbarsPosition: function() {
    var toolbarHeight = 22;
    var hebrewOffsetTitle = jQuery('#toolbar_title').width() + 10 - jQuery('.title-holder').width();
    var hebrewOffsetMsg = jQuery('#toolbar_msg').width() + 10 - jQuery('.msg-holder').width();
    jQuery("#toolbar_title").css("top",jQuery(".title-holder").offset().top - toolbarHeight + "px");
    jQuery("#toolbar_msg").css("top",jQuery(".msg-holder").offset().top + jQuery(".msg-holder").height() + 3 + "px");
    if(jQuery('.hebrew').length > 0) {
      jQuery("#toolbar_title").css("left",jQuery(".title-holder").offset().left - hebrewOffsetTitle + "px");
      jQuery("#toolbar_msg").css("left",jQuery(".msg-holder").offset().left - hebrewOffsetMsg + "px");
    } else {
      jQuery("#toolbar_title").css("left",jQuery(".title-holder").offset().left + "px");
      jQuery("#toolbar_msg").css("left",jQuery(".msg-holder").offset().left + "px");
    }
  },

  setOverflowWarning: function() {
    if(stage2.isTextOverflow())
        jQuery(".overflow_warning").show();
    else
        jQuery(".overflow_warning").hide();
  },

  show_title_border: function() {
    jQuery(".title-holder").css("border", "1px dashed red");
    stage2.setToolbarsPosition();
    jQuery('#toolbar_title').css("visibility", "visible");
    stage2.hide_msg_border();
  },
  show_msg_border: function() {
    jQuery(".msg-holder").css("border", "1px dashed red");
    stage2.setToolbarsPosition();
    jQuery('#toolbar_msg').css("visibility", "visible");
    stage2.hide_title_border();
  },
  hide_title_border: function() {
    jQuery(".title-holder").css("border", "");
    jQuery('#toolbar_title').css("visibility", "hidden");
    stage2.workingOnTitle = false;
  },
  hide_msg_border: function() {
    jQuery(".msg-holder").css("border", "");
    jQuery('#toolbar_msg').css("visibility", "hidden");
    stage2.workingOnMsg = false;
  },
  alignTitle: function(align) {
    jQuery('#title-holder').css('text-align',align);
    jQuery('#event_title_text_align').val(align);
    jQuery(".background_holder .title_holder").css("text-align",align);
    stage2.show_title_border();
    jQuery.fn.unload_monit_set();
  },

  alignMsg: function(align) {
    jQuery('#msg-holder').css("text-align",align);
    jQuery('#event_msg_text_align').val(align);
    jQuery(".msg_holder").css("text-align",align);
    stage2.show_msg_border();
    jQuery.fn.unload_monit_set();
  },

  initToolbars: function() {
    jQuery('#toolbar_title li.a-l a').click(function(){
        stage2.alignTitle("left")
        return false;
    });
    jQuery('#toolbar_title li.a-c a').click(function(){
        stage2.alignTitle("center")
        return false;
    });
    jQuery('#toolbar_title li.a-r a').click(function(){
        stage2.alignTitle("right")
        return false;
    });
    jQuery('#toolbar_msg li.a-l a').click(function(){
        stage2.alignMsg("left")
        return false;
    });
    jQuery('#toolbar_msg li.a-c a').click(function(){
        stage2.alignMsg("center")
        return false;
    });
    jQuery('#toolbar_msg li.a-r a').click(function(){
        stage2.alignMsg("right")
        return false;
    });

    jQuery('#toolbar_title a.font-plus').click(function(){
        stage2.change_font_size_by(1, "title");
        stage2.setOverflowWarning();
        stage2.show_title_border();
        jQuery.fn.unload_monit_set();
        return false;
    });
    jQuery('#toolbar_title a.font-minus').click(function(){
        stage2.change_font_size_by(-1, "title");
        stage2.setOverflowWarning();
        stage2.show_title_border();
        jQuery.fn.unload_monit_set();
        return false;
    });
    jQuery('#toolbar_msg a.font-plus').click(function(){
        stage2.change_font_size_by(1, "free_text");
        stage2.setOverflowWarning();
        stage2.show_msg_border();
        jQuery.fn.unload_monit_set();
        return false;
    });
    jQuery('#toolbar_msg a.font-minus').click(function(){
        stage2.change_font_size_by(-1, "free_text");
        stage2.setOverflowWarning();
        stage2.show_msg_border();
        jQuery.fn.unload_monit_set();
        return false;
    });
    jQuery('.selectOptions.select_title a, .selectOptions.select_msg a, #toolbar_title .selectArea .center, #toolbar_msg .selectArea .center').each(function(){
        jQuery(this).css("font-family", jQuery(this).html());
    });
    jQuery("#select_title").change(function(){
        var currSelected = jQuery("#toolbar_title .selectArea .center");
        currSelected.css("font-family",currSelected.html());
        jQuery('.background_holder .title_holder, .background_holder .title, #title').css("font-family",currSelected.html());
        jQuery("#event_font_title").val(currSelected.html());
        stage2.cloneTextBoxes('.title-holder', 'title');
        stage2.setOverflowWarning();
        stage2.show_title_border();
        stage2.justChangedTitle = true;
        stage2.workingOnTitle = false;
        if(stage2.title_first_font_change){
          jQuery.fn.unload_monit_set();
        }
        stage2.title_first_font_change = true;
    });
    jQuery("#select_msg").change(function(){
        var currSelected = jQuery("#toolbar_msg .selectArea .center");
        currSelected.css("font-family",currSelected.html());
        jQuery('#free_text, .msg').css("font-family",currSelected.html());
        jQuery("#event_font_body").val(currSelected.html());
        stage2.cloneTextBoxes('.msg-holder', 'free_text');
        stage2.setOverflowWarning();
        stage2.show_msg_border();
        stage2.justChangedMsg = true;
        stage2.workingOnMsg = false;
        if(stage2.msg_first_font_change){
          jQuery.fn.unload_monit_set();
        }
        stage2.msg_first_font_change = true;
    });
    var msgFont = jQuery("#free_text").css("font-family");
    jQuery('.selectOptions.select_msg a').each(function(){
        if(jQuery(this).html() == msgFont)
            jQuery(this).click();
    });
    var titleFont = jQuery("#title").css("font-family");
    jQuery('.selectOptions.select_title a').each(function(){
        if(jQuery(this).html() == titleFont)
            jQuery(this).click();
    });
    jQuery("#pallete_title").change(function(){
        jQuery('.background_holder .title_holder, .background_holder .title, #title').css("color",jQuery(this).val());
        jQuery("#event_title_color").val(jQuery(this).val());
        jQuery.fn.unload_monit_set();
        stage2.justChangedTitle = true;
        stage2.workingOnTitle = false;
    });
    jQuery("#pallete_title").colorPicker();
    if(jQuery("#event_title_color").val().length > 0)
        jQuery("#pallete_title").val(jQuery("#event_title_color").val()).change();

    jQuery("#pallete_msg").change(function(){
        jQuery('#free_text, .msg').css("color",jQuery(this).val());
        jQuery("#event_msg_color").val(jQuery(this).val());
        jQuery.fn.unload_monit_set();
        stage2.justChangedMsg = true;
        stage2.workingOnMsg = false;
    });
    jQuery("#pallete_msg").colorPicker();
    if(jQuery("#event_msg_color").val().length > 0)
        jQuery("#pallete_msg").val(jQuery("#event_msg_color").val()).change();
  },
  show_ending_at_block: function() {
    jQuery('.show_ending_at, .hide_ending_at').toggle();
    jQuery('.ending_at_block').css('display','block');
    if ("" == jQuery("#ending_at_mock").val()) {
        stage2.set_ending_at(stage2.starting_at());
    }
  },

  hide_ending_at_block: function() {
    jQuery('.show_ending_at, .hide_ending_at').toggle();
    jQuery('.ending_at_block').css('display','none');
    jQuery("#ending_at_mock").val("");
    jQuery("#event_ending_at_year").val("");
    jQuery("#event_ending_at_month").val("");
    jQuery("#event_ending_at_day").val("");
    jQuery("#event_ending_at_4i").val("");
    jQuery("#event_ending_at_5i").val("");
    jQuery("#event_ending_at_4i").prev(".selectArea").find(".center").html('');
    jQuery("#event_ending_at_5i").prev(".selectArea").find(".center").html('');
  },

  starting_at: function() {
    var start_date = jQuery("#starting_at_mock").val().split(".");
    start_date.push(jQuery("#event_starting_at_4i").val());
    start_date.push(jQuery("#event_starting_at_5i").val());
    return new Date(start_date[2], start_date[1], start_date[0], start_date[3], start_date[4]);
  },

  ending_at: function () {
    var ending_date = jQuery("#ending_at_mock").val().split(".");
    ending_date.push(jQuery("#event_ending_at_4i").val());
    ending_date.push(jQuery("#event_ending_at_5i").val());
    return new Date(ending_date[2], ending_date[1], ending_date[0], ending_date[3], ending_date[4]);
  },

  set_ending_at: function(date) {
    var hrs = date.getHours().toString();
    if (hrs.length < 2) hrs = "0" + hrs;
    var min = date.getMinutes().toString();
    if (min.length < 2) min = "0" + min;
    jQuery("#ending_at_mock").val(jQuery("#starting_at_mock").val());
    jQuery("#event_ending_at_year").val(date.getFullYear());
    jQuery("#event_ending_at_month").val(date.getMonth() + 1);
    jQuery("#event_ending_at_day").val(date.getDate());
    jQuery("#event_ending_at_4i").val(hrs);
    jQuery("#event_ending_at_5i").val(min);
    jQuery("#event_ending_at_4i").prev(".selectArea").find(".center").html(hrs);
    jQuery("#event_ending_at_5i").prev(".selectArea").find(".center").html(min);
  },

  submit_form: function(is_resend_invitation) {
    jQuery('#event_resend_invitations').val(is_resend_invitation ? 'true' : '');
    jQuery.nyroModalRemove();
    jQuery('body').css('cursor', 'wait');
    jQuery('.form.new-event').submit();
  },

  previewMap: function() {
    if(jQuery("#map_holder img").length > 0) return;//there is a map image already shown
    var link = jQuery("#event_map_link").val()
    if(link == "") {
      jQuery("#map_box").hide();
      return;
    }
    if(link.indexOf("http") != 0) {
      link = "http://" + link;
      jQuery("#event_map_link").val(link)
    }
    jQuery("#map_holder").html("<iframe src='" + link + "'></iframe>");
    jQuery("#map_box").show();
  },
  setTextPosition: function(holder, otherElSelector, ui){
    jQuery.fn.unload_monit_set();
    jQuery('#event_' + holder + '_top_x').val(Math.ceil(ui.position.left*1.6));
    jQuery('#event_' + holder + '_top_y').val(Math.ceil(ui.position.top*1.6));
    jQuery(otherElSelector).css({
      top: ui.position.top,
      left: ui.position.left
    });
    if(ui.size){
      jQuery('#event_' + holder + '_width').val(Math.ceil(ui.size.width*1.6));
      jQuery('#event_' + holder + '_height').val(Math.ceil(ui.size.height*1.6));
      jQuery(otherElSelector).css({
        width: ui.size.width,
        height: ui.size.height
      });
    }
    stage2.setOverflowWarning();
  },

  cloneTextBoxes: function(parentSelector, target) {
    jQuery("#" + target + "_clone").remove();
    stage2[target + "_clone"] = jQuery('#' + target).clone().attr('id', target + '_clone').css({
      overflow: 'auto',
      visibility: 'hidden',
      height: jQuery(parentSelector).css('height'),
      width: jQuery(parentSelector).css('width'),
      paddingRight: 0,
      zIndex: -1
    }).appendTo(jQuery(parentSelector));
  },

  bindTitleEvents: function() {
    jQuery(".title-holder").mouseenter(function(){
      if(stage2.workingOnMsg) return;
      if(stage2.justChangedMsg) {
        if(stage2.delayedShowTitleBorder) return;
        stage2.delayedShowTitleBorder = setTimeout(function(){
          if(!stage2.workingOnMsg) {
            stage2.show_title_border();
            jQuery(".title-holder").css('z-index', '101');
          }
          stage2.justChangedMsg = false;
          stage2.delayedShowTitleBorder = null;
        }, 1000);
        return;
      }
      clearTimeout(stage2.delayedShowMsgBorder);
      stage2.delayedShowMsgBorder = null;
      stage2.show_title_border();
      jQuery(this).css('z-index', '101');
    }).mouseleave(function(){
      jQuery(this).css('z-index', '100');
    }).resizable({
      handles: 'all',
      autoHide: true,
      containment: 'parent',
      stop: function(event, ui){
        stage2.cloneTextBoxes('.title-holder', 'title');
        stage2.setTextPosition("title", ".title_holder", ui);
        stage2.setToolbarsPosition();
        stage2.workingOnTitle = false;
      },
      start: function(event, ui){
        stage2.workingOnTitle = true;
      }
    }).draggable({
      containment: 'parent',
      stop: function(event, ui){
        stage2.setTextPosition("title", ".title_holder", ui);
        stage2.setToolbarsPosition();
        stage2.workingOnTitle = false;
      },
      start: function(event, ui){
        stage2.workingOnTitle = true;
      }
    });
  },
  bindMsgEvents: function() {
    jQuery(".msg-holder").mouseenter(function(){
      if(stage2.workingOnTitle) return;
      if(stage2.justChangedTitle) {
        if(stage2.delayedShowMsgBorder) return;
        stage2.delayedShowMsgBorder = setTimeout(function(){
          if(!stage2.workingOnTitle) stage2.show_msg_border();
          stage2.justChangedTitle = false;
          stage2.delayedShowMsgBorder = null;
        }, 1000);
        return;
      }
      clearTimeout(stage2.delayedShowTitleBorder);
      stage2.delayedShowTitleBorder = null;
      stage2.show_msg_border();
      jQuery(this).css('z-index', '101');
    }).mouseleave(function(){
      jQuery(this).css('z-index', '100');
    }).resizable({
      handles: 'all',
      autoHide: true,
      containment: 'parent',
      stop: function(event, ui){
        stage2.cloneTextBoxes('.msg-holder', 'free_text');
        stage2.setTextPosition("text", ".msg_holder", ui);
        stage2.setToolbarsPosition();
        stage2.workingOnMsg = false;
      },
      start: function(event, ui){
        stage2.workingOnMsg = true;
      }
    }).draggable({
      containment: 'parent',
      stop: function(event, ui){
        stage2.setTextPosition("text", ".msg_holder", ui);
        stage2.setToolbarsPosition();
        stage2.workingOnMsg = false;
      },
      start: function(event, ui){
        stage2.workingOnMsg = true;
      }
    });
  }
}
jQuery(document).ready(function(){
  jQuery(".starting_at_time_select select.short:first").addClass("marg");
  jQuery(".ending_at_time_select select.short:first").addClass("marg");
  jQuery('select').customSelect();
  stage2.cloneTextBoxes('.msg-holder', 'free_text');
  stage2.cloneTextBoxes('.title-holder', 'title');
  stage2.initToolbars();
  stage2.hide_msg_border();
  stage2.hide_title_border();
  stage2.bindMsgEvents();
  stage2.bindTitleEvents();
  stage2.previewMap();
  if(jQuery("#event_starting_at_day").val() != "" && jQuery("#event_starting_at_month").val() != "" && jQuery("#event_starting_at_year").val() != "") {
    jQuery("#starting_at_mock").val(jQuery("#event_starting_at_day").val() + "." + jQuery("#event_starting_at_month").val() + "." + jQuery("#event_starting_at_year").val());
  }
  if(jQuery("#event_ending_at_day").val() != "" && jQuery("#event_ending_at_month").val() != "" && jQuery("#event_ending_at_year").val() != "") {
    jQuery("#ending_at_mock").val(jQuery("#event_ending_at_day").val() + "." + jQuery("#event_ending_at_month").val() + "." + jQuery("#event_ending_at_year").val());
  }
  if(jQuery("#ending_at_mock").val() == "" && jQuery("#event_ending_at_4i").val() == "" && jQuery("#event_ending_at_5i").val() == "") {
    stage2.hide_ending_at_block();
  }

  stage2.location = jQuery("#event_location_name").val();
  stage2.startDate = jQuery("#starting_at_mock").val();
  stage2.startTime = (jQuery("#event_starting_at_4i").val().length > 0 && jQuery("#event_starting_at_5i").val().length > 0) ? jQuery("#event_starting_at_4i").val() + ":" + jQuery("#event_starting_at_5i").val() : "";

  clearInputs("event_user_attributes_name");
  clearInputs("event_user_attributes_email");
  clearInputs("event_name");
  clearInputs("event_location_name");
  clearInputs("event_location_address");
  clearInputs("event_invitation_title", ["event_guest_message"]);
  clearInputs("event_guest_message", ["event_invitation_title"]);

  stage2.preview_text("event_invitation_title", "title", !isInputFieldWithDefaultVal("event_invitation_title"));
  stage2.preview_text("event_guest_message", "free_text", !isInputFieldWithDefaultVal("event_guest_message"));

  jQuery("#event_invitation_title").bind("blur focus keyup", function(){
    stage2.preview_text("event_guest_message", "free_text", true);
    stage2.preview_text("event_invitation_title", "title", true);
  });
  jQuery("#event_guest_message").bind("blur focus keyup", function(){
    stage2.preview_text("event_invitation_title", "title", true);
    stage2.preview_text("event_guest_message", "free_text", true);
  });

  stage2.months_arr = stage2.months_arr.splice(1,13);
  cal1 = new Calendar(
        {
            starting_at_mock: {
                starting_at_mock: 'j.n.Y',
                event_starting_at_year: 'Y',
                event_starting_at_month: 'm',
                event_starting_at_day: 'd'
            },
            ending_at_mock: {
                ending_at_mock: 'j.n.Y',
                event_ending_at_year: 'Y',
                event_ending_at_month: 'm',
                event_ending_at_day: 'd'
            }
        },
        {
            classes: ['i-heart-ny','prev_month','next_month'],
            direction: 0.5,
            months: stage2.months_arr
        }
    );

    var old_start_date = stage2.starting_at();
    setInterval(function(){
        if (stage2.starting_at().getTime() == old_start_date.getTime()) {
            return;
        }
        jQuery("#starting_at_mock").trigger('change');
        if ('visible' == jQuery('.ending_at_block').css('visibility')) {
            if ("" == jQuery("#ending_at_mock").val()) {
                stage2.set_ending_at(stage2.starting_at());
            }
            else if (stage2.ending_at() < stage2.starting_at()) {
                stage2.set_ending_at(stage2.starting_at());
            }
        }
        old_start_date = stage2.starting_at();
    }, 200);
  jQuery("#event_guest_message").focus(function(){
    stage2.show_msg_border();
  });
  jQuery("#event_guest_message").blur(function(){
    if(stage2.cancelMsgBlur){
      stage2.cancelMsgBlur = false;
      return;
    }
    stage2.hide_msg_border();
  });
  jQuery("#toolbar_msg").mousedown(function(){
    stage2.cancelMsgBlur = true;
  });
  jQuery("#event_invitation_title").focus(function(){
    stage2.show_title_border();
  });
  jQuery("#toolbar_title").mousedown(function(){
    stage2.cancelTitleBlur = true;
  });
  jQuery("#event_invitation_title").blur(function(){
    if(stage2.cancelTitleBlur) {
      stage2.cancelTitleBlur = false;
      return;
    }
    stage2.hide_title_border();
  });

  jQuery(".title-holder").click(function(){
    jQuery("#event_invitation_title").focus();
  });
  jQuery(".msg-holder").click(function(){
    jQuery("#event_guest_message").focus();
  });
  
  stage2.bindTitleEvents();
  stage2.bindMsgEvents();

  jQuery(document).bind('mousedown', function(e){
    e = e || event;
    var t = e.target || e.srcElement;
    t = jQuery(t);
    var clickedColorPallete = t.parents("#color_selector").length > 0;
    var clickedElsewhere = (jQuery.inArray(t.attr("id"), ['toolbar_msg', 'event_guest_message', 'msg-holder']) == -1) && t.parents('#toolbar_msg, #event_guest_message, #msg-holder, .selectOptions.select_msg').length == 0;
    if(!clickedColorPallete) {
      if(clickedElsewhere && jQuery('#toolbar_msg').css("visibility") == "visible"){
        stage2.hide_msg_border();
      }else if(!clickedElsewhere && jQuery('#toolbar_msg').css("visibility") == "hidden"){
        stage2.show_msg_border();
      }
    }
    var clickedElsewhere = (jQuery.inArray(t.attr("id"),['toolbar_title', 'event_invitation_title', 'title-holder']) == -1) && t.parents('#toolbar_title, #event_invitation_title, #title-holder, .selectOptions.select_title').length == 0;;
    if(!clickedColorPallete) {
      if(clickedElsewhere && jQuery('#toolbar_title').css("visibility") == "visible"){
        stage2.hide_title_border();
      }else if (!clickedElsewhere && jQuery('#toolbar_title').css("visibility") == "hidden"){
        stage2.show_title_border();
      }
    }
  });
  jQuery(".form input:first").focus();
  jQuery('#find_address').click(function(){
    var addr = jQuery('#event_location_address').val();
    if(addr.length == 0 || addr == jQuery(this).attr('ex_text')){
        alert(jQuery(this).attr('alert'));
        jQuery('#event_location_address').focus();
        return false;
    }
    jQuery(this).attr('href','http://maps.google.com/?hl=he&t=m&q=' + addr)
  });
  set_counter("#event_invitation_title", "#event_invitation_title_input .inline-hints", 1024);
  set_counter("#event_guest_message", "#event_guest_message_input .inline-hints", 1024);
  jQuery(".side-area input, .side-area textarea").unload_monit();
  jQuery("#event_map_link").live("blur", function(){
    stage2.previewMap();
  });
  jQuery(".overflow_warning").draggable({
    opacity: 0.7,
    appendTo: 'body',
    zIndex: 200
  });
  if(typeof _gaq != 'undefined') {
    jQuery("input, textarea, select").focus(function(){
      _gaq.push(['_trackEvent', 'Event Form', this.name + '_focus', jQuery(this).val()]);
    });
    jQuery("input, textarea, select").change(function(){
      _gaq.push(['_trackEvent', 'Event Form', this.name + '_change', jQuery(this).val()]);
    });
  }
});
