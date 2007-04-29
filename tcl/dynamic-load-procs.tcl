ad_library {

	Ajax Exprimental Procs

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-1
}

namespace eval ah::exp { }

ad_proc -public ah::exp::yui_js_source_dynamic {
	{-js "default"}
	{-enclose:boolean}
} {
	Dynamically Loads the Yahoo UI javascript libraries.
        WARNING : experimental, use ah::yui::js_sources instead


	@author Hamilton Chua (ham@solutiongrove.com)	
	@creation-date 2006-04-20

	@param js Comma separated list of javascript files to load
		Valid values include 
		"default" : loads yui.js and dom.js, the most commonly used
		"animation" : loads js for animation 
		"event" : loads js for event monitoring (e.g. listnern)
		"treeview" : loads js for Yahoo's Tree View control
		"calendar" : loads js for Yahoo's Calendar Control
		"dragdrop" : loads js for Yahoo's Drag and Drop functions
		"slider" : loads js for slider functions

} {

	set ah_base_url [ah::get_url]
	set script ""
	set js_file_list [split $js ","]
	
	foreach x $js_file_list {
		switch $x { 
			"animation" { 
				append script [ah::js_include -js_file "${ah_base_url}yui/animation/animation.js"]
			}
			"event" {
				append script [ah::js_include -js_file "${ah_base_url}yui/event/event.js"]
			}
			"treeview" {
				append script [ah::js_include -js_file "${ah_base_url}yui/treeview/treeview.js"]
			}
			"calendar" {
				append script [ah::js_include -js_file "${ah_base_url}yui/calendar/calendar.js"]
			}
			"dragdrop" {
				append script [ah::js_include -js_file "${ah_base_url}yui/dragdrop/dragdrop.js"]
			}
			"slider" {
				append script [ah::js_include -js_file "${ah_base_url}yui/slider/slider.js"]
			}
			default {
				append script [ah::js_include -js_file "${ah_base_url}yui/yui.js"]
				append script [ah::js_include -js_file "${ah_base_url}yui/dom/dom.js"]
			}
		}
	}

	if { $enclose_p } { set script [ah::enclose_in_script -script ${script} ] }

	return $script
}


ad_proc -private ah::exp::dynamic_load_functions {
	
} {
	Generates the javascript functions that perform dynamic loading of local javascript files.
	http://www.phpied.com/javascript-include/
        WARNING : experimental

	@author Hamilton Chua (ham@solutiongrove.com)	
	@creation-date 2006-04-20

} {
	set ah_base_url [ah::get_url]
	set script "<script type=\"text/javascript\" src=\"${ah_base_url}dynamicInclude.js\"></script>"
	return $script
}

ad_proc -public ah::exp::js_include {
	{-js_file ""}
} {
	Generates the javscript to include a js file dynamically via DOM to the head section of the page.
        WARNING : experimental

	@author Hamilton Chua (ham@solutiongrove.com)	
	@creation-date 2006-04-20
} {
	return "js_include_once('$js_file'); "
}

ad_proc -public ah::exp::js_source_dynamic {
	{-js "default"}
	{-enclose:boolean}
} {
	Uses the javascript dynamic loading functions to load the comma separated list of javascript source file.
        WARNING : experimental

	@author Hamilton Chua (ham@solutiongrove.com)	
	@creation-date 2006-04-20

	@param js A comma separated list of js files to load. Possible values include prototype, scriptaculous, rounder, rico, overlibmws, overlibmws_bubble, overlibmws_scroll, overlibmws_drag
        @param enclose Specify this if you want the javascript to be enclosed in script tags, which is usually the case unless you include this along with other javascript.
} {

	set ah_base_url [ah::get_url]
	set script ""
	set js_file_list [split $js ","]
	
	foreach x $js_file_list {
		switch $x {
			"rico" { 
				append script [ah::js_include -js_file "${ah_base_url}rico/rico.js"]
			}
			"rounder" {
				append script [ah::js_include -js_file "${ah_base_url}rico/rico.js"]
				append script [ah::js_include -js_file "${ah_base_url}rico/rounder.js"]
			}
			"overlibmws" {
				append script [ah::js_include -js_file "${ah_base_url}overlibmws/overlibmws.js"]
				append script [ah::js_include -js_file "${ah_base_url}overlibmws/overlibmws_overtwo.js"]
			}
			"overlibmws_bubble" {
				append script [ah::js_include -js_file "${ah_base_url}overlibmws/overlibmws_bubble.js"]
			}
			"overlibmws_scroll" {
				append script [ah::js_include -js_file "${ah_base_url}overlibmws/overlibmws_scroll.js"]
			}
			"overlibmws_drag" {
				append script [ah::js_include -js_file "${ah_base_url}overlibmws/overlibmws_draggable.js"]
			}
			default {
				append script [ah::js_include -js_file "${ah_base_url}prototype/prototype.js"]
				append script [ah::js_include -js_file "${ah_base_url}scriptaculous/scriptaculous.js"]
			}
		}
	}

	if { $enclose_p } { set script [ah::enclose_in_script -script ${script} ] }

	return $script
}
