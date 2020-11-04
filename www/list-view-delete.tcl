ad_page_contract {
    Delete a view for a list
} {
    list_name
    view_name
    return_url:localurl
    parent_id:naturalnum,notnull
}

set name "template:list:${list_name}:view:${view_name}"

set view_item_id [db_string get_item_id "select item_id from cr_items where name=:name and parent_id=:parent_id" -default ""]
if {$view_item_id ne ""} {
    if {[permission::permission_p \
	     -object_id $view_item_id \
	     -party_id [ad_conn user_id] \
	     -privilege "admin"]} {
	content::item::delete -item_id $view_item_id
    }
}
regexp {([^\?]*)\??} $return_url discard base_url
set key [ns_sha1 [list $base_url $list_name]]

ad_set_client_property acs-templating $key ""

ad_returnredirect -message "[_ acs-templating.List_View_Deleted]" $return_url