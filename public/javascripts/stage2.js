var stage2 = {
  curr_title_font_size: 0,
  curr_free_text_font_size: 0,
  title_scroll_width: 0,
  free_text_scroll_width: 0,
  months_arr: [],
  seperated_title: false,
  prev_text: "",

  isTextOverflow: function() {
    var overflow = false;
    stage2.curr_free_text_font_size = parseInt(jQuery("#free_text").css("font-size"));
    stage2.curr_title_font_size = parseInt(jQuery("#title").css("font-size"));
    if(!stage2.seperated_title) {
      if(jQuery(".msg-holder").height() < (jQuery("#free_text").height() + jQuery("#title").height())) {
        overflow = true;
      }
    } else {
      if(jQuery(".msg-holder").height() < jQuery("#free_text").height()) {
        overflow = true;
      }
      if(jQuery(".title-holder").height() < jQuery("#title").height()) {
        overflow = true;
      }
    }
    if(jQuery("#title")[0].scrollWidth > stage2.title_scroll_width) {
        overflow = true;
    }
    if(jQuery("#free_text")[0].scrollWidth > stage2.free_text_scroll_width) {
        overflow = true;
    }
    return overflow;
  },

  change_font_size_by: function(delta, id) {
    var new_font_size = parseInt(jQuery("#" + id).css("font-size")) + delta;
    jQuery("#" + id).css("font-size", new_font_size + "px");
    if(id == "title") {
      jQuery("#event_title_font_size").val(new_font_size);
      jQuery(".background_holder .title_holder, .background_holder .title").css("font-size", new_font_size + "px");
    } else {
      jQuery("#event_msg_font_size").val(new_font_size);
      jQuery(".background_holder .msg").css("font-size", new_font_size + "px");
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
    text = text.replace(/\n/g,"<BR/>").replace(/ /g, "&nbsp;");
    jQuery("#" + targetId).html(text);
    stage2.setOverflowWarning();
    stage2.setToolbarsPosition();
  },
  setToolbarsPosition: function() {
    var toolbarHeight = 22;
    if(stage2.seperated_title){
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
    }else{
      var hebrewOffset = jQuery('#toolbar_title').width() + 10 - jQuery('.msg-holder').width();
      jQuery("#toolbar_title").css("top",jQuery(".msg-holder").offset().top - toolbarHeight + "px");
      jQuery("#toolbar_msg").css("top",jQuery(".msg-holder").offset().top + jQuery("#title").height() + jQuery("#free_text").height() + 3 + "px");
      if(jQuery('.hebrew').length > 0) {
        jQuery("#toolbar_title").css("left",jQuery(".msg-holder").offset().left - hebrewOffset + "px");
        jQuery("#toolbar_msg").css("left",jQuery(".msg-holder").offset().left - hebrewOffset + "px");
      } else {
        jQuery("#toolbar_title").css("left",jQuery(".msg-holder").offset().left + "px");
        jQuery("#toolbar_msg").css("left",jQuery(".msg-holder").offset().left + "px");
      }
    }
  },

  setOverflowWarning: function() {
    if(stage2.isTextOverflow())
        jQuery(".overflow_warning").show();
    else
        jQuery(".overflow_warning").hide();
  },

  showTitleBorder: function() {
    var selector = stage2.seperated_title ? ".title-holder" : "#title";
    jQuery(selector).css("border", "1px dashed red");
  },
  showMsgBorder: function() {
    var selector = stage2.seperated_title ? ".msg-holder" : "#free_text";
    jQuery(selector).css("border", "1px dashed red");
  },
  hideTitleBorder: function() {
    var selector = stage2.seperated_title ? ".title-holder" : "#title";
    jQuery(selector).css("border", "");
  },
  hideMsgBorder: function() {
    var selector = stage2.seperated_title ? ".msg-holder" : "#free_text";
    jQuery(selector).css("border", "");
  },

  initToolbars: function() {
    jQuery('#toolbar_title li.a-l a').click(function(){
        jQuery('#title').css('text-align','left');
        jQuery('#event_title_text_align').val('left');
        jQuery(".background_holder .title_holder, .background_holder .title").css("text-align","left");
        stage2.showTitleBorder();
        stage2.setToolbarsPosition();
        return false;
    });
    jQuery('#toolbar_title li.a-c a').click(function(){
        jQuery('#title').css("text-align","center");
        jQuery('#event_title_text_align').val('center');
        jQuery(".background_holder .title_holder, .background_holder .title").css("text-align","center");
        stage2.showTitleBorder();
        stage2.setToolbarsPosition();
        return false;
    });
    jQuery('#toolbar_title li.a-r a').click(function(){
        jQuery('#title').css("text-align","right");
        jQuery('#event_title_text_align').val('right');
        jQuery(".background_holder .title_holder, .background_holder .title").css("text-align","right");
        stage2.showTitleBorder();
        stage2.setToolbarsPosition();
        return false;
    });
    jQuery('#toolbar_msg li.a-l a').click(function(){
        jQuery('#free_text').css("text-align","left");
        jQuery('#event_msg_text_align').val('left');
        jQuery(".msg").css("text-align","left");
        stage2.showMsgBorder();
        stage2.setToolbarsPosition();
        return false;
    });
    jQuery('#toolbar_msg li.a-c a').click(function(){
        jQuery('#free_text').css("text-align","center");
        jQuery('#event_msg_text_align').val('center');
        jQuery(".msg").css("text-align","center");
        stage2.showMsgBorder();
        stage2.setToolbarsPosition();
        return false;
    });
    jQuery('#toolbar_msg li.a-r a').click(function(){
        jQuery('#free_text').css("text-align","right");
        jQuery('#event_msg_text_align').val('right');
        jQuery(".msg").css("text-align","right");
        stage2.showMsgBorder();
        stage2.setToolbarsPosition();
        return false;
    });
    jQuery('#toolbar_title a.font-plus').click(function(){
        stage2.change_font_size_by(1, "title");
        stage2.setOverflowWarning();
        stage2.showTitleBorder();
        stage2.setToolbarsPosition();
        return false;
    });
    jQuery('#toolbar_title a.font-minus').click(function(){
        stage2.change_font_size_by(-1, "title");
        stage2.setOverflowWarning();
        stage2.showTitleBorder();
        stage2.setToolbarsPosition();
        return false;
    });
    jQuery('#toolbar_msg a.font-plus').click(function(){
        stage2.change_font_size_by(1, "free_text");
        stage2.setOverflowWarning();
        stage2.showMsgBorder();
        stage2.setToolbarsPosition();
        return false;
    });
    jQuery('#toolbar_msg a.font-minus').click(function(){
        stage2.change_font_size_by(-1, "free_text");
        stage2.setOverflowWarning();
        stage2.showMsgBorder();
        stage2.setToolbarsPosition();
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
        stage2.setOverflowWarning();
        stage2.showTitleBorder();
        stage2.setToolbarsPosition();
    });
    jQuery("#select_msg").change(function(){
        var currSelected = jQuery("#toolbar_msg .selectArea .center");
        currSelected.css("font-family",currSelected.html());
        jQuery('#free_text, .msg').css("font-family",currSelected.html());
        jQuery("#event_font_body").val(currSelected.html());
        stage2.setOverflowWarning();
        stage2.showMsgBorder();
        stage2.setToolbarsPosition();
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
  },
  show_ending_at_block: function() {
    jQuery('.show_ending_at, .hide_ending_at').toggle();
    jQuery('.ending_at_block').css('visibility','visible');
    jQuery('fieldset.location_section').css('margin-top', '0px');
        if ("" == jQuery("#ending_at_mock").val()) {
            stage2.set_ending_at(stage2.starting_at());
        }
  },

  hide_ending_at_block: function() {
    jQuery('.show_ending_at, .hide_ending_at').toggle();
    jQuery('.ending_at_block').css('visibility','hidden');
    jQuery('fieldset.location_section').css('margin-top', '-81px');
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

    setScrollWidths: function() {
        var title_bk = jQuery("#title").html();
        var free_text_bk = jQuery("#free_text").html();
        jQuery("#title").html("");
        jQuery("#free_text").html("");
        stage2.title_scroll_width = jQuery("#title")[0].scrollWidth;
        stage2.free_text_scroll_width = jQuery("#free_text")[0].scrollWidth;
        jQuery("#title").html(title_bk);
        jQuery("#free_text").html(free_text_bk);
    }
}
jQuery(document).ready(function(){
  jQuery(".starting_at_time_select select.short:first").addClass("marg");
  jQuery(".ending_at_time_select select.short:first").addClass("marg");
  jQuery('select').customSelect();
  stage2.seperated_title = (jQuery(".title-holder").length == 1);
  stage2.initToolbars();
  stage2.hideMsgBorder();
  stage2.hideTitleBorder();
  if(jQuery("#event_starting_at_day").val() != "" && jQuery("#event_starting_at_month").val() != "" && jQuery("#event_starting_at_year").val() != "") {
    jQuery("#starting_at_mock").val(jQuery("#event_starting_at_day").val() + "." + jQuery("#event_starting_at_month").val() + "." + jQuery("#event_starting_at_year").val());
  }
  if(jQuery("#event_ending_at_day").val() != "" && jQuery("#event_ending_at_month").val() != "" && jQuery("#event_ending_at_year").val() != "") {
    jQuery("#ending_at_mock").val(jQuery("#event_ending_at_day").val() + "." + jQuery("#event_ending_at_month").val() + "." + jQuery("#event_ending_at_year").val());
  }
  if(jQuery("#ending_at_mock").val() == "" && jQuery("#event_ending_at_4i").val() == "" && jQuery("#event_ending_at_5i").val() == "") {
    stage2.hide_ending_at_block();
  }

  stage2.setScrollWidths();

  stage2.location = jQuery("#event_location_name").val();
  stage2.startDate = jQuery("#starting_at_mock").val();
  stage2.startTime = (jQuery("#event_starting_at_4i").val().length > 0 && jQuery("#event_starting_at_5i").val().length > 0) ? jQuery("#event_starting_at_4i").val() + ":" + jQuery("#event_starting_at_5i").val() : "";

  clearInputs("event_user_attributes_name");
  clearInputs("event_user_attributes_email");
  clearInputs("event_name");
  clearInputs("event_location_name");
  clearInputs("event_location_address");
  clearInputs("event_invitation_title");
  clearInputs("event_guest_message");

  stage2.preview_text("event_guest_message", "free_text");
  stage2.preview_text("event_invitation_title", "title");
  jQuery("#event_invitation_title").blur(function(){
    stage2.preview_text("event_invitation_title", "title");
  });
  jQuery("#event_invitation_title").focus(function(){
    stage2.preview_text("event_invitation_title", "title");
  });
  jQuery("#event_invitation_title").keyup(function(){
    stage2.preview_text("event_invitation_title", "title");
  });
  jQuery("#event_guest_message").blur(function(){
    stage2.preview_text("event_guest_message", "free_text");
  });
  jQuery("#event_guest_message").focus(function(){
    stage2.preview_text("event_guest_message", "free_text");
  });
  jQuery("#event_guest_message").keyup(function(){
    stage2.preview_text("event_guest_message", "free_text");
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
    stage2.showMsgBorder();
    stage2.setToolbarsPosition();
    jQuery('#toolbar_msg').css("visibility", "visible");
  });
  jQuery("#event_guest_message").blur(function(){
    stage2.hideMsgBorder();
  });
  jQuery("#event_invitation_title").focus(function(){
    stage2.showTitleBorder();
    stage2.setToolbarsPosition();
    jQuery('#toolbar_title').css("visibility", "visible");
  });
  jQuery("#event_invitation_title").blur(function(){
    stage2.hideTitleBorder();
    var selector = stage2.seperated_title ? ".title-holder" : "#title";
    jQuery(selector).css("border", "");
  });
  jQuery("#title,#free_text").css("cursor", "pointer");
  jQuery("#title").click(function(){
    jQuery("#event_invitation_title").focus();
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
    var clickedElsewhere = (jQuery.inArray(t.attr("id"),['toolbar_title', 'event_invitation_title', 'title']) == -1) && t.parents('#toolbar_title, #event_invitation_title, #title, .selectOptions.select_title').length == 0;;
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
        jQuery('#event_location_address').focus();
        return false;
    }
    jQuery(this).attr('href','http://maps.google.com/?hl=he&t=m&q=' + addr)
  });
});
