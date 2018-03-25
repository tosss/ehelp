/*2017-03-23- anirudh.singh@cdk.com- Added 5 styles for showing Spinner.*/
.tps input[type="checkbox"] {
    margin: 4px 0 0;
    margin-top: 1px \9;
    line-height: normal;
    width: 25px;
    height: 25px;
}
@media screen and (max-width: 900px) {
    .tpsMenu {
        float: left;        
        padding-top: 10px !Important;
        padding-left: 0px !Important;
    }
}

.tps .navbar-default {
    background: #00A9CE;
    width: 100%;
    box-shadow: 0 0 .5rem 0 #000;
    margin-top: 0!Important;
    padding: 6px;
    color: white;
}
.tps .pull-left {
    float: left!important;
    position: absolute;
}
.tps a {
    color: #00a9ce;
    text-decoration: underline;
}
.tps .panel {
    margin-bottom: 0px; 
}
.tps .footable>thead>tr>th, .footable>thead>tr>td {
    background-color: #00A9CE;
    border: 1px solid #fff;
    color: #ffffff;        
    font-weight: normal;
}
.tps .footable.breakpoint>tbody>tr.footable-row-detail {
    background: #eeeeee;
}
.tps .footable.breakpoint>tbody>tr>td.footable-row-detail-cell {
    background: #fff;
}
.tps .footable-row-detail-inner {
    display: table;
}
.tps .footable-row-detail-row {
    display: table-row;
    line-height: 1.5em;
}
.tps .footable-row-detail-name {
    display: table-cell;
    font-weight: bold;
    padding-right: .5em;
}
.tps .footable-row-detail-value {
    display: table-cell;
}
.tps .footable.breakpoint>tbody>tr>td>span.footable-toggle {
    display: inline-block;
    font-family: 'footable';
    speak: none;
    font-style: normal;
    font-weight: normal;
    font-variant: normal;
    text-transform: none;
    -webkit-font-smoothing: antialiased;
    padding-right: 5px;
    font-size: 14px;
    color: #888888;
}
.tps .footable.breakpoint>tbody>tr.footable-detail-show>td {
    border-bottom: 0;
}
.tps .discSolHeader
{
    margin:0px;  
}
.tps .modal.in .modal-dialog {
    -webkit-transform: translate(0,0);
    -ms-transform: translate(0,0);
    -o-transform: translate(0,0);
    transform: translate(0,0);
    z-index: 9999 !Important;
}
.tps .errorM3{
    padding: 5px;
    margin-bottom: 20px;
    border: 1px solid transparent;
    border-radius: 4px;
    background-color: #f2dede;
    border-color: #ebccd1;
    color: #a94442;     
    margin-bottom: 10px;
    border: 1px solid transparent;    
}
.tps .warningM3{
    background-image: -webkit-linear-gradient(top,#fcf8e3 0,#f8efc0 100%);
    background-image: -o-linear-gradient(top,#fcf8e3 0,#f8efc0 100%);
    background-image: -webkit-gradient(linear,left top,left bottom,from(#fcf8e3),to(#f8efc0));
    background-image: linear-gradient(to bottom,#fcf8e3 0,#f8efc0 100%);
    filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#fffcf8e3', endColorstr='#fff8efc0', GradientType=0);
    background-repeat: repeat-x;    
    text-shadow: 0 1px 0 rgba(255,255,255,.2);
    -webkit-box-shadow: inset 0 1px 0 rgba(255,255,255,.25),0 1px 2px rgba(0,0,0,.05);
    box-shadow: inset 0 1px 0 rgba(255,255,255,.25),0 1px 2px rgba(0,0,0,.05);
    color: #8a6d3b;
    background-color: #fcf8e3;
    border-color: #faebcc;
    padding: 5px;
    margin-bottom: 10px;
    border: 1px solid transparent;
    border-radius: 4px;
}
.tps .confirmM3{
    color: #3c763d;
    background-color: #dff0d8;
    border-color: #d6e9c6;
    padding: 5px;
    margin-bottom: 10px;
    border: 1px solid transparent;
    border-radius: 4px;
    background-color: #dff0d8;
    border-color: #d6e9c6;
    color: #3c763d;
    padding: 5px;        
    border-radius: 4px;
}
.tps .productAtSiteHeader,
.tps .solutionAtSiteHeader
{
    background: #00A9CE;
    width: 100%;
    box-shadow: 0rem 0rem 0.5rem 0rem #000;
    margin-top: 0px;
    padding: 6px;
    color: white;
    margin-bottom: 10px;
}
.tps .pdfTable .tableData
{
    vertical-align: middle;
}
.tps .pdfTable .tableHeader
{
    background-color: #00A9CE;
    color: white;
}
/*2017-03-23- anirudh.singh@cdk.com- Added the below 5 styles for showing Spinner.*/
.tps .modal-backdrop
{
    z-index: 0;
}
.tps .modal-dialog
{
    margin-top: 10%;
}
.tps .discProdSolSpinnerDiv
{
    z-index: 1100;
    visibility: visible;
}
.tps .discProdSolSpinnerDiv,
.tps .discProdSolSpinnerDiv td
{
    text-align: center;
}
.tps .discProdSolSpinnerDiv .modal-dialog
{
    max-width: 100%;
    width: auto !important;
    display: inline-block;
}
.pdfSolutionAtSiteComponent .selectField, 
.pdfProductAtSiteComponent .selectField
{
    width: 2%;
}
.pdfSolutionAtSiteComponent .appNameField
{
    width: 25%;
}
.pdfSolutionAtSiteComponent .vendorField
{
    width: 25%;
}
.pdfSolutionAtSiteComponent .currentCheckboxField, 
.pdfProductAtSiteComponent .currentCheckboxField
{
    width: 6%;
}
.pdfSolutionAtSiteComponent .proposedCheckboxField, 
.pdfProductAtSiteComponent .proposedCheckboxField
{
    width: 6%;
}
.pdfSolutionAtSiteComponent .soldCheckboxField, 
.pdfProductAtSiteComponent .soldCheckboxField
{
    width: 6%;
}
.pdfSolutionAtSiteComponent .notesField, 
.pdfProductAtSiteComponent .notesField
{
    width: 30%;
}
.pdfProductAtSiteComponent .prodNameField
{
    width: 20%;
}
.pdfProductAtSiteComponent .deptField
{
    width: 15%;
}
.pdfProductAtSiteComponent .workflowField
{
    width: 15%;
}
.header {
  cursor: pointer;
}

.headerSortDown:after {
    content: " \f0dd";
    font-family: FontAwesome;    
    position:absolute;    
}

.headerSortUp:after {
    content: " \f0de"; 
    font-family: FontAwesome;    
    position:absolute;    
}
.tps .solprodHeaderDiv
{
    background: #00A9CE;
    width: 100%;
    box-shadow: 0rem 0rem 0.5rem 0rem #000000;
    margin-top: 0px;
    margin-bottom: 2px;
    padding: 6px;
    color: white;
}
.tps .searchFilterDiv
{
    width: 0px; 
    display: inline-block;
}
.tps .tpsMenuDiv
{
    text-align: center;
    width: 100%;
    display: inline-block;
    vertical-align: top;
}
@media only screen and (max-width : 1024px)
{
    .tps .searchFilterDiv
    {
        display: block;
    }
    .tps .tpsMenuDiv
    {
        text-align: left;
    }
}