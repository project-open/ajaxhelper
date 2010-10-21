# create the nodes for our tree
set nodes [list]

# 1st level
lappend nodes [list "fld1" "Folder 1" "tree" "" "" "" ""]
lappend nodes [list "fld2" "Folder 2" "tree" "javascript:alert('this is a tree node')" "" "" ""]

#  2nd level, node 1 (fld1)
lappend nodes [list "fld11" "Folder 1.1" "tree" "" "fld1" "" ""]
lappend nodes [list "fld12" "Folder 1.2" "tree" "" "fld1" "" ""]

#  2nd level, node 2 (fld2)
lappend nodes [list "fld21" "Folder 2.1" "tree" "" "fld2" "" ""]
lappend nodes [list "fld22" "Folder 2.2" "tree" "" "fld2" "" ""]

# generate the javascript
ah::yui::create_tree -element "folders" \
		-nodes $nodes \
		-varname "tree"