// RQ-05865 SubProject Confidential Indicator
// 2015-12-09 - Venkata.shrivol@cdk.com  -Created

function addConfidentialStyle(value)
{
    //__ConfidentialFlag = value;
    
    if(value) 
    {
        jQuery('.pageDescription').attr('id', 'confidential-header');
    }
    else
    {
        jQuery('.pageDescription').removeAttr('id');
    }
}