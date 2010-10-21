set options [list [list "minWidth" "350"] [list "closable" "false"] [list "title" "\"Sample Progress Bar\""] [list "progress" "true"] [list "msg" "\"Please wait ...\""] ]
set script [ah::ext::msgbox -options $options]
append script [ah::ext::ajax -url "test_extprogressbar-handler" -success [ah::create_js_function -body "eval(o.responseText)" -parameters "o"] ]
set script [ah::enclose_in_script  -script [ah::ext::onready -body $script]]