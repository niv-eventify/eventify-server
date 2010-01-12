new function(jQuery) {
  jQuery.fn.getSelection = function() {
		var e = this.jquery ? this[0] : this;
    if('selectionStart' in e) {/* mozilla / dom 3.0 */
        var l = e.selectionEnd - e.selectionStart;
        return { start: e.selectionStart, end: e.selectionEnd, length: l, text: e.value.substr(e.selectionStart, l) };
    } else if(document.selection) {/* explorer */
      e.focus();
      var r = document.selection.createRange();
      if (r == null) {
        return { start: 0, end: e.value.length, length: 0 }
      }

      var re = e.createTextRange();
      var rc = re.duplicate();
      re.moveToBookmark(r.getBookmark());
      rc.setEndPoint('EndToStart', re);

      return { start: rc.text.length, end: rc.text.length + r.text.length, length: r.text.length, text: r.text };
    } else {/* browser not supported */
      return { start: 0, end: e.value.length, length: 0 };
    }
  }
}(jQuery);

new function(jQuery) {
  jQuery.fn.setSelection = function(start,end) {
    if (jQuery(this).get(0).setSelectionRange) {
      jQuery(this).get(0).setSelectionRange(start, end);
    } else if (jQuery(this).get(0).createTextRange) {
      var range = jQuery(this).get(0).createTextRange();
      range.collapse(true);
      range.moveEnd('character', end);
      range.moveStart('character', start);
      range.select();
    }
  }
}(jQuery);

