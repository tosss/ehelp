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
        var action = component.get("c.getvotes");
        action.setParams({
            knowledgearticleID: topicName
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.knowledgeArticles", response.returnValue);
                if(response.returnValue.voteup !== undefined){
                    component.set("v.votesUp",response.returnValue.voteup );
                }else {        
                    component.set("v.votesUp",'0' );
                }
                if(response.returnValue.votedown !== undefined){
                    component.set("v.votesDown",response.returnValue.votedown);
                }else{            
                    component.set("v.votesDown",'0');
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    handleClick: function(component, event) {
        var topicName ;
        
        if (component.get("v.dsg_knowledgeArticleID") === undefined || 
            component.get("v.dsg_knowledgeArticleID") === '' || 
            component.get("v.dsg_knowledgeArticleID") === null ){
            topicName = window.location.href.split('/').slice(-1)[0];
        } else{
            topicName = component.get("v.dsg_knowledgeArticleID");             
        }
        
        var clicked = event.getSource().getLocalId();
        var action = component.get("c.createVote");
        action.setParams({
            knowledgeArticleID: topicName,
            voteType: clicked
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