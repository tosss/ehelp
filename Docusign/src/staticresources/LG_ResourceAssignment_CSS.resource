.autocomplete-container
{
	border: solid 1px #BBB;
	background-color: #FFF;
	width: 50%;
	overflow: hidden;
	position: relative;
}

.autocomplete-input-container
{
	display: block;
	overflow: hidden;
}

.autocomplete-input
{
	font-size: 18pt;
	color: #333;
	padding: 4px 0 2px 2px;
	border: solid 0px transparent;
	width: 100%;
}

.autocomplete-button
{
    cursor: pointer;
    font-size: 14px;
    line-height: 20px;
    padding: 15px 9px;
    text-align: center;
    vertical-align: middle;
	border: solid 1px transparent;
	border-radius: 0px;
	background: url("") no-repeat scroll right top #EEE;
	float: right;
}

.caret 
{
	display: inline-block;
	width: 0;
	height: 0;
	vertical-align: top;
	border-top: 4px solid #666;
	border-right: 4px solid transparent;
	border-left: 4px solid transparent;
	content: "";
}

.selected
{
	border-top-right-radius: 4px;
	border-top-left-radius: 4px;
	border-top: solid 1px #DEDEDE;
	padding: 3px;
	background-color: #FFF;
	font-size: 0.7em;
	overflow-y: scroll;
	height: auto;
	max-height: 58px;
	min-height: 28px;
}

.selected-label
{
	color: #DEDEDE;
	font-size: 1.6em;
	padding: 5px 8px;
	position: absolute;
	cursor: default;
}

.dataTables_wrapper .ui-toolbar 
{
	border-top-right-radius: 0px !important;
	border-top-left-radius: 0px !important;
    padding: 5px;
}

.datatable
{
	width: 100%;
	border-spacing: 0;
}

.datatable tbody
{
	border-left: 1px solid #DDD;
    border-right: 1px solid #DDD;
}

.dt-input
{
	border: solid 1px #BBB;
	width: 150px;
}

.datatable input[type=checkbox]
{
	margin: 3px;
}

table.display thead th, table.display td
{
	padding: 3px;
	vertical-align: middle;
}

.changed
{
	background-color: #FFFAEC;
	font-style:normal;
}

.control-group
{
	padding: 0 10px 10px 10px;
}

.control-group-label
{
	color: #444444;
    font: bold 9pt sans-serif;
    vertical-align: middle;
	margin-right: 6px;
	display: inline-block;
}

.control-group-input
{
	font: 14pt sans-serif;
	margin-right: 6px;
	position: relative;
	top: 3px;
}

.control-group-button
{
	margin-right: 6px;
}

.left
{
	float: left;
}

.right
{
	float: right;
}

.clear
{
	clear: both;
}
