function initScript() {
		
	addClass({
		tagName:'a',
		tagClass:'open',
		classAdd:'edit-drop',
		addToParent:true
	})
}

function addClass (_options) {
	var _tagName = _options.tagName;
	var _tagClass = _options.tagClass;
	var _classAdd = _options.classAdd;
	var _addToParent = false || _options.addToParent;
	var _el = document.getElementsByTagName(_tagName);
	if (_el) {
		for (var i=0; i < _el.length; i++) {
			if (_el[i].className.indexOf(_tagClass) != -1) {
				_el[i].onclick = function() {
					if (_addToParent) {
						if (this.parentNode.parentNode.className.indexOf(_classAdd) == -1) {
							this.parentNode.parentNode.className += ' '+_classAdd;
						} else {
							this.parentNode.parentNode.className = this.parentNode.parentNode.className.replace(_classAdd,'');
						}
					} else {
						if (this.className.indexOf(_classAdd) == -1) {
							this.className += ' '+_classAdd;
						} else {
							this.className = this.className.replace(_classAdd,'');
						}
					}
					return false;
				}
			}
		}
	}
}
if (window.addEventListener)
	window.addEventListener("load", initScript, false);
else if (window.attachEvent)
	window.attachEvent("onload", initScript);