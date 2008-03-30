// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

/* fade flashes automatically */
Event.observe(window, 'load', function() { 
	$A(document.getElementsByClassName('alert')).each(function(o) {
		o.opacity = 100.0
		Effect.Fade(o, {duration: 3.5})
	});
});

function toggle_visibility(id) {
	var e = document.getElementById(id);
	if(e.style.display == 'block')
	e.style.display = 'none';
	else
	e.style.display = 'block';
}
