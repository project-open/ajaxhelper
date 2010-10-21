for { set x 0 } { $x< 21 } { incr x } {
    set script [ah::create_js_function -body [ah::ext::updateprogress -progress_count "$x/20" -progress_txt "Installing $x files of My Sample Program" ] ]
    ns_write "setTimeout($script,$x*1000); "
}