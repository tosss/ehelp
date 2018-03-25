({
    helper_countArticles: function(component, event, helper) {
        var actioncount = component.get("c.knowledgeArticleVersionCount");
        var dsg_Offset = parseInt(component.get("v.c_offset"));
        var offsetval = component.get("v.c_offset");
        var loadMoreButton = component.find('loadMore');
        var showArticle = component.get("v.dsg_articleCounter");
        
        var hashes = window.location.href.split('/').slice(-2)[0];
        var topicId = window.location.href.split('/').slice(-1)[0];
        var topicName;
        
        if(component.get("v.dsg_topicName") ==='' && hashes.length == '18'){
            topicName = hashes;
            console.log('am here in hashes');
        }else if(topicId.length == '18'){
            topicName = topicId;
            console.log('am here in topicid');
            
        }else{
          topicName =  component.get("v.dsg_topicName");
        }
        actioncount.setParams({
            TopicName:topicName,
            articleCounter: '1'
        });
        actioncount.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.knowledgeArticlesCount", response.returnValue);
				console.log('response',response.returnValue);
                console.log('showArticle',showArticle);
                if (response.returnValue <= offsetval || response.returnValue <= showArticle) {
                    component.set("v.loadMore","True");
                    console.log('am in load more true');
                }
            }
        });
        $A.enqueueAction(actioncount);
    }

})