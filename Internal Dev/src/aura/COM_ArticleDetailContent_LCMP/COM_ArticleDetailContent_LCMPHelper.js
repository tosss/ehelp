({
	helperMethod : function(component, event, helper , articleName) {
		 var topicName ;
        topicName =articleName;
        var articleType = component.get("v.articleType");
        var action = component.get("c.articleDetails");
        console.log('component.get("v.dsg_knowledgeArticleID")',component.get("v.dsg_knowledgeArticleID"));
        console.log('topicName',topicName);
        action.setParams({
        	articleType: articleType,
            topicName: topicName
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.knowledgeArticles", response.returnValue);
            }
        });
        $A.enqueueAction(action);
	}
})