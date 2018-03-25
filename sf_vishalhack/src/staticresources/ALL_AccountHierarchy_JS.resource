//Author: Anirudh Singh
//Created Date: 2015-08-26
//Description: This javascript is used to override the View Hierarchy link on Account page to show custom Account Hierarchy functionality.
Sfdc.onReady(
    function()
    {
        //Fetch all the anchorLink elements.
        var anchorElements=document.getElementsByTagName("a");
        
        //Iterate over the anchorLinks elements.
        for(var i=0; i<anchorElements.length; i++)
        {
            //If the innerHTML Matches, then only do further processing.
            if(anchorElements[i].innerHTML=='[View Hierarchy]')
            {
                //Get the default Href link.
                var defaultHrefLink=anchorElements[i].getAttribute("href");
                
                //Get the index of the Id parameter in Href.
                var indexOfAccountIdParameter=anchorElements[i].getAttribute("href").indexOf('id');
                
                //Get the accountIdParemeter using substring.
                var accountIdParameter=defaultHrefLink.substring(indexOfAccountIdParameter, defaultHrefLink.length);
                
                //Get the Account Name.
                var accountName=document.getElementsByClassName("pageDescription")[0].innerText;
                
                //Create Salesforce Base URL.
                var salesforceBaseURL=location.protocol+"//"+location.hostname+(location.port && ":"+location.port)+"/";
                
                //Modify the URL to create the desired URL for AccountHierarchyView.
                salesforceBaseURL+="apex/ALL_AccountHierarchyView";
                
                //Pass the Account Id Parameter.
                salesforceBaseURL+="?"+accountIdParameter;
                
                //Set the View Hierarchy href to the new value.
                anchorElements[i].href=salesforceBaseURL;
                break;
            }
        }
	}
);