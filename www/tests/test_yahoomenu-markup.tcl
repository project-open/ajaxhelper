
# demonstrates how to create YUI Menu using existing html markup

# generate the code
ah::yui::menu_from_markup \
    -varname "mymenu" \
    -markupid "testmenu" \
    -arrayname "yuimenu" \
    -enclose \
    -options "context:new Array(\"showmenu\",\"tl\",\"bl\")"

# get the render and show values of the resulting array
set js_script $yuimenu(render)

# get the action script that triggers the display of the menu
set action_script $yuimenu(show)