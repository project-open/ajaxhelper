
# demonstrates how to create a context menu

set menulist1 { { { "text" "Google"} { "url" "http://www.google.com"} } \
                { { "text" "Yahoo"} { "url" "http://www.yahoo.com"} } \
                { { "text" "Ask.com"} { "url" "javascript:alert('You clicked Ask.com')"} } }

ah::yui::contextmenu \
    -varname "oContextMenu" \
    -id "mycontextmenu" \
    -menulist $menulist1 \
    -triggerel "document"