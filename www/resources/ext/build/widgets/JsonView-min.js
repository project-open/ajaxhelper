/*
 * Ext JS Library 1.1.1
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://www.extjs.com/license
 */

Ext.JsonView=function(A,D,C){Ext.JsonView.superclass.constructor.call(this,A,D,C);var B=this.el.getUpdateManager();B.setRenderer(this);B.on("update",this.onLoad,this);B.on("failure",this.onLoadException,this);this.addEvents({"beforerender":true,"load":true,"loadexception":true})};Ext.extend(Ext.JsonView,Ext.View,{jsonRoot:"",refresh:function(){this.clearSelections();this.el.update("");var C=[];var E=this.jsonData;if(E&&E.length>0){for(var B=0,A=E.length;B<A;B++){var D=this.prepareData(E[B],B,E);C[C.length]=this.tpl.apply(D)}}else{C.push(this.emptyText)}this.el.update(C.join(""));this.nodes=this.el.dom.childNodes;this.updateIndexes(0)},load:function(){var A=this.el.getUpdateManager();A.update.apply(A,arguments)},render:function(el,response){this.clearSelections();this.el.update("");var o;try{o=Ext.util.JSON.decode(response.responseText);if(this.jsonRoot){o=eval("o."+this.jsonRoot)}}catch(e){}this.jsonData=o;this.beforeRender();this.refresh()},getCount:function(){return this.jsonData?this.jsonData.length:0},getNodeData:function(C){if(C instanceof Array){var D=[];for(var B=0,A=C.length;B<A;B++){D.push(this.getNodeData(C[B]))}return D}return this.jsonData[this.indexOf(C)]||null},beforeRender:function(){this.snapshot=this.jsonData;if(this.sortInfo){this.sort.apply(this,this.sortInfo)}this.fireEvent("beforerender",this,this.jsonData)},onLoad:function(A,B){this.fireEvent("load",this,this.jsonData,B)},onLoadException:function(A,B){this.fireEvent("loadexception",this,B)},filter:function(F,E){if(this.jsonData){var D=[];var C=this.snapshot;if(typeof E=="string"){var H=E.length;if(H==0){this.clearFilter();return }E=E.toLowerCase();for(var B=0,A=C.length;B<A;B++){var G=C[B];if(G[F].substr(0,H).toLowerCase()==E){D.push(G)}}}else{if(E.exec){for(var B=0,A=C.length;B<A;B++){var G=C[B];if(E.test(G[F])){D.push(G)}}}else{return }}this.jsonData=D;this.refresh()}},filterBy:function(E,D){if(this.jsonData){var F=[];var C=this.snapshot;for(var B=0,A=C.length;B<A;B++){var G=C[B];if(E.call(D||this,G)){F.push(G)}}this.jsonData=F;this.refresh()}},clearFilter:function(){if(this.snapshot&&this.jsonData!=this.snapshot){this.jsonData=this.snapshot;this.refresh()}},sort:function(D,A,F){this.sortInfo=Array.prototype.slice.call(arguments,0);if(this.jsonData){var E=D;var B=A&&A.toLowerCase()=="desc";var C=function(H,G){var J=F?F(H[E]):H[E];var I=F?F(G[E]):G[E];if(J<I){return B?+1:-1}else{if(J>I){return B?-1:+1}else{return 0}}};this.jsonData.sort(C);this.refresh();if(this.jsonData!=this.snapshot){this.snapshot.sort(C)}}}});