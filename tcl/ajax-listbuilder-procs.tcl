ad_library {
    Ajax enahanced list builder features
    
    @author Dave Bauer (dave@solutiongrove.com)
    @creation-date 2007-08-21

}

namespace eval ah::lb:: {}

ad_proc ah::lb::add_column_menu {
    -list_name
    -element_names
    {-menus {sort group move hide}}
    {-return_url ""}
    {-hide_url_var "hide"}
} {
    Add dynamic dropdown menus
    
    @param list_name Name of template::list list to work with
    @param element_names List of element names to attach the menus tp
    @param menus List of menus to add options include
    <ul>
    <li>sort Sort by A-Z, Z-A</li>
    <li>group Group by Exact Value, First Letter</li>
    <li>move Move left, right, after (additional menu of itmes to move after)</li>
    <li>hide Choose to hide a column</li>
} {
    if {$return_url eq ""} {
        set return_url [ad_conn url]
    }
    upvar $hide_url_var _hide_column
    if {[info exists _hide_column]} {
        set hide_column $_hide_column
    } else {
        set hide_column [list]
    }
    upvar move _move 
    if {[info exists _move]} {
        set move $_move
    } else {
        set move [list]
    }
    upvar groupby _groupby
    set previous_index 0
    set index 0
    set first_not_checkbox ""

    template::list::get_reference -name $list_name
    upvar #[template::adp_level] ${list_name}:filter:groupby:properties groupby_ref

    set groupbys [list]
    foreach elm $groupby_ref(values) {
	set value [lindex $elm 1]
        lappend groupbys [lindex $value 0 1]
    }

    foreach {name value} [array get list_properties] {
        append output "<h2>$name<h2>$value"
    }

#    ad_return_complaint 1 $output

    set menudata ""
    set init_listeners ""

    foreach element $element_names {
        
        template::list::element::get_reference -list_name $list_name -element_name $element
        
        if { ![regexp "input type" $element_properties(label) isEl] && $element_properties(label) ne "" } {
            if {$first_not_checkbox eq ""} {
                set first_not_checkbox 1
            }
            
            set sortmenuitems [list]
            lappend sortmenuitems [list [list "text" "A-Z"] [list "url" "[filter_url -list_name $list_name -filter_name orderby -filter_value ${element},asc -return_url $return_url]"]]
            lappend sortmenuitems [list [list "text" "Z-A"] [list "url" "[filter_url -list_name $list_name -filter_name orderby  -filter_value ${element},desc -return_url $return_url]"]]
	    
            set groupmenuitems [list]	    

            lappend groupmenuitems [list [list "text" "By Exact Value"] [list "url" "[filter_url -list_name $list_name -filter_name groupby -filter_value $element -return_url $return_url]"] ]
#            lappend groupmenuitems [list [list "text" "By First Letter"] [list "url" "javascript:void(0)"] ]
	   
	    set movemenuitems [list]
            set this_move $move
            if {[set this_move_index [lsearch $move $element]] > -1} {
                set this_move [lreplace $move $this_move_index [expr {$this_move_index + 1}]]
            }
            if {$previous_index < $index} {
                lappend movemenuitems [list [list "text" "Left"] [list "url" "[filter_url -list_name $list_name -filter_name move -filter_value [concat $this_move [list $element $previous_index]] -return_url $return_url]"]]
            }
            if {$previous_index < [llength $list_properties(display_elements)]} {
                lappend movemenuitems [list [list "text" "Right"] [list "url" "[filter_url -list_name $list_name -filter_name move -filter_value [concat $this_move [list $element [expr {$index + 1}]]] -return_url $return_url]"]]
            }
            if {$index > $first_not_checkbox} {
                lappend movemenuitems [list [list "text" "First"] [list "url" "[filter_url -list_name $list_name -filter_name move -filter_value [concat $this_move [list $element $first_not_checkbox]] -return_url $return_url]"]]
            }

            set menulist [list]
            if {[lsearch $list_properties(orderby_refs) "*${element_properties(name)}*"] > -1} {
               lappend menulist [list [list "text" "Sort"] [list "submenu" [list [list "id" "sort-$element_properties(name)"] [list "itemdata" $sortmenuitems] ] ] ]
            }
            if {[lsearch $groupbys $element_properties(name)] > -1} {
		if {[info exists _groupby] && $element eq $_groupby} {
		    lappend menulist [list [list "text" "Ungroup"] [list "url" "[export_vars -base [ad_conn url] {{clear_one groupby}}]"]]
		} else {
		    lappend menulist [list [list "text" "Group"] [list "url" "[filter_url -list_name $list_name -filter_name groupby -filter_value $element -return_url $return_url]"]]
#		    lappend menulist [list [list "text" "Group"] [list "submenu" [list [list "id" "group-$element_properties(name)"] [list "itemdata" $groupmenuitems] ] ] ]
		}
            }
            if {[llength $movemenuitems]} {
		lappend menulist [list [list "text" "Move"] [list "submenu" [list [list "id" "move-$element_properties(name)"] [list "itemdata" $movemenuitems]]]]
	    }

            if {[info exists element_properties(filter_names)]} {
                set filter_url [ah::lb::multiple_filter_url -list_name $list_name -filter_names $element_properties(filter_names) -return_url $return_url]
            } else {
                set filter_url [ah::lb::filter_url -list_name $list_name -filter_name $element -return_url $return_url]
            }

            if {[lsearch $list_properties(filters) $element_properties(name)] > -1 || [info exists element_properties(filter_names)]} {
                lappend menulist [list [list "text" "Add Filter"] [list "url" $filter_url]]
            }
            lappend menulist [list [list "text" "Hide"] [list "url" "[filter_url -list_name $list_name -filter_name hide -filter_value [concat $hide_column $element] -return_url $return_url]"] ]
	    
#	        ah::yui::menu_from_list -varname "oMenu$element_properties(name)" \
#	            -id "menu-$element_properties(name)" \
#	            -menulist $menulist \
#	            -triggerel "header_$element_properties(name)" \
#	            -triggerevent "click" \
#	            -options "context:new Array(\"header_$element_properties(name)\",\"tl\",\"bl\"),position:'dynamic',width:120"

            append menu_data "var data_$element_properties(name)=\[[ah::yui::menu_list_to_json -lists_of_pairs $menulist]\]; "
            append init_listeners [ah::yui::addlistener \
                    -element "header_$element_properties(name)" \
                    -event "click" \
                    -callback [ah::create_js_function -body "YAHOO.util.Event.preventDefault(e); showMenu(\"header_$element_properties(name)\",data_$element_properties(name));" -parameters [list "e"] ] ]

            if {$previous_index < $index} {
                incr previous_index
            }
            incr index

    	} else {
            incr previous_index
            incr index
        }
    }

    set custom_script $menu_data
    append custom_script "var menuObj = null; "
    append custom_script "function showMenu(triggerel,menudata) { if(menuObj == null) { menuObj = new YAHOO.widget.Menu('listbuilder-menu',{context:new Array(triggerel,\"tl\",\"bl\"),position:'dynamic',width:120}) } else { menuObj.cfg.setProperty(\"context\", new Array(triggerel,\"tl\",\"bl\")); menuObj.clearContent() } menuObj.addItems(menudata); menuObj.render(document.body); menuObj.show() } "

    global ajax_helper_custom_scripts
    append ajax_helper_custom_scripts $custom_script

    global ajax_helper_init_scripts
    append ajax_helper_init_scripts $init_listeners
}

ad_proc ah::lb::add_add_column_menu {
    -list_name
    {-allowed_elements {}}
    {-add_url_var "add_column"}
    {-return_url ""}
} {
    Create a dropdown menu to add a column to be dislayed

    @param list_name template::list list name
    @param allowed_elements List of element names that may appear in add
    column dropdown
    @parma add_url_var Name of URL variable to use to add the chosen column
    @param -hidden_elements List of hidden elements that should be passed in the 
} {
    if {$return_url eq ""} {
	set return_url [ad_return_url]
    }
    upvar $add_url_var _add_column
    if {[info exists _add_column]} {
        set add_column $_add_column
    } else {
        set add_column [list]
    }
    set addcolumnlist [list]
    template::list::get_reference -name $list_name
    
    lappend list_properties(actions) [_ acs-templating.Add_Column] "javascript:void(0)" [_ acs-templating.Add_Column]
    set elements $list_properties(elements)
    foreach element $list_properties(elements) {
    	template::list::element::get_reference -list_name $list_name -element_name $element
	    if {[lsearch $allowed_elements $element] > -1 && $element_properties(hide_p)} {
		regsub -all "\n" $element_properties(label) "" text
		regsub -all "\r" $text "" text
		set text [string range $text 0 65]
		if {$text ne ""} {
		    lappend addcolumnlist [list [list "text" $text] [list "url" "[filter_url -list_name $list_name -filter_name add_column -filter_value [concat $add_column $element] -return_url $return_url]"]]
		}
	    }
    }
    if {[llength $addcolumnlist]} {
	set actions_count [expr {[llength $list_properties(actions)] / 3}]
	ah::yui::menu_from_list -varname "oMenuAddColumn" \
	    -id "menuAddColumn" \
	    -menulist $addcolumnlist \
	    -triggerel "action_${actions_count}" \
	    -triggerevent "click" \
	    -options "context:new Array(\"action_${actions_count}\",\"tl\",\"bl\"),position:'dynamic',maxheight:200,zindex:1000"
    }
}

ad_proc ah::lb::filter_url {
    -list_name
    -filter_name
    -return_url
    {-filter_value ""}
} {
    Prepare a URL to add a filter to a list
} {
    # don't put URL vars in the key just the page we are looking at
    regexp {([^\?]*)\??} $return_url discard base_url
    set key [ns_sha1 [list $base_url $list_name]]
    set url [export_vars -no_empty -base /ajax/list-add-filter {list_name filter_name key return_url filter_value}]
    return $url
}

ad_proc ah::lb::multiple_filter_url {
    -list_name
    -filter_names
    -return_url
} {
    Prepare a URL to add a filter to a list
} {
    # don't put URL vars in the key just the page we are looking at
    regexp {([^\?]*)\??} $return_url discard base_url
    set key [ns_sha1 [list $base_url $list_name]]
    set url [export_vars -no_empty -base /ajax/list-add-filter {list_name filter_names key return_url}]
    return $url
}

ad_proc ah::lb::add_view_menu {
    -list_name
    {-view_names {}}
} {
    Create a dropdown menu for saved views

    @param list_name template::list list name
    @param view_names list of views

} {

    foreach view $view_names {
        set view_name [lindex $view 0]
        set value [lindex $view 1]
        set viewmenuitems [list]
        lappend viewlist [list [list "text" $view_name] [list "url" "[filter_url -list_name $list_name -filter_name __list_view -filter_value $value -return_url [ad_conn url]]" ]]

    }
    ah::yui::menu_from_list -varname "oMenuChooseView" \
        -id "menuChooseView" \
        -menulist $viewlist \
        -triggerel "choose_view" \
        -triggerevent "click" \
        -options "context:new Array(\"choose_view\",\"tl\",\"bl\"),position:'dynamic',maxheight:200,autosubmenudisplay: true,showdelay:1"

}


#  "submenu" [list [list "id" "view-$view_name"] [list "itemdata" [list]]]

ad_proc ah::lb::validate_cr_name {
    -id
    -parent_id
    {-url "/ajax/validate" }
    {-msg_valid "Name is available" }
    {-msg_invalid "Choose a different name" }
    {-name_pattern ""}
} {
    Checks whether the value of the html element with the given id is a valid crname. A valid crname is one
        that does not yet exist in the db.
    
    @param id The html id of the text input element where the string we want to validate is typed
    @param parent_id The parent_id of we want to pass to the validator.
    @param url The url that will be queried to check if the string is valid or not. Defaults to /ajax/validate
    @param msg_valid Message to show if the string is valid
    @param msg_invalid Message to show if the string is invalid

} {

    ah::yui::requires -sources "event,connection"
    if {$name_pattern eq ""} {
	set name_pattern "crname='+document.getElementById('$id').value)"
    } else {
	set name_pattern "crname='+'${name_pattern}'.replace('%name%',document.getElementById('$id').value)"
    }
    set success_body "
            if(!document.getElementById('msg${id}')) {
                var msgnode = document.createElement('DIV');
                msgnode.setAttribute('id','msg${id}');
                document.getElementById('${id}').parentNode.insertBefore(msgnode,document.getElementById('${id}').nextSibling);
            }
            if(o.responseText=='0') { 
                document.getElementById('msg${id}').innerHTML=\"<span style='color:green;font-weight:bold'>${msg_valid}</span>\";
            } else { 
                document.getElementById('msg${id}').innerHTML=\"<span style='color:red;font-weight:bold'>${msg_invalid}</span>\";
            }
    "

    set fail_body "alert('Sorry, we encountered a problem validating this string, Try again later.')"

    set success [ah::create_js_function -body $success_body -parameters [list "o"] ]
    set failure [ah::create_js_function -body $fail_body -parameters [list "o"] ]
    set listener_callback "\{success:${success}, failure:${failure}\}"
    
    set callback_body "YAHOO.util.Connect.asyncRequest('POST', '${url}', ${listener_callback}, 'parent_id=$parent_id&${name_pattern});"

    set js_scripts [ah::yui::addlistener \
                    -element $id \
                    -event "keyup" \
                    -callback [ah::create_js_function -body $callback_body -parameters [list "e"] ] ]
    

    global ajax_helper_init_scripts
    append ajax_helper_init_scripts $js_scripts

}

ad_proc ah::lb::prepare_template {
    -list_name
    -package_id
} {
    Prepare all the stuff for ajax dynamic list template
} {
    upvar ___list_name ___list_name
    set ___list_name $list_name
    uplevel {
    template::list::get_reference -name $___list_name
    
    if {[info exists move]} {
	set element_list $list_properties(display_elements)
	foreach {elm index} $move {
	    set old_index [lsearch $element_list $elm]
	    set element_list [lreplace $element_list $old_index $old_index]
	    set element_list [linsert $element_list $index $elm]
	}
	set list_properties(display_elements) $element_list
	
    }


	if {[info exists hide]} {
	    foreach elm $hide {
		template::list::element::get_reference -list_name $___list_name -element_name $elm
		set element_properties(hide_p) 1
	    }
	}
  
    ah::lb::add_column_menu -list_name $___list_name -element_names $list_properties(display_elements)

    ah::lb::add_add_column_menu -list_name $___list_name -allowed_elements $list_properties(elements)

    set available_views [concat [list [list "--New View--" ""]] [db_list_of_lists get_available_views "select title,title from cr_items ci, cr_revisions cr where name like 'template:list:${___list_name}:view:%' and ci.latest_revision=cr.revision_id and parent_id = :package_id"]]
    set available_views_p [expr {[llength $available_views] > 1}]
    ad_form -name load-view -form {
	{__list_view:text(select),optional {label "Choose View"} {options $available_views}}
    }

    # ajax view menu
    ah::lb::add_view_menu -list_name $___list_name -view_names $available_views

    if {$format eq "csv"} {
	
	foreach elm {checkbox application_status assessment_result actions} {
	    template::list::element::set_property \
		-list_name $___list_name \
		-element_name $elm \
		-property hide_p \
		-value 1
    }
	template::list::get_reference -name $___list_name
	foreach elm $list_properties(elements) {
	    if {[lsearch {checkbox} $elm] < 0} {
		template::list::element::get_reference -list_name $___list_name -element_name $elm
		set element_properties(hide_p) 0
	    }
	}    
	template::list::write_output -name $___list_name
    }


	ad_form -name save_view -has_submit 1 -export {__list_view} -form {
	    {save_view:text,optional {label "[_ acs-templating.Save_View]"}}
	    {formbutton_ok:text(submit) {label "[_ acs-kernel.common_OK]"}}
	    {formbutton_cancel:text(submit) {label "[_ acs-kernel.common_Cancel]"} 
		{html {onclick "getElementById('ViewTitle').style.display='';getElementById('ViewTitleSave').style.display='none';"}}
	    }
	}

	if {([info exists __list_view] && $__list_view ne "")} {
	    ad_form -extend -name save_view -form {
		{formbutton_delete:text(submit) {label "[_ acs-kernel.common_Delete]"}}
	    }
	}
	ad_form -extend -name save_view  -on_request {
	    if {[info exists __list_view]} {
		element set_value save_view save_view $__list_view
	    }
	} -on_submit {
	    if {([info exists formbutton_delete] && $formbutton_delete ne "")} {
		ad_returnredirect [export_vars -base /ajax/list-view-delete {{list_name $___list_name} {view_name $__list_view} {return_url "[ad_conn url]"} {parent_id "[ad_conn package_id]}}]
		ad_script_abort
	    }
	}

	if {([info exists save_view] && $save_view ne "")} {
	    set saved_view_id [template::list::view_save \
				   -list_name $___list_name \
				   -view_name $save_view \
				   -parent_id [ad_conn package_id]
			      ]
	    if {$saved_view_id ne ""} {
		ad_returnredirect \
		    [export_vars -base [ad_conn url] {{__list_view $save_view}}]
		ad_script_abort
	    } else {
		ad_returnredirect \
		    -message "[_ acs-templating.List_view_name_already_exists]" \
		    [export_vars -base [ad_conn url] {{show_save 1}}]
		ad_script_abort        
	    }
	} 
    }    
}

ad_proc ah::lb::prepare_list {
    -list_name
} {
    Prepare the stuff we need before the list is created
} {
    upvar ___list_name ___list_name
    set ___list_name $list_name
    uplevel {
	set view_name ""
	set view_title "Unsaved View"
	
	template::list::view_set_filter_vars \
	    -list_name $___list_name
	set view_modified_p 0
	if {([info exists __list_view] && $__list_view ne "")} {
	    set view_name $__list_view
	    set view_title $__list_view

	    # check if saved view has been modified
	    set view_modified_p [template::list::view_modified_p -list_name $___list_name -view_name $__list_view]
	}

	if {[info exists hide]} {
	    set reset_filters [list]
	    if {[info exists orderby] && [lsearch $hide [lindex [split $orderby ,] 0]] > -1} {
		unset orderby
		lappend reset_filters orderby
	    }
	    if {[info exists groupby] && [lsearch $hide $groupby] > -1} {
		unset groupby
		unset -nocomplain orderby
		lappend reset_filters orderby groupby
	    }

	    if {[llength $reset_filters]} {
		template::list::filter::set_client_property -list_name $___list_name -url [ad_conn url] -exclude_filters $reset_filters
	    }

	}

	if {[info exists hide] && [llength $hide] && [info exists add_column] && [llength $add_column]} {
	    set hide_orig $hide
	    set c 0
	    foreach elm $hide {
		set i [lsearch $add_column $elm]
		if {$i > -1} {
		    set add_column [lreplace $add_column $i $i]
		    set i [lsearch $hide_orig $elm]
		    if {$i > -1} {
			set hide_orig [lreplace $hide_orig $i $i]
		    }
		}
	    }
	    set hide $hide_orig
	    template::list::filter::set_client_property -list_name $___list_name -url [ad_conn url] -filters [list hide $hide add_column $add_column]
	}

    }
}