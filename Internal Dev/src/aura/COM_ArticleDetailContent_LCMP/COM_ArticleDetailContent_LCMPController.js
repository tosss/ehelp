({
    doInit: function(component) {
        var topicName ;
        if (component.get("v.dsg_knowledgeArticleID") === undefined || 
            component.get("v.dsg_knowledgeArticleID") === '' || 
            component.get("v.dsg_knowledgeArticleID") === null ){
            topicName = window.location.href.split('/').slice(-1)[0];
        } else{
            topicName = component.get("v.dsg_knowledgeArticleID");             
        }
                var action = component.get("c.articleDetails");
                var articleType = component.get("v.articleType");
        action.setParams({
        	articleType: articleType,
            topicName: topicName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {
                component.set("v.knowledgeArticles", response.getReturnValue());
                console.log('--------------',response.getReturnValue().EMPCommunityArticle.Show_Summary__c);
                if(response.getReturnValue().content == undefined && response.getReturnValue().KnowledgeArticleVersionlst.Summary == undefined && response.getReturnValue().ImageName === undefined){
                    component.set("v.noData",'true');
                }
            }
        });
        $A.enqueueAction(action);
    },
    setSelectedArticle : function(component, event, helper) {
        console.log("account set to: ",component.get("v.dsg_knowledgeArticleID"));
        var articleName = component.get("v.dsg_knowledgeArticleID");
        helper.helperMethod(component, event, helper, articleName);
        /*var selectedAccount = event.getParam("articleName");
        console.log("account set to: ",selectedAccount);
        component.set("v.dsg_knowledgeArticleID", selectedAccount);*/
    } 
})