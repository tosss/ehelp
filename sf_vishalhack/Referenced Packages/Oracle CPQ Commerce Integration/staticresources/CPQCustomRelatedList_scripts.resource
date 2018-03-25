(function() {
	if (window.addEventListener) {
		window.addEventListener('load', runJsChanges, false);
	}
})();

/**
*  The JS that should be run when the page is loaded or a section of the page is rerendered.
*/
function runJsChanges() {
    convertUserProfileLinks();
    convertSiteRecordLinks();
}

/**
*  Appends '?noredirect=1' to the end of the URLs for Salesforce Users, so that the links will go to the setup page of the User 
*  rather than their profile page.
*/
function convertUserProfileLinks() {
    for (var i = 0; i < document.getElementsByClassName('salesforce_user').length; i++) {
        if (document.getElementsByClassName('salesforce_user')[i].children[0]
            && document.getElementsByClassName('salesforce_user')[i].children[0].getElementsByTagName('a')[0]) {
            document.getElementsByClassName('salesforce_user')[i].children[0].getElementsByTagName('a')[0].href += '?noredirect=1';
        }
    }
}

/**
*  As the Visualforce page is shown in an iframe, links get opened in the iframe.  This method makes links from the iframe open in the parent window.
*/
function convertSiteRecordLinks() {
    for (var i = 0; i < document.getElementsByClassName('oracle_cpq_site').length; i++) {
        if (document.getElementsByClassName('oracle_cpq_site')[i].children[0]
            && document.getElementsByClassName('oracle_cpq_site')[i].children[0].getElementsByTagName('a')[0]) {
            // create a new 'onclick' attribute
            var onclickAttr = document.createAttribute('onclick');
            var hrefLocation = document.getElementsByClassName('oracle_cpq_site')[i].children[0].getElementsByTagName('a')[0].href;
            // assign the attribute a value
            onclickAttr.value = "parent.parent.location.href='" + hrefLocation + "';";
            // add the attribute to the existing node
            document.getElementsByClassName('oracle_cpq_site')[i].children[0].getElementsByTagName('a')[0].setAttributeNode(onclickAttr);
            
            // disable the link's href
            document.getElementsByClassName('oracle_cpq_site')[i].children[0].getElementsByTagName('a')[0].href = 'javascript:void(0);';
        }
    }
}