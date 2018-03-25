/* *******************************************************************
 * Author: hemanth.kesapragada@cdk.com
 * Description: Generic CSS for visualforce pages rendered as PDF
 * History:
 * 
 * 2015-July-07 	Hemanth Kesapragada 	Created
 * 
 * ******************************************************************* */
@page 
{
    size: letter;
    margin: 15mm;
    /* Add footer on every page */
    @bottom-center 
    {
        content: "Page " counter(page) " of " counter(pages);
    }
}
.page-break 
{
    display:block;
    page-break-after:always;
}
/* Displays Labes as bold */
.labelCol
{
    font-weight:bold;
}
/* Displays hyperlink as normal text */
a
{
    color: #000000;
    text-decoration: none;
    font-weight: normal;
    cursor: text;
}
/* Removes styling for anchor tags */
a:hover
{
    text-decoration: none;
    cursor: text;
}
/* Adds space between 2 sections */
h3
{
    display:block;
    margin-top:40px;
}
/* Hides Column containing Edit/Delete links */
.actionColumn
{
    display:none;
}
/* Hides avatar image */
.chatter-avatar
{
    display:none;
}
/* Hides fewer/more records & back to top links */
.fewerMore
{
    display:none;
}    

