/*2016-12-12- anirudh.singh@cdk.com- Modified the below CSS to combine all the CSS present on the component and this CSS file.*/
.buildingImagesComponent
{
    color: #666666;
    min-width: 320px!important;
    margin-bottom: 40px;
}
.buildingImagesComponent .buildingImgHeader,
.buildingImagesComponent .commentsHeader
{
    background: #00A9CE;
    width: 100%;
    box-shadow: 0 0 .5rem 0 #000;
    padding: 6px;
    margin-bottom: 2px;
    color: white;
}
.buildingImagesComponent .buildingImgHeader
{
    margin-top: 0!important;
}
.buildingImagesComponent .buttonGroup
{
    text-align: center;
    padding: 6px;
}
.buildingImagesComponent .saveButton
{
    margin-right: 4px;
}
.buildingImagesComponent #map
{
    font-family: Arial;
    font-size: 12px;
    line-height: normal !important;
    height: 500px;
    background: transparent;
    margin: 0px 5px 0px 5px;
}
.buildingImagesComponent .richTextFieldDiv
{
    margin: 0px 5px 0px 5px;
}
.buildingImagesComponent .richTextFieldDiv > div
{
    padding: 0px 5px 5px 5px;
}
.buildingImagesComponent .modal-backdrop
{
    z-index: 0;
}
.buildingImagesComponent .modal-dialog
{
    margin-top: 10%;
}
.buildingImagesComponent .addAttachmentLinkForBuilding
{
    width: 150px;
    margin: 0 auto;
    text-align: center;
}
.buildingImagesComponent .disabledButton
{
    cursor: not-allowed;
}
.buildingImagesComponent .deleteButton
{
    margin-left: 4px;
}
.buildingImagesComponent .deleteInfoBtn
{
    margin-right: 4px;
}
.buildingImagesComponent .richTextFieldDiv textarea
{
    font-size: 16px;
    height: 4em;
    padding: 2px;
}
.buildingImagesComponent .messageDiv
{
    margin-top: 5px;
}
.buildingImagesComponent .messageDiv > div
{
    margin-bottom: 0px;
}
.buildingImagesComponent .deleteText,
.buildingImagesComponent .infoText
{
    font-size: 1.25em;
    margin: 1em 0em 1em 0em;
    word-wrap: break-word;
}
.buildingImagesComponent .pencilIcon
{
    margin-left: 1em;
    cursor: pointer;
}
.buildingImagesComponent .iwElement
{
    top: 19px!important;
    left: 0!important;
}
.buildingImagesComponent .gm-style-iw .infoContent
{
    background-color: #FFFFFF;
    min-width: 300px;
    max-width: 350px;
    top: 15px;
    border: 2px solid rgb(0, 169, 206);
    border-radius: 4px;
}
.buildingImagesComponent .gm-style-iw .indexNo,
.buildingImagesComponent .gm-style-iw .accountInfo
{
    background-color: #FFFFFF;
    min-width: 50px;
    top: 15px;
    border-radius: 4px;
    padding: 5px;
    margin-left: 55px;
    text-align: center;
    font-weight: bold;
    font-size: 1.2em;
}
.buildingImagesComponent .gm-style-iw .indexNo
{
    border: 2px solid #FF0000;
}
.buildingImagesComponent .infoWindowHeader,
.buildingImagesComponent .deleteWindowHeader
{
    padding: 15px;
    border-bottom: 1px solid #e5e5e5;
}
.buildingImagesComponent .infoWindowHeader h4,
.buildingImagesComponent .deleteWindowHeader h4
{
    margin:0;
}
.buildingImagesComponent .infoWindowBody,
.buildingImagesComponent .deleteWindowBody
{
    padding: 15px;
}
.buildingImagesComponent .infoWindowFooter,
.buildingImagesComponent .deleteWindowFooter
{
    padding: 15px;
    text-align: right;
    border-top: 1px solid #e5e5e5;
}
.buildingImagesComponent .lineColorBtn li
{
    cursor: pointer;
}
.buildingImagesComponent .lineColorBtn .lineColorLiLabel
{
    width: 80%;
    display: inline-block;
}
.buildingImagesComponent .defaultLineColor,
.buildingImagesComponent .redLine,
.buildingImagesComponent .greenLine,
.buildingImagesComponent .blueLine,
.buildingImagesComponent .orangeLine,
.buildingImagesComponent .yellowLine
{
    width: 20px;
    height: 20px;
    display: inline-block;
    vertical-align: middle;
}
.buildingImagesComponent .defaultLineColor
{
    background-color: #000000;
}
.buildingImagesComponent .redLine
{
    background-color: #FF0000;
}
.buildingImagesComponent .greenLine
{
    background-color: #00FF00;
}
.buildingImagesComponent .blueLine
{
    background-color: #0000FF;
}
.buildingImagesComponent .orangeLine
{
    background-color: #FFA500;
}
.buildingImagesComponent .yellowLine
{
    background-color: #FFFF00;
}
.buildingImagesComponent .mapIndexContent
{
    margin-top: 20px;
    margin-left: 5px;
    margin-right: 5px;
}
.buildingImagesComponent .mapIndexContent table 
{
    max-width: 100%;
    margin-bottom: 20px;
}
.buildingImagesComponent .mapIndexContent table th,
.buildingImagesComponent .mapIndexContent table td
{
    padding: 10px;
}
.buildingImagesComponent .indexNoTh
{
    background-color: #00A9CE;
    color: white;
}
.buildingImagesComponent .contentTh
{
    min-width: 300px;
    background-color: #00A9CE;
    color: white;
}
.buildingImagesComponent .indexNoTd
{
    text-align: center;
}
.buildingImagesComponent tr td
{
    white-space: nowrap;
}
.buildingImagesComponent .pdfMap
{
    width: 1000px;
}
@media only screen and (max-width : 1024px)
{
    .buildingImagesComponent .modal-dialog
    {
        width: 80%;
        margin-left: auto;
        margin-right: auto;
    }
}
@media only screen and (max-width : 1024px) and (orientation: landscape)
{
    .buildingImagesComponent .modal-dialog
    {
        width: 60%;
        margin-left: auto;
        margin-right: auto;
    }
}
@media print
{
    .buildingImagesComponent .mapDiv img
    {
        max-width: none!important;
    }
    .buildingImagesComponent .deviceImageLi
    {
        position: static;
    }
}
.buildingImagesComponent #deviceImageFilters,
.buildingImagesComponent .deviceImageUl
{
    margin: 5px;
}
.buildingImagesComponent #deviceImageFilters
{
    font-weight: bold;
    text-shadow: 1px 1px 3px #111;
}
.buildingImagesComponent #deviceImageFilters .devImgFilterCheckbox
{
    vertical-align: bottom;
    margin-right: 10px;
    width: 18px;
    height: 18px;
}
.buildingImagesComponent .deviceImageLi
{
    float: none;
    display: inline-block;
    vertical-align: top;
    border: 2px solid #DDDDDD;
    border-radius: 4px;
    margin: 5px;
    background-color: #EEEEEE;
}
.buildingImagesComponent .deviceImageLi:hover
{
    border: 2px solid #82C600;
    box-shadow: inset 0 1px 1px rgba(0,0,0,.075), 0 0 8px rgba(102, 175, 233, 0.6);
}
.buildingImagesComponent .deviceImageLi a
{
    padding: 5px;
}
.buildingImagesComponent .deviceImageLi img
{
    border-radius: 4px;
    max-width: 500px !important;
}
.buildingImagesComponent .deviceImageLi img
{
    margin: 0px;
}
.buildingImagesComponent .deviceImageLi .deviceImgToolBtns
{
    margin: 0px 5px 5px 8px;
}
.buildingImagesComponent .deviceImageLi .deviceImgToolBtns
{
    font-size: 22px;
    border-radius: 4px;
    text-align: right;
}
.buildingImagesComponent .deviceImageLi .deviceImgToolBtns .rotateLeft,
.buildingImagesComponent .deviceImageLi .deviceImgToolBtns .rotateRight,
.buildingImagesComponent .deviceImageLi .deviceImgToolBtns .saveDeviceImgChanges
{
    padding: 5px;
    color: #FFFFFF;
    background-color: #00a9ce;
    border-radius: 4px;
    text-shadow: 1px 1px 0px #111;
}
.buildingImagesComponent .deviceImageLi .deviceImgToolBtns .rotateLeft:hover,
.buildingImagesComponent .deviceImageLi .deviceImgToolBtns .rotateRight:hover,
.buildingImagesComponent .deviceImageLi .deviceImgToolBtns .saveDeviceImgChanges:hover
{
    background-color: #82C600;
    border-radius: 4px;
    cursor: pointer;
}
.buildingImagesComponent .deviceImageLi .deviceImageDescDiv
{
    padding: 0px 4px 4px 4px;
}
.buildingImagesComponent .deviceImageLi .deviceImageDesc
{
    height: 8em;
}
.buildingImagesComponent .deviceImageLi textarea
{
    resize: none;    
    overflow-y: scroll;
}
.buildingImagesComponent .deviceImageLi .deviceImgLink
{
    padding: 0px;
}
.buildingImagesComponent .deviceImageLi .deviceImgLink .deviceImg,
.buildingImagesComponent .deviceImageLi .deviceImgPrint
{
    padding: 5px;
}
.buildingImagesComponent .deviceImageLi .deviceImageDescPrintDiv
{
    padding: 0px 5px 5px 5px;
}
.buildingImagesComponent .deviceImageLi .deviceImageDescPrint
{
    border-radius: 4px 4px 0px 0px;
    border-bottom-width: 0px;
}
.buildingImagesComponent .deviceImageLi .blankDescArea
{
    height: 8em;
    border-radius: 0px 0px 4px 4px;
    border-top-width: 0px;
}
.buildingImagesComponent .deviceImageLi .blankDescAreaNoVal
{
    height: 8em;
}
.buildingImagesComponent .buildImgSpinnerDiv
{
    z-index: 1100;
    visibility: visible;
}
.buildingImagesComponent .buildImgSpinnerDiv,
.buildingImagesComponent .buildImgSpinnerDiv td
{
    text-align: center;
}
.buildingImagesComponent .buildImgSpinnerDiv .modal-dialog
{
    max-width: 100%;
    width: auto !important;
    display: inline-block;
}