//Author: Anirudh Singh
//Created Date: 2015-11-05
//Description: This javascript is used to display the Edit Page Layout link on the overriden Account Detail Page.
Sfdc.onReady(
    function()
    {
        //Fetch all the linksElements elements.
        var linksElements=document.getElementsByTagName("a");
        
        //Iterate over the linksElements elements.
        for(var i=0; i<linksElements.length; i++)
        {
            //If the innerHTML Matches, then only do further processing.
            if(linksElements[i].innerHTML=='Printable View')
            {
                //Print View Element
                var printViewElement=linksElements[i];
                
                //Get the default Href link.
                var printViewElementHref=linksElements[i].getAttribute("href");
                
                //Get the index of the retUrl parameter in printViewElementHref.
                var indexOfretUrlParameter=printViewElementHref.indexOf('retURL');
                
                //Get returnUrl.
                var returnUrl=printViewElementHref.substring(indexOfretUrlParameter, printViewElementHref.length-4);
                
                var scriptTextElements=document.getElementsByTagName("script");
                
                var layoutId;
                
                for(var j=0; j<scriptTextElements.length; j++)
                {
                    if(scriptTextElements[j].innerHTML.indexOf('layout=')>-1)
                    {
                        //Get the index of the layout Parameter.
                        var indexOfLayoutParameter=scriptTextElements[j].innerHTML.indexOf('layout=');
                        
                        //Get Account Id using substring.
                        var layoutId=scriptTextElements[j].innerHTML.substring(indexOfLayoutParameter+7, indexOfLayoutParameter+22);
                        break;
                    }
                }
                
                var parentElement=linksElements[i].parentElement;
                
                var editLayoutElement=document.createElement('a');
                editLayoutElement.href='/layouteditor/layoutEditor.apexp?type=Account&lid='+layoutId+'&'+returnUrl;
                editLayoutElement.className='configLinks';
                editLayoutElement.innerHTML='Edit Layout';
                
                var lineElement=document.createTextNode(' | ');
                
                parentElement.insertBefore(editLayoutElement, printViewElement);
                parentElement.insertBefore(lineElement, printViewElement);
                break;
            }
        }
	}
);