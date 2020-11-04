ad_page_contract {
    Add a filter to saved filter view for a list builder list
} {
    return_url:localurl
    list_name
    {filter_name ""} 
    {filter_names ""}
    {filter_value ""}
    {filter_values ""}
}
    
# get filters from existing session property
# don't put URL vars in the key just the page we are looking at
regexp {([^\?]*)\??} $return_url discard base_url
set key [ns_sha1 [list $base_url $list_name]]
if {$filter_name eq "__list_view"} {
    set current_filters(${list_name}:filter:${filter_name}:properties) $filter_value
} elseif {[llength $filter_names]} {
    array set current_filters [ad_get_client_property acs-templating ${key}]
    foreach name $filter_names value $filter_values {
        set current_filters(${list_name}:filter:${name}:properties) $value
    }
} elseif {$filter_name ne ""} {
    array set current_filters [ad_get_client_property acs-templating ${key}]
    set current_filters(${list_name}:filter:${filter_name}:properties) $filter_value
}
ns_log notice "current filters
[array get current_filters]
"
ad_set_client_property acs-templating $key [array get current_filters]

ad_returnredirect $return_url