/*2016-08-30- anirudh.singh@cdk.com- Created this CSS for ALL_ObjectDetails Visualforce Component.*/
.objectDetailsComponent
{
    color: #666666;
    min-width: 320px!important;
    margin-bottom: 40px;
}
.objectDetailsComponent .objectDetailsHeader
{
    background: #00A9CE;
    width: 100%;
    box-shadow: 0rem 0rem 0.5rem 0rem #000;
    margin-top: 0px;
    padding: 6px;
    color: white;
}
.objectDetailsComponent .objectDetailsTable
{
    margin-bottom: 0px;
}
.objectDetailsComponent .objectDetailsTh
{
    background-color: #00A9CE;
    color: white;
}
.objectDetailsComponent .createNewRecord
{
    margin-bottom: 0px;
    text-align: right;
}
.objectDetailsComponent .createNewButton
{
    float: right;
    vertical-align: middle;
}
.objectDetailsComponent .alignCenter
{
    text-align: center;
}
.objectDetailsComponent .createNewButtonOutsideHeader
{
    margin-bottom: 10px;
}
.objectDetailsComponent .createButtonh4Tag
{
    margin: 0px;
    margin-top: -4px;
}
.objectDetailsComponent .createNewLink
{
    font-weight: bold;
}
.objectDetailsComponent .createButtonDropdown
{
    border-radius: 4px!important;
}
.objectDetailsComponent .underlinedLinks
{
    text-decoration: underline;
}
.objectDetailsComponent .noDisplay
{
    display: none;
}
.objectDetailsComponent .objectDetailsRowData:nth-child(even)
{
    background: #F1F1F1;
}
.objectDetailsComponent .objectDetailsRowData:nth-child(odd)
{
    background: #FFFFFF;
}
.objectDetailsComponent .holidaySchedule, 
.objectDetailsComponent .reportLinks
{
    display: block;
    display: inline-block;
    display: -webkit-inline-box;
    padding: 8px;
    vertical-align: middle;
    font-size: 16px;
    width: 100%;
    background-color: #00c389;
    color: white;
}
.objectDetailsComponent .holidaySchedule label, 
.objectDetailsComponent .reportLinks label
{
    margin-bottom: 0px;
}
.objectDetailsComponent .editLink
{
    color: white;
    font-weight: bold;
    font-style: italic;
    text-decoration: underline;
    margin-left: 20px;
}
.objectDetailsComponent .reportRecLink
{
    color: white;
    font-style: italic;
    text-decoration: underline;
    margin-left: 6px;
}
.objectDetailsComponent .deleteIconColumn
{
    text-align: center;
    vertical-align: middle;
    width: 50px;
    padding: 0;
}
.objectDetailsComponent .deleteIcon
{
    cursor: pointer;
    font-size: 1.5em;
}
.objectDetailsComponent .modal-backdrop
{
    z-index: 0;
}
.objectDetailsComponent .modal-dialog
{
    margin-top: 10%;
}
.objectDetailsComponent .popupBackground
{
    background-color: black;
    opacity: 0.60;
    filter: alpha(opacity = 60);
    width: 100%;
    height: 100%;
    top: 0;
    left: 0;
    z-index: 998;
    position: fixed;
    cursor: wait;
}
.objectDetailsComponent .popupPanel
{
    background-color: white;
    left: 50%;
    width: auto;
    margin-left: -100px;
    top: 50%;
    height: auto;
    margin-top: -25px;
    padding: 20px;
    z-index: 999;
    position: fixed;
}
.objectDetailsComponent .itemNoColumn
{
    width: 60px;
}
.objectDetailsComponent .disabledButton
{
    cursor: not-allowed;
}
.objectDetailsComponent .objDetSpinnerDiv
{
    z-index: 1100;
    visibility: visible;
}
.objectDetailsComponent .objDetSpinnerDiv,
.objectDetailsComponent .objDetSpinnerDiv td
{
    text-align: center;
}
.objectDetailsComponent .objDetSpinnerDiv .modal-dialog
{
    max-width: 100%;
    width: auto !important;
    display: inline-block;
}
.objectDetailsComponent .objDetSpinnerDiv tr,
.objectDetailsComponent .objDetSpinnerDiv td
{
    border: 0!important;
}
@media only screen and (max-width : 1040px)
{
    .objectDetailsComponent .itemNoColumn
    {
        display: none;
    }
    .objectDetailsComponent table, 
    .objectDetailsComponent tbody, 
    .objectDetailsComponent td, 
    .objectDetailsComponent tr
    { 
        display: block; 
    }
    .objectDetailsComponent th
    { 
        display: none; 
    }
    .objectDetailsComponent tr
    {
        border: 1px solid #ccc;
    }
    .objectDetailsComponent td
    {
        border: 0px!important;
        border-bottom: 1px solid #e3deb8!important;
        width: 100%!important;
    }
    .objectDetailsComponent .objectDetailsRowData:nth-child(even)
    {
        background: #F1F1F1;
    }
    .objectDetailsComponent .objectDetailsRowData:nth-child(odd)
    {
        background: #FFFFFF;
    }
    .objectDetailsComponent .objectDetailsTable td::before
    {
        content: attr(data-th);
        font-weight: bold;
        width: 51%;
        display: inline-block;
        display: -webkit-inline-box;
        vertical-align: top;
        padding: 5px 20px 5px 20px;
    }
    .objectDetailsComponent .tdChildContent
    {
        width: 45%;
        display: inline-block;
        display: -webkit-inline-box;
        padding: 5px 20px 5px 20px;
    }
    .objectDetailsComponent a.tdChildContent
    {
        margin-left: -5px!important;
    }
    .objectDetailsComponent .holidaySchedule
    {
        padding: 15px 20px 5px 30px;
    }
    .objectDetailsComponent .modal-dialog
    {
        width: 80%;
        margin-left: auto;
        margin-right: auto;
    }
    .objectDetailsComponent .deleteIconColumn
    {
        width: auto;
        padding: 8px 8px 8px 0px;
    }
    .objectDetailsComponent td.deleteIconColumn::before
    {
        padding: 5px 20px 5px 15px!important;
    }
    .objectDetailsComponent .deleteIcon
    {
        padding: 5px 20px 5px 4px!important;
    }
}
@media only screen and (max-width : 1040px) and (orientation: landscape)
{
    .objectDetailsComponent td.deleteIconColumn::before
    {
        padding: 5px 20px 5px 10px!important;
    }
    .objectDetailsComponent .deleteIcon
    {
        padding: 5px 20px 5px 0px!important;
    }
    .objectDetailsComponent .modal-dialog
    {
        width: 60%;
        margin-left: auto;
        margin-right: auto;
    }
}