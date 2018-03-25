/*2016-08-25- anirudh.singh@cdk.com- Created this CSS for ALL_DiscoveryHome Visualforce Page.*/
.discoveryHomePage
{
    color: #666666;
    min-width: 320px!important;
}
html
{
    visibility: hidden;
    -ms-overflow-style: scrollbar;
}
.discoveryHomePage .homePageHeader
{
    background: #00A9CE;
    width: 100%;
    box-shadow: 0rem 0rem 0.5rem 0rem #000000;
    margin-top: 0px;
    margin-bottom: 2px;
    padding: 6px;
    color: white;
}
.discoveryHomePage .buttonGroup
{
    text-align: center;
    padding: 6px;
}
.discoveryHomePage .buttonGroup ul
{
    padding: 0px;
}
.discoveryHomePage .generatePdf
{
    float: right;
    margin-top: -35px;
}
.discoveryHomePage .homeIcon
{
    float: right;
    cursor: pointer;
}
.discoveryHomePage .printIcon
{
    float: right;
    cursor: pointer;
    padding-right: 10px;
}
.discoveryHomePage .homeDetailsHeader
{
    background: #82C600;
    width: 100%;
    margin-top: 0px;
    margin-bottom: 0px;
    padding: 6px;
    color: white;
    box-shadow: 0rem 0rem 1rem 0rem #000;
    z-index: 9;
}
.discoveryHomePage .homepageDetailsTable
{
    margin-top: 0px;
    margin-bottom: 10px;
}
.discoveryHomePage .homepageDetailsTableTd
{
    width: 50%;
}
.discoveryHomePage .homepageDetailsTableTdLabel
{
    width: 40%;
    text-align: right;
    margin: 0px 30px 0px 0px;
}
.discoveryHomePage .homepageDetailsTableTdField
{
    width: 60%;
}
.discoveryHomePage .homePageTabs
{
    /* 2017-01-30 matt.keefe@cdk.com - removed border, not needed; without border tabs are more crisp
    border-top: 1px solid lightgray;
    border-right: 1px solid lightgray;
    border-left: 1px solid lightgray;
    border-bottom: 0px;
    */
    border-top-left-radius: 6px;
    border-top-right-radius: 6px;
    border-bottom-left-radius: 0px;
    border-bottom-right-radius: 0px;
    margin-right: 2px;
}
.discoveryHomePage .tabButtonStyle
{
    border-top-left-radius: 5px;  /* 2017-01-30 matt.keefe@cdk.com - changed to 5px */
    border-top-right-radius: 5px; /* 2017-01-30 matt.keefe@cdk.com - changed to 5px */
    border-bottom-right-radius: 0px;
    border-bottom-left-radius: 0px;
    position: relative;
    display: block;
    padding: 10px 15px;
    color: #666666;
    text-decoration: none;
    box-sizing: border-box;
    background-color: transparent;
    border: 0px solid lightgray;
    font-weight: bold; /* 2017-01-30 matt.keefe@cdk.com - added bold for readability */
    color: #fff;
    text-shadow: 1px 1px 3px #111;
}
.discoveryHomePage .selectedTab
{
    background-color: #00A9CE!important; 
    text-decoration: underline!important;
    
    /* 2017-01-30 matt.keefe@cdk.com - added below to further differentiate selected tab */
    color: white!important;
    background: -webkit-linear-gradient(#bfdde4, #00A9CE);
    background: -o-linear-gradient(#bfdde4, #00A9CE);
    background: -moz-linear-gradient(#bfdde4, #00A9CE);
    background: linear-gradient(#bfdde4, #00A9CE);
    border-left: solid 1px #005d71!important;
    border-right: solid 1px #005d71!important;
    border-top: solid 1px #005d71!important;
    box-shadow: 0px -2px 10px -4px #005365;
}
.discoveryHomePage .tabContent
{
    border: 1px solid lightgray;
    border-bottom-width: 0px;
}
.discoveryHomePage .homePageTable
{
    border-top: 0px;
    margin-bottom: 0px;
}
.discoveryHomePage .homePageTable .homePageTh
{
    padding-top: 11px;
    padding-bottom: 11px;
    background-color: #00A9CE;
    color: white;
    vertical-align: middle;
}
.discoveryHomePage .homePageTable .homepageTr:nth-child(even)
{
    background: #F1F1F1;
}
.discoveryHomePage .homePageTable .homepageTr:nth-child(odd)
{
    background: #FFFFFF;
}
.discoveryHomePage .homePageTable .dataColumn
{
    vertical-align: middle;
}
.discoveryHomePage .underlinedLinks
{
    text-decoration: underline;
}
.discoveryHomePage .homePageTable .homePageProgress 
{
    position: relative;
    height: 30px;
    margin-bottom: 0px;
    box-shadow: inset 0px 0px 4px #000000;
}
.discoveryHomePage .homePageTable .homePageProgressBar
{
    font-size: 14px;
    line-height: 20px;
    float: left;
    width: 0;
    height: 100%;
    -webkit-transition: width .6s ease;
    -o-transition: width .6s ease;
    transition: width .6s ease;
    text-align: center;
    padding: 6px;
}
.discoveryHomePage .homePageTable .homePageProgressSpan
{
    position: absolute;
    display: block;
    width: 100%;
    color: #000000;
    font-weight: bold;
}
.discoveryHomePage .scrollToTop
{
	text-align: center;
	position: fixed;
	bottom: 75px;
    right: 10px;
	display: none;
    z-index: 1;
}
.discoveryHomePage .scrollToTop > i
{
    background: #808080;
    color: #A4D65E;
    padding: 4px 8px 4px 8px;
    border: 2px solid;
    border-radius: 4px;
    font-size: 2em;
}
.discoveryHomePage .scrollToTop:hover
{
	text-decoration: none;
}
.discoveryHomePage .pdfPageBreak .modalDialogSectionSelect .modal-body
{
    height: 300px;
    overflow-y: auto;
}
.discoveryHomePage .pdfPageBreak .selectSectionsTable
{
    height: 10%;
}
.discoveryHomePage .pdfPageBreak .selectSectionsTable input[type="checkbox"]
{
    height: 1.4em;
    width: 1.4em;
}
.discoveryHomePage .pdfPageBreak .selectSectionsTable th
{
    background-color: #00A9CE;
    color: white;
    vertical-align: middle;
}
.discoveryHomePage .pdfPageBreak .selectSectionsTable th, 
.discoveryHomePage .pdfPageBreak .selectSectionsTable td
{
    vertical-align: middle;
}
.discoveryHomePage .pdfPageBreak .selectSectionsTable .selectAllSections,
.discoveryHomePage .pdfPageBreak .selectSectionsTable .selectSection
{
    text-align: center;
}
.discoveryHomePage .pdfPageBreak .summaryButton
{
    margin-bottom: 5px;
}
.discoveryHomePage .pdfPageBreak .mapDiv
{
    margin-top: 6px;
}
.discoveryHomePage .additionalTabs
{
    border-top-left-radius: 6px;
    border-top-right-radius: 6px;
    border-bottom-right-radius: 0px;
    border-bottom-left-radius: 0px;
    border-color: transparent;
    border-bottom-color: #ccc;
}
.discoveryHomePage .plusIconLi
{
    background-color: transparent;
    border-top: 1px solid lightgray;
    border-right: 1px solid lightgray;
    border-left: 1px solid lightgray;
    border-bottom: 0px;
}
.discoveryHomePage .plusIcon
{
    font-size: 24px;
    color: #337ab7;
}
.discoveryHomePage .additionalTabsDropdown
{
    position: absolute;
    right: 0px;
    left: auto;
    min-width: 100%;
    margin-top: -1px;
}
.discoveryHomePage .tabDropdownLiElement
{
    border: 0px;
    position: relative;
    display: block;
    padding: 10px 15px;
    color: #666666;
    text-decoration: none;
    box-sizing: border-box;
    background-color: transparent;
    width: 100%;
    text-align: left;
}
.discoveryHomePage .tabDropdownLiElement:hover
{
    background: #D3D3D3;
}
.discoveryHomePage .summaryReportIcon
{
    vertical-align: bottom;
    padding-right: 10px;
    font-size: 18px;
}
.discoveryHomePage .whiteColor
{
    color: #FFFFFF;
    background-color: #82C600;
    border-color: #82C600;
    outline: none;
}
.discoveryHomePage .checkIcon
{
    margin-left: 10px;
    color: #82C600;
}
.discoveryHomePage .quesTypeLiBtn
{
    width: 100%;
    padding: 5px 10px 5px 10px;
    background-color: transparent;
    border: 0px solid lightgray;
    text-align: left;
}
.discoveryHomePage .quesTypeBtn li:hover
{
    background-color: #F1F1F1;
}
@media only screen and (max-width : 1024px)
{
    .discoveryHomePage
    {
        margin-bottom: 20px;
    }
    .discoveryHomePage table.homePageTable, 
    .discoveryHomePage .homePageTable tbody, 
    .discoveryHomePage .homePageTable td, 
    .discoveryHomePage .homePageTable tr
    { 
        display: block; 
    }
    .discoveryHomePage .homePageTable th
    { 
        display: none; 
    }
    .discoveryHomePage .homePageTable tr
    {
        border: 1px solid #ccc;
    }
    .discoveryHomePage .homePageTable td
    {
        border: 0px!important;
        border-bottom: 1px solid #e3deb8!important;
    }
    .discoveryHomePage .homePageTable .homepageTr:nth-child(even)
    {
        background: #F1F1F1;
    }
    .discoveryHomePage .homePageTable .homepageTr:nth-child(odd)
    {
        background: #FFFFFF;
    }
    .discoveryHomePage .homePageTable td::before
    {
        content: attr(data-th);
        font-weight: bold;
        width: 51%;
        display: inline-block;
        display: -webkit-inline-box;
        vertical-align: top;
        padding: 5px 20px 5px 20px;
    }
    .discoveryHomePage .homePageTable .tdChildHomeTableContent
    {
        width: 45%;
        display: inline-block;
        display: -webkit-inline-box;
        padding: 5px 20px 5px 20px;
    }
    .discoveryHomePage .homePageTable a.tdChildHomeTableContent
    {
        margin-left: -5px!important;
    }
    .discoveryHomePage .homePageTable .homePageProgress
    {
        width: 100%;
    }
    .discoveryHomePage .modal-dialog
    {
        width: 80%;
        margin-left: auto;
        margin-right: auto;
    }
}
@media only screen and (max-width : 1024px) and (orientation: landscape)
{
    .discoveryHomePage .modal-dialog
    {
        width: 60%;
        margin-left: auto;
        margin-right: auto;
    }
}
.sectionTables, .summaryEmptySections
{
    display: none;
}
.sectionDivs
{
    display: inline;
}
.discoveryHomePage .dealerAck
{
    margin-top: 20px;
}
.discoveryHomePage .ackLabel
{
    width: 20%;
}
.discoveryHomePage .ackInputLine
{
    width: 80%;
    display: inline-block;
    border-bottom: 1.5px solid black;
}
@media print
{    
    .homeIcon, .scrollToTop, .printIcon, .modal, .sectionDivs
    {
        display: none !important;
    }
    .sectionToDisplay > div
    {
        page-break-before: always;
    }
    .sectionToDisplay > div .sectionTables
    {
        display: table !important;
    }
    .firstSection > div
    {
        page-break-before: auto!important;
    }
    .firstSection table.sectionTables
    {
        display: none!important;
    }
    .summaryEmptySections
    {
        display: inline;
    }
    .mapDiv .indexNo, 
    .mapDiv .accountInfo
    {
        background-color: #FFFFFF!important;
    }
    .mapDiv .iwElementThirdDiv > div > div
    {
        background-color: #FFFFFF!important;
    }
}
.discoveryHomePage .pdfCheckboxIcon
{
    font-size: 1.5em;
}
.discoveryHomePage .blueTabColor
{
    background-color: #7095E1;
}
.discoveryHomePage .brownTabColor
{
    background-color: #C1B38E;
}
.discoveryHomePage .darkGreenTabColor
{
    background-color: #B1C27A;
}
.discoveryHomePage .darkPurpleTabColor
{
    background-color: #CA9F92;
}
.discoveryHomePage .greenTabColor
{
    background-color: #B2E289;
}
.discoveryHomePage .greyTabColor
{
    background-color: #D1C6BF;
}
.discoveryHomePage .lightBlueTabColor
{
    background-color: #9FA3E3;
}
.discoveryHomePage .lightOrangeTabColor
{
    background-color: #F9CD97;
}
.discoveryHomePage .pinkTabColor
{
    background-color: #F1C3D0;
}
.discoveryHomePage .purpleTabColor
{
    background-color: #DB8DB2;
}
.discoveryHomePage .steelBlueTabColor
{
    background-color: #8DB6C7;
}
.discoveryHomePage .tanTabColor
{
    background-color: #E3D9B0;
}
.discoveryHomePage .tealTabColor
{
    background-color: #51C0BF;
}
.discoveryHomePage .turquoiseTabColor
{
    background-color: #59ADD0;
}
.discoveryHomePage .violetTabColor
{
    background-color: #C993D4;
}
.discoveryHomePage .docuSignTags
{
    color: #FFFFFF !important;
    font-size: 1px!important;
    -webkit-print-color-adjust: exact;
    display: inline-block;
    width: 48% !important;
}
.discoveryHomePage .modal-backdrop
{
    z-index: 0;
}
.discoveryHomePage .modal-dialog
{
    margin-top: 10%;
}
.discoveryHomePage .discHomeSpinnerDiv
{
    z-index: 1100;
    visibility: visible;
}
.discoveryHomePage .discHomeSpinnerDiv,
.discoveryHomePage .discHomeSpinnerDiv td
{
    text-align: center;
}
.discoveryHomePage .discHomeSpinnerDiv .modal-dialog
{
    max-width: 100%;
    width: auto !important;
    display: inline-block;
}