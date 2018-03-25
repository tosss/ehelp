function applyRelatedListLinksAndBadges(elements, parentId) {
    var j$ = !j$ ? jQuery.noConflict() : j$;
    
    j$.each(elements,function(index, element) {
        var j$element = j$(element);
        
        // get the contents of the PhoneNumberElement (cell)
        var v = j$element.html(); 
        
        if(/[0-9]/ig.test(v)) { // if the cell contains numbers
            var recordId = null;
            
            // find any existing links in the table row
            j$element.parents("tr").first().children().find("a").each( 
                function(i,v) { 
                    var url = jQuery(v).attr("href"); // get the anchor url
                    
                    // split the url to get everything after the last forward-slash
                    var split = url.split("/"); url = split[split.length-1];
                    
                    // get rid of all non-alpha-numeric characters
                    url = url.replace(/[^a-zA-Z0-9]*/ig,"");
                    
                    // if the length of only the alpha-numeric characters in the url is between 15 and 18
                    if(url.length == 15 || url.length == 18) { recordId = url; }
                }
            );
            
            if(recordId != null) { 
                // add a click to call event
                var js = "javascript: if (window && window.top && window.top.pd) { "
                    + "  window.scrollTo(0,0); j$('.ui-dialog-content').dialog('close'); "
                    + "  window.top.pd.dial('"+v+"', '"+recordId+"', window, '"+parentId+"', '"+recordId+"'); "
                    + "}";
                
                // add a link and badge to invoke the call event
                var dialLink = j$("<a>").addClass("ISC2C_PhoneLink").html(v).attr("href",js); 
                var dialBadge = j$("<span>").addClass("ISC2C_PhoneBadge").attr("href",js); 
                
                // add the link to the PhoneNumberElement (cell)
                j$element.html("").append(dialLink).append(dialBadge);
            }
        }
    });
}