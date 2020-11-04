ad_library {

	Library for Ajax Helper Procs
	based on the dojo javascript toolkit

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-05
}

namespace eval ah::dojo { }

ad_proc -private ah::dojo::load_js_sources {
	-source_list
} {
	Accepts a Tcl list of sources to load.
	This source_list will be the global ajax_helper_dojo_js_sources variable.
	This script is called in the blank-master template.

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-05
} {

	set ah_base_url [ah::get_url]
	set script "<script type=\"text/javascript\" src=\"${ah_base_url}dojo-ajax/dojo.js\"></script>\n"
	set dojo_script ""

	foreach source $source_list {
		switch $source {
			"event" {
				append dojo_script "dojo.require(\"dojo.event.*\"); "
			}
			"io" {
				append dojo_script "dojo.require(\"dojo.io.*\"); "
			}
			"dnd" {
				append dojo_script "dojo.require(\"dojo.dnd.*\"); "
			}
			"json" {
				append dojo_script "dojo.require(\"dojo.json\"); "
			}
			"storage" {
				append dojo_script "dojo.require(\"dojo.storage.*\"); "
			}
			"lfx" {
				append dojo_script "dojo.require(\"dojo.lfx.*\"); "
			}
            "collections" {
                append dojo_script "dojo.require(\"dojo.collections.Store\"); "
            }
			"chart" {
				append dojo_script "dojo.require(\"dojo.charting.Chart\"); "
			}
			"widget-chart" {
				append dojo_script "dojo.require(\"dojo.widget.Chart\"); "
			}
		}
	}
	append script [ah::enclose_in_script -script $dojo_script]
	return $script

	return ""
}

ad_proc -private ah::dojo::requires {
    -sources
} {
    This proc should be called by an ajaxhelper proc that uses dojo with a comma separated list of dojo javascript sources
        that the ajaxhelper proc needs in order to work.

        @author Hamilton Chua (ham@solutiongrove.com)
        @creation-date 2006-12-19
        @param sources Comma separated list of sources
} {
    #split up the comma delimited sources into a list
    set source_list [split $sources ","]
    #declare the global variable
    global ajax_helper_dojo_js_sources
    foreach source $source_list {
        # do some checks before we add the source to the global
        # - is it already loaded
        # - is it a valid source name
        # - is the source utilities or yahoo,dom,event
        if { ![ah::dojo::is_js_sources_loaded -js_source $source] && [ah::dojo::is_valid_source -js_source $source] } {
            # TODO : figure out other dependencies and possible overlaps and try to work them out here
            lappend ajax_helper_dojo_js_sources $source
        } else {
            # TODO : we must return an error/exception, for now just add a notice in the log
            ns_log debug "AJAXHELPER dojo: $source is already loaded or not valid"
        }
    }
}

ad_proc -private ah::dojo::is_js_sources_loaded {
	-js_source
} {
	This proc will loop thru source_list and check for the presence of js_source.
	If found, this proc will return 1
	If not found, this proc will return 0

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-05
} {
	global ajax_helper_dojo_js_sources
	set state 0
	if { [info exists ajax_helper_dojo_js_sources] } {
		foreach source $ajax_helper_dojo_js_sources {
			if { [string match $source $js_source] } {
				set state 1
				break
			}
		}
	}
	return $state
}

ad_proc -public ah::dojo::js_sources {
	{-source ""}
} {
	Generates the javascript that loads the dojo javascript sources.

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-05

} {
	set ah_base_url [ah::get_url]
	if { ![ah::dojo::is_js_sources_loaded -js_source "dojo"] } {
		set script "<script type=\"text/javascript\" src=\"${ah_base_url}dojo-ajax/dojo.js\"></script>"
	}
	set dojo_script ""

	foreach source $source_list {
		switch $source {
			"event" {
				if { ![ah::dojo::is_js_sources_loaded -js_source "event"] } {
					append dojo_script "dojo.require(\"dojo.event.*\"); "
				}
			}
			"io" {
				if { ![ah::dojo::is_js_sources_loaded -js_source "io"] } {
					append dojo_script "dojo.require(\"dojo.io.*\"); "
				}
			}
			"dnd" {
				if { ![ah::dojo::is_js_sources_loaded -js_source "dnd"] } {
					append dojo_script "dojo.require(\"dojo.dnd.*\"); "
				}
			}
			"json" {
				if { ![ah::dojo::is_js_sources_loaded -js_source "json"] } {
					append dojo_script "dojo.require(\"dojo.json\"); "
				}
			}
			"storage" {
				if { ![ah::dojo::is_js_sources_loaded -js_source "storage"] } {
					append dojo_script "dojo.require(\"dojo.storage.*\"); "
				}
			}
			"lfx" {
				if { ![ah::dojo::is_js_sources_loaded -js_source "lfx"] } {
					append dojo_script "dojo.require(\"dojo.lfx.*\"); "
				}
			}
            "collections" {
                if { ![ah::dojo::is_js_sources_loaded -js_source "collections"] } {
                    append dojo_script "dojo.require(\"dojo.collections.Store\"); "
                }
            }
			"chart" {
				if { ![ah::dojo::is_js_sources_loaded -js_source "chart"] } {
					append dojo_script "dojo.require(\"dojo.charting.Chart\"); "
				}
			}
			"widget-chart" {
				if { ![ah::dojo::is_js_sources_loaded -js_source "widget-chart"] } {
					append dojo_script "dojo.require(\"dojo.widget.Chart\"); "
				}
			}
		}
	}
	append script [ah::enclose_in_script -script $dojo_script]
	return $script
}

ad_proc -public ah::dojo::args {
	-varname:required
	-argslist:required
} {
	Builds a javascript object that holds the arguments that are commonly passed to a dojo function.

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-05

} {
	set objargs [list]
	foreach args $argslist {
		lappend objargs [join $args ":"]
	}
	set objargs [join $objargs ","]
	set script "var $varname = {$objargs}; "
	return $script
}

ad_proc -public ah::dojo::iobind {
	-objargs:required
} {
	Generates the javascript for a dojo io bind.
    Does the same thing as ah::ajaxrequest or ah::ajaxupdate
        but is more robust as dojo.io.bind is capable of using
        different transport layers. In fact, it's smart enough to determine
        which transport layer to use given a certain situation without bothering
        the developer. More details in the dojo book.
    http://manual.dojotoolkit.org/WikiHome/DojoDotBook/Book8

	@author Hamilton Chua (ham@solutiongrove.com)
	@creation-date 2006-11-05

	@param objargs A javascript object generated by ah::dojo::args which contain arguments that is passed to dojo.io.bind.
} {
    ah::dojo::requires -sources "dojo,io"
	set script "dojo.io.bind($objargs); "
	return $script
}

ad_proc -public ah::dojo::collections_store {
    -varname:required
    -lists_of_pairs:required
} {
    Creates a dojo collection store
} {
    ah::dojo::requires -sources "dojo,collections"
    set json [ah::dojo::util_list_to_json -lists_of_pairs $lists_of_pairs]
    set script "var ${varname}_data = \[$json\]; \n"
    append script "var ${varname} = new dojo.collections.Store(); ${varname}.setData(${varname}_data); \n"
    return $script
}

ad_proc -public ah::dojo::chart {
    -varname:required
    -node:required
    -datalist
    -serieslist
    -axislist
    -plotlist
    -onload:boolean
} {
    Creates a chart using the dojo charting engine
} {
    ah::dojo::requires -sources "dojo,chart"
}
