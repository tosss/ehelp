//2017-03-31- anirudh.singh@cdk.com- Created this JS for separating the scripts from Visualforce Page.
function showLoadingIcon()
{
    document.getElementById('terminateLoadingImage').className='displayLoadingIcon';
    document.getElementsByClassName('terminateUserBtn')[0].disabled=true;
    document.getElementsByClassName('terminateUserBtn')[0].style.cursor='not-allowed!important';
}
function hideLoadingIcon()
{
    document.getElementById('terminateLoadingImage').className='noDisplay';
}
function showAlert(termUserStatusMsg, isLockError)
{
    termUserStatusMsg=termUserStatusMsg.replace(/(<br[\/]>)/g, '\n').replace(/(<[\/]?b>)/g, '');
    if(isLockError)
    {
        alert('There is a conflict in editing the record. Please try after sometime.');
        return;
    }
    
    if(termUserStatusMsg.length==0)
    {
        alert('There is some problem connecting to the server. Please try again.');
    }
    else
    {
        alert(termUserStatusMsg);    
        if(termUserStatusMsg.includes('User Terminated Successfully'))
        {
            var url=(window.location!=window.parent.location) ? document.referrer : document.location.href;
			window.parent.location=url;
			//window.top.location.reload();
        }
    }
}