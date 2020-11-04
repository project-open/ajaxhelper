ad_library {

	Library for Ajax Helper Procs
	based on Yahoo's User Interface Libraries

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-16
}

namespace eval ah::yui { }

ad_proc -private ah::yui::load_js_sources {
    -source_list
} {
    Accepts a Tcl list of sources to load.
    This source_list will be the global ajax_helper_yui_js_sources variable.
    This script is called in the blank-master template.
    As of 0.86d with YUI 2.3.0, this proc now uses the Yahoo Loader Utility to
     load the required sources.

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2006-11-05
} {

    set ah_base_url "[ah::get_url]yui/"
    set script ""
    set minsuffix ""
    set base "base: '${ah_base_url}',"

    if { [parameter::get_from_package_key -package_key "ajaxhelper" -parameter "UseMinifiedJs"] == 1 } {
        set minsuffix "-min"
    }

    if { [parameter::get_from_package_key -package_key "ajaxhelper" -parameter "LoadJsfromYahoo"] == 1 } {
        set minsuffix "-min"
        set ah_base_url "http://yui.yahooapis.com/2.3.0/build/"
        set base ""
    }

    set requires_list [join $source_list "','"]

    append script "<script src='${ah_base_url}yuiloader/yuiloader-debug.js'></script>"
    append script "<script language=\"javascript\" type=\"text/javascript\">loader = new YAHOO.util.YUILoader({ require: \['${requires_list}'\], ${base} onSuccess: function(loader) { ah_page_init() } });\nloader.insert();</script>"
    return ${script}
}

ad_proc -private ah::yui::is_valid_source {
    -js_source
} {
    This proc will determine if the YUI js_source file is the name is a valid name associated to
        a javascript source. This proc contains hard coded list of javascript sources that
        ajaxhelper supports.

        @author Hamilton Chua (ham@solutiongrove.com)
        @creation-date 2006-12-19
        @param js_source The name of the javascript source to check
} {

    set valid_sources [list "utilities" \
                                "yahoo" \
                                "dom" \
                                "event" \
                                "connection" \
                                "treeview" \
                                "animation" \
                                "calendar" \
                                "menu" \
                                "dragdrop" \
                                "slider" \
                                "container" \
                                "autocomplete" ]
    set found [lsearch -exact $valid_sources $js_source]
    if { $found == -1 } {
        return 0
    } else {
        return 1
    }
}

ad_proc -private ah::yui::is_js_sources_loaded {
	-js_source
} {
	This proc will loop thru the global source_list
        and check for the presence of the given js_source.
	If found, this proc will return 1
	If not found, this proc will return 0

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-05
} {
	set state 0
	if { [info exists ::ajax_helper_yui_js_sources] } {
		foreach source $::ajax_helper_yui_js_sources {
			if { [string match $source $js_source] } {
				set state 1
				break
			}
		}
	}
	return $state
}

ad_proc -private ah::yui::requires {
    -sources
} {
    This proc should be called by an ajaxhelper proc that uses YUI with a comma separated list of YUI javascript sources
        that the ajaxhelper proc needs in order to work.

        @author Hamilton Chua (ham@solutiongrove.com)
        @creation-date 2006-12-19
        @param sources Comma separated list of sources
} {
    #split up the comma delimited sources into a list
    set source_list [split $sources ","]
    #declare the global variable
    global ajax_helper_yui_js_sources
    foreach source $source_list {
        # do some checks before we add the source to the global
        # - is it already loaded
        # - is it a valid source name
        # - is the source "utilities" or "yahoo","dom","event"
        if { ![ah::yui::is_js_sources_loaded -js_source $source] && [ah::yui::is_valid_source -js_source $source] } {
            # source is utilities
            if { $source eq "utilities"} {
                # load it only if yahoo, dom and event are not loaded
                if { ![ah::yui::is_js_sources_loaded -js_source "yahoo"] && ![ah::yui::is_js_sources_loaded -js_source "dom"] && ![ah::yui::is_js_sources_loaded -js_source "event"]} {
                    lappend ajax_helper_yui_js_sources $source
                }
            } else {
                # TODO : figure out other dependencies and possible overlaps and try to work them out here
                lappend ajax_helper_yui_js_sources $source
            }
        } else {
            # TODO : we must return an error/exception, for now just add a notice in the log
            # ns_log debug "AJAXHELPER YUI: $source is already loaded or not valid"
        }
    }
}


ad_proc -public ah::yui::js_sources {
	{-source "default"}
	{-min:boolean}
} {

    DEPRECATED. Use ah::yui::requires instead.

	Generates the <script> syntax needed on the head
	for Yahoo's User Interface Library
	The code :
	<pre>
		[ah::yui::js_sources -source "event"]
	</pre>
	will load the default YUI javascript library which includes the connections and doms js files

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-16

	@param default Loads the prototype and scriptaculous javascript libraries.
	@param source The caller can specify which set of javascript source files to load. You can specify more than one by separating the list with commas.
		Valid values include
		"animation" : loads animation.js
		"event" : loads events.js
		"treeview" : loads treeview.js
		"calendar" : loads calendar.js
		"dragdrop" : loads dragdrop.js
		"slider" : loads slider.js
		"container" : loads container.js
	@param min Provide this parameter to use minified versions of the yahoo javascript sources

	@return
	@error

} {
	set ah_base_url "[ah::get_url]yui/"
    set script ""

    set minsuffix ""

    if { $min_p || [parameter::get_from_package_key -package_key "ajaxhelper" -parameter "UseMinifiedJs"] == 1 } {
        set minsuffix "-min"
    }

    if { [parameter::get_from_package_key -package_key "ajaxhelper" -parameter "LoadJsfromYahoo"] == 1 } {
        set minsuffix "-min"
        set ah_base_url "http://yui.yahooapis.com/2.3.0/build/"
    }

    # js_sources was called with no parameters, just load the defaults
    if { $source eq "default" } {
        # yahoo has a compressed js file with  yahoo, dom and event all in one file (utilities)
        if { ![ah::is_js_sources_loaded -js_source "utilities"] } {
                append script "<script type=\"text/javascript\" src=\"${ah_base_url}utilities/utilities.js\"></script> \n"
                # make sure it doesn't load again
                lappend ajax_helper_yui_js_sources "utilities"
        }
    }

	set js_file_list [split $source ","]

	foreach x $js_file_list {
		switch $x {
			"animation" {
				if { ![ah::yui::is_js_sources_loaded -js_source "animation"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}animation/animation${minsuffix}.js\"></script> \n"
				}
			}
			"event" {
				if { ![ah::yui::is_js_sources_loaded -js_source "event"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}event/event${minsuffix}.js\"></script> \n"
				}
			}
			"treeview" {
				if { ![ah::yui::is_js_sources_loaded -js_source "treeview"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}treeview/treeview${minsuffix}.js\"></script> \n"
				}
			}
			"calendar" {
				if { ![ah::yui::is_js_sources_loaded -js_source "calendar"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}calendar/calendar${minsuffix}.js\"></script> \n"
				}
			}
			"dragdrop" {
				if { ![ah::yui::is_js_sources_loaded -js_source "dragdrop"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}dragdrop/dragdrop${minsuffix}.js\"></script> \n"
				}
			}
			"slider" {
				if { ![ah::yui::is_js_sources_loaded -js_source "slider"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}slider/slider${minsuffix}.js\"></script> \n"
				}
			}
			"container" {
				if { ![ah::yui::is_js_sources_loaded -js_source "container"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}container/container${minsuffix}.js\"></script> \n"
					append script "<link rel=\"stylesheet\" type=\"text/css\" href=\"${ah_base_url}container/assets/container.css\" /> \n"
				}
			}
			"menu" {
				if { ![ah::yui::is_js_sources_loaded -js_source "menu"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}menu/menu${minsuffix}.js\"></script> \n"
					append script "<link rel=\"stylesheet\" type=\"text/css\" href=\"${ah_base_url}menu/assets/menu.css\" /> \n"
				}
			}
			"connection" {
				if { ![ah::yui::is_js_sources_loaded -js_source "connection"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}connection/connection${minsuffix}.js\"></script> \n"
				}
			}
			"dom" {
				if { ![ah::yui::is_js_sources_loaded -js_source "yahoo"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}dom/dom${minsuffix}.js\"></script> \n"
				}
            }
            "yahoo" {
				if { ![ah::yui::is_js_sources_loaded -js_source "yahoo"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}yahoo/yahoo${minsuffix}.js\"></script> \n"
				}
			}
            "utilities" {
                if { ![ah::yui::is_js_sources_loaded -js_source "utilities"] } {
                    append script "<script type=\"text/javascript\" src=\"${ah_base_url}utilities/utilities.js\"></script> \n"
                }
            }
		}
	}
	return $script
}

ad_proc -public ah::yui::cssclass {
    {-varname "yuiclass"}
    {-action "add"}
    -element:required
    -classname:required
    {-element_is_var:boolean}
} {

    Generates javascript code to control css class on html elements.
    
    http://developer.yahoo.com/yui/dom/

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2007-08-11

    @param varname The javascript variable name to use.
    @param action Valid actions are "add", "remove", and "check"
    @param element The html element that will be affected
    @param classname The css class to add, remove, or check

} {

    if { !$element_is_var_p } {
        set element [ah::isnot_js_var $element]
    }

    ah::yui::requires -sources "dom"
    set script "YAHOO.util.Dom."
    switch $action {
        "add" { append script "addClass(${element},\"${classname}\"); " }
        "remove" { append script "removeClass(${element},\"${classname}\") ;" }
        "check" { append script "hasClass(${element},\"${classname}\"); " }
        
    }
    return ${script}
}

ad_proc -public ah::yui::addlistener {
	-element:required
	-event:required
	-callback:required
	{-element_is_var:boolean}
} {
	Creates javascript for Yahoo's Event Listener.
	http://developer.yahoo.com/yui/event/

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-05

	@param element The element that this function will listen for events. This is the id of an html element (e.g. div or a form)
	@param event The event that this function waits for. Values include load, mouseover, mouseout, unload etc.
	@param callback The name of the javascript function to execute when the event for the given element has been triggered.
} {

    ah::yui::requires -sources "event"

	if { !$element_is_var_p } {
		set element [ah::isnot_js_var $element]
	}

	return "YAHOO.util.Event.addListener($element,\"$event\",${callback});\n"
}

ad_proc -public ah::yui::tooltip {
	-varname:required
	-element:required
	-message:required
	{-enclose:boolean}
	{-options ""}
} {
	Generates the javascript to create a tooltip using yahoo's user interface javascript library.
	http://developer.yahoo.com/yui/container/tooltip/index.html

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-05

	@param varname The variable name you want to give to the tooltip
	@param element The element where you wish to attache the tooltip
	@param message The message that will appear in the tooltip
} {

    ah::yui::requires -sources "container"

	set script "var $varname = new YAHOO.widget.Tooltip(\"alertTip\", { context:\"$element\", text:\"$message\", $options });"
    global ajax_helper_init_scripts
    append ajax_helper_init_scripts $script
}

ad_proc -public ah::yui::create_tree {
	-element:required
	-nodes:required
	{-varname "tree"}
	{-css ""}
    {-nodedroppable:boolean}
} {
	Generates the javascript to create a yahoo tree view control.
    Nodes accepts a list of lists.

    This is an example of a node list.

            set nodes [list]
            lappend nodes [list "fld1" "Folder 1" "tree" "" "" "" ""]
            lappend nodes [list "fld2" "Folder 2" "tree" "javascript:alert('this is a tree node')" "" "" ""]

    A node list is expected to have the following values in the given order :
    list index  -   expected value
    0   -   javascript variable name of the nodes
    1   -   the pretty name or label of the nodes
    2   -   the javascript variable name of the treeview
    3   -   the value of the href attribute of a nodes
    4   -   the variable name of the node to attach to, if blank it will automatically attach to the root nodes
    5   -   a javascript function to execute if the node should load it's children dynamically
    6   -   should the node be opened or closed

	http://developer.yahoo.com/yui/treeview/

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-05

	@param element This is the id of the html elment where you want to generate the tree view control.
	@param nodes Is list of lists. Each list contains the node information to be passed to ah::yui::create_tree_node to create a node.
	@param varname The javascript variable name to give the tree.

} {

    ah::yui::requires -sources "dom,treeview"

    if { $css ne "" } { template::head::add_css -href $css }

	set script "var ${varname} = new YAHOO.widget.TreeView(\"${element}\"); "
	append script "var ${varname}root = ${varname}.getRoot(); "
	foreach node $nodes {
        if { $nodedroppable_p } {
          append script [ah::yui::create_tree_node -varname [lindex $node 0] \
                    -label [lindex $node 1] \
                    -treevarname [lindex $node 2] \
                    -href [lindex $node 3] \
                    -attach_to_node [lindex $node 4] \
                    -dynamic_load [lindex $node 5] \
                    -open [lindex $node 6] \
                    -droppable ]
        } else {
		  append script [ah::yui::create_tree_node -varname [lindex $node 0] \
				    -label [lindex $node 1] \
				    -treevarname [lindex $node 2] \
				    -href [lindex $node 3] \
				    -attach_to_node [lindex $node 4] \
				    -dynamic_load [lindex $node 5] \
				    -open [lindex $node 6] ]
        }
	}
	append script "${varname}.draw(); "

    global ajax_helper_init_scripts
    append ajax_helper_init_scripts [ah::yui::addlistener \
        -element "window" \
        -event "load" \
        -callback [ah::create_js_function -body ${script}] \
        -element_is_var ]


}

ad_proc -private ah::yui::create_tree_node {
	-varname:required
	-label:required
	-treevarname:required
	{-href "javascript:void(0)"}
	{-attach_to_node ""}
	{-dynamic_load ""}
	{-open "false"}
    {-droppable:boolean}
} {
	Generates the javascript to add a node to a yahoo tree view control
	http://developer.yahoo.com/yui/treeview/

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-05

    @param varname The name to give the javascript variable to represent the node.
    @param label The label to assign the node.
    @param treevarname The javascript variable associated with the tree object
    @param href Link that the node goes to when it is clicked.
    @param attach_to_node The variable name of an existing node to attach this node to.
    @param dynamic_load A javascript function that is executed when the children of this node are loaded.
    @param open Set this to "true" if you want this node to be open by default when it is rendered.
} {
	set script "var od${varname} = {label: \"${label}\", id: \"${varname}\", href: \"${href}\"}; "

	if { $attach_to_node ne "" } {
		append script "var node = ${treevarname}.getNodeByProperty('id','${attach_to_node}'); "
		append script "if ( node == null ) { var node = nd${attach_to_node}; } "
	} else {
		append script "var node = ${treevarname}root; "
	}

	if { $open eq "" } { set open "false" }

	append script "var nd${varname} = new YAHOO.widget.TextNode(od${varname},node,${open}); "

    if { $droppable_p } {
        append script "var dd${varname} = new YAHOO.util.DDTarget(nd${varname}.labelElId); "
    }

	if { $dynamic_load ne "" } {
		append script "nd${varname}.setDynamicLoad(${dynamic_load}); "
	}

	return $script
}

ad_proc -public ah::yui::menu_from_markup {
    -varname:required
    -markupid:required
    -triggerel:required
    -triggerevent:required
    {-css ""}
    {-options ""}
} {
    Generates the javascript to create a YUI menu from existing html markup.


    http://developer.yahoo.com/yui/menu/

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2006-12-23

    @param varname The javascript variable to represent the menu object.
    @param markupid The html id of with the markup we want to transform into a menu.
    @param triggerel The element from which the menu will be launched
    @param triggerevent The event on triggerel that will make the menu appear. (e.g. click, mouseover)
    @param css Specify the full path to a css style sheet file to use an alternative to the menu.css that is used.
    @param options Additional options that you want to pass to the javascript object constructor.

} {
    ah::yui::requires -sources "menu,container,overlay"

    if { $css ne "" } { template::head::add_css -href $css }

    set script "${varname} = new YAHOO.widget.Menu(\"${markupid}\",{${options}}); "
    append script "${varname}.render(); "

    set script [ah::yui::addlistener \
        -element "window" \
        -event "load" \
        -callback [ah::create_js_function -body ${script}] \
        -element_is_var ]

    append script [ah::yui::addlistener \
        -element "${triggerel}" \
        -event "${triggerevent}" \
        -callback [ah::create_js_function -body "${varname}.show();"] ]

    global ajax_helper_init_scripts
    append ajax_helper_init_scripts $script

}

ad_proc -public ah::yui::menu_list_to_json {
    -lists_of_pairs
} {
    Converts a properly structured list of menu items into JSON format.
        The list of lists may look something like

            set submenu [list]
            lappend submenu [list [list "text" "Submenu1"] [list "url" "http://www.google.com"] ]
            lappend submenu [list [list "text" "Submenu2"] [list "url" "http://www.yahoo.com"] ]

        each line represents a row composed of lists.
        Each list in the row holds a pair that will be joined by ":".
} {

    set rows [list]
    foreach row $lists_of_pairs {
        set pairs [list]
        foreach pair $row {
            if { [lindex $pair 0] eq "submenu" } {
                set submenulist [lindex $pair 1]

                set submenuid [lindex $submenulist 0]
                set itemdata [lindex $submenulist 1]

                set itemdatajson [ah::yui::menu_list_to_json -lists_of_pairs [lindex $itemdata 1] ]

                set submenujson "\"[join $submenuid "\":\""]\""
                append submenujson ", [lindex $itemdata 0] : \[ $itemdatajson \]"

                lappend pairs "\"[lindex $pair 0]\": { $submenujson }"
            } else {
                lappend pairs "\"[join $pair "\":\""]\""
            }
        }
        lappend rows [join $pairs ","]
    }
    return "\{[join $rows "\},\{"]\}"
}


ad_proc -public ah::yui::menu_from_list {
    -varname:required
    -id:required
    -menulist:required
    -triggerel:required
    -triggerevent:required
    {-css ""}
    {-options ""}
    {-renderin "document.body"}
} {
    Generates the javascript to create a YUI menu from a Tcl list.

    http://developer.yahoo.com/yui/menu/

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2006-12-25

    @param varname The javascript variable to represent the menu object.
    @param menulist A list of lists with the parameters this script needs to generate your menu.
    @param id The html id the menu element.
    @param triggerel The element from which the menu will be launched
    @param triggerevent The event on triggerel that will make the menu appear. (e.g. click, mouseover)
    @param css Specify the full path to a css style sheet file to use an alternative to the menu.css that is used.
    @param options Additional options that you want to pass to the javascript object constructor.
    @param renderin Specify a div element where you want to render the menu in, default is document.body.

} {

    ah::yui::requires -sources "event,menu,container,overlay"

    if { $css ne "" } { template::head::add_css -href $css }

    set jsonlist [ah::yui::menu_list_to_json -lists_of_pairs $menulist]

    set script "$varname = new YAHOO.widget.Menu(\"${id}\",{${options}}); "
    append script "$varname.addItems(\[${jsonlist}\]); "
    append script "${varname}.render(${renderin}); "

    # show when triggerevent occurs on triggerel
    append script [ah::yui::addlistener \
        -element "${triggerel}" \
        -event "${triggerevent}" \
        -callback [ah::create_js_function -body "YAHOO.util.Event.preventDefault(e);  ${varname}.show();" -parameters [list "e"] ] ]

    global ajax_helper_init_scripts
    append ajax_helper_init_scripts $script

}

ad_proc -public ah::yui::contextmenu {
    -varname:required
    -id:required
    -menulist:required
    {-css ""}
    {-options ""}
    {-triggerel "document"}
    {-renderin "document.body"}
} {
    Generates the javascript to create a YUI context menu from a Tcl list.
    http://developer.yahoo.com/yui/menu/

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2006-12-25

    @param varname The javascript variable to represent the menu object.
    @param menulist A list of lists with the parameters this script needs to generate your menu.
    @param id The html id the menu element.
    @param css Specify the full path to a css style sheet file to use an alternative to the menu.css that is used.
    @param options Additional options that you want to pass to the javascript object constructor.
    @param triggerel What element on the page which when right clicked will show the contextmenu
    @param renderin The element on the html page where the menu will be rendered. Default is the body of the page.

} {

    ah::yui::requires -sources "menu,container,overlay"

    if { $css ne "" } { template::head::add_css -href $css }

    set jsonlist [ah::yui::menu_list_to_json -lists_of_pairs $menulist]

    set initoptions "trigger: ${triggerel}, lazyload:true"
    if { $options ne "" } {
        set options "${initoptions},${options}"
    } else {
        set options "${initoptions}"
    }

    append options ", itemdata: \[${jsonlist}\]"

    set script "var $varname = new YAHOO.widget.ContextMenu(\"${id}\", { ${options} } ); "

    global ajax_helper_init_scripts

    append ajax_helper_init_scripts ${script}

}

ad_proc -public ah::yui::autocomplete {
    -varname:required
    -id:required
    -inputid:required
    -suggestlist:required
    {-delimchar ","}
    {-useiframe "true"}
    {-maxresults "20"}
    {-forceselection "false"}
    {-events {}}
} {
    Generates the javascript to create a YUI autocomplete object from a Tcl list
    http://developer.yahoo.com/yui/autocomplete/

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2006-12-25

    @param varname The javascript variable to represent the autocomplete object.
    @param suggestlist A list or a list of lists with the values that will act as the datasource for the autocomplete object.
    @param id The html id of that the autosuggest component will use to present suggestions. IMPORTANT : The html element with this id should already be in the adp page. e.g if id is oAutoContainer then your html document should already have "<div id='oAutoContainer'></div>" in it
    @param inputid The id of the input text box that the user will type in
    @param options Additional options that you want to pass to the javascript object constructor

} {

    ah::yui::requires -sources "autocomplete"

    if { [llength $suggestlist] > 0 } {

        # check if we have a list of lists
        if { [llength [lindex $suggestlist 0]] > 1} {

            # yes , let's create the array for the innerlist and put each array into one big array
            set outerlist [list]
            foreach onelist $suggestlist {
                set escaped_list [list]
                foreach elm $onelist {
                    lappend escaped_list [string map {' \\'} $elm]
                }

                lappend outerlist "\[ '[join $escaped_list "','"]' \]"
            }
            set script "var ${varname}Arr = \[ [join $outerlist ","] \];"
            set markup [list]
            for { set x 0} { $x < [llength [lindex $suggestlist 0]] } { incr x} {
                lappend markup "oResultItem\[${x}\]"
            }
            set markup [join $markup "+\" \"+"]
            set format "${varname}.formatResult=function(oResultItem, sQuery) { var sMarkup=${markup}; return sMarkup; };"

        } else {
    
            # no, transform the list into an array
            set script "var ${varname}Arr = \[ '[join $suggestlist "','"]' \];"
            set format ""
        }
    
        # create the datasource object
        append script "var ${varname}DS = new YAHOO.widget.DS_JSArray(${varname}Arr);"
    
        # create autocomplete object with some predefined options
        append script "if (document.getElementById('${inputid}')) {"
        append script "var ${varname} = new YAHOO.widget.AutoComplete('${inputid}','${id}', ${varname}DS);"
        append script "${varname}.animHoriz=false;"
        append script "${varname}.animVert=false;"
        append script "${varname}.queryDelay=0;"
        append script "${varname}.maxResultsDisplayed=${maxresults};"
        append script "${varname}.useIFrame=${useiframe};"
        append script "${varname}.delimChar=\"${delimchar}\";"

        append script "${varname}.forceSelection=\"${forceselection}\";"
		append script "${varname}.allowBrowserAutocomplete=false;"
		append script "${varname}.typeAhead=true;"
		append script ${format}

#        append script "${varname}.doBeforeExpandContainer = function(oTextbox, oContainer, sQuery, aResults) {var pos = YAHOO.util.Dom.getXY(oTextbox);pos\[1\] += YAHOO.util.Dom.get(oTextbox).offsetHeight;YAHOO.util.Dom.setXY(oContainer,pos);YAHOO.util.Dom.setStyle(oContainer,'overflow-y','auto');YAHOO.util.Dom.setStyle(oContainer,'overflow-x','hidden');YAHOO.util.Dom.setStyle(oContainer,'position','absolute');YAHOO.util.Dom.setStyle(oContainer,'height','150px');YAHOO.util.Dom.setStyle(oContainer,'z-index','100');return true;};"
#        append script ${format}
#        append script "${varname}.containerCollapseEvent.subscribe([ah::create_js_function -body "YAHOO.util.Dom.setStyle('${id}', 'height', 0)" -parameters [list "type" "args"] ]);"
#        append script "${varname}.itemArrowToEvent.subscribe([ah::create_js_function -body "elItem\[1\].scrollIntoView(false)" -parameters [list "oSelf" "elItem"] ]); "

         foreach {name value} $events {
            append script "${varname}.${name}.subscribe${value};\n"
        }
       
        # prevent the container from overlapping other elements, e.g. buttons, links

		# remove the yui-ac-input class
        append script [ah::yui::cssclass \
            -varname "yuiinputclass${varname}" \
            -action "remove" \
            -element ${inputid} \
            -classname "yui-ac-input" ]
            
        append script "}; "
    
        global ajax_helper_init_scripts
        append ajax_helper_init_scripts $script
    }

}

