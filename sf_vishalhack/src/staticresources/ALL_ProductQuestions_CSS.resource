/*2016-10-19- anirudh.singh@cdk.com- Created this for Questions Tab for Products.*/
.productQuestionsComponent
{
    color: #666666;
    min-width: 320px !important;
}
.productQuestionsComponent .sideBar
{
    position: static;
    width: 100%;
    
    background-color: #FFF; /* 2016-10-24 matt.keefe@cdk.com - forced background to white */
    border-right: 1px solid lightgrey;
    box-shadow: 0 0 0.5rem 0rem -2px #000; /* 2016-10-24 matt.keefe@cdk.com - added right shadow */
    -webkit-box-shadow: 0 0 0.5rem -2px #000; /* 2016-10-24 matt.keefe@cdk.com - added webkit support */
    
    /* 2016-10-24 matt.keefe@cdk.com - added transition timeframes */
    -webkit-transition: 0.25s ease-in-out;
    -moz-transition: 0.25s ease-in-out;
    -o-transition: 0.25s ease-in-out;
    transition: 0.25s ease-in-out;
}
/* 2016-10-24 matt.keefe@cdk.com - added header styling */
.productQuestionsComponent .sideBar .catergoryHeader
{
    background: #00A9CE;
    width: 100%;
    box-shadow: 0 0 0.5rem 0rem #000;
    -webkit-box-shadow: 0 0 0.5rem #000; /* 2016-10-24 matt.keefe@cdk.com - added webkit support */
    margin-top: 0px;
    padding: 6px;
    color: white;
}
.productQuestionsComponent .productQuestionsQuesAnsDiv
{
    width: 100%;
}
.productQuestionsComponent .buttonAnchorTag
{
    padding: 0px;
}
.productQuestionsComponent .sideBarButton
{
    border: none;
    background: transparent;
    padding: 10px 15px 10px 15px;
    width: 100%;
    text-align: left;
    /* 2016-10-24 matt.keefe@cdk.com - added bold for readability */
    font-weight: bold;
}
.productQuestionsComponent .sideBarTabs li:nth-child(even)
{
    /* 2016-10-24 matt.keefe@cdk.com */
    /*  - changed from #FFFACD to rgba(238,238,236,1) to be more consistent with branding, variation of rgba(208, 208, 206, 1) */
    background: rgba(238,238,236,1) !important;
}
.productQuestionsComponent .sideBarTabs li:nth-child(odd)
{
    background: #FFFFFF !important;
}
.productQuestionsComponent .nav-pills>li.active>a
{
    background: #00C389;
}
.productQuestionsComponent .sideBarTabs li>a
{
    cursor: pointer;
    border-radius: 0; /* 2016-10-24 matt.keefe@cdk.com - remove border radius from anchor tags */
}
.productQuestionsComponent .modal-backdrop
{
    z-index: 0;
}
.productQuestionsComponent .modal-dialog
{
    margin-top: 10%;
}
.productQuestionsComponent .prodQuesSpinnerDiv
{
    z-index: 1100;
    visibility: visible;
}
.productQuestionsComponent .prodQuesSpinnerDiv,
.productQuestionsComponent .prodQuesSpinnerDiv td
{
    text-align: center;
}
.productQuestionsComponent .prodQuesSpinnerDiv .modal-dialog
{
    max-width: 100%;
    width: auto !important;
    display: inline-block;
}
.pdfVersion
{
    padding-left: 0px!important;
}
/* 2016-10-24 matt.keefe@cdk.com - added media query for small screens (tablet and phone) */
@media (min-width: 768px) 
{
    .productQuestionsComponent .sideBar
    {
        position: fixed !important; /* 2016-10-24 matt.keefe@cdk.com - fixing location */
        width: 250px !important; /* 2016-10-24 matt.keefe@cdk.com - updated, because sidebar moved to inside productQuestionsContentDiv for pos:fixed */
        height: 100vh !important;
        overflow: auto; /* 2016-10-24 matt.keefe@cdk.com - controlled overflow to prevent shadow overlap */
    }
    .productQuestionsComponent .productQuestionsContentDiv
    {
        /* 2016-10-24 matt.keefe@cdk.com - removed padding-left: 0.2em; */
        display: -webkit-box;
        overflow: auto;
    }
    .productQuestionsComponent .productQuestionsQuesAnsDiv 
    {
        padding-left: 250px; /* 2016-10-24 matt.keefe@cdk.com - added padding left to account for fixed sidebar */
    }
}