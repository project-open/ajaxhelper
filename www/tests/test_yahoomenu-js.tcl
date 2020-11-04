# demonstrates how to create YUI Menu using a properly formatted Tcl list

# Menu 1

# set menulist1 [list]
# lappend menulist1 [list [list "text" "Google"] [list "url" "http://www.google.com"] ]
# lappend menulist1 [list [list "text" "Yahoo"] [list "url" "http://www.yahoo.com"] ]

set menulist1 { { { "text" "Google"} { "url" "http://www.google.com"} } \
                 { { "text" "Yahoo"} { "url" "http://www.yahoo.com"} } \
                }

ah::yui::menu_from_list -varname "oMenu1" \
    -id "basicmenu1" \
    -menulist $menulist1 \
    -triggerel "menu1" \
    -triggerevent "click" \
    -options "context:new Array(\"menu1\",\"tl\",\"bl\"),clicktohide:true"

# Menu 2

# set submenuitems [list]
# lappend submenuitems [list [list "text" "Home Page"] [list "url" "http://www.solutiongrove.com"] ]
# lappend submenuitems [list [list "text" "Blog"] [list "url" "http://www.solutiongrove.com/blogger/"] ]
# set submenulist1 [list [list "id" "sgrovelinks"] [list "itemdata" $submenuitems] ]
# set menulist2 [list]
# lappend menulist2 [list [list "text" "OpenACS"] [list "url" "http://www.openacs.org"] ]
# lappend menulist2 [list [list "text" "Solution Grove"] [list "submenu" $submenulist1] ]

set menulist2 { { { "text" "OpenACS" } { "url" "http://www.openacs.org" } } 
                 { { "text" "Solution Grove" } { "submenu" 
                        { { "id" "sgrovelinks" } { "itemdata"  {
                                                    { { "text" "Home Page"} { "url" "http://www.solutiongrove.com"} } 
                                                    { { "text" "Blog"} { "url" "http://www.solutiongrove.com/blogger/"} } 
                                                } } }
                } } \
                }


ah::yui::menu_from_list -varname "oMenu2" \
    -id "basicmenu2" \
    -menulist $menulist2 \
    -triggerel "menu2" \
    -triggerevent "click" \
    -options "context:new Array(\"menu2\",\"tl\",\"bl\"),hidedelay:1,clicktohide:true"
