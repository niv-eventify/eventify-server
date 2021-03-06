﻿var rsvps = {
  dialog_height: 0,
  dialog_width: 0,
  minimized_by: 0,
  replacedTitleHolder: null,
  replacedMsgHolder: null,
  envelopeTimeout: null,
  maxWaitTimeReached: false,
  lastWindowHeight: null,
  lastWindowWidth: null,

  adjust_dialogs_size: function() {
    jQuery("div[id ^= 'invitation']").each(function(){
        rsvps.adjust_dialog_size(jQuery(this).attr("id"));
    })
  },

  adjust_dialog_size: function(invitation_id) {
    var width = jQuery(window).width() - 62;
    var height = jQuery(window).height() - 63 - 64 - 10;//the second and third are the height of the toolbar and the margins

    var ratio = width / height;
    if(ratio < 1.5) {
      if(width > 900) width = 900;
      rsvps.dialog_width = width;
      rsvps.dialog_height  = Math.ceil(width / 1.5);
    }else{
      if(height > 600) height = 600;
      rsvps.dialog_height = height;
      rsvps.dialog_width = Math.ceil(height * 1.5);
    }
    var back_holder_selector = "#" + invitation_id + " .background_holder";
    var movie_iframe_selector = "#" + invitation_id + " iframe";
    jQuery(back_holder_selector + ", #" + invitation_id + ", " + movie_iframe_selector).css("width",rsvps.dialog_width + "px");
    jQuery(back_holder_selector + ", #" + invitation_id + ", " + movie_iframe_selector).css("height",rsvps.dialog_height + "px");
    rsvps.minimized_by = 900 / rsvps.dialog_width;

    jQuery("#" + invitation_id + " .background_holder .window").each(function(){
      jQuery(this).css("width", Math.ceil(parseInt(jQuery(this).css("width")) / rsvps.minimized_by) + "px");
      jQuery(this).css("height", Math.ceil(parseInt(jQuery(this).css("height")) / rsvps.minimized_by) + "px");
      jQuery(this).css("top", Math.ceil(parseInt(jQuery(this).css("top")) / rsvps.minimized_by + 5) + "px");
      jQuery(this).css("left", Math.ceil(parseInt(jQuery(this).css("left")) / rsvps.minimized_by + 5) + "px");
    });
  },
  cloneTextBox: function(nyroModalContent, holderClass) {
    var zoom = 1.6 / rsvps.minimized_by;
    var holder = nyroModalContent.find(".background_holder ." + holderClass);
    var clone = holder.clone();
    clone.css({
      top: Math.ceil(parseInt(clone.css("top")) * zoom),
      left: Math.ceil(parseInt(clone.css("left")) * zoom)
    });
    if(jQuery.browser.webkit)
      clone.css('-webkit-transform', 'scale(' + zoom + ')').css('-webkit-transform-origin','top left');
    else if (jQuery.browser.mozilla)
      clone.css('-moz-transform', 'scale(' + zoom + ')').css('-moz-transform-origin','top left');
    else if (jQuery.browser.msie)
      clone.css('zoom', zoom);
    return holder.replaceWith(clone);
  },

  showRealInvitation: function() {
    jQuery("#envelope a").nyroModalManual({
      closeButton:'',
      modal: true,
      endFillContent: function(elts, settings){
        rsvps.replacedTitleHolder = rsvps.cloneTextBox(elts.content, "title_holder");
        rsvps.replacedMsgHolder = rsvps.cloneTextBox(elts.content, "msg_holder");
      },
      endShowContent: function(elts, settings){
        jQuery("#envelope img").hide();
      }
    });
    jQuery(".toolbar").show();
    if(typeof(handlePlayer) === "undefined"){
      rsvps.startRsvpsPopupTimer();
    }
    jQuery("#rsvps_dialog_opener").click(function(){
      jQuery("#rsvps_dialog").dialog({
        height: "auto",
        width: "auto",
        resizable: false,
        draggable: true
      });
      $(".ui-dialog-titlebar").hide();
    });
  },

  startRsvpsPopupTimer: function() {
    setTimeout(function(){
      jQuery("#rsvps_dialog_opener").click();
    }, 7000);
  }
}
jQuery(document).ready(function(jQuery){
  rsvps.lastWindowHeight =jQuery(window).height();
  rsvps.lastWindowWidth = jQuery(window).width();
  rsvps.adjust_dialogs_size();

  if(jQuery("#envelope").length > 0) {
    rsvps.envelopeTimeout = setTimeout(function(){
      rsvps.maxWaitTimeReached = true;
      rsvps.showRealInvitation();
    }, 7000);
  }
  if(jQuery.browser.msie) {
    jQuery(".msg, .title").each(function(){
      jQuery(this).html(jQuery(this).html().replace(/ /g, ""))
    });
  }
  jQuery(".toolbar").hide();
  jQuery(window).resize(function(){
    if(rsvps.lastWindowHeight != jQuery(window).height() && rsvps.lastWindowWidth != jQuery(window).width()){
      rsvps.lastWindowHeight = jQuery(window).height();
      rsvps.lastWindowWidth = jQuery(window).width();
      rsvps.adjust_dialogs_size();
    }
  });
  jQuery('.toolbar_preview').appendTo('body');
  jQuery('a.preview.nyroModal').nyroModal({
    processHandler: function(settings){
      if(jQuery('.title-holder').length > 0 && jQuery('#title').text() != jQuery('#invitation .title').text()) {
        jQuery('#invitation .title').html(jQuery('#title').html());
      }
      if(jQuery('#free_text').length > 0 && jQuery('#free_text').text() != jQuery('#invitation .msg_holder .msg').text()) {
        jQuery('#invitation .msg_holder .msg').html(jQuery('#free_text').html());
      }
    },
    endFillContent: function(elts, settings){
      rsvps.replacedTitleHolder = rsvps.cloneTextBox(elts.content, "title_holder");
      rsvps.replacedMsgHolder = rsvps.cloneTextBox(elts.content, "msg_holder");
    },
    endShowContent: function(elts, settings){
      jQuery("#nyroModalContent iframe:hidden").show();
      jQuery('.toolbar').show();
    },
    endRemove: function(elts, settings){
      jQuery('.toolbar').hide();
      jQuery(this.selector + ' .background_holder .msg_holder').replaceWith(rsvps.replacedMsgHolder);
      jQuery(this.selector + ' .background_holder .title_holder').replaceWith(rsvps.replacedTitleHolder);
    }
  });
  var iframe = jQuery('#invitation iframe')[0];
  if(typeof(handlePlayer) !== "undefined"){
    handlePlayer(iframe, "#nyroModalContent .background_holder");
  }
});
jQuery(window).load(function () {
  if(jQuery("#envelope").length > 0) {
    jQuery("#envelope").show();
    if(rsvps.maxWaitTimeReached) return;
    clearTimeout(rsvps.envelopeTimeout);
    jQuery('#envelope').crossSlide({
      sleep: 0.4,
      fade: 0.4,
      loop: 1
    }, [
      { src: '/images/envelope1.png'},
      { src: '/images/envelope2.png'},
      { src: '/images/envelope3.png'},
      { src: '/images/envelope4.png', href: '#invitation', onclick: function(){
          rsvps.showRealInvitation();
      }}
    ]);
    var intervalId = setInterval(function(){
      if(jQuery("#envelope a img").css("visibility") == "visible"){
          clearInterval(intervalId);
          jQuery("#envelope a").click();
      }
    },1500);
  }
});
