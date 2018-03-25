({
    helper_countArticles: function(component, event, helper, loadMoreClick) {
        var actioncount = component.get("c.knowledgeArticleVersionCount");
        var offsetval = component.get("v.c_offset");
        var showArticle = component.get("v.dsg_articleCounter");
        var hashes = window.location.href.split('/').slice(-2)[0];
        var topicId = window.location.href.split('/').slice(-1)[0];
        var topicName;
        if (component.get("v.dsg_topicName") === '' && hashes.length === 18) {
            topicName = hashes;
        } else if (topicId.length === 18) {
            topicName = topicId;
        } else {
            topicName = component.get("v.dsg_topicName");
        }
        actioncount.setParams({
            TopicName:topicName,
            articleCounter: '1'
        });
        actioncount.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.knowledgeArticlesCount", response.returnValue);
                if ((response.returnValue <= offsetval || response.returnValue <= showArticle) && loadMoreClick ==='clicked') {
                    component.set("v.loadMore","True");
                } else if((response.returnValue <= offsetval || response.returnValue <= showArticle) && loadMoreClick ===''){
                    component.set("v.loadMore","");
                }
            }
        });
        $A.enqueueAction(actioncount);
    }
})