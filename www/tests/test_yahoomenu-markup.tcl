
# demonstrates how to create YUI Menu using existing html markup

# generate the code
ah::yui::menu_from_markup \
    -varname "mymenu1" \
    -markupid "testmenu1" \
    -triggerel "showmenu1" \
    -triggerevent "click" \
    -options "context:new Array(\"showmenu1\",\"tl\",\"bl\")"

ah::yui::menu_from_markup \
    -varname "mymenu2" \
    -markupid "testmenu2" \
    -triggerel "showmenu2" \
    -triggerevent "click" \
    -options "context:new Array(\"showmenu2\",\"tl\",\"bl\")"