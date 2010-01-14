var stage2 = {
  location: "",
  startDate: "",
  startTime: "",
  message: "",
  max_title_font_size: 0,
  max_free_text_font_size: 0,

  calcFontSize: function() {
//TODO: fix this
//    while(jQuery(".info-holder").width() < jQuery("#free_text").width()) {
//      stage2.change_font_size_by(-1);
//    }
//    while(jQuery(".info-holder").width() < jQuery("#title").width()) {
//      stage2.change_font_size_by(-1);
//    }
    while(parseInt(jQuery("#free_text").css("font-size")) < stage2.max_free_text_font_size && (jQuery(".info-holder").height() > (jQuery("#free_text").height() + jQuery("#title").height() + parseInt(jQuery("#free_text").css("line-height"))))) {
      stage2.change_font_size_by(1);
    }
    while(jQuery(".info-holder").height() < (jQuery("#free_text").height() + jQuery("#title").height())) {
      stage2.change_font_size_by(-1);
    }
  },
  change_font_size_by: function(delta) {
      var font_size = jQuery("#free_text").css("font-size");
      jQuery("#free_text").css("font-size", ((parseInt(font_size)+delta) + "px"));
      font_size = jQuery("#title").css("font-size");
      jQuery("#title").css("font-size", ((parseInt(font_size)+delta) + "px"));
  },
  preview_text: function(sourceId, targetId) {
    var text = jQuery("#" + sourceId).val().replace(/\n/g,"<BR/>");
    jQuery("#" + targetId).html(text);
    stage2.calcFontSize();
  },
  setLocationInMessage: function() {
    stage2.setFieldValueInMessage(jQuery("#event_location_name").val(), "location");
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
  }
}
jQuery(document).ready(function(){
  stage2.max_title_font_size = parseInt(jQuery("#title").css("font-size"));
  stage2.max_free_text_font_size = parseInt(jQuery("#free_text").css("font-size"));

  jQuery(".hide_ending_at").click(function(){
    jQuery(".ending_at_block").hide();
  });
  jQuery(".show_ending_at").click(function(){
    jQuery(".ending_at_block").show();
  });

  jQuery("#event_name").keyup(function(){
    stage2.preview_text("event_name", "title");
  });

  jQuery("#event_guest_message").click(function(){
    stage2.selectAllSafeValue(stage2.location);
    stage2.selectAllSafeValue(stage2.startDate);
    stage2.selectAllSafeValue(stage2.startTime);
  });

  jQuery("#event_guest_message").keyup(function(){
    if(jQuery(this).val().search(stage2.location) < 0) {
      alert("you can't change the location from here. Please edit the \"Location\" field");
      jQuery(this).val(stage2.message);
    } else if(jQuery(this).val().search(stage2.startDate) < 0) {
      alert("you can't change the starting date from here. Please edit the \"Date\" field");
      jQuery(this).val(stage2.message);
    } else if(jQuery(this).val().search(stage2.startTime) < 0) {
      alert("you can't change the starting date from here. Please edit the \"Time\" field");
      jQuery(this).val(stage2.message);
    } else {
      stage2.message = jQuery(this).val();
      stage2.preview_text("event_guest_message", "free_text");
    }
  });
  jQuery("#event_location_name").change(stage2.setLocationInMessage);
  jQuery("#event_location_name").blur(stage2.setLocationInMessage);
  jQuery("#event_starting_at_4i,#event_starting_at_5i").change(stage2.setTimeInMessage);

  cal1 = new Calendar({ starting_at_mock: {starting_at_mock: 'd.m.Y', event_starting_at_year: 'Y', event_starting_at_month: 'm', event_starting_at_day: 'd' } }, { classes: ['i-heart-ny'], direction: 1, months: ['ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני', 'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'], onHideStart: stage2.setDateInMessage });
  cal2 = new Calendar({ ending_at_mock: {ending_at_mock: 'd.m.Y', event_ending_at_year: 'Y', event_ending_at_month: 'm', event_ending_at_day: 'd' } }, { classes: ['i-heart-ny'], direction: 1, months: ['ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני', 'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'] });
});
