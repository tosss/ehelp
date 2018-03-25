({
    doInit: function(component, event) {
        var action = component.get("c.articleDetails");
        var pathName_Attachment = window.location.pathname.split('/');
        var pathName = window.location.pathname.split('/')[1] +'/'+ window.location.pathname.split('/')[2];
        component.set("v.pathName", pathName);
        component.set("v.hostName", window.location.hostname);
        component.set("v.pathName_Attachment", pathName_Attachment[1]);
        var topicName ;
        if (component.get("v.dsg_knowledgeArticleID") === undefined || 
            component.get("v.dsg_knowledgeArticleID") === '' || 
            component.get("v.dsg_knowledgeArticleID") === null ){
            topicName = window.location.href.split('/').slice(-1)[0];
        } else{
            topicName = component.get("v.dsg_knowledgeArticleID");             
        }
        action.setParams({
            topicName: topicName
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