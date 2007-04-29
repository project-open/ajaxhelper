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
	Accepts a tcl list of sources to load.
	This source_list will be the global ajax_helper_yui_js_sources variable.
	This script is called in the blank-master template.

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-05
} {
	set ah_base_url [ah::get_url]
	set script ""
	set minsuffix ""

	if { [parameter::get_from_package_key -package_key "ajaxhelper" -parameter "UseMinifiedJs"] == 1 } {
		set minsuffix "-min"
	}

	foreach source $source_list {
		switch $source {
			"animation" {
				append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/animation/animation${minsuffix}.js\"></script> \n"
			}
			"event" {
				append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/event/event${minsuffix}.js\"></script> \n"
			}
			"treeview" {
				append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/treeview/treeview${minsuffix}.js\"></script> \n"
				global yahoo_treeview_css
				if { [exists_and_not_null yahoo_treeview_css] } {
					append script "<link rel=\"stylesheet\" type=\"text/css\" href=\"${yahoo_treeview_css}\" /> \n"
				} else {
					append script "<link rel=\"stylesheet\" type=\"text/css\" href=\"${ah_base_url}yui/treeview/assets/tree.css\" /> \n"
				}
			}
            "menu" {
                append script "<link rel=\"stylesheet\" type=\"text/css\" href=\"${ah_base_url}yui/fonts/fonts${minsuffix}.css\" /> \n"
                global yahoo_menu_css
                if { [exists_and_not_null yahoo_menu_css] } {
                    append script "<link rel=\"stylesheet\" type=\"text/css\" href=\"${yahoo_menu_css}\" /> \n"
                } else {
                    append script "<link rel=\"stylesheet\" type=\"text/css\" href=\"${ah_base_url}yui/menu/assets/menu.css\" /> \n"
                }
                append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/container/container_core${minsuffix}.js\"></script> \n"
                append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/menu/menu${minsuffix}.js\"></script> \n"
            }
			"calendar" {
				append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/calendar/calendar${minsuffix}.js\"></script> \n"
			}
			"dragdrop" {
				append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/dragdrop/dragdrop${minsuffix}.js\"></script> \n"
			}
			"slider" {
				append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/slider/slider${minsuffix}.js\"></script> \n"
			}
			"container" {
				append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/container/container${minsuffix}.js\"></script> \n"
				append script "<link rel=\"stylesheet\" type=\"text/css\" href=\"${ah_base_url}yui/container/assets/container.css\" /> \n"
			}
			"dom" {
				append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/dom/dom${minsuffix}.js\"></script> \n"
			}
			"connection" {
				append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/connection/connection${minsuffix}.js\"></script> \n"
			}
			"yahoo" {
				append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/yahoo/yahoo${minsuffix}.js\"></script> \n"
			}
            "utilities" {
                append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/utilities/utilities.js\"></script> \n"
            }
		}
	}
	return $script
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
                                "container" ]
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
	global ajax_helper_yui_js_sources
	set state 0
	if { [info exists ajax_helper_yui_js_sources] } {
		foreach source $ajax_helper_yui_js_sources {
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
        # - is the source utilities or yahoo,dom,event
        if { ![ah::yui::is_js_sources_loaded -js_source $source] && [ah::yui::is_valid_source -js_source $source] } {
            # source is utilities
            if { $source == "utilities"} {
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
            ns_log Notice "AJAXHELPER YUI: $source is already loaded or not valid"
        }
    }
}


ad_proc -public ah::yui::js_sources {
	{-source "default"}
	{-min:boolean}
} {

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
	set ah_base_url [ah::get_url]
    set script ""

    set minsuffix ""
    if { $min_p || [parameter::get_from_package_key -package_key "ajaxhelper" -parameter "UseMinifiedJs"] == 1 } {
        set minsuffix "-min"
    }

    # js_sources was called with no parameters, just load the defaults
    if { $source == "default" } {
        # yahoo has a compressed js file with  yahoo, dom and event all in one file (utilities)
        if { ![ah::is_js_sources_loaded -js_source "utilities"] } {
                append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/utilities/utilities.js\"></script> \n"
                # make sure it doesn't load again
                lappend ajax_helper_yui_js_sources "utilities"
        }
    }

	set js_file_list [split $source ","]

	foreach x $js_file_list {
		switch $x {
			"animation" {
				if { ![ah::yui::is_js_sources_loaded -js_source "animation"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/animation/animation${minsuffix}.js\"></script> \n"
				}
			}
			"event" {
				if { ![ah::yui::is_js_sources_loaded -js_source "event"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/event/event${minsuffix}.js\"></script> \n"
				}
			}
			"treeview" {
				if { ![ah::yui::is_js_sources_loaded -js_source "treeview"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/treeview/treeview${minsuffix}.js\"></script> \n"
				}
			}
			"calendar" {
				if { ![ah::yui::is_js_sources_loaded -js_source "calendar"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/calendar/calendar${minsuffix}.js\"></script> \n"
				}
			}
			"dragdrop" {
				if { ![ah::yui::is_js_sources_loaded -js_source "dragdrop"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/dragdrop/dragdrop${minsuffix}.js\"></script> \n"
				}
			}
			"slider" {
				if { ![ah::yui::is_js_sources_loaded -js_source "slider"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/slider/slider${minsuffix}.js\"></script> \n"
				}
			}
			"container" {
				if { ![ah::yui::is_js_sources_loaded -js_source "container"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/container/container${minsuffix}.js\"></script> \n"
					append script "<link rel=\"stylesheet\" type=\"text/css\" href=\"${ah_base_url}yui/container/assets/container.css\" /> \n"
				}
			}
			"menu" {
				if { ![ah::yui::is_js_sources_loaded -js_source "menu"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/menu/menu${minsuffix}.js\"></script> \n"
					append script "<link rel=\"stylesheet\" type=\"text/css\" href=\"${ah_base_url}yui/menu/assets/menu.css\" /> \n"
				}
			}
			"connection" {
				if { ![ah::yui::is_js_sources_loaded -js_source "connection"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/connection/connection${minsuffix}.js\"></script> \n"
				}
			}
			"dom" {
				if { ![ah::yui::is_js_sources_loaded -js_source "yahoo"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/dom/dom${minsuffix}.js\"></script> \n"
				}
            }
            "yahoo" {
				if { ![ah::yui::is_js_sources_loaded -js_source "yahoo"] } {
					append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/yahoo/yahoo${minsuffix}.js\"></script> \n"
				}
			}
            "utilities" {
                if { ![ah::yui::is_js_sources_loaded -js_source "utilities"] } {
                    append script "<script type=\"text/javascript\" src=\"${ah_base_url}yui/utilities/utilities.js\"></script> \n"
                }
            }
		}
	}
	return $script
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

    ah::yui::requires -sources "yahoo,event"

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

    ah::yui::requires -sources "utilities,container"

	set script "var $varname = new YAHOO.widget.Tooltip(\"alertTip\", { context:\"$element\", text:\"$message\", $options });"
	if { $enclose_p } { set script [ah::enclose_in_script -script ${script} ] }
	return $script
}

ad_proc -public ah::yui::create_tree {
	-element:required
	-nodes:required
	{-varname "tree"}
	{-css ""}
    {-enclose:boolean}
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

    ah::yui::requires -sources "utilities,treeview"
    global yahoo_treeview_css
    set yahoo_treeview_css $css

	set script "${varname} = new YAHOO.widget.TreeView(\"${element}\"); "
	append script "var ${varname}root = ${varname}.getRoot(); "
	foreach node $nodes {
		append script [ah::yui::create_tree_node -varname [lindex $node 0] \
				-label [lindex $node 1] \
				-treevarname [lindex $node 2] \
				-href [lindex $node 3] \
				-attach_to_node [lindex $node 4] \
				-dynamic_load [lindex $node 5] \
				-open [lindex $node 6] ]
	}
	append script "${varname}.draw(); "
    if { $enclose_p } { set script [ah::enclose_in_script -script ${script} ] }
	return $script
}

ad_proc -private ah::yui::create_tree_node {
	-varname:required
	-label:required
	-treevarname:required
	{-href "javascript:void(0)"}
	{-attach_to_node ""}
	{-dynamic_load ""}
	{-open "false"}
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

	if { [exists_and_not_null attach_to_node] } {
		append script "var node = ${treevarname}.getNodeByProperty('id','${attach_to_node}'); "
		append script "if ( node == null ) { var node = nd${attach_to_node}; } "

	} else {
		append script "var node = ${treevarname}root; "
	}
	if { ![exists_and_not_null open] } { set open "false" }
	append script "var nd${varname} = new YAHOO.widget.TextNode(od${varname},node,${open}); "

	if { [exists_and_not_null dynamic_load] } {
		append script "nd${varname}.setDynamicLoad(${dynamic_load}); "
	}

	return $script
}

ad_proc -public ah::yui::menu_from_markup {
    -varname:required
    -markupid:required
    {-enclose:boolean}
    {-arrayname "yuimenu"}
    {-css ""}
    {-options ""}
} {
    Generates the javascript to create a YUI menu from existing html markup.
    The resulting script is placed in an array named $arrayname which defaults to "yuimenu".
    The array will have 2 items $yuimenu(show) and $yuimenu(render).
        render holds the script that creates the Yui Menu widget while
        show holds the script to display the menu, the show script can be placed in an onclick event of an html element.

    http://developer.yahoo.com/yui/menu/

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2006-12-23

    @param varname The javascript variable to represent the menu object.
    @param markupid The html id of with the markup we want to transform into a menu.
    @param enclose Specify this if you want to enclose the entire script in script tags.
    @param arrayname Type the name of an array to use. "yuimenu" will be used if none is specified.
    @param css Specify the full path to a css style sheet file to use an alternative to the menu.css that is used.
    @param options Additional options that you want to pass to the javascript object constructor.

} {
    ah::yui::requires -sources "utilities,menu"

    global yahoo_menu_css
    set yahoo_menu_css $css

    set script "${varname} = new YAHOO.widget.Menu(\"${markupid}\",{${options}}); "
    append script "${varname}.render(); "

    set script [ah::yui::addlistener \
        -element "window" \
        -event "load" \
        -callback [ah::create_js_function -body ${script}] \
        -element_is_var ]

    if { $enclose_p } { set script [ah::enclose_in_script -script ${script} ] }

    set showscript "${varname}.show(); "

    upvar $arrayname arr
    set arr(render) $script
    set arr(show) $showscript
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
            if { [lindex $pair 0] == "submenu" } {
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
    {-enclose:boolean}
    {-arrayname "yuimenu"}
    {-css ""}
    {-options ""}
    {-renderin "document.body"}
} {
    Generates the javascript to create a YUI menu from a tcl list.
    The resulting script is placed in an array named $arrayname which defaults to "yuimenu".
    The array will have 2 items $yuimenu(show) and $yuimenu(render).
        render holds the script that creates the Yui Menu widget while
        show holds the script to display the menu, the show script can be placed in an onclick event of an html element.

    http://developer.yahoo.com/yui/menu/

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2006-12-25

    @param varname The javascript variable to represent the menu object.
    @param menulist A list of lists with the parameters this script needs to generate your menu.
    @param id The html id the menu element.
    @param enclose Specify this if you want to enclose the entire script in script tags.
    @param arrayname Type the name of an array to use. "yuimenu" will be used if none is specified.
    @param css Specify the full path to a css style sheet file to use an alternative to the menu.css that is used.
    @param options Additional options that you want to pass to the javascript object constructor.

} {

    ah::yui::requires -sources "utilities,menu"

    global yahoo_menu_css
    set yahoo_menu_css $css

    set jsonlist [ah::yui::menu_list_to_json -lists_of_pairs $menulist]

    set script "$varname = new YAHOO.widget.Menu(\"${id}\",{${options}}); "
    append script "$varname.addItems(\[${jsonlist}\]); "
    append script "${varname}.render(${renderin}); "

    set script [ah::yui::addlistener \
        -element "window" \
        -event "load" \
        -callback [ah::create_js_function -body ${script}] \
        -element_is_var ]

    if { $enclose_p } { set script [ah::enclose_in_script -script ${script} ] }

    set showscript "${varname}.show(); "

    upvar $arrayname arr
    set arr(render) $script
    set arr(show) $showscript

}

ad_proc -public ah::yui::contextmenu {
    -varname:required
    -id:required
    -menulist:required
    {-enclose:boolean}
    {-css ""}
    {-options ""}
    {-trigger "document"}
    {-renderin "document.body"}
} {
    Generates the javascript to create a YUI context menu from a tcl list.
    http://developer.yahoo.com/yui/menu/

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2006-12-25

    @param varname The javascript variable to represent the menu object.
    @param menulist A list of lists with the parameters this script needs to generate your menu.
    @param id The html id the menu element.
    @param enclose Specify this if you want to enclose the entire script in script tags.
    @param css Specify the full path to a css style sheet file to use an alternative to the menu.css that is used.
    @param options Additional options that you want to pass to the javascript object constructor.

} {

    ah::yui::requires -sources "utilities,menu"

    set jsonlist [ah::yui::menu_list_to_json -lists_of_pairs $menulist]

    set initoptions "trigger: ${trigger}"
    if { [exists_and_not_null options] } {
        set options "${initoptions},${options}"
    } else {
        set options "${initoptions}"
    }

    set script "var $varname = new YAHOO.widget.ContextMenu(\"${id}\", { ${options} } ); "
    append script "$varname.addItems(\[${jsonlist}\]); "
    append script "$varname.render(${renderin}); "

    set script [ah::yui::addlistener \
        -element "window" \
        -event "load" \
        -callback [ah::create_js_function -body ${script}] \
        -element_is_var ]

    if { $enclose_p } { set script [ah::enclose_in_script -script ${script} ] }
    return ${script}

}