function handlePlayer(iframe, invitation_selector){
  player = $f(iframe);
  // When the player is ready, add listeners for pause, finish, and playProgress
  player.addEvent('ready', function() {
    player.addEvent('pause', onPause);
    player.addEvent('finish', onFinish);
//    player.addEvent('playProgress', onPlayProgress);
  });

// Call the API when a button is pressed
  jQuery('.play-movie').live('click', function() {
    jQuery(invitation_selector).hide();
    jQuery(iframe).show();
    player.api('seekTo','1');
    player.api('play');
  });

  function onPause(id) {
//    player.api('pause');
//    jQuery(iframe).hide();
//    jQuery(invitation_selector).show();
//    if(typeof(rsvps) !== "undefined"){
//      rsvps.startRsvpsPopupTimer();
//    }
  }

  function onFinish(id) {
    jQuery(iframe).hide();
    jQuery(invitation_selector).show();
    if(typeof(rsvps) !== "undefined"){
      rsvps.startRsvpsPopupTimer();
    }
  }

//  function onPlayProgress(data, id) {
//    status.text(data.seconds + 's played');
//  }
}
