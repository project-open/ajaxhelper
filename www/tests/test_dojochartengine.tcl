
# create the list that holds our data
set data [list]
lappend data [list [list "x" "1"] [list "y" "10"] ]
lappend data [list [list "x" "5"] [list "y" "20"] ]

# create a collections store,
# used by dojo to hold data for the chart engine to render
set storeobj [ah::dojo::collections_store -varname "testchart" -lists_of_pairs $data]

# create a data series
set objname "series1"
Object $objname
    $objname set varname "s1"
    $objname set datavar "testchart"
    $objname set label "Series 1"
    $objname set type "CurvedLine"
    $objname set bindingslist [list [list "x" "\"x\""] [list "y" "\"y\""] ]
    $objname proc getvarname {} {
        my instvar varname
        return $varname
    }
    $objname proc gettype {} {
        my instvar type
        return $type
    }
    $objname proc bindings_from_list {lists_of_pairs} {
        set pairs [list]
        foreach pair $lists_of_pairs {
            lappend pairs [join $pair ":"]
        }
        [self] set bindings [join $pairs ","]
    }
    $objname proc createscript {} {
        my instvar varname datavar bindingslist label
        set bindings [my bindings_from_list $bindingslist]
        set script "var $varname = new dojo.charting.Series({dataSource:$datavar,bindings:{$bindings},label:\"$label\"}); \n"
        [self] set series_script $script
    }
    $objname proc render {} {
        my instvar series_script
        my createscript
        return $series_script
    }

# create the X axis
set objname "axis1"
Object $objname
    $objname set varname "xA"
    $objname set rangelist [list [list "upper" "130"] [list "lower" "0"]]
    $objname set origin "0"
    $objname set showlines "true"
    $objname set showticks "true"
    $objname set label "X Axis"
    $objname set labelslist [list "0" "20" "40" "60" "80" "100"]
    $objname proc getvarname {} {
        my instvar varname
        return $varname
    }
    $objname proc range_from_list {rangelist} {
        set pairs [list]
        foreach pair $rangelist {
            lappend pairs [join $pair ":"]
        }
        [self] set range [join $pairs ","]
    }
    $objname proc labels_from_list {labelslist} {
            [self] set labels [join $labelslist ","]
    }
    $objname proc createscript {} {
        my instvar varname label rangelist labelslist showlines showticks origin
        set range [my range_from_list $rangelist]
        set labels [my labels_from_list $labelslist]
        [self] set axis_script "var $varname = new.dojo.charting.Axis(); \n"
        [self] append axis_script "$varname.range = {$range}; \n"
        [self] append axis_script "$varname.origin = {$origin}; "
        [self] append axis_script "$varname.showLines = $showlines; \n"
        [self] append axis_script "$varname.showTicks = $showticks; \n"
        [self] append axis_script "$varname.label = $label; \n"
        [self] append axis_script "$varname.labels = \[$labels\]; \n"
    }
    $objname proc render {} {
        my instvar axis_script
        my createscript
        return $axis_script
    }

# create the Y axis
set objname "axis2"
Object $objname
    $objname set varname "yA"
    $objname set rangelist [list [list "upper" "250"] [list "lower" "0"]]
    $objname set origin "0"
    $objname set showlines "true"
    $objname set showticks "true"
    $objname set label "Y Axis"
    $objname set labelslist [list "0" "50" "100" "150" "200" "250"]
    $objname proc getvarname {} {
        my instvar varname
        return $varname
    }
    $objname proc range_from_list {rangelist} {
        set pairs [list]
        foreach pair $rangelist {
            lappend pairs [join $pair ":"]
        }
        [self] set range [join $pairs ","]
    }
    $objname proc labels_from_list {labelslist} {
            [self] set labels [join $labelslist ","]
    }
    $objname proc createscript {} {
        my instvar varname label rangelist labelslist showlines showticks origin
        set range [my range_from_list $rangelist]
        set labels [my labels_from_list $labelslist]
        [self] set axis_script "var $varname = new.dojo.charting.Axis(); \n"
        [self] append axis_script "$varname.range = {$range}; \n"
        [self] append axis_script "$varname.origin = {$origin}; "
        [self] append axis_script "$varname.showLines = $showlines; \n"
        [self] append axis_script "$varname.showTicks = $showticks; \n"
        [self] append axis_script "$varname.label = $label; \n"
        [self] append axis_script "$varname.labels = \[$labels\]; \n"
    }
    $objname proc render {} {
        my instvar axis_script
        my createscript
        return $axis_script
    }

# create a plot
set objname "plot"
Object $objname
    $objname set varname "p"
    $objname set series_obj_list [list "series1"]
    $objname set axis_obj_list [list "axis1" "axis2"]
    $objname proc createscript { } {
        my instvar varname series_obj_list axis_obj_list
        set axislist [list]
        foreach axis $axis_obj_list {
            lappend axislist [$axis getvarname]
        }
        set axis [join $axislist ","]
        [self] set plot_script "var $varname = new dojo.charting.Plot($axis); \n"
        foreach series $series_obj_list {
            [self] append plot_script "$varname.addSeries({data: [$series getvarname], plotter: dojo.charting.Plotters.[$series gettype]}); "
        }
    }
    $objname proc render {} {
        my instvar plot_script
        my createscript
        return $plot_script
    }

set testjs $storeobj
append testjs [series1 render]
append testjs "\n"
append testjs [axis1 render]
append testjs "\n"
append testjs [axis2 render]
append testjs "\n"
append testjs [plot render]