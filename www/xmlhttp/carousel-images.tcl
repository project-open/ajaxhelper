ad_page_contract {
	Return images for attach-image carousel
} {
	{start "0"}
	{nb "3"}
}

set user_id [ad_conn user_id]    
    
db_multirow -unclobber user_images user_images \
{
    select ci.item_id as item_id, ci.name
    from cr_items ci, cr_revisionsx cr, cr_child_rels ccr
    where ci.live_revision=cr.revision_id
    and ci.content_type='image'
    and cr.creation_user=:user_id
    and ccr.parent_id=ci.item_id
    and ccr.relation_tag='image-thumbnail'
    order by creation_date desc
    limit :nb offset :start
} {
    set name [regsub "${item_id}_" $name ""] 	    
}
    