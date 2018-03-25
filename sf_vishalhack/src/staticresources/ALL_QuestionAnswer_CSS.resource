/*2016-08-22- anirudh.singh@cdk.com- Created this CSS for ALL_QuestionAnswer Visualforce Component.*/
.questionAnswerComponent
{
    color: #666666;
    min-width: 320px!important;
    margin-bottom: 40px;
}
.questionAnswerComponent .categoryHeader
{
    background: #00A9CE;
    width: 100%;
    box-shadow: 0rem 0rem 0.5rem 0rem #000000;
    margin-top: 0px;
    margin-bottom: 2px;
    padding: 6px;
    color: white;
}
.questionAnswerComponent .buttonGroup
{
    text-align: center;
    padding: 6px;
}
.questionAnswerComponent .quickSaveIcon
{
    vertical-align: bottom;
    padding-right: 10px;
    font-size: 18px;
}
.questionAnswerComponent .whiteColor
{
    color: #FFFFFF;
    background-color: #82C600;
}
.questionAnswerComponent .questionTable
{
    margin-left: 4px;
}
.questionAnswerComponent .quesNo
{
    padding: 5px 20px 5px 20px;
    vertical-align: middle;
}
.questionAnswerComponent .quesText
{
    padding: 5px;
    vertical-align: middle;
}
.questionAnswerComponent .childQuestPadding
{
    padding: 5px 5px 5px 30px;
}
.questionAnswerComponent .hrLine
{
    border-bottom: 1px solid #e3deb8;
}
.questionAnswerComponent .ansColumn
{
    padding: 5px;
    vertical-align: middle;
}
.questionAnswerComponent .parentRow
{
    border-bottom: 1px solid #e3deb8;
}
.questionAnswerComponent .multiselectClearButton
{
    margin-top: 5px;
}
.questionAnswerComponent option[value='']
{ 
    background-color: #F2F2F2;
}
.questionAnswerComponent input[type=number]::-webkit-inner-spin-button, 
.questionAnswerComponent input[type=number]::-webkit-outer-spin-button
{ 
    -webkit-appearance: none; 
    margin: 0; 
}
.questionAnswerComponent .checkBoxField
{
    width: 25px;
    height: 25px;
    vertical-align: middle;
}
.questionAnswerComponent input[type="checkbox"]:not(:checked)
{
    border: 10px solid #FF0000;
}
.questionAnswerComponent input[type="checkbox"]:checked
{
    border: 10px solid #FF0000;
}
.questionAnswerComponent .pre
{
    font-weight: bold;
}
.questionAnswerComponent .talkTrack
{
    font-style: italic;
}
.questionAnswerComponent .other
{
    font-weight: bold;
    display: block;
    margin-top: 6px;
    margin-bottom: 6px;
}
.questionAnswerComponent .parentName, 
.questionAnswerComponent .parentDatatype, 
.questionAnswerComponent .parentQuestionName, 
.questionAnswerComponent .parentAnswerForRendering,
.questionAnswerComponent .hideQuickSaveSpinner
{
    display: none;
}
.questionAnswerComponent .notApplicableColumn
{
    padding: 5px;
}
.questionAnswerComponent .notApplicableLabel
{
    margin-left: 4px;
}
.questionAnswerComponent .virtualIcon
{
    font-size: 1.5em;
}
.questionAnswerComponent .modal-backdrop
{
    z-index: 0;
}
.questionAnswerComponent .modal-dialog
{
    margin-top: 10%;
}
.questionAnswerComponent .fieldError
{
    margin-top: 4px;
    margin-bottom: 0px;
    padding: 2px;
}
.questionAnswerComponent .quesTypeBtn ul
{
    margin-bottom: 20px;
}
.questionAnswerComponent .quesTypeFilterHide
{
    display: none!important;
}
.questionAnswerComponent .qaSpinnerDiv
{
    z-index: 1100;
    visibility: visible;
}
.questionAnswerComponent .qaSpinnerDiv,
.questionAnswerComponent .qaSpinnerDiv td
{
    text-align: center;
}
.questionAnswerComponent .qaSpinnerDiv .modal-dialog
{
    max-width: 100%;
    width: auto !important;
    display: inline-block;
}
.questionAnswerComponent .quickSaveSpinner
{
    margin-left: 10px;
    font-size: 1.2em;
}
.questionAnswerComponent .showQuickSaveSpinner
{
    display: inline-block;
}
.questionAnswerComponent .dateField,
.questionAnswerComponent .dateTimeField
{
    border-top-left-radius: 4px!important;
    border-bottom-left-radius: 4px!important;
}
.questionAnswerComponent .datepicker,
.questionAnswerComponent .datetimepicker
{
    width: 100%;
}
/*iPads (Portrait and Landscape)*/
@media only screen and (min-width : 480px) and (max-width : 1024px)
{
    .questionAnswerComponent .emptyColumn
    {
        padding: 5px!important;
    }
}
@media only screen and (max-width : 1024px)
{
    .questionAnswerComponent .modal-dialog
    {
        width: 80%;
        margin-left: auto;
        margin-right: auto;
    }
}
@media only screen and (max-width : 1024px) and (orientation: landscape)
{
    .questionAnswerComponent .modal-dialog
    {
        width: 60%;
        margin-left: auto;
        margin-right: auto;
    }
}
.pdfQuesComponent table.picklistCheckbox td
{
    padding-right: 15px;
    display: inline-block;
    display: -webkit-inline-box;
}
.pdfQuesComponent table.picklistCheckbox label
{
    padding-left: 10px;
    height: 25px;
    vertical-align: middle;
}
.pdfQuesComponent .quesNo
{
    width: 1%;
}
.pdfQuesComponent .quesText
{
    width: 49%;
}
.pdfQuesComponent .ansColumn
{
    width: 40%;
}
.pdfQuesComponent .otherAnswer
{
    padding: 5px;
    vertical-align: middle;
}
.pdfQuesComponent .otherAnsValue
{
    height: 6em;
}
.pdfQuesComponent .notApplicableColumn
{
    width: 10%;
}
.pdfQuesComponent .notApplicableLabel
{
    vertical-align: middle;
}