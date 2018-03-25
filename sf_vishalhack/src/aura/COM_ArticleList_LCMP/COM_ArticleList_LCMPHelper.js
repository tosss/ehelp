({
    countArticles : function(component, event, helper) {
        var actioncount = component.get("c.knowledgeArticleVersionCount");
        actioncount.setParams({
            TopicName :component.get("v.dsg_topicName")
        });
        actioncount.setCallback(this, function(response){
            var state = response.state;
            if (state === "SUCCESS")
            {
                component.set("v.knowledgeArticlesCount", response.returnValue);
                console.log('count : ',response.returnValue);
            }
        });
        $A.enqueueAction(actioncount);
    }
})