ad_library {

    Library for Ajax Helper Procs
    based on ExtJs

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2007-09-07

}

namespace eval ah::ext { }

ad_proc -public ah::ext::requires {

} {

    Everything needed for ExtJs is in 2 javascript files and 1 css file.
    These files were built by combining smaller css and javascript files.
    

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2007-09-07

} {

    set ah_base_url [ah::get_url]
    template::head::add_css -href "${ah_base_url}ext/resources/css/ext-all.css"
    template::head::add_css -href "${ah_base_url}ext/resources/css/xtheme-vista.css"
    template::head::add_javascript -order 1 -src "${ah_base_url}ext/adapter/ext/ext-base.js"
    template::head::add_javascript -order 2 -src "${ah_base_url}ext/ext-all.js"

}

ad_proc -public ah::ext::onready {
    -body
} {

    Wrapper for Ext.onReady.
    http://extjs.com/deploy/ext/docs/output/Ext.html#onReady

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2007-09-07

    @param body The javascript to be executed inside the onReady funciton
    

} {

    ah::ext::requires
    set function_body [ah::create_js_function -body ${body}]
    return "Ext.onReady( ${function_body} ); "
}

ad_proc -public ah::ext::ajax {
    -url
    {-params {}}
    {-success ""}
    {-failure ""}
} {

    Wrapper for Ext.Ajax.request
    http://extjs.com/deploy/ext/docs/output/Ext.Ajax.html#request

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2007-09-07

    @param url The url that the javascript will post to
    @param params A Tcl list of parameters to pass to the url
    @param success A javascript function to be executed when the url is successfully accessed
    @param failure A javascript function to execute if transaction failed.

} {
    set script "Ext.Ajax.request({url:\"$url\""
    if { ([info exists params] && $params ne "") } { append script ",params:$params" }
    if { ([info exists success] && $success ne "") } { append script ",success:$success" }
    if { ([info exists failure] && $failure ne "") } { append script ",failure:$failure" }
    append script  "}); "
    return $script
}

ad_proc -public ah::ext::msgbox {
    {-options {}}
} {
    
    Wrapper for Ext.MessageBox.
        http://extjs.com/deploy/ext/docs/output/Ext.MessageBox.html
    Possible options are listed in
        http://extjs.com/deploy/ext/docs/output/Ext.MessageBox.html#show

    <b>options</b> is a list of lists e.g.
    set options [list [list "title" "\"Sample Progress Bar\""] [list "progress" "true"] [list "progressText" "\"Please wait ...\""] ]

    it is fed to ah::ext::msgbox like this
    set popup_script [ah::ext::msgbox -options $options]
    

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2007-09-07

    @param options A Tcl list of options, see above for more info on how to structure and pass options to this proc.

} {

    ah::ext::requires

    set script "Ext.Msg.show("
    append script [ah::util_list_to_json -lists_of_pairs [list $options] ]
    append script "); "

    return $script

}

ad_proc -public ah::ext::updateprogress {
    -progress_count
    -progress_txt
} {

    Wrapper for Ext.MessageBox.updateProgress.
    http://extjs.com/deploy/ext/docs/output/Ext.MessageBox.html#updateProgress
    

    @author Hamilton Chua (ham@solutiongrove.com)
    @creation-date 2007-09-07

    @param progress_count Sets the progress bar in the progress bar dialog.
    @param progress_txt The text to display for the given count.

} {

    ah::ext::requires
    return "Ext.Msg.updateProgress(${progress_count},'${progress_txt}'); "

}