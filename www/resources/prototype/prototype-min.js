var Prototype={Version:"1.5.0_rc1",ScriptFragment:"(?:<script.*?>)((\n|\r|.)*?)(?:</script>)",emptyFunction:function(){
},K:function(x){
return x;
}};
var Class={create:function(){
return function(){
this.initialize.apply(this,arguments);
};
}};
var Abstract=new Object();
Object.extend=function(_2,_3){
for(var _4 in _3){
_2[_4]=_3[_4];
}
return _2;
};
Object.extend(Object,{inspect:function(_5){
try{
if(_5==undefined){
return "undefined";
}
if(_5==null){
return "null";
}
return _5.inspect?_5.inspect():_5.toString();
}
catch(e){
if(e instanceof RangeError){
return "...";
}
throw e;
}
},keys:function(_6){
var _7=[];
for(var _8 in _6){
_7.push(_8);
}
return _7;
},values:function(_9){
var _a=[];
for(var _b in _9){
_a.push(_9[_b]);
}
return _a;
},clone:function(_c){
return Object.extend({},_c);
}});
Function.prototype.bind=function(){
var _d=this,_e=$A(arguments),_f=_e.shift();
return function(){
return _d.apply(_f,_e.concat($A(arguments)));
};
};
Function.prototype.bindAsEventListener=function(_10){
var _11=this,_12=$A(arguments),_10=_12.shift();
return function(_13){
return _11.apply(_10,[(_13||window.event)].concat(_12).concat($A(arguments)));
};
};
Object.extend(Number.prototype,{toColorPart:function(){
var _14=this.toString(16);
if(this<16){
return "0"+_14;
}
return _14;
},succ:function(){
return this+1;
},times:function(_15){
$R(0,this,true).each(_15);
return this;
}});
var Try={these:function(){
var _16;
for(var i=0;i<arguments.length;i++){
var _18=arguments[i];
try{
_16=_18();
break;
}
catch(e){
}
}
return _16;
}};
var PeriodicalExecuter=Class.create();
PeriodicalExecuter.prototype={initialize:function(_19,_1a){
this.callback=_19;
this.frequency=_1a;
this.currentlyExecuting=false;
this.registerCallback();
},registerCallback:function(){
this.timer=setInterval(this.onTimerEvent.bind(this),this.frequency*1000);
},stop:function(){
if(!this.timer){
return;
}
clearInterval(this.timer);
this.timer=null;
},onTimerEvent:function(){
if(!this.currentlyExecuting){
try{
this.currentlyExecuting=true;
this.callback(this);
}
finally{
this.currentlyExecuting=false;
}
}
}};
Object.extend(String.prototype,{gsub:function(_1b,_1c){
var _1d="",_1e=this,_1f;
_1c=arguments.callee.prepareReplacement(_1c);
while(_1e.length>0){
if(_1f=_1e.match(_1b)){
_1d+=_1e.slice(0,_1f.index);
_1d+=(_1c(_1f)||"").toString();
_1e=_1e.slice(_1f.index+_1f[0].length);
}else{
_1d+=_1e,_1e="";
}
}
return _1d;
},sub:function(_20,_21,_22){
_21=this.gsub.prepareReplacement(_21);
_22=_22===undefined?1:_22;
return this.gsub(_20,function(_23){
if(--_22<0){
return _23[0];
}
return _21(_23);
});
},scan:function(_24,_25){
this.gsub(_24,_25);
return this;
},truncate:function(_26,_27){
_26=_26||30;
_27=_27===undefined?"...":_27;
return this.length>_26?this.slice(0,_26-_27.length)+_27:this;
},strip:function(){
return this.replace(/^\s+/,"").replace(/\s+$/,"");
},stripTags:function(){
return this.replace(/<\/?[^>]+>/gi,"");
},stripScripts:function(){
return this.replace(new RegExp(Prototype.ScriptFragment,"img"),"");
},extractScripts:function(){
var _28=new RegExp(Prototype.ScriptFragment,"img");
var _29=new RegExp(Prototype.ScriptFragment,"im");
return (this.match(_28)||[]).map(function(_2a){
return (_2a.match(_29)||["",""])[1];
});
},evalScripts:function(){
return this.extractScripts().map(function(_2b){
return eval(_2b);
});
},escapeHTML:function(){
var div=document.createElement("div");
var _2d=document.createTextNode(this);
div.appendChild(_2d);
return div.innerHTML;
},unescapeHTML:function(){
var div=document.createElement("div");
div.innerHTML=this.stripTags();
return div.childNodes[0]?div.childNodes[0].nodeValue:"";
},toQueryParams:function(){
var _2f=this.match(/^\??(.*)$/)[1].split("&");
return _2f.inject({},function(_30,_31){
var _32=_31.split("=");
var _33=_32[1]?decodeURIComponent(_32[1]):undefined;
_30[decodeURIComponent(_32[0])]=_33;
return _30;
});
},toArray:function(){
return this.split("");
},camelize:function(){
var _34=this.split("-");
if(_34.length==1){
return _34[0];
}
var _35=this.indexOf("-")==0?_34[0].charAt(0).toUpperCase()+_34[0].substring(1):_34[0];
for(var i=1,len=_34.length;i<len;i++){
var s=_34[i];
_35+=s.charAt(0).toUpperCase()+s.substring(1);
}
return _35;
},inspect:function(_39){
var _3a=this.replace(/\\/g,"\\\\");
if(_39){
return "\""+_3a.replace(/"/g,"\\\"")+"\"";
}else{
return "'"+_3a.replace(/'/g,"\\'")+"'";
}
}});
String.prototype.gsub.prepareReplacement=function(_3b){
if(typeof _3b=="function"){
return _3b;
}
var _3c=new Template(_3b);
return function(_3d){
return _3c.evaluate(_3d);
};
};
String.prototype.parseQuery=String.prototype.toQueryParams;
var Template=Class.create();
Template.Pattern=/(^|.|\r|\n)(#\{(.*?)\})/;
Template.prototype={initialize:function(_3e,_3f){
this.template=_3e.toString();
this.pattern=_3f||Template.Pattern;
},evaluate:function(_40){
return this.template.gsub(this.pattern,function(_41){
var _42=_41[1];
if(_42=="\\"){
return _41[2];
}
return _42+(_40[_41[3]]||"").toString();
});
}};
var $break=new Object();
var $continue=new Object();
var Enumerable={each:function(_43){
var _44=0;
try{
this._each(function(_45){
try{
_43(_45,_44++);
}
catch(e){
if(e!=$continue){
throw e;
}
}
});
}
catch(e){
if(e!=$break){
throw e;
}
}
},all:function(_46){
var _47=true;
this.each(function(_48,_49){
_47=_47&&!!(_46||Prototype.K)(_48,_49);
if(!_47){
throw $break;
}
});
return _47;
},any:function(_4a){
var _4b=false;
this.each(function(_4c,_4d){
if(_4b=!!(_4a||Prototype.K)(_4c,_4d)){
throw $break;
}
});
return _4b;
},collect:function(_4e){
var _4f=[];
this.each(function(_50,_51){
_4f.push(_4e(_50,_51));
});
return _4f;
},detect:function(_52){
var _53;
this.each(function(_54,_55){
if(_52(_54,_55)){
_53=_54;
throw $break;
}
});
return _53;
},findAll:function(_56){
var _57=[];
this.each(function(_58,_59){
if(_56(_58,_59)){
_57.push(_58);
}
});
return _57;
},grep:function(_5a,_5b){
var _5c=[];
this.each(function(_5d,_5e){
var _5f=_5d.toString();
if(_5f.match(_5a)){
_5c.push((_5b||Prototype.K)(_5d,_5e));
}
});
return _5c;
},include:function(_60){
var _61=false;
this.each(function(_62){
if(_62==_60){
_61=true;
throw $break;
}
});
return _61;
},inject:function(_63,_64){
this.each(function(_65,_66){
_63=_64(_63,_65,_66);
});
return _63;
},invoke:function(_67){
var _68=$A(arguments).slice(1);
return this.collect(function(_69){
return _69[_67].apply(_69,_68);
});
},max:function(_6a){
var _6b;
this.each(function(_6c,_6d){
_6c=(_6a||Prototype.K)(_6c,_6d);
if(_6b==undefined||_6c>=_6b){
_6b=_6c;
}
});
return _6b;
},min:function(_6e){
var _6f;
this.each(function(_70,_71){
_70=(_6e||Prototype.K)(_70,_71);
if(_6f==undefined||_70<_6f){
_6f=_70;
}
});
return _6f;
},partition:function(_72){
var _73=[],_74=[];
this.each(function(_75,_76){
((_72||Prototype.K)(_75,_76)?_73:_74).push(_75);
});
return [_73,_74];
},pluck:function(_77){
var _78=[];
this.each(function(_79,_7a){
_78.push(_79[_77]);
});
return _78;
},reject:function(_7b){
var _7c=[];
this.each(function(_7d,_7e){
if(!_7b(_7d,_7e)){
_7c.push(_7d);
}
});
return _7c;
},sortBy:function(_7f){
return this.collect(function(_80,_81){
return {value:_80,criteria:_7f(_80,_81)};
}).sort(function(_82,_83){
var a=_82.criteria,b=_83.criteria;
return a<b?-1:a>b?1:0;
}).pluck("value");
},toArray:function(){
return this.collect(Prototype.K);
},zip:function(){
var _86=Prototype.K,_87=$A(arguments);
if(typeof _87.last()=="function"){
_86=_87.pop();
}
var _88=[this].concat(_87).map($A);
return this.map(function(_89,_8a){
return _86(_88.pluck(_8a));
});
},inspect:function(){
return "#<Enumerable:"+this.toArray().inspect()+">";
}};
Object.extend(Enumerable,{map:Enumerable.collect,find:Enumerable.detect,select:Enumerable.findAll,member:Enumerable.include,entries:Enumerable.toArray});
var $A=Array.from=function(_8b){
if(!_8b){
return [];
}
if(_8b.toArray){
return _8b.toArray();
}else{
var _8c=[];
for(var i=0;i<_8b.length;i++){
_8c.push(_8b[i]);
}
return _8c;
}
};
Object.extend(Array.prototype,Enumerable);
if(!Array.prototype._reverse){
Array.prototype._reverse=Array.prototype.reverse;
}
Object.extend(Array.prototype,{_each:function(_8e){
for(var i=0;i<this.length;i++){
_8e(this[i]);
}
},clear:function(){
this.length=0;
return this;
},first:function(){
return this[0];
},last:function(){
return this[this.length-1];
},compact:function(){
return this.select(function(_90){
return _90!=undefined||_90!=null;
});
},flatten:function(){
return this.inject([],function(_91,_92){
return _91.concat(_92&&_92.constructor==Array?_92.flatten():[_92]);
});
},without:function(){
var _93=$A(arguments);
return this.select(function(_94){
return !_93.include(_94);
});
},indexOf:function(_95){
for(var i=0;i<this.length;i++){
if(this[i]==_95){
return i;
}
}
return -1;
},reverse:function(_97){
return (_97!==false?this:this.toArray())._reverse();
},reduce:function(){
return this.length>1?this:this[0];
},uniq:function(){
return this.inject([],function(_98,_99){
return _98.include(_99)?_98:_98.concat([_99]);
});
},inspect:function(){
return "["+this.map(Object.inspect).join(", ")+"]";
}});
var Hash={_each:function(_9a){
for(var key in this){
var _9c=this[key];
if(typeof _9c=="function"){
continue;
}
var _9d=[key,_9c];
_9d.key=key;
_9d.value=_9c;
_9a(_9d);
}
},keys:function(){
return this.pluck("key");
},values:function(){
return this.pluck("value");
},merge:function(_9e){
return $H(_9e).inject($H(this),function(_9f,_a0){
_9f[_a0.key]=_a0.value;
return _9f;
});
},toQueryString:function(){
return this.map(function(_a1){
return _a1.map(encodeURIComponent).join("=");
}).join("&");
},inspect:function(){
return "#<Hash:{"+this.map(function(_a2){
return _a2.map(Object.inspect).join(": ");
}).join(", ")+"}>";
}};
function $H(_a3){
var _a4=Object.extend({},_a3||{});
Object.extend(_a4,Enumerable);
Object.extend(_a4,Hash);
return _a4;
}
ObjectRange=Class.create();
Object.extend(ObjectRange.prototype,Enumerable);
Object.extend(ObjectRange.prototype,{initialize:function(_a5,end,_a7){
this.start=_a5;
this.end=end;
this.exclusive=_a7;
},_each:function(_a8){
var _a9=this.start;
while(this.include(_a9)){
_a8(_a9);
_a9=_a9.succ();
}
},include:function(_aa){
if(_aa<this.start){
return false;
}
if(this.exclusive){
return _aa<this.end;
}
return _aa<=this.end;
}});
var $R=function(_ab,end,_ad){
return new ObjectRange(_ab,end,_ad);
};
var Ajax={getTransport:function(){
return Try.these(function(){
return new XMLHttpRequest();
},function(){
return new ActiveXObject("Msxml2.XMLHTTP");
},function(){
return new ActiveXObject("Microsoft.XMLHTTP");
})||false;
},activeRequestCount:0};
Ajax.Responders={responders:[],_each:function(_ae){
this.responders._each(_ae);
},register:function(_af){
if(!this.include(_af)){
this.responders.push(_af);
}
},unregister:function(_b0){
this.responders=this.responders.without(_b0);
},dispatch:function(_b1,_b2,_b3,_b4){
this.each(function(_b5){
if(_b5[_b1]&&typeof _b5[_b1]=="function"){
try{
_b5[_b1].apply(_b5,[_b2,_b3,_b4]);
}
catch(e){
}
}
});
}};
Object.extend(Ajax.Responders,Enumerable);
Ajax.Responders.register({onCreate:function(){
Ajax.activeRequestCount++;
},onComplete:function(){
Ajax.activeRequestCount--;
}});
Ajax.Base=function(){
};
Ajax.Base.prototype={setOptions:function(_b6){
this.options={method:"post",asynchronous:true,contentType:"application/x-www-form-urlencoded",parameters:""};
Object.extend(this.options,_b6||{});
},responseIsSuccess:function(){
return this.transport.status==undefined||this.transport.status==0||(this.transport.status>=200&&this.transport.status<300);
},responseIsFailure:function(){
return !this.responseIsSuccess();
}};
Ajax.Request=Class.create();
Ajax.Request.Events=["Uninitialized","Loading","Loaded","Interactive","Complete"];
Ajax.Request.prototype=Object.extend(new Ajax.Base(),{initialize:function(url,_b8){
this.transport=Ajax.getTransport();
this.setOptions(_b8);
this.request(url);
},request:function(url){
var _ba=this.options.parameters||"";
if(_ba.length>0){
_ba+="&_=";
}
if(this.options.method!="get"&&this.options.method!="post"){
_ba+=(_ba.length>0?"&":"")+"_method="+this.options.method;
this.options.method="post";
}
try{
this.url=url;
if(this.options.method=="get"&&_ba.length>0){
this.url+=(this.url.match(/\?/)?"&":"?")+_ba;
}
Ajax.Responders.dispatch("onCreate",this,this.transport);
this.transport.open(this.options.method,this.url,this.options.asynchronous);
if(this.options.asynchronous){
setTimeout(function(){
this.respondToReadyState(1);
}.bind(this),10);
}
this.transport.onreadystatechange=this.onStateChange.bind(this);
this.setRequestHeaders();
var _bb=this.options.postBody?this.options.postBody:_ba;
this.transport.send(this.options.method=="post"?_bb:null);
if(!this.options.asynchronous&&this.transport.overrideMimeType){
this.onStateChange();
}
}
catch(e){
this.dispatchException(e);
}
},setRequestHeaders:function(){
var _bc=["X-Requested-With","XMLHttpRequest","X-Prototype-Version",Prototype.Version,"Accept","text/javascript, text/html, application/xml, text/xml, */*"];
if(this.options.method=="post"){
_bc.push("Content-type",this.options.contentType);
if(this.transport.overrideMimeType){
_bc.push("Connection","close");
}
}
if(this.options.requestHeaders){
_bc.push.apply(_bc,this.options.requestHeaders);
}
for(var i=0;i<_bc.length;i+=2){
this.transport.setRequestHeader(_bc[i],_bc[i+1]);
}
},onStateChange:function(){
var _be=this.transport.readyState;
if(_be!=1){
this.respondToReadyState(this.transport.readyState);
}
},header:function(_bf){
try{
return this.transport.getResponseHeader(_bf);
}
catch(e){
}
},evalJSON:function(){
try{
return eval("("+this.header("X-JSON")+")");
}
catch(e){
}
},evalResponse:function(){
try{
return eval(this.transport.responseText);
}
catch(e){
this.dispatchException(e);
}
},respondToReadyState:function(_c0){
var _c1=Ajax.Request.Events[_c0];
var _c2=this.transport,_c3=this.evalJSON();
if(_c1=="Complete"){
try{
(this.options["on"+this.transport.status]||this.options["on"+(this.responseIsSuccess()?"Success":"Failure")]||Prototype.emptyFunction)(_c2,_c3);
}
catch(e){
this.dispatchException(e);
}
if((this.header("Content-type")||"").match(/^text\/javascript/i)){
this.evalResponse();
}
}
try{
(this.options["on"+_c1]||Prototype.emptyFunction)(_c2,_c3);
Ajax.Responders.dispatch("on"+_c1,this,_c2,_c3);
}
catch(e){
this.dispatchException(e);
}
if(_c1=="Complete"){
this.transport.onreadystatechange=Prototype.emptyFunction;
}
},dispatchException:function(_c4){
(this.options.onException||Prototype.emptyFunction)(this,_c4);
Ajax.Responders.dispatch("onException",this,_c4);
}});
Ajax.Updater=Class.create();
Object.extend(Object.extend(Ajax.Updater.prototype,Ajax.Request.prototype),{initialize:function(_c5,url,_c7){
this.containers={success:_c5.success?$(_c5.success):$(_c5),failure:_c5.failure?$(_c5.failure):(_c5.success?null:$(_c5))};
this.transport=Ajax.getTransport();
this.setOptions(_c7);
var _c8=this.options.onComplete||Prototype.emptyFunction;
this.options.onComplete=(function(_c9,_ca){
this.updateContent();
_c8(_c9,_ca);
}).bind(this);
this.request(url);
},updateContent:function(){
var _cb=this.responseIsSuccess()?this.containers.success:this.containers.failure;
var _cc=this.transport.responseText;
if(!this.options.evalScripts){
_cc=_cc.stripScripts();
}
if(_cb){
if(this.options.insertion){
new this.options.insertion(_cb,_cc);
}else{
Element.update(_cb,_cc);
}
}
if(this.responseIsSuccess()){
if(this.onComplete){
setTimeout(this.onComplete.bind(this),10);
}
}
}});
Ajax.PeriodicalUpdater=Class.create();
Ajax.PeriodicalUpdater.prototype=Object.extend(new Ajax.Base(),{initialize:function(_cd,url,_cf){
this.setOptions(_cf);
this.onComplete=this.options.onComplete;
this.frequency=(this.options.frequency||2);
this.decay=(this.options.decay||1);
this.updater={};
this.container=_cd;
this.url=url;
this.start();
},start:function(){
this.options.onComplete=this.updateComplete.bind(this);
this.onTimerEvent();
},stop:function(){
this.updater.options.onComplete=undefined;
clearTimeout(this.timer);
(this.onComplete||Prototype.emptyFunction).apply(this,arguments);
},updateComplete:function(_d0){
if(this.options.decay){
this.decay=(_d0.responseText==this.lastText?this.decay*this.options.decay:1);
this.lastText=_d0.responseText;
}
this.timer=setTimeout(this.onTimerEvent.bind(this),this.decay*this.frequency*1000);
},onTimerEvent:function(){
this.updater=new Ajax.Updater(this.container,this.url,this.options);
}});
function $(){
var _d1=[],_d2;
for(var i=0;i<arguments.length;i++){
_d2=arguments[i];
if(typeof _d2=="string"){
_d2=document.getElementById(_d2);
}
_d1.push(Element.extend(_d2));
}
return _d1.reduce();
}
document.getElementsByClassName=function(_d4,_d5){
var _d6=($(_d5)||document.body).getElementsByTagName("*");
return $A(_d6).inject([],function(_d7,_d8){
if(_d8.className.match(new RegExp("(^|\\s)"+_d4+"(\\s|$)"))){
_d7.push(Element.extend(_d8));
}
return _d7;
});
};
if(!window.Element){
var Element=new Object();
}
Element.extend=function(_d9){
if(!_d9){
return;
}
if(_nativeExtensions||_d9.nodeType==3){
return _d9;
}
if(!_d9._extended&&_d9.tagName&&_d9!=window){
var _da=Object.clone(Element.Methods),_db=Element.extend.cache;
if(_d9.tagName=="FORM"){
Object.extend(_da,Form.Methods);
}
if(["INPUT","TEXTAREA","SELECT"].include(_d9.tagName)){
Object.extend(_da,Form.Element.Methods);
}
for(var _dc in _da){
var _dd=_da[_dc];
if(typeof _dd=="function"){
_d9[_dc]=_db.findOrStore(_dd);
}
}
}
_d9._extended=true;
return _d9;
};
Element.extend.cache={findOrStore:function(_de){
return this[_de]=this[_de]||function(){
return _de.apply(null,[this].concat($A(arguments)));
};
}};
Element.Methods={visible:function(_df){
return $(_df).style.display!="none";
},toggle:function(_e0){
_e0=$(_e0);
Element[Element.visible(_e0)?"hide":"show"](_e0);
return _e0;
},hide:function(_e1){
$(_e1).style.display="none";
return _e1;
},show:function(_e2){
$(_e2).style.display="";
return _e2;
},remove:function(_e3){
_e3=$(_e3);
_e3.parentNode.removeChild(_e3);
return _e3;
},update:function(_e4,_e5){
$(_e4).innerHTML=_e5.stripScripts();
setTimeout(function(){
_e5.evalScripts();
},10);
return _e4;
},replace:function(_e6,_e7){
_e6=$(_e6);
if(_e6.outerHTML){
_e6.outerHTML=_e7.stripScripts();
}else{
var _e8=_e6.ownerDocument.createRange();
_e8.selectNodeContents(_e6);
_e6.parentNode.replaceChild(_e8.createContextualFragment(_e7.stripScripts()),_e6);
}
setTimeout(function(){
_e7.evalScripts();
},10);
return _e6;
},inspect:function(_e9){
_e9=$(_e9);
var _ea="<"+_e9.tagName.toLowerCase();
$H({"id":"id","className":"class"}).each(function(_eb){
var _ec=_eb.first(),_ed=_eb.last();
var _ee=(_e9[_ec]||"").toString();
if(_ee){
_ea+=" "+_ed+"="+_ee.inspect(true);
}
});
return _ea+">";
},recursivelyCollect:function(_ef,_f0){
_ef=$(_ef);
var _f1=[];
while(_ef=_ef[_f0]){
if(_ef.nodeType==1){
_f1.push(Element.extend(_ef));
}
}
return _f1;
},ancestors:function(_f2){
return $(_f2).recursivelyCollect("parentNode");
},descendants:function(_f3){
_f3=$(_f3);
return $A(_f3.getElementsByTagName("*"));
},previousSiblings:function(_f4){
return $(_f4).recursivelyCollect("previousSibling");
},nextSiblings:function(_f5){
return $(_f5).recursivelyCollect("nextSibling");
},siblings:function(_f6){
_f6=$(_f6);
return _f6.previousSiblings().reverse().concat(_f6.nextSiblings());
},match:function(_f7,_f8){
_f7=$(_f7);
if(typeof _f8=="string"){
_f8=new Selector(_f8);
}
return _f8.match(_f7);
},up:function(_f9,_fa,_fb){
return Selector.findElement($(_f9).ancestors(),_fa,_fb);
},down:function(_fc,_fd,_fe){
return Selector.findElement($(_fc).descendants(),_fd,_fe);
},previous:function(_ff,_100,_101){
return Selector.findElement($(_ff).previousSiblings(),_100,_101);
},next:function(_102,_103,_104){
return Selector.findElement($(_102).nextSiblings(),_103,_104);
},getElementsBySelector:function(){
var args=$A(arguments),_106=$(args.shift());
return Selector.findChildElements(_106,args);
},getElementsByClassName:function(_107,_108){
_107=$(_107);
return document.getElementsByClassName(_108,_107);
},getHeight:function(_109){
_109=$(_109);
return _109.offsetHeight;
},classNames:function(_10a){
return new Element.ClassNames(_10a);
},hasClassName:function(_10b,_10c){
if(!(_10b=$(_10b))){
return;
}
return Element.classNames(_10b).include(_10c);
},addClassName:function(_10d,_10e){
if(!(_10d=$(_10d))){
return;
}
Element.classNames(_10d).add(_10e);
return _10d;
},removeClassName:function(_10f,_110){
if(!(_10f=$(_10f))){
return;
}
Element.classNames(_10f).remove(_110);
return _10f;
},observe:function(){
Event.observe.apply(Event,arguments);
return $A(arguments).first();
},stopObserving:function(){
Event.stopObserving.apply(Event,arguments);
return $A(arguments).first();
},cleanWhitespace:function(_111){
_111=$(_111);
var node=_111.firstChild;
while(node){
var _113=node.nextSibling;
if(node.nodeType==3&&!/\S/.test(node.nodeValue)){
_111.removeChild(node);
}
node=_113;
}
return _111;
},empty:function(_114){
return $(_114).innerHTML.match(/^\s*$/);
},childOf:function(_115,_116){
_115=$(_115),_116=$(_116);
while(_115=_115.parentNode){
if(_115==_116){
return true;
}
}
return false;
},scrollTo:function(_117){
_117=$(_117);
var x=_117.x?_117.x:_117.offsetLeft,y=_117.y?_117.y:_117.offsetTop;
window.scrollTo(x,y);
return _117;
},getStyle:function(_11a,_11b){
_11a=$(_11a);
var _11c=_11a.style[_11b.camelize()];
if(!_11c){
if(document.defaultView&&document.defaultView.getComputedStyle){
var css=document.defaultView.getComputedStyle(_11a,null);
_11c=css?css.getPropertyValue(_11b):null;
}else{
if(_11a.currentStyle){
_11c=_11a.currentStyle[_11b.camelize()];
}
}
}
if(window.opera&&["left","top","right","bottom"].include(_11b)){
if(Element.getStyle(_11a,"position")=="static"){
_11c="auto";
}
}
return _11c=="auto"?null:_11c;
},setStyle:function(_11e,_11f){
_11e=$(_11e);
for(var name in _11f){
_11e.style[name.camelize()]=_11f[name];
}
return _11e;
},getDimensions:function(_121){
_121=$(_121);
if(Element.getStyle(_121,"display")!="none"){
return {width:_121.offsetWidth,height:_121.offsetHeight};
}
var els=_121.style;
var _123=els.visibility;
var _124=els.position;
els.visibility="hidden";
els.position="absolute";
els.display="";
var _125=_121.clientWidth;
var _126=_121.clientHeight;
els.display="none";
els.position=_124;
els.visibility=_123;
return {width:_125,height:_126};
},makePositioned:function(_127){
_127=$(_127);
var pos=Element.getStyle(_127,"position");
if(pos=="static"||!pos){
_127._madePositioned=true;
_127.style.position="relative";
if(window.opera){
_127.style.top=0;
_127.style.left=0;
}
}
return _127;
},undoPositioned:function(_129){
_129=$(_129);
if(_129._madePositioned){
_129._madePositioned=undefined;
_129.style.position=_129.style.top=_129.style.left=_129.style.bottom=_129.style.right="";
}
return _129;
},makeClipping:function(_12a){
_12a=$(_12a);
if(_12a._overflow){
return;
}
_12a._overflow=_12a.style.overflow||"auto";
if((Element.getStyle(_12a,"overflow")||"visible")!="hidden"){
_12a.style.overflow="hidden";
}
return _12a;
},undoClipping:function(_12b){
_12b=$(_12b);
if(!_12b._overflow){
return;
}
_12b.style.overflow=_12b._overflow=="auto"?"":_12b._overflow;
_12b._overflow=null;
return _12b;
}};
if(document.all){
Element.Methods.update=function(_12c,html){
_12c=$(_12c);
var _12e=_12c.tagName.toUpperCase();
if(["THEAD","TBODY","TR","TD"].indexOf(_12e)>-1){
var div=document.createElement("div");
switch(_12e){
case "THEAD":
case "TBODY":
div.innerHTML="<table><tbody>"+html.stripScripts()+"</tbody></table>";
depth=2;
break;
case "TR":
div.innerHTML="<table><tbody><tr>"+html.stripScripts()+"</tr></tbody></table>";
depth=3;
break;
case "TD":
div.innerHTML="<table><tbody><tr><td>"+html.stripScripts()+"</td></tr></tbody></table>";
depth=4;
}
$A(_12c.childNodes).each(function(node){
_12c.removeChild(node);
});
depth.times(function(){
div=div.firstChild;
});
$A(div.childNodes).each(function(node){
_12c.appendChild(node);
});
}else{
_12c.innerHTML=html.stripScripts();
}
setTimeout(function(){
html.evalScripts();
},10);
return _12c;
};
}
Object.extend(Element,Element.Methods);
var _nativeExtensions=false;
if(!window.HTMLElement&&/Konqueror|Safari|KHTML/.test(navigator.userAgent)){
["","Form","Input","TextArea","Select"].each(function(tag){
var _133=window["HTML"+tag+"Element"]={};
_133.prototype=document.createElement(tag?tag.toLowerCase():"div").__proto__;
});
}
Element.addMethods=function(_134){
Object.extend(Element.Methods,_134||{});
function copy(_135,_136){
var _137=Element.extend.cache;
for(var _138 in _135){
var _139=_135[_138];
_136[_138]=_137.findOrStore(_139);
}
}
if(typeof HTMLElement!="undefined"){
copy(Element.Methods,HTMLElement.prototype);
copy(Form.Methods,HTMLFormElement.prototype);
[HTMLInputElement,HTMLTextAreaElement,HTMLSelectElement].each(function(_13a){
copy(Form.Element.Methods,_13a.prototype);
});
_nativeExtensions=true;
}
};
var Toggle=new Object();
Toggle.display=Element.toggle;
Abstract.Insertion=function(_13b){
this.adjacency=_13b;
};
Abstract.Insertion.prototype={initialize:function(_13c,_13d){
this.element=$(_13c);
this.content=_13d.stripScripts();
if(this.adjacency&&this.element.insertAdjacentHTML){
try{
this.element.insertAdjacentHTML(this.adjacency,this.content);
}
catch(e){
var _13e=this.element.tagName.toLowerCase();
if(_13e=="tbody"||_13e=="tr"){
this.insertContent(this.contentFromAnonymousTable());
}else{
throw e;
}
}
}else{
this.range=this.element.ownerDocument.createRange();
if(this.initializeRange){
this.initializeRange();
}
this.insertContent([this.range.createContextualFragment(this.content)]);
}
setTimeout(function(){
_13d.evalScripts();
},10);
},contentFromAnonymousTable:function(){
var div=document.createElement("div");
div.innerHTML="<table><tbody>"+this.content+"</tbody></table>";
return $A(div.childNodes[0].childNodes[0].childNodes);
}};
var Insertion=new Object();
Insertion.Before=Class.create();
Insertion.Before.prototype=Object.extend(new Abstract.Insertion("beforeBegin"),{initializeRange:function(){
this.range.setStartBefore(this.element);
},insertContent:function(_140){
_140.each((function(_141){
this.element.parentNode.insertBefore(_141,this.element);
}).bind(this));
}});
Insertion.Top=Class.create();
Insertion.Top.prototype=Object.extend(new Abstract.Insertion("afterBegin"),{initializeRange:function(){
this.range.selectNodeContents(this.element);
this.range.collapse(true);
},insertContent:function(_142){
_142.reverse(false).each((function(_143){
this.element.insertBefore(_143,this.element.firstChild);
}).bind(this));
}});
Insertion.Bottom=Class.create();
Insertion.Bottom.prototype=Object.extend(new Abstract.Insertion("beforeEnd"),{initializeRange:function(){
this.range.selectNodeContents(this.element);
this.range.collapse(this.element);
},insertContent:function(_144){
_144.each((function(_145){
this.element.appendChild(_145);
}).bind(this));
}});
Insertion.After=Class.create();
Insertion.After.prototype=Object.extend(new Abstract.Insertion("afterEnd"),{initializeRange:function(){
this.range.setStartAfter(this.element);
},insertContent:function(_146){
_146.each((function(_147){
this.element.parentNode.insertBefore(_147,this.element.nextSibling);
}).bind(this));
}});
Element.ClassNames=Class.create();
Element.ClassNames.prototype={initialize:function(_148){
this.element=$(_148);
},_each:function(_149){
this.element.className.split(/\s+/).select(function(name){
return name.length>0;
})._each(_149);
},set:function(_14b){
this.element.className=_14b;
},add:function(_14c){
if(this.include(_14c)){
return;
}
this.set(this.toArray().concat(_14c).join(" "));
},remove:function(_14d){
if(!this.include(_14d)){
return;
}
this.set(this.select(function(_14e){
return _14e!=_14d;
}).join(" "));
},toString:function(){
return this.toArray().join(" ");
}};
Object.extend(Element.ClassNames.prototype,Enumerable);
var Selector=Class.create();
Selector.prototype={initialize:function(_14f){
this.params={classNames:[]};
this.expression=_14f.toString().strip();
this.parseExpression();
this.compileMatcher();
},parseExpression:function(){
function abort(_150){
throw "Parse error in selector: "+_150;
}
if(this.expression==""){
abort("empty expression");
}
var _151=this.params,expr=this.expression,_153,_154,_155,rest;
while(_153=expr.match(/^(.*)\[([a-z0-9_:-]+?)(?:([~\|!]?=)(?:"([^"]*)"|([^\]\s]*)))?\]$/i)){
_151.attributes=_151.attributes||[];
_151.attributes.push({name:_153[2],operator:_153[3],value:_153[4]||_153[5]||""});
expr=_153[1];
}
if(expr=="*"){
return this.params.wildcard=true;
}
while(_153=expr.match(/^([^a-z0-9_-])?([a-z0-9_-]+)(.*)/i)){
_154=_153[1],_155=_153[2],rest=_153[3];
switch(_154){
case "#":
_151.id=_155;
break;
case ".":
_151.classNames.push(_155);
break;
case "":
case undefined:
_151.tagName=_155.toUpperCase();
break;
default:
abort(expr.inspect());
}
expr=rest;
}
if(expr.length>0){
abort(expr.inspect());
}
},buildMatchExpression:function(){
var _157=this.params,_158=[],_159;
if(_157.wildcard){
_158.push("true");
}
if(_159=_157.id){
_158.push("element.id == "+_159.inspect());
}
if(_159=_157.tagName){
_158.push("element.tagName.toUpperCase() == "+_159.inspect());
}
if((_159=_157.classNames).length>0){
for(var i=0;i<_159.length;i++){
_158.push("Element.hasClassName(element, "+_159[i].inspect()+")");
}
}
if(_159=_157.attributes){
_159.each(function(_15b){
var _15c="element.getAttribute("+_15b.name.inspect()+")";
var _15d=function(_15e){
return _15c+" && "+_15c+".split("+_15e.inspect()+")";
};
switch(_15b.operator){
case "=":
_158.push(_15c+" == "+_15b.value.inspect());
break;
case "~=":
_158.push(_15d(" ")+".include("+_15b.value.inspect()+")");
break;
case "|=":
_158.push(_15d("-")+".first().toUpperCase() == "+_15b.value.toUpperCase().inspect());
break;
case "!=":
_158.push(_15c+" != "+_15b.value.inspect());
break;
case "":
case undefined:
_158.push(_15c+" != null");
break;
default:
throw "Unknown operator "+_15b.operator+" in selector";
}
});
}
return _158.join(" && ");
},compileMatcher:function(){
this.match=new Function("element","if (!element.tagName) return false;       return "+this.buildMatchExpression());
},findElements:function(_15f){
var _160;
if(_160=$(this.params.id)){
if(this.match(_160)){
if(!_15f||Element.childOf(_160,_15f)){
return [_160];
}
}
}
_15f=(_15f||document).getElementsByTagName(this.params.tagName||"*");
var _161=[];
for(var i=0;i<_15f.length;i++){
if(this.match(_160=_15f[i])){
_161.push(Element.extend(_160));
}
}
return _161;
},toString:function(){
return this.expression;
}};
Object.extend(Selector,{matchElements:function(_163,_164){
var _165=new Selector(_164);
return _163.select(_165.match.bind(_165));
},findElement:function(_166,_167,_168){
if(typeof _167=="number"){
_168=_167,_167=false;
}
return Selector.matchElements(_166,_167||"*")[_168||0];
},findChildElements:function(_169,_16a){
return _16a.map(function(_16b){
return _16b.strip().split(/\s+/).inject([null],function(_16c,expr){
var _16e=new Selector(expr);
return _16c.inject([],function(_16f,_170){
return _16f.concat(_16e.findElements(_170||_169));
});
});
}).flatten();
}});
function $$(){
return Selector.findChildElements(document,$A(arguments));
}
var Form={reset:function(form){
$(form).reset();
return form;
}};
Form.Methods={serialize:function(form){
var _173=Form.getElements($(form));
var _174=new Array();
for(var i=0;i<_173.length;i++){
var _176=Form.Element.serialize(_173[i]);
if(_176){
_174.push(_176);
}
}
return _174.join("&");
},getElements:function(form){
form=$(form);
var _178=new Array();
for(var _179 in Form.Element.Serializers){
var _17a=form.getElementsByTagName(_179);
for(var j=0;j<_17a.length;j++){
_178.push(_17a[j]);
}
}
return _178;
},getInputs:function(form,_17d,name){
form=$(form);
var _17f=form.getElementsByTagName("input");
if(!_17d&&!name){
return _17f;
}
var _180=new Array();
for(var i=0;i<_17f.length;i++){
var _182=_17f[i];
if((_17d&&_182.type!=_17d)||(name&&_182.name!=name)){
continue;
}
_180.push(_182);
}
return _180;
},disable:function(form){
form=$(form);
var _184=Form.getElements(form);
for(var i=0;i<_184.length;i++){
var _186=_184[i];
_186.blur();
_186.disabled="true";
}
return form;
},enable:function(form){
form=$(form);
var _188=Form.getElements(form);
for(var i=0;i<_188.length;i++){
var _18a=_188[i];
_18a.disabled="";
}
return form;
},findFirstElement:function(form){
return Form.getElements(form).find(function(_18c){
return _18c.type!="hidden"&&!_18c.disabled&&["input","select","textarea"].include(_18c.tagName.toLowerCase());
});
},focusFirstElement:function(form){
form=$(form);
Field.activate(Form.findFirstElement(form));
return form;
}};
Object.extend(Form,Form.Methods);
Form.Element={focus:function(_18e){
$(_18e).focus();
return _18e;
},select:function(_18f){
$(_18f).select();
return _18f;
}};
Form.Element.Methods={serialize:function(_190){
_190=$(_190);
var _191=_190.tagName.toLowerCase();
var _192=Form.Element.Serializers[_191](_190);
if(_192){
var key=encodeURIComponent(_192[0]);
if(key.length==0){
return;
}
if(_192[1].constructor!=Array){
_192[1]=[_192[1]];
}
return _192[1].map(function(_194){
return key+"="+encodeURIComponent(_194);
}).join("&");
}
},getValue:function(_195){
_195=$(_195);
var _196=_195.tagName.toLowerCase();
var _197=Form.Element.Serializers[_196](_195);
if(_197){
return _197[1];
}
},clear:function(_198){
$(_198).value="";
return _198;
},present:function(_199){
return $(_199).value!="";
},activate:function(_19a){
_19a=$(_19a);
_19a.focus();
if(_19a.select){
_19a.select();
}
return _19a;
},disable:function(_19b){
_19b=$(_19b);
_19b.disabled="";
return _19b;
},enable:function(_19c){
_19c=$(_19c);
_19c.blur();
_19c.disabled="true";
return _19c;
}};
Object.extend(Form.Element,Form.Element.Methods);
var Field=Form.Element;
Form.Element.Serializers={input:function(_19d){
switch(_19d.type.toLowerCase()){
case "checkbox":
case "radio":
return Form.Element.Serializers.inputSelector(_19d);
default:
return Form.Element.Serializers.textarea(_19d);
}
return false;
},inputSelector:function(_19e){
if(_19e.checked){
return [_19e.name,_19e.value];
}
},textarea:function(_19f){
return [_19f.name,_19f.value];
},select:function(_1a0){
return Form.Element.Serializers[_1a0.type=="select-one"?"selectOne":"selectMany"](_1a0);
},selectOne:function(_1a1){
var _1a2="",opt,_1a4=_1a1.selectedIndex;
if(_1a4>=0){
opt=_1a1.options[_1a4];
_1a2=opt.value||opt.text;
}
return [_1a1.name,_1a2];
},selectMany:function(_1a5){
var _1a6=[];
for(var i=0;i<_1a5.length;i++){
var opt=_1a5.options[i];
if(opt.selected){
_1a6.push(opt.value||opt.text);
}
}
return [_1a5.name,_1a6];
}};
var $F=Form.Element.getValue;
Abstract.TimedObserver=function(){
};
Abstract.TimedObserver.prototype={initialize:function(_1a9,_1aa,_1ab){
this.frequency=_1aa;
this.element=$(_1a9);
this.callback=_1ab;
this.lastValue=this.getValue();
this.registerCallback();
},registerCallback:function(){
setInterval(this.onTimerEvent.bind(this),this.frequency*1000);
},onTimerEvent:function(){
var _1ac=this.getValue();
if(this.lastValue!=_1ac){
this.callback(this.element,_1ac);
this.lastValue=_1ac;
}
}};
Form.Element.Observer=Class.create();
Form.Element.Observer.prototype=Object.extend(new Abstract.TimedObserver(),{getValue:function(){
return Form.Element.getValue(this.element);
}});
Form.Observer=Class.create();
Form.Observer.prototype=Object.extend(new Abstract.TimedObserver(),{getValue:function(){
return Form.serialize(this.element);
}});
Abstract.EventObserver=function(){
};
Abstract.EventObserver.prototype={initialize:function(_1ad,_1ae){
this.element=$(_1ad);
this.callback=_1ae;
this.lastValue=this.getValue();
if(this.element.tagName.toLowerCase()=="form"){
this.registerFormCallbacks();
}else{
this.registerCallback(this.element);
}
},onElementEvent:function(){
var _1af=this.getValue();
if(this.lastValue!=_1af){
this.callback(this.element,_1af);
this.lastValue=_1af;
}
},registerFormCallbacks:function(){
var _1b0=Form.getElements(this.element);
for(var i=0;i<_1b0.length;i++){
this.registerCallback(_1b0[i]);
}
},registerCallback:function(_1b2){
if(_1b2.type){
switch(_1b2.type.toLowerCase()){
case "checkbox":
case "radio":
Event.observe(_1b2,"click",this.onElementEvent.bind(this));
break;
default:
Event.observe(_1b2,"change",this.onElementEvent.bind(this));
break;
}
}
}};
Form.Element.EventObserver=Class.create();
Form.Element.EventObserver.prototype=Object.extend(new Abstract.EventObserver(),{getValue:function(){
return Form.Element.getValue(this.element);
}});
Form.EventObserver=Class.create();
Form.EventObserver.prototype=Object.extend(new Abstract.EventObserver(),{getValue:function(){
return Form.serialize(this.element);
}});
if(!window.Event){
var Event=new Object();
}
Object.extend(Event,{KEY_BACKSPACE:8,KEY_TAB:9,KEY_RETURN:13,KEY_ESC:27,KEY_LEFT:37,KEY_UP:38,KEY_RIGHT:39,KEY_DOWN:40,KEY_DELETE:46,KEY_HOME:36,KEY_END:35,KEY_PAGEUP:33,KEY_PAGEDOWN:34,element:function(_1b3){
return _1b3.target||_1b3.srcElement;
},isLeftClick:function(_1b4){
return (((_1b4.which)&&(_1b4.which==1))||((_1b4.button)&&(_1b4.button==1)));
},pointerX:function(_1b5){
return _1b5.pageX||(_1b5.clientX+(document.documentElement.scrollLeft||document.body.scrollLeft));
},pointerY:function(_1b6){
return _1b6.pageY||(_1b6.clientY+(document.documentElement.scrollTop||document.body.scrollTop));
},stop:function(_1b7){
if(_1b7.preventDefault){
_1b7.preventDefault();
_1b7.stopPropagation();
}else{
_1b7.returnValue=false;
_1b7.cancelBubble=true;
}
},findElement:function(_1b8,_1b9){
var _1ba=Event.element(_1b8);
while(_1ba.parentNode&&(!_1ba.tagName||(_1ba.tagName.toUpperCase()!=_1b9.toUpperCase()))){
_1ba=_1ba.parentNode;
}
return _1ba;
},observers:false,_observeAndCache:function(_1bb,name,_1bd,_1be){
if(!this.observers){
this.observers=[];
}
if(_1bb.addEventListener){
this.observers.push([_1bb,name,_1bd,_1be]);
_1bb.addEventListener(name,_1bd,_1be);
}else{
if(_1bb.attachEvent){
this.observers.push([_1bb,name,_1bd,_1be]);
_1bb.attachEvent("on"+name,_1bd);
}
}
},unloadCache:function(){
if(!Event.observers){
return;
}
for(var i=0;i<Event.observers.length;i++){
Event.stopObserving.apply(this,Event.observers[i]);
Event.observers[i][0]=null;
}
Event.observers=false;
},observe:function(_1c0,name,_1c2,_1c3){
_1c0=$(_1c0);
_1c3=_1c3||false;
if(name=="keypress"&&(navigator.appVersion.match(/Konqueror|Safari|KHTML/)||_1c0.attachEvent)){
name="keydown";
}
Event._observeAndCache(_1c0,name,_1c2,_1c3);
},stopObserving:function(_1c4,name,_1c6,_1c7){
_1c4=$(_1c4);
_1c7=_1c7||false;
if(name=="keypress"&&(navigator.appVersion.match(/Konqueror|Safari|KHTML/)||_1c4.detachEvent)){
name="keydown";
}
if(_1c4.removeEventListener){
_1c4.removeEventListener(name,_1c6,_1c7);
}else{
if(_1c4.detachEvent){
try{
_1c4.detachEvent("on"+name,_1c6);
}
catch(e){
}
}
}
}});
if(navigator.appVersion.match(/\bMSIE\b/)){
Event.observe(window,"unload",Event.unloadCache,false);
}
var Position={includeScrollOffsets:false,prepare:function(){
this.deltaX=window.pageXOffset||document.documentElement.scrollLeft||document.body.scrollLeft||0;
this.deltaY=window.pageYOffset||document.documentElement.scrollTop||document.body.scrollTop||0;
},realOffset:function(_1c8){
var _1c9=0,_1ca=0;
do{
_1c9+=_1c8.scrollTop||0;
_1ca+=_1c8.scrollLeft||0;
_1c8=_1c8.parentNode;
}while(_1c8);
return [_1ca,_1c9];
},cumulativeOffset:function(_1cb){
var _1cc=0,_1cd=0;
do{
_1cc+=_1cb.offsetTop||0;
_1cd+=_1cb.offsetLeft||0;
_1cb=_1cb.offsetParent;
}while(_1cb);
return [_1cd,_1cc];
},positionedOffset:function(_1ce){
var _1cf=0,_1d0=0;
do{
_1cf+=_1ce.offsetTop||0;
_1d0+=_1ce.offsetLeft||0;
_1ce=_1ce.offsetParent;
if(_1ce){
p=Element.getStyle(_1ce,"position");
if(p=="relative"||p=="absolute"){
break;
}
}
}while(_1ce);
return [_1d0,_1cf];
},offsetParent:function(_1d1){
if(_1d1.offsetParent){
return _1d1.offsetParent;
}
if(_1d1==document.body){
return _1d1;
}
while((_1d1=_1d1.parentNode)&&_1d1!=document.body){
if(Element.getStyle(_1d1,"position")!="static"){
return _1d1;
}
}
return document.body;
},within:function(_1d2,x,y){
if(this.includeScrollOffsets){
return this.withinIncludingScrolloffsets(_1d2,x,y);
}
this.xcomp=x;
this.ycomp=y;
this.offset=this.cumulativeOffset(_1d2);
return (y>=this.offset[1]&&y<this.offset[1]+_1d2.offsetHeight&&x>=this.offset[0]&&x<this.offset[0]+_1d2.offsetWidth);
},withinIncludingScrolloffsets:function(_1d5,x,y){
var _1d8=this.realOffset(_1d5);
this.xcomp=x+_1d8[0]-this.deltaX;
this.ycomp=y+_1d8[1]-this.deltaY;
this.offset=this.cumulativeOffset(_1d5);
return (this.ycomp>=this.offset[1]&&this.ycomp<this.offset[1]+_1d5.offsetHeight&&this.xcomp>=this.offset[0]&&this.xcomp<this.offset[0]+_1d5.offsetWidth);
},overlap:function(mode,_1da){
if(!mode){
return 0;
}
if(mode=="vertical"){
return ((this.offset[1]+_1da.offsetHeight)-this.ycomp)/_1da.offsetHeight;
}
if(mode=="horizontal"){
return ((this.offset[0]+_1da.offsetWidth)-this.xcomp)/_1da.offsetWidth;
}
},page:function(_1db){
var _1dc=0,_1dd=0;
var _1de=_1db;
do{
_1dc+=_1de.offsetTop||0;
_1dd+=_1de.offsetLeft||0;
if(_1de.offsetParent==document.body){
if(Element.getStyle(_1de,"position")=="absolute"){
break;
}
}
}while(_1de=_1de.offsetParent);
_1de=_1db;
do{
if(!window.opera||_1de.tagName=="BODY"){
_1dc-=_1de.scrollTop||0;
_1dd-=_1de.scrollLeft||0;
}
}while(_1de=_1de.parentNode);
return [_1dd,_1dc];
},clone:function(_1df,_1e0){
var _1e1=Object.extend({setLeft:true,setTop:true,setWidth:true,setHeight:true,offsetTop:0,offsetLeft:0},arguments[2]||{});
_1df=$(_1df);
var p=Position.page(_1df);
_1e0=$(_1e0);
var _1e3=[0,0];
var _1e4=null;
if(Element.getStyle(_1e0,"position")=="absolute"){
_1e4=Position.offsetParent(_1e0);
_1e3=Position.page(_1e4);
}
if(_1e4==document.body){
_1e3[0]-=document.body.offsetLeft;
_1e3[1]-=document.body.offsetTop;
}
if(_1e1.setLeft){
_1e0.style.left=(p[0]-_1e3[0]+_1e1.offsetLeft)+"px";
}
if(_1e1.setTop){
_1e0.style.top=(p[1]-_1e3[1]+_1e1.offsetTop)+"px";
}
if(_1e1.setWidth){
_1e0.style.width=_1df.offsetWidth+"px";
}
if(_1e1.setHeight){
_1e0.style.height=_1df.offsetHeight+"px";
}
},absolutize:function(_1e5){
_1e5=$(_1e5);
if(_1e5.style.position=="absolute"){
return;
}
Position.prepare();
var _1e6=Position.positionedOffset(_1e5);
var top=_1e6[1];
var left=_1e6[0];
var _1e9=_1e5.clientWidth;
var _1ea=_1e5.clientHeight;
_1e5._originalLeft=left-parseFloat(_1e5.style.left||0);
_1e5._originalTop=top-parseFloat(_1e5.style.top||0);
_1e5._originalWidth=_1e5.style.width;
_1e5._originalHeight=_1e5.style.height;
_1e5.style.position="absolute";
_1e5.style.top=top+"px";
_1e5.style.left=left+"px";
_1e5.style.width=_1e9+"px";
_1e5.style.height=_1ea+"px";
},relativize:function(_1eb){
_1eb=$(_1eb);
if(_1eb.style.position=="relative"){
return;
}
Position.prepare();
_1eb.style.position="relative";
var top=parseFloat(_1eb.style.top||0)-(_1eb._originalTop||0);
var left=parseFloat(_1eb.style.left||0)-(_1eb._originalLeft||0);
_1eb.style.top=top+"px";
_1eb.style.left=left+"px";
_1eb.style.height=_1eb._originalHeight;
_1eb.style.width=_1eb._originalWidth;
}};
if(/Konqueror|Safari|KHTML/.test(navigator.userAgent)){
Position.cumulativeOffset=function(_1ee){
var _1ef=0,_1f0=0;
do{
_1ef+=_1ee.offsetTop||0;
_1f0+=_1ee.offsetLeft||0;
if(_1ee.offsetParent==document.body){
if(Element.getStyle(_1ee,"position")=="absolute"){
break;
}
}
_1ee=_1ee.offsetParent;
}while(_1ee);
return [_1f0,_1ef];
};
}
Element.addMethods();

