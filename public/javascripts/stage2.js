var stage2 = {
  location: "",
  message: "",
  max_title_font_size: 0,
  max_free_text_font_size: 0,
  
  calcFontSize: function() {
    while(jQuery(".info-holder").width() < (jQuery("#free_text").width())) {
      stage2.change_font_size_by(-1);    
    }
    while(jQuery(".info-holder").width() < (jQuery("#title").width())) {
      stage2.change_font_size_by(-1);    
    }
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
    if(jQuery("#event_location_name").val() != stage2.location) {
      var message = jQuery("#event_guest_message").val();
      if(stage2.location.length > 0) {
        jQuery("#event_guest_message").val(message.replace(stage2.location, jQuery("#event_location_name").val()));
      } else {
        jQuery("#event_guest_message").val(message + "\rLocation: " + jQuery("#event_location_name").val());
      }
      stage2.location = jQuery("#event_location_name").val();
      stage2.preview_text("event_guest_message", "free_text");
    }  
  }
}
jQuery(document).ready(function(){
  stage2.max_title_font_size = parseInt(jQuery("#title").css("font-size"));
  stage2.max_free_text_font_size = parseInt(jQuery("#free_text").css("font-size"));
  jQuery("#event_name").keyup(function(){
    stage2.preview_text("event_name", "title");
  });
  jQuery("#event_guest_message").click(function(){
    var locationStart = jQuery(this).val().search(jQuery("#event_location_name").val());
    var locationEnd = locationStart >= 0 ? (locationStart + jQuery("#event_location_name").val().length) : -1;
    if(jQuery(this).getSelection().start > locationStart && jQuery(this).getSelection().start < locationEnd)
      jQuery(this).setSelection(locationStart, locationEnd);
  });
  jQuery("#event_guest_message").keyup(function(){
    if(jQuery(this).val().search(jQuery("#event_location_name").val()) < 0) {
      alert("you can't change the location from here. Please edit the \"Location\" field");
      jQuery(this).val(stage2.message);
    } else {
      stage2.message = jQuery(this).val();
      stage2.preview_text("event_guest_message", "free_text");
    }
  });
  jQuery("#event_location_name").change(stage2.setLocationInMessage);
  jQuery("#event_location_name").blur(stage2.setLocationInMessage);  
  myCal3 = new Calendar({ event_location_address: 'd/m/Y' }, { classes: ['i-heart-ny'], direction: 1, months: ['ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני', 'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'] });
});