var rsvps = {
    dialog_height: 0,
    dialog_width: 0,
    minimized_by: 0,
    replacedHolder: null,

    adjust_dialog_size: function(invitation_id) {
        var width = jQuery(window).width() - 62;
        var height = jQuery(window).height() - 63;

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
        jQuery("#" + invitation_id + " .background_holder, #" + invitation_id).css("width",rsvps.dialog_width + "px");
        jQuery("#" + invitation_id + " .background_holder, #" + invitation_id).css("height",rsvps.dialog_height + "px");
        rsvps.minimized_by = 900 / rsvps.dialog_width;

//        jQuery("#" + invitation_id + " .background_holder .title_holder, #" + invitation_id + " .background_holder .msg_holder, #" + invitation_id + " .background_holder .window").each(function(){
//            jQuery(this).css("width", Math.floor(parseInt(jQuery(this).css("width")) / minimized_by) + "px");
//            jQuery(this).css("height", Math.floor(parseInt(jQuery(this).css("height")) / minimized_by) + "px");
//            jQuery(this).css("top", Math.floor(parseInt(jQuery(this).css("top")) / minimized_by) + "px");
//            jQuery(this).css("left", Math.floor(parseInt(jQuery(this).css("left")) / minimized_by) + "px");
//            jQuery(this).css("font-size", Math.floor(parseInt(jQuery(this).css("font-size")) / minimized_by) + "px");
//        });
        
        jQuery("#" + invitation_id + " .background_holder .window").each(function(){
            var minimized_by = 900 / rsvps.dialog_width;
            jQuery(this).css("top", (parseInt(jQuery(this).css("top"))+5) + "px");
            jQuery(this).css("left", (parseInt(jQuery(this).css("left"))+5) + "px");
        });
    },
    setTextBoxes: function() {
        var zoom = 1.6 / rsvps.minimized_by;
        var clone = jQuery(".image-h .msg-holder").clone();
        var msgHolder = jQuery(".background_holder .msg_holder");
        clone.css({
            top: Math.floor(parseInt(msgHolder.css("top")) / rsvps.minimized_by),
            left: Math.floor(parseInt(msgHolder.css("left")) / rsvps.minimized_by)
        });
        if(jQuery.browser.webkit)
            clone.css('-webkit-transform', 'scale(' + zoom + ')').css('-webkit-transform-origin','top left');
        else if (jQuery.browser.mozilla)
            clone.css('-moz-transform', 'scale(' + zoom + ')').css('-moz-transform-origin','top left');
        else if (jQuery.browser.msie)
            clone.css('zoom', zoom);
        rsvps.replacedHolder = msgHolder.replaceWith(clone);
    }
}
jQuery(document).ready(function(jQuery){
    jQuery(".toolbar").hide();
    jQuery("div[id ^= 'invitation']").each(function(){
        rsvps.adjust_dialog_size(jQuery(this).attr("id"));
    })
    jQuery('.toolbar_preview').appendTo('body');
    jQuery('a.preview.nyroModal').nyroModal({
        endFillContent: function(elts, settings){
            rsvps.setTextBoxes();
        },
        endShowContent: function(elts, settings){
            jQuery('.toolbar').show();
        },
        endRemove: function(elts, settings){
            jQuery('.toolbar').hide();
            jQuery('.background_holder .msg-holder').replaceWith(rsvps.replacedHolder);        }
    });
});
jQuery(window).load(function () {
    if(jQuery("#envelope").length > 0) {
        jQuery('#envelope').crossSlide({
            sleep: 0.5,
            fade: 0.5,
            loop: 1
        }, [
            { src: '/images/envelope1.png'},
            { src: '/images/envelope2.png'},
            { src: '/images/envelope3.png'},
            { src: '/images/envelope4.png', href: '#invitation', onclick: function(){
                jQuery("#envelope a").nyroModalManual({
                    closeButton:'',
                    modal: true,
                    endShowContent: function(elts, settings){
                        jQuery("#envelope img").hide();
                    }
                });
                jQuery(".toolbar").show();
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
