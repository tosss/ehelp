({
    doInit: function(component) {
        var topicName ;
        if (component.get("v.dsg_knowledgeArticleID") === undefined || 
            component.get("v.dsg_knowledgeArticleID") === '' || 
            component.get("v.dsg_knowledgeArticleID") === null)
        {
            topicName = window.location.href.split('/').slice(-1)[0];
        } else{
            topicName = component.get("v.dsg_knowledgeArticleID");             
        }
        var action = component.get("c.KnowledgeArticleViewStat");
        action.setParams({
            knowledgeArticleId: topicName
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.knowledgeArticles", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})