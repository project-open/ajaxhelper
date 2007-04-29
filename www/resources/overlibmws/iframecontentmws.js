function OLiframeContent(src, width, height, name, frameborder) {
 return ('<iframe src="'+src+'" width="'+width+'" height="'+height+'"'+(name!=null?' name="'+name+'" id="'+name+'"':'')+(frameborder!=null?' frameborder="'+frameborder+'"':'')+' scrolling="auto">'+'<div>[iframe not supported]</div></iframe>');
}
