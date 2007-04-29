<master>
<property name="title"> TEST : Yahoo Menu from TCL List</property>
<property name="header_stuff">
<style>
#samplemenu li {
    list-style:none;
    margin:10px;
    padding:0;
    float:left;
}
</style>
</property>

<div id="samplemenu" style="margin:10px;">
    <ul>
        <li><a href="javascript:void(0)" id="menu1" onclick="@action_script1;noquote@">Menu 1</a></li>
        <li><a href="javascript:void(0)" id="menu2" onclick="@action_script2;noquote@">Menu 2</a></li>
    </ul>
</div>

@js_script;noquote@