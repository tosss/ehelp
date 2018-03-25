        /* 
		Author: Rey Austral
		Company: Cloud Sherpas
		Description: all css that is used in IMP.Milestone component
		History
		11/12/14    Rey Austral         Created
		*/
		
		h2 {
			font-size: 16px !important;
		}
		.child_td {
			border-left: 1px dotted #aaa;
			margin-left: 5px;
			padding: 5px 0px 5px 0px;
        }
        
        .child_td_header {
			cursor:pointer;
        }
        

        .child_td_node {
			position: relative;
			display: inline-block;
			border-bottom: 1px dotted #aaa;
			width: 10px;
			top: -4px;
        }
        
        .child_td_content {
			margin-left: 20px;
			margin-top: 7px;           
        }
        
        .child_td_content_container {
        
        }
        
        .child_td_hide {
			display:none;
        }
        
        .child_td_show {
			display:block;
        }
        
        .mainTable {
			border-collapse: collapse;
			width:100%
        }
        
        .childTable {
			border-collapse: collapse;
			width:100%
        }
		
		.grandChildTable {
			border-collapse: collapse;
			width:100%
        }
		
        .mainTable td, .childTable td, .grandChildTable td{
			padding: 5px;
			vertical-align: top;
        }
        
        
        .header_tr {
			background-color: #f2f3f3;
			font-weight: bold;
        }
        
        .dataRow {
			background-color: white;
        }
        .header_tr th, .dataRow td {
			border: 1px solid #e0e3e5 !important;
			border-right: none !important;
			white-space: nowrap;
			padding:5px;
        }
        
        .mainTable .dataRow td textarea, .childTable .dataRow_child td textarea , .granChildTable .dataRow_child td textarea{
			resize: both;
			height: 65px;
			width: 98%;
			overflow: auto;
			min-height: 61px;
			min-width: 186px;
        }
        
       
        
        .child_header_tr {
			background-color: #C8D7E3;
			font-weight: bold;
        }
        
        .dataRow_child {
			background-color: white;
        }
        .child_header_tr th, .dataRow_child  td {
			border: 1px solid #e0e3e5 !important;
			border-right: none !important;
			white-space: nowrap;
			vertical-align:middle;
			padding:5px;
        }
		
		.dataTd_Ouput {
			padding-right:16px;
		}
        .changedValue {
           
        }
		
		.psrHeader {
			position:relative;
			bottom:1px;
			vertical-align:middle;
		}
		
		.CautionFont{
			color: #F3D904 !important;
		}
		.At.RiskFont{
			color: #FF0000 !important;
		}
		.CompleteFont{
			color: #999999 !important;
		}
		.On.HoldFont{
			color: #3333FF !important;
		}
		
		.errorClass {
        	background-color: #FFCE33;
        }
        
        .activityExpandClass {
        	/* add style for h3 if the activity expand*/
        }
		
		.milestone_border {
			border-left: 3px solid #007fcc;
		}
		
		.milestone_description {
			font-size:14px;
			font-style:italic;
		}
		
		.hide_component {
			display:none;
		}
		
		.milestone_site {
			width:100%;
			height:38px;
		}
		
		.remove_Activity {
			cursor:pointer;
			width:100%;
			text-align:center;
		}
		
		.remove_Activity :hover{
			color:blue;
			text-decoration: underline;
		}
		
		.add_Activity {
			cursor:pointer;
			width:100px;
			display:inline;
			margin-left:10px;
			font-style: italic;
			font-weight: bold;
		}	

		.add_Activity span:hover {
			color:blue;
			text-decoration: underline;
		}
		
		.milestone_massSite {
			width:100%;
		}
		
		.milestone_comment {			
			white-space:normal !important;
			word-break: break-all;
			width: 130px;
		}
		
		.activity_comment {			
			white-space:normal !important;
			min-width:200px;
		}
		
		.checkbox_td {
			width:inherit !important;
		}
		
	    .mass_success {
			border: 2px solid green;
			padding:10px;
			border-radius:3px;
			margin-bottom:10px;
			color:green;
        }
        
        .mass_error {
			border: 2px solid #f5aca6;
			padding:10px;
			border-radius:3px;
			margin-bottom:10px;
			color:red;
        }
		
		.update_dialog {
			display:none;
			text-align:center;
			padding-top:15px !important;
		}
		
		.massUpdate_Type {
			margin-bottom:10px
		}
		
		.hoverEditableField {
			background: url("/img/func_icons/util/pencil12.gif") no-repeat scroll right 4px transparent;
		}
		
		.ui-dialog-titlebar {
			border-top-left-radius: 0px !important;
			border-top-right-radius: 0px !important;
			border-bottom-left-radius: 0px !important;
			border-bottom-right-radius: 0px !important;
		}
		
		.ui-corner-flat {
			border-top-left-radius: 0px !important;
			border-top-right-radius: 0px !important;
			border-bottom-left-radius: 0px !important;
			border-bottom-right-radius: 0px !important;
		}
		
		.ui-widget-header {
			background: #5C9CCC !important;
		}
		
		 .hide_button {
			display:none !important;
		 }
		
		.activity_border {
        	border-left: 3px solid #82C600;
        }
        
        .grandChild_header_tr {
            background-color: #2D97D3;
            font-weight: bold;
        }
        
        .grandChild_header_tr th, .dataRow_child td {
			border: 1px solid #e0e3e5 !important;
			border-right: none !important;
            white-space: nowrap;
            vertical-align: middle;
            padding: 5px;
        }
		
		.popupContainer {
			position:absolute;
		}
		
		.popupContent {
			position:relative;
			min-width:100vw;
		}
		
		.milestone_required {
			background-color: #c00;
			float: left; 
			width: 3px; 
			margin-right: 1px; 
			height:20px;
		}
		
		
		
		
		
	