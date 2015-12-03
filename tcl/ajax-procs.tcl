ad_library {

	Library for Ajax Helper Procs

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-16
}

namespace eval ah { }

# ********** Use the acs-subsite extra headers callback to load ajaxhelper scripts ******************

ad_proc -public -callback subsite::get_extra_headers -impl my_implementation {} {
    replaces the ajaxhelper-template include
} {

    global ajax_helper_js_sources
    global ajax_helper_yui_js_sources
    global ajax_helper_dojo_js_sources
    global ajax_helper_custom_scripts
    global ajax_helper_init_scripts
    
    set js_sources ""
    set init_body ""
    
    if { [info exists ajax_helper_js_sources] } {
        append js_sources [ah::load_js_sources -source_list $ajax_helper_js_sources]
    }
    
    if { [info exists ajax_helper_yui_js_sources] } {
    
        append js_sources [ah::yui::load_js_sources -source_list $ajax_helper_yui_js_sources]
    
        # Yahoo has implemented a theming system, to make the css work, a class must be added
        #  to the body of the page before any widget is rendered
        append init_body [ah::yui::cssclass \
                -varname "yuiclass" \
                -action "add" \
                -element "document.body" \
                -classname "yui-skin-sam" \
                -element_is_var ]
    }
    
    if { [info exists ajax_helper_dojo_js_sources] } {
        append js_sources [ah::dojo::load_js_sources -source_list $ajax_helper_dojo_js_sources]
    }
    
    if { ![info exists ajax_helper_custom_scripts] } { set ajax_helper_custom_scripts "" }
    if { [info exists ajax_helper_init_scripts] } { append init_body $ajax_helper_init_scripts } 
    
    set js_init_script [ah::create_js_function -name "ah_page_init" -body ${init_body}]
    
    set script "
    ${js_init_script}
    ${ajax_helper_custom_scripts}
    "

    set js_sources "[ah::enclose_in_script -script ${script}] $js_sources"

    return $js_sources

} 


# ********* Loading Sources **********

ad_proc -private ah::requires {
    -sources
} {
    This proc should be called by an ajaxhelper proc with a comma separated list of javascript sources
        that the ajaxhelper proc needs in order to work.

        @author Hamilton Chua (ham@solutiongrove.com)
        @creation-date 2006-12-19
        @param sources Comma separated list of sources
} {
    #split up the comma delimited sources into a list
    set source_list [split $sources ","]

    set ah_base_url [ah::get_url]
    set script ""
    set minsuffix ""
    if { [parameter::get_from_package_key -package_key "ajaxhelper" -parameter "UseMinifiedJs"] == 1 } {
        set minsuffix "-min"
    }

    foreach source $source_list {
        switch $source {
            "rounder" {
                template::head::add_javascript -src "${ah_base_url}curvycorners/rounded_corners_lite.inc.js"
            }
            "overlibmws" {
                template::head::add_javascript -src "${ah_base_url}overlibmws/overlibmws${minsuffix}.js"
            }
            "overlibmws_bubble" {
                template::head::add_javascript -order 1 -src "${ah_base_url}overlibmws/overlibmws${minsuffix}.js"
                template::head::add_javascript -order 2 -script "var OLbubbleImageDir=\"${ah_base_url}overlibmws\";"
                template::head::add_javascript -order 3 -src "${ah_base_url}overlibmws/overlibmws_bubble${minsuffix}.js"
            }
            "overlibmws_scroll" {
                template::head::add_javascript -order 1 -src "${ah_base_url}overlibmws/overlibmws${minsuffix}.js"
                template::head::add_javascript -order 2 -src "${ah_base_url}overlibmws/overlibmws_scroll${minsuffix}.js"
            }
            "overlibmws_drag" {
                template::head::add_javascript -order 1 -src "${ah_base_url}overlibmws/overlibmws${minsuffix}.js"
                template::head::add_javascript -order 2 -src "${ah_base_url}overlibmws/overlibmws_draggable${minsuffix}.js"
            }
            "prototype" {
                template::head::add_javascript -src "${ah_base_url}prototype/prototype${minsuffix}.js"
            }
            "scriptaculous" {
                template::head::add_javascript -order 1 -src "${ah_base_url}prototype/prototype${minsuffix}.js"
                template::head::add_javascript -order 2 -src "${ah_base_url}scriptaculous/scriptaculous.js"
            }
            "autosuggest" {
                template::head::add_javascript -order 1 -src "${ah_base_url}prototype/prototype${minsuffix}.js"
                template::head::add_javascript -order 2 -src "${ah_base_url}autosuggest/autosuggest.js"
                template::head::add_css -href "${ah_base_url}autosuggest/autosuggest.css"
            }
        }
    }
}

ad_proc -public ah::js_sources {
	{-source "default"}
} {
    DEPRECATED. Use ah::requires instead.

	Will load any of the following javascript sources
		prototype,
		scriptaculous,
		rounder,
		overlibmws.
	This will also check global variables.
	If the sources have already been defined, we will not define them again.
	Once the js_source has been loaded, the global variable with list of sources will be updated.
	Calling this function is not necessary anymore as long as the required code to dynamically call
		javascript functions is in the blank-master template, unless of course you want to write your own javascript.

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-16

	@param source The caller can specify which set of javascript source files to load. This can be a comma seprated list
		Valid values include
		"default" : to load prototype and scriptaculous libraries
		"rounder" : to load the rico corner rounder functions only, use this if you are working primarily with scriptaculous,
		"overlibmws" : to load the overlibmws javascript files for dhtml callouts and popups.
		"overlibmws_bubble" : to load the overlibmws javascript files for dhtml callouts and popups.
		"overlibmws_scroll" : to load the overlibmws javascript files for dhtml bubble callouts and popups that scroll.
		"overlibmws_drag" : to load the overlibmws javascript files for draggable dhtml callouts and popups.
        "prototype" : to load ONLY the prototype javascript source.
        "scriptaculous" : to load all scriptaculous javascript sources.

	@return
	@error
} {

	set ah_base_url [ah::get_url]
    set script ""

    set minsuffix ""
    if { [parameter::get_from_package_key -package_key "ajaxhelper" -parameter "UseMinifiedJs"] == 1 } {
        set minsuffix "-min"
    }

    # js_sources was called with no parameters, just load the defaults
    if { $source eq "default" } {
        if { ![ah::is_js_sources_loaded -js_source "prototype"] } {
                # load prototype
                template::head::add_javascript -src "${ah_base_url}prototype/prototype${minsuffix}.js"
                # make sure helper procs don't load it again
                lappend ajax_helper_js_sources "prototype"
        }
        if { ![ah::is_js_sources_loaded -js_source "scriptaculous"] } {
                # load scriptaculous
                template::head::add_javascript -src "${ah_base_url}scriptaculous/scriptaculous${minsuffix}.js"
                # make sure it doesn't get loaded again
                lappend ajax_helper_js_sources "scriptaculous"
        }
    }

	set js_file_list [split $source ","]

	foreach x $js_file_list {
		switch $x {
			"rounder" {
				if { ![ah::is_js_sources_loaded -js_source "rounder"] } {
					template::head::add_javascript -src "${ah_base_url}curvycorners/rounded_corners_lite.inc.js"
				}
			}
			"overlibmws" {
				if { ![ah::is_js_sources_loaded -js_source "overlibmws"] } {
					template::head::add_javascript -src "${ah_base_url}overlibmws/overlibmws${minsuffix}.js"
					template::head::add_javascript -src "${ah_base_url}overlibmws/overlibmws_overtwo${minsuffix}.js"
				}
			}
			"overlibmws_bubble" {
				if { ![ah::is_js_sources_loaded -js_source "overlibmws_bubble"] } {
					template::head::add_javascript -script "var OLbubbleImageDir=\"${ah_base_url}overlibmws\";"
					template::head::add_javascript -src "${ah_base_url}overlibmws/overlibmws_bubble${minsuffix}.js"
				}
			}
			"overlibmws_scroll" {
				if { ![ah::is_js_sources_loaded -js_source "overlibmws_scroll"] } {
					template::head::add_javascript -src "${ah_base_url}overlibmws/overlibmws_scroll${minsuffix}.js"
				}
			}
			"overlibmws_drag" {
				if { ![ah::is_js_sources_loaded -js_source "overlibmws_drag"] } {
					template::head::add_javascript -src "${ah_base_url}overlibmws/overlibmws_draggable${minsuffix}.js"
				}
			}
            "prototype" {
                if { ![ah::is_js_sources_loaded -js_source "prototype"] } {
                    template::head::add_javascript -src "${ah_base_url}prototype/prototype${minsuffix}.js"
                }
            }
            "scriptaculous" {
                if { ![ah::is_js_sources_loaded -js_source "scriptaculous"] } {
                    template::head::add_javascript -src "${ah_base_url}scriptaculous/scriptaculous${minsuffix}.js"
                }
            }
            "autosuggest" {
                if { ![ah::is_js_sources_loaded -js_source "autosuggest"] } {
                    template::head::add_javascript -src "${ah_base_url}autosuggest/autosuggest.js"
                    template::head::add_css -href "${ah_base_url}autosuggest/autosuggest.css"
                }
            }
		}
	}

	return $script
}

# ********* UTILS ************

ad_proc -public ah::util_list_to_json {
    -lists_of_pairs
} {
    Converts a properly structured list of lists into JSON format.
        The list of lists may look something like

            set data [list]
            lappend data [list [list "x" "1"] [list "y" "10"] ]
            lappend data [list [list "x" "5"] [list "y" "20"] ]

        each line represents a row composed of lists.
        Each list in the row holds a pair that will be joined by ":".
} {
    set rows [list]
    foreach row $lists_of_pairs {
        set pairs [list]
        foreach pair $row {
            lappend pairs [join $pair ":"]
        }
        lappend rows [join $pairs ","]
    }
    return "\{[join $rows "\},\{"]\}"
}

ad_proc -private ah::get_package_id  {

} {
	Return the package_id of the installed and mounted ajax helper instance

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-16
	@return

	@error

} {
	return [apm_package_id_from_key "ajaxhelper"]
}

ad_proc -private ah::get_url  {

} {
	Return the path to the ajaxhelper resource files

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-16
	@return

	@error

} {
	return "/resources/ajaxhelper/"
}

ad_proc -private ah::isnot_js_var {
	element
} {
	Receives a string and surrounds it with single quotes.
	This is a utility proc used to turn a parameter passed to a proc into a string.
	The assumption is that an element passed as a parameter is a javascript variable.

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-16
	@return
} {
	return "'$element'"
}

ad_proc -private ah::enclose_in_script {
	-script:required
} {
	Encloses whatever is passed to the script parameter in javascript tags.
	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-16

	@param script string to enclose in javascript tags.
} {
	set tag "<script language=\"javascript\" type=\"text/javascript\"> \n"
	append tag ${script}
	append tag "\n</script>"
	return $tag
}

ad_proc -public ah::create_js_function {
	-body:required
	{-name ""}
	{-parameters "" }
} {
	Helper procedure to generate a javascript function
	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-05

	@param name The name of the javascript function
	@param body The body of the javascript function
	@param parameters The comma separated list of parameters of the javascript function
} {
	set script "function ${name} ("
	if { $parameters ne "" } { append script [join $parameters ","] }
	append script ") \{ $body \}"
	return $script
}

ad_proc -public ah::insert {
	-element:required
	-text:required
	{-position "After"}
} {
	Inserts text or html in a position given the element as reference.
	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-05

	@param element The element that will be used as reference
	@param text What you want to insert.
	@param position Where you want to insert text. This is case sensitive. Possible values include After, Bottom, Before and Top. Defaults to After.
} {

	ah::requires -sources "prototype"

	set script "new Insertion.${position}('${element}','${text}'); "
	return $script
}

# ************ Listeners **************

ad_proc -public ah::starteventwatch {
	-element:required
	-event:required
	-obs_function:required
	{-element_is_var:boolean}
	{-useCapture "false"}
} {
	Use prototype's Event object to watch/listen for a specific event from a specific html element.
	Valid events include click, load, mouseover etc.
        See ah::yui::addlistener for Yahoo's implementation which some say is superior.
	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-02-28

	@param element the element you want to observe
	@param event the event that the observer will wait for
	@param obs_function the funcion that will be executed when the event is detected

} {
	ah::requires -sources "prototype"

	if { !$element_is_var_p } {
		set element [ah::isnot_js_var $element]
	}
	set script "Event.observe(${element}, '${event}', ${obs_function}, $useCapture);"
	return $script
}

ad_proc -public ah::stopeventwatch {
	-element:required
	-event:required
	-obs_function:required
	{-useCapture "false"}
	{-element_is_var:boolean}
} {
	Use prototype's Event object to watch/listen to a specific event from a specific html element.
	Valid events include click, load, mouseover etc.
	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-02-28

	@param element the element you want to observe
	@param event the event that the observer will wait for
	@param obs_function the funcion that will be executed when the event is detected

} {
    ah::requires -sources "prototype"

	if { !$element_is_var_p } {
		set element [ah::isnot_js_var $element]
	}
	set script "Event.stopObserving(${element}, '${event}', ${obs_function}, $useCapture);"
	return $script
}


# *********** Ajax Procs *************

ad_proc -public ah::ajaxperiodical {
	-url:required
	-container:required
	{-frequency "5"}
	{-asynchronous "true"}
	{-pars ""}
	{-options ""}
} {
	Returns javascript that calls the prototype javascript library's ajax periodic updater object.
	This object makes "polling" possible. Polling is a way by which a website can regularly update itself.
	The ajax script is executed periodically in a set interval.
	It has the same properties as ajax update, the only difference is that it is executed after x number of seconds.
	Parameters and options are case sensitive, refer to scriptaculous documentation
	http://wiki.script.aculo.us/scriptaculous/show/Ajax.PeriodicalUpdater

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2006-11-05

    @param url the url that the ajax will call
    @param container the html object that will get updated periodically
    @param frequency how often is the script called, default is 5 seconds
} {

    ah::requires -sources "prototype"

	set preoptions "asynchronous:${asynchronous},frequency:${frequency},method:'post'"

	if { $pars ne "" } {
		append preoptions ",parameters:$pars"
	}
	if { $options ne "" } { append preoptions ",$options" }
	set script "new Ajax.PeriodicalUpdater('$container','$url',{$preoptions}); "

	return $script

}

ad_proc -public ah::ajaxrequest {
	-url:required
	{-asynchronous "true"}
	{-pars ""}
	{-options ""}
} {
	Returns javascript that calls the prototype javascript library's ajax request (Ajax.Request) object.
	The Ajax.Request object will only perform an xmlhttp request to a url.
	If you prefer to perform an xmlhttp request and then update the contents of a < div >, look at ah::ajaxupdate.
	Parameters and options are case sensitive, refer to scriptaculous documentation.
	http://wiki.script.aculo.us/scriptaculous/show/Ajax.Request

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-16

	@param url the url that the javascript will call/query
	@param pars the parameters that will be passed to Ajax.Request. these parameters should normally be enclosed in single quotes ('') unless you intend to provide a javascript variable or function as a parameter
	@param options the options that will be passed to the Ajax.Request javascript function
    @param asynchronous the default is true

} {

    ah::requires -sources "prototype"

	set preoptions "asynchronous:${asynchronous},method:'post'"

	if { $pars ne "" } {
		append preoptions ",parameters:$pars"
	}
	if { $options ne "" } { append preoptions ",$options" }
	set script "new Ajax.Request('$url',{$preoptions}); "

	return $script
}

ad_proc -public ah::ajaxupdate {
	-container:required
	-url:required
	{-asynchronous "true"}
	{-pars ""}
	{-options ""}
	{-effect ""}
	{-effectopts ""}
	{-enclose:boolean}
	{-container_is_var:boolean}
} {
	Generate an Ajax.Updater javascript object.
	The parameters are passed directly to the Ajax.Update script.
	You can optionally specify an effect to use as the container is updated.
	By default it will use the "Appear" effect.
	Parameters and options are case sensitive, refer to scriptaculous documentation.
	http://wiki.script.aculo.us/scriptaculous/show/Ajax.Updater

	<pre>
		set script [ah::ajaxupdate -container "connections"  \
				-url "/xmlhttp/getconnections" \
				-pars "'q=test&limit_n=3'"
				-enclose  \
				-effectopts "duration: 1.5"]
	</pre>

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-16

	@param container the 'id' of the layer (div) you want to update via ajax
	@param url the url that will be querried for the content to update the container's innerHtml
	@param options optional parameters that you can pass to the Ajax.Updater script
	@param effect optionally specify an effect to use as the container is updated
	@param effectopts options for the effect
	@param enclose optionally specify whether you want your script to be enclosed in < script > tags

	@return

	@error
} {

    ah::requires -sources "scriptaculous"

	if { !$container_is_var_p } {
		set container [ah::isnot_js_var $container]
	}

	set preoptions "asynchronous:$asynchronous,method:'post'"

	if { $pars ne "" } {
		append preoptions ",parameters:$pars"
	}
	if { $options ne "" } { append preoptions ",$options" }

	if { $effect ne "" } {
		set effects_script [ah::effects -element $container -effect $effect -options $effectopts -element_is_var]
		append preoptions ",onSuccess: function(t) { $effects_script }"
	}

	set script "new Ajax.Updater ($container,'$url',\{$preoptions\}); "

	if { $enclose_p } { set script [ah::enclose_in_script -script ${script} ] }

	return $script
}

# *********** Overlib PopUp **************

ad_proc -public ah::popup {
	-content:required
	{-options ""}
} {
	This proc will generate javascript for an overlibmws popup.
	This script has to go into a javscript event like onClick or onMouseover.
	The ah::source must be executed with -source "overlibmws"
	For more information about the options that you can pass
	http://www.macridesweb.com/oltest/
        See ah::yui::tooltip for Yahoo's implementation

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-02-12

	@param content this is what the popup will contain or display. if content is text, enclose it in single quotes (' ').
	@param options the options to pass to overlibmws

	@return

	@error

} {

    ah::requires -sources "overlibmws"

	if { $options ne "" } {
		set overlibopt ","
		append overlibopt $options
	} else {
		set overlibopt ""
	}
	set script "return overlib\(${content}${overlibopt}\);"
	return $script
}

ad_proc -public ah::clearpopup {

} {
	This proc will generate javascript for to clear a popup.
	This script has to go into a javscript event like onClick or onMouseover.
	The ah::source must be executed with -source "overlibmws"

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-02-12

	@return

	@error

} {

    ah::requires -sources "overlibmws"

	set script "nd();"
	return $script
}

ad_proc -public ah::bubblecallout {
	-text:required
	{-type "square"}
	{-textsize "x-small"}
} {

	This proc will generate mouseover and mouseout javascript
	for dhtml callout or popup using overlibmws
	and the overlibmws bubble plugin.

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-16

	@param type this is passed to the overlibmws script, refer to overlib documentation for possible values.
	@param text the text that will appear in the popup.
	@param textsize the size of the text in the popup

	@return
	@error

} {

    ah::requires -sources "overlibmws_bubble"

	set script "onmouseover=\""
	append script [ah::popup -content "'$text'" -options "BUBBLE,BUBBLETYPE,'$type',TEXTSIZE,'$textsize'"]
	append script "\" onmouseout=\""
	append script [ah::clearpopup]
	append script "\""
	return $script
}

ad_proc -public ah::ajax_bubblecallout {
	-url:required
	{-pars ""}
	{-options ""}
	{-type "square"}
	{-textsize "x-small"}
} {
	This proc executes an xmlhttp call and outputs the response text in a bubblecallout.

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-16

	@param url the url to make the xmlhttp call to
	@param pars the parameters in querystring format you want to pass to the url
        @param options the options you want to pass to overlibmws
        @param type parameter specific to the bubble callout
        @param textsize the size of the text in the callout

	@return

	@error
} {

    ah::requires -sources "overlibmws_bubble"

	set popup [ah::popup -content "t.responseText" -options "BUBBLE,BUBBLETYPE,'$type',TEXTSIZE,'$textsize'"]
	set request [ah::ajaxrequest -url $url -pars '$pars' -options "onSuccess: function(t) { $popup }" ]
	set script "onmouseover=\"$request\" onmouseout=\"nd();\""
	return $script
}

# ********** Effects **************

ad_proc -public ah::effects {
	-element:required
	{-effect "Appear"}
	{-options ""}
	{-element_is_var:boolean}
} {
	Generates javascript for effects by scriptaculous.
	Refer to the scriptaculous documentaiton for a list of effects.
	This proc by default will use the "Appear" effect
	The parameters are passed directly to the scriptaculous effects script.
	Parameters and options are case sensitive, refer to scriptaculous documentation.
	http://wiki.script.aculo.us/scriptaculous/show/CoreEffects

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-16

	@param element the page element that you want to apply the effect to
	@param effect specify one of the scriptaculous effects you want to implement
	@param options specify the options to pass to the scritpaculous javascript
        @param element_is_var specify this if the element you are passing is a javascript variable

	@return
	@error

} {
    ah::requires -sources "scriptaculous"

	if { !$element_is_var_p } {
		set element [ah::isnot_js_var $element]
	}
	set script "new Effect.$effect\($element,\{$options\}\); "
	return $script
}

ad_proc -public ah::toggle {
	-element:required
	{-effect "Appear"}
	{-options ""}
	{-element_is_var:boolean}
} {
	Generates javascript that toggles the state of an element.
	The parameters are passed directly to the scriptaculous toggle script.
	Parameters and options are case sensitive, refer to scriptaculous documentation.
	http://wiki.script.aculo.us/scriptaculous/show/Effect.toggle

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-02-23

	@param element the page element that you want to apply the effect to
	@param effect specify one of the scriptaculous effects you want to toggle
	@param options specify the options to pass to the scritpaculous javascript
        @param element_is_var specify this if the element you are passing is a javascript variable

        @return
	@error

} {
    ah::requires -sources "scriptaculous"

	if { !$element_is_var_p } {
		set element [ah::isnot_js_var $element]
	}
	set script "Effect.toggle\($element,'$effect',{$options}\)"
	return $script
}

# ********** Drag n Drop **************

ad_proc -public ah::draggable {
	-element:required
	{-options ""}
	{-uid ""}
	{-element_is_var:boolean}
} {
	Generates javascript to make the given element a draggable.
	The parameters are passed directly to the scriptaculous script.
	Parameters and options are case sensitive, refer to scriptaculous documentation.
	http://wiki.script.aculo.us/scriptaculous/show/Draggables

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-24

	@param element the page element that you want to make draggable
	@param options specify the scriptaculous options
	@param uid provide a unique id that is used as a variable to associate with the draggable
	@param element_is_var specify this parameter if the element you are passing is a javscript variable

	@return

	@error

} {
    ah::requires -sources "scriptaculous"

	if { !$element_is_var_p } {
		set element [ah::isnot_js_var $element]
	}
	set script "new Draggable \($element,\{$options\}\);"
	return $script
}

ad_proc -public ah::droppable {
	-element:required
	{-options ""}
	{-uid ""}
	{-element_is_var:boolean}
} {
	Generates javascript to make the given element a droppable.
	If a uid parameter is provided, the script will also check if the droppable with the same uid has already been created.
	The parameters are passed directly to the scriptaculous script.
	Parameters and options are case sensitive, refer to scriptaculous documentation.
	http://wiki.script.aculo.us/scriptaculous/show/Droppables

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-02-24

	@param element the page element that you want to be a droppable
	@param element_is_var specify this parameter if the element you are passing is a javscript variable
	@param uid provide a unique id that is used as a variable to associate with the droppable
	@param options specify the scriptaculous options for droppables

	@return

	@error

} {
    ah::requires -sources "scriptaculous"

	if { !$element_is_var_p } {
		set element [ah::isnot_js_var $element]
	}

	set script "Droppables.add (${element},{${options}});"

	return $script
}

ad_proc -public ah::droppableremove {
	-element:required
	{-element_is_var:boolean}
} {
	Generates javascript to remove a droppable.
	The parameters are passed directly to the scriptaculous script.
	Parameters and options are case sensitive, refer to scriptaculous documentation.
	http://wiki.script.aculo.us/scriptaculous/show/Droppables

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-02-24

	@param element the page element that you want to be a droppable
	@param element_is_var specify this parameter if the element you are passing is a javscript variable

	@return
	@error

} {

    ah::requires -sources "scriptaculous"

	if { !$element_is_var_p } {
		set element [ah::isnot_js_var $element]
	}
	set script "Droppables.remove \($element);"
	return $script
}


ad_proc -public ah::sortable {
	-element:required
	{-options ""}
	{-element_is_var:boolean}
} {
	Generates javascript for sortable elements.
	The parameters are passed directly to the scriptaculous sortable script.
	Parameters and options are case sensitive, refer to scriptaculous documentation.
	http://wiki.script.aculo.us/scriptaculous/show/Sortables

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-24

	@param element the page element that you want to apply the effect to
	@param options specify the scriptaculous options
	@param element_is_var specify this parameter if the element you are passing is a javscript variable

	@return
	@error

} {

    ah::requires -sources "scriptaculous"

	if { !$element_is_var_p } {
		set element [ah::isnot_js_var $element]
	}
	set script "Sortable.destroy($element); "
	append script "Sortable.create\($element, \{$options\}\); "
	return $script
}

# ********** Round Corners ************

ad_proc -public ah::rounder {
	-classname:required
	{-jsobjname "myBoxObject"}
	{-validtags "div"}
	{-radius "20"}
	{-element_is_var:boolean}
	{-enclose:boolean}
} {
	Generates javascript to round html div elements.
	Parameters are case sensitive.
	http://www.curvycorners.net/

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-01-24

	@param classname The name of the html class that the script will look for. All validtags with this classname will be rounded.
	@param jsobjname The javascript object name you want to use.
	@param validtags Comma separated values of valid tags to apply rounded corners. Values include "div", "form" or "div,form"
	@param radius The radius of the rounded corners.

} {


    ah::requires -sources "rounder"

	if { !$element_is_var_p } {
		set element [ah::isnot_js_var $element]
	}

	set script "var settings = { tl: { radius: ${radius} },tr: { radius: ${radius} },bl: { radius: ${radius} },br: { radius: ${radius} },antiAlias: true,autoPad: true,validTags: \[\"${validtags}\"\]};
	var ${jsobjname} = new curvyCorners(settings, \"${classname}\");
	${jsobjname}.applyCornersToAll();"

	if { $enclose_p } { set script [ah::enclose_in_script -script ${script} ] }

	return $script
}

# ************* Auto Suggest *****************

ad_proc -public ah::generate_autosuggest_array {
    {-array_list {}}
    {-sql_query {}}
} {
    Generates a javascript array for inclusion in a page header.
    This array will be used as values for the autosuggestbox.
    Array is a two-dimensional array with first elements the word
    for autosuggesting and the second is for the description

    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2006-06-21

    @param array_list a list of lists which will be constructed
                      as the javascript array. this takes priority
                      over sql_query parameter.
    @param sql_query  sql query to pass to db_list_of_lists to generate
                      the array
} {


    ah::requires -sources "autosuggest"

    if {[llength $array_list]} {
	set suggestion_list $array_list
    } elseif {$sql_query ne {} } {
	set suggestion_list [db_list_of_lists get_array_list $sql_query]
    } else {
	# just do something for failover
	set suggestion_list {}
    }

    set suggestions_stub {}

    append suggestions_stub "
function AUTOSuggestions() {
    this.auto = \[
    "

set suggestion_formatted_list {}
foreach suggestion $suggestion_list {
    lappend suggestion_formatted_list "\[\"[lindex $suggestion 0]\",\"[lindex $suggestion 1]\"\]"
}

append suggestions_stub [join $suggestion_formatted_list ","]

append suggestions_stub "
    \];
}
"
append suggestions_stub {
    AUTOSuggestions.prototype.requestSuggestions = function (oAutoSuggestControl /*:AutoSuggestControl*/,
							     bTypeAhead /*:boolean*/) {
								 var aSuggestions = [];
								 var aDescriptions = [];
								 var sTextboxValue = oAutoSuggestControl.textbox.value.toLowerCase();

								 if (sTextboxValue.length > 0){

								          //search for matching states
									  for (var i=0; i < this.auto.length; i++) {
														    if (this.auto[i][0].toLowerCase().indexOf(sTextboxValue) == 0) {
															aSuggestions.push(this.auto[i][0]);
															aDescriptions.push(this.auto[i][1]);
														    }
														}
								      }

								  //provide suggestions to the control
								 oAutoSuggestControl.autosuggest(aSuggestions, aDescriptions, bTypeAhead);
							     };
}

return $suggestions_stub

}
