//2016-07-26- anirudh.singh@cdk.com- Created this class for RQ-07332.
({
    displayLinkCollection: function(component, event, helper)
    {
        var action=component.get("c.fetchLinkCollection");
        var collectionName=component.get("v.collectionName");
        
        action.setParams({
            "linkCollectionName": collectionName
        });
        
        action.setCallback(this, function(response)
                           {
                               helper.responseProcessor(component, event, helper, response);
                           });
        
        $A.enqueueAction(action);
    },
    addToUserLinks: function(component, event, helper)
    {
        var selectedLinkId=event.currentTarget.dataset.linkid;
        var action=component.get("c.addSelectedLinkToUserLinks");
        
        action.setParams({
            "linkId": selectedLinkId,
            "linkCollectionName": component.get("v.collectionName")
        });
        
        action.setCallback(this, function(response)
                           {
                               helper.responseProcessor(component, event, helper, response);
                               
                           });
        
        $A.enqueueAction(action);
    },
    removeFromUserLinks: function(component, event, helper)
    {
        var selectedLinkId=event.currentTarget.dataset.linkid;
        var action=component.get("c.removeSelectedLinkFromUserLinks");
        
        action.setParams({
            "linkId": selectedLinkId
        });
        
        action.setCallback(this, function(response)
                           {
                               helper.responseProcessor(component, event, helper, response);
                           });
        
        $A.enqueueAction(action);
    },
    
    onClick: function(component, event, helper){
        var clicked = event.target.id;
        console.log('clicked',clicked);
        component.set("v.dsg_knowledgeArticleID",clicked);        
        /*     var articleNameEvent = $A.get("e.c:ArticleNameEvent");
        console.log('am here',articleNameEvent);
        articleNameEvent.setParams({"ArticleName": clicked});console.log('ArticleName');
        articleNameEvent.fire();   */
    }
})