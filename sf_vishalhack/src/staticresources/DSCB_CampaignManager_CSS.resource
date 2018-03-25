#SelectCampaign
{
	width: 50%;
	font-size: 18pt;
	padding: 3px;
	border: 1px solid #DEDEDE;
	border-radius: 0px;
	background-color: #FFF;
	vertical-align: middle;
}

#ToggleSelectCampaign
{
	padding: 11px 0px;
	vertical-align: middle;
	position: relative;
	left: -4px;
	border-radius: 0px;
}

#overlay, .overlay 
{
	background-color: #FFF;
	position: absolute;
	left: -10px;
	top: 4px;
	width:100%;
	height:100%;
	text-align:center;
	z-index: 75;
	filter:alpha(opacity=75); 
	-moz-opacity: 0.75; 
	opacity: 0.75; 
	border-radius: 4px;
    margin: 0 10px;
}

#FindContacts
{
	margin: 4px 0px;
	vertical-align: top;
}

#AddNewContactButtonContainer input, #SendEngageEmailButtonContainer input
{
	font-size: 8pt;
	margin: 0;
	padding: 3px;
}

#NewContactAccountSelect
{
	width:200px;
}

.Selected
{
	border-radius: 4px;
	border-top: solid 1px #DEDEDE;
	padding: 3px;
	background-color: #FFF;
	font-size: 0.7em;
	overflow: auto;
	height: auto;
	max-height: 58px;
	min-height: 28px;
}

.SelectedLabel
{
	color: #DEDEDE;
	font-size: 1.6em;
	padding: 5px 8px;
	position: absolute;
	cursor: default;
}

.NewContactErrorSummary
{
	font-weight: bold;
	padding: 10px;
	text-align: center;
}

.PageSection
{
	background-color: #EDF7FF;
	border: 1px solid #C0DAEA;
	border-radius: 4px;
	color: #333333;
	font-family: Arial,Helvetica,sans-serif;
	font-weight: bold;
	line-height: 2em;
	margin-top: 6px;
	padding: 6px !important;
	text-align: left !important;
}

.divider
{
	border-top:solid 1px #DBDBDB; 
	border-bottom: solid 1px #FFF; 
	margin-bottom: 4px; 
	margin-top: 10px;
	width:100%; 
	height:0px; 
}

.TableButton 
{ 
	font-size: 0.8em;
	padding: 2px 6px; 
}

.dataTables_filter 
{
	width:auto;
}

.dataTables_wrapper th
{
	cursor: pointer;
}

.DataTables_sort_wrapper
{
	padding-right: 20px;
	position: relative;
	font-size: 90%;
}

.css_right
{
	margin-top: -8px;
	position: absolute;
	right: 0;
	top: 50%;
}

.labelCol { padding-top:6px; }

.dataTables_wrapper { min-height:1px; }

tr.odd { background-color: #DFEFFC; }
tr.odd td.sorting_1 { background-color: #CEE9FF; }

tr.even { background-color: #FFF; }
tr.even td.sorting_1 { background-color: #EDF7FF; }
