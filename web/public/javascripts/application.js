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

function toggle_group_visibility(group) {
	for (el in group) {
		toggle_visibility(el);
	}
}

function make_visible(id) {
	var e = document.getElementById(id);
	e.style.display = 'block';
}

function make_invisible(id) {
	var e = document.getElementById(id);
	e.style.display = 'none';
}

function switch_visibility(id1, id2) {
	make_invisible(id1);
	make_visible(id2);
}

function value_visible_invisible(value, id1, id2) {
	if (value == 1) {
		make_visible(id1);
		make_invisible(id2);
	} else {
		make_visible(id2);
		make_invisible(id1);
	}
}