# HAM : lets check ajaxhelper globals ***********************

global ajax_helper_js_sources
global ajax_helper_yui_js_sources
global ajax_helper_dojo_js_sources
global ajax_helper_custom_scripts
global ajax_helper_init_scripts

set js_sources ""
set init_body ""

# if we're using ajax, let's use doc_type strict so we can get
# consistent results accross standards compliant browsers
# if { [info exists ajax_helper_js_sources] || [info exists ajax_helper_yui_js_sources] || [info exists ajax_helper_dojo_js_sources] } {
#    set doc_type { <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> }
# }

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
append js_sources [ah::enclose_in_script -script ${script}]

# ***********************************************************
