# this is the function that gets executed after the ajax is called
set load_function [ah::create_js_function -parameters [list "type" "data" "evt"] -body {
                        if (data) { document.getElementById('content').innerHTML = data; }
                        }]

# the arguments you pass to dojo.io.bind
set argslist [list    [list "url" "\"test_dojoiobindhandle\""] \
                        [list "method" "\"post\""] \
                        [list "mimetype" "'text/html'"] \
                        [list "load" $load_function] \
                ]

# the variable name for the arguments
set argsvarname "myargs"

# generate the arguments javascript and the io.bind javascript
set function_body [ah::dojo::args -varname $argsvarname -argslist $argslist]
append function_body [ah::dojo::iobind -objargs $argsvarname]

# put it all inside a javascript function called "testio"
set iofunction [ah::create_js_function -name "testio" -body $function_body ]

# enclose the script in script tags
set js_script [ah::enclose_in_script -script $iofunction]