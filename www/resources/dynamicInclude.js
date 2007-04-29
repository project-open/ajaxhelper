//Javascript dynamic Include Library
//Code derived from:
//Author: Stoyan Stefanov
//SITE: www.phpied.com
//email: ssttoo at gmaildotcom
//mad props due..
//I made the manager objects and added the css methods so 
//I can use this library for both
//me: Greg Patmore
//hit me up: //greg at ito-ydotcom


//js

//holds the currently loaded .js libraries
//NOTE: idiot alert! any files included outside these methods cannot be 
//		referenced by this array
var js_includes = new Array();


//use this manager to keep things simple
function JSManager(){
	this.included = js_includes;
	this.include = js_include_once;
	this.remove = js_remove_include;
}

function js_include_dom(script_filename) {
    var html_doc = document.getElementsByTagName('head').item(0);
    var js = document.createElement('script');
    js.setAttribute('language', 'javascript');
    js.setAttribute('type', 'text/javascript');
    js.setAttribute('src', script_filename);
    html_doc.appendChild(js);
    return false;
}

function js_include_once(script_filename) {
    if (!in_array(script_filename, js_includes)) {
        js_includes[js_includes.length] = script_filename;
        js_include_dom(script_filename);
    }
}

//"un-includes" the included js file from the document
//use sparingly, as it's a memory whore
//NOTE: will not kill any timeouts you may have going
//		but the script will be removed from the rendered source
function js_remove_include(scriptname){
	var docScripts = document.getElementsByTagName('script');
	for(var i=0;i<docScripts.length; i++){
		if(docScripts[i].getAttribute("src") && docScripts[i].getAttribute("src").toLowerCase() == scriptname.toLowerCase()){
			var tmpID = create_unique_id();
			docScripts[i].setAttribute('id',tmpID);
			yank_node(tmpID);
			js_array_splice(scriptname);
		}
	}
}

function js_array_splice(scriptname){
	for(var i=0;i<js_includes.length;++i){
		if(js_includes[i].toLowerCase() == scriptname.toLowerCase()){
			js_includes.splice(i,1);
		}
	}
}

function wait4Script(object) {
	if (typeof(object) == 'undefined') {
		setTimeout(wait4Scripts(object), 5);
	}
}

//css

//holds the currently loaded .css files
//holds same Idiot Note as js version
var css_includes = new Array();

//use this manager to keep things simple
function CSSManager(){
	this.included = css_includes;
	this.include = css_include_once;
	this.remove = css_remove_include;
}

function css_include(css_file) {
	var html_doc = document.getElementsByTagName('head').item(0);
	var css = document.createElement('link');
	css.setAttribute('rel', 'stylesheet');
	css.setAttribute('type', 'text/css');
	css.setAttribute('href', css_file);
	html_doc.appendChild(css);
	return false;
}

function css_include_once(script_filename) {
    if (!in_array(script_filename, css_includes)) {
        css_includes[css_includes.length] = script_filename;
        css_include(script_filename);
    }
}

//"un-includes" the included css file from the document
//use sparingly, as it's a memory whore
function css_remove_include(scriptname){
	var scripts = document.getElementsByTagName('link');
	for(var i=0;i<scripts.length; i++){
		if(scripts[i].getAttribute("href") && scripts[i].getAttribute("href").toLowerCase() == scriptname.toLowerCase()){
			var tmpID = create_unique_id();
			scripts[i].setAttribute('id',tmpID);
			yank_node(tmpID);
			css_array_splice(scriptname);
		}
	}
}

function css_array_splice(scriptname){
	for(var i=0;i<css_includes.length;++i){
		if(css_includes[i].toLowerCase() == scriptname.toLowerCase()){
			css_includes.splice(i,1);
		}
	}
}


//utility functions

//returns bool of whether a value exists in array
//used here to reference the includes
function in_array(needle, haystack) {
    for (var i = 0; i < haystack.length; i++) {
        if (haystack[i] == needle) return true;
    }
    return false;
}


//returns a random id
function create_unique_id(){
	return "id_" + Math.floor(Math.random() * (1000000 + 1)).toString();
}

//yanks a node with a given ID out of the DOM
//fall out: cascades, so all children are yanked as well 
function yank_node(nodeId){
	var toYank = document.getElementById(nodeId);
	if(toYank){
		var container = toYank.parentNode;
		container.removeChild(toYank);
	}
	return (toYank)?false:true;
}

