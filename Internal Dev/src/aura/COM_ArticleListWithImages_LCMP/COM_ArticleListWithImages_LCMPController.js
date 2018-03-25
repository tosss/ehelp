({
    doInit: function(component, event, helper) {
        var spinner = component.find('spinner-div');
        $A.util.removeClass(spinner, 'hideBlock');
        component.showSpinnerMethod();
        var pathName_Attachment = window.location.pathname.split('/');
        var pathName = window.location.pathname.split('/')[1] +'/'+ window.location.pathname.split('/')[2];
        component.set("v.pathName", pathName);
        component.set("v.hostName", window.location.hostname);
        component.set("v.pathName_Attachment", pathName_Attachment[1]);
        helper.helper_countArticles(component, event, helper, '');
        var action = component.get("c.KnowledgeArticleVersionImage");
        var showArticle = component.get("v.dsg_articleCounter");
        var counter = component.get("v.c_offset");
        var showPagination = component.get("v.showPagination");
        var dsgn_sortBy = component.get("v.dsgn_sortBy");
        var hashes = window.location.href.split('/').slice(-2)[0];
        var topicId = window.location.href.split('/').slice(-1)[0];
        var topicName;
        
        if ((component.get("v.dsg_topicName") === '' || component.get("v.dsg_topicName") === undefined) && hashes.length === 18) {
            topicName = hashes;
            
        } else if (topicId.length === 18) {
            topicName = topicId;
        } else {
            topicName = component.get("v.dsg_topicName");
        }
        
        action.setParams({
            TopicName: topicName,
            articleCounter: showArticle,
            counter: counter,
            showPagination: showPagination,
            sortBy: dsgn_sortBy
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.knowledgeArticles", response.getReturnValue());
                component.set("v.dsg_articleCounter", showArticle);
                component.set("v.c_offset", counter);
            }
            component.hideSpinnerMethod();
            
        });
        $A.enqueueAction(action);
    },
    
    nextArticles: function(component, event, helper) {
        component.showSpinnerMethod();
        var action = component.get("c.KnowledgeArticleVersionImage");
        var showArticle = component.get("v.dsg_articleCounter");
        var dsgn_sortBy = component.get("v.dsgn_sortBy");
        var dsg_articleCounter = parseInt(component.get("v.dsg_articleCounter"));
        var dsg_Offset = parseInt(component.get("v.c_offset"));
        var offsetval = component.get("v.c_offset");
        var loadMoreClick = 'clicked';
        helper.helper_countArticles(component, event, helper, loadMoreClick);
        offsetval = dsg_Offset + dsg_articleCounter;
        offsetval = offsetval.toString();
        
        var hashes = window.location.href.split('/').slice(-2)[0];
        var topicId = window.location.href.split('/').slice(-1)[0];
        console.log('topicId',topicId);
        console.log('topicId len',topicId.length);
        
        var topicName;
        if ((component.get("v.dsg_topicName") === '' || component.get("v.dsg_topicName") === undefined) && hashes.length === 18) {
            topicName = hashes;
            
        } else if (topicId.length === 18) {
            topicName = topicId;
        } else {
            topicName = component.get("v.dsg_topicName");
        }
        
        console.log('topicName',topicName);
        action.setParams({
            TopicName: topicName,
            articleCounter: offsetval,
            counter: offsetval,
            showPagination: 'Yes',
            sortBy: dsgn_sortBy
        });
        
        action.setCallback(this, function(response) {
            var showToast = $A.get('e.force:showToast');
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.knowledgeArticles", response.returnValue);
                component.set("v.dsg_articleCounter", showArticle);
                component.set("v.c_offset", offsetval);
            }
            component.hideSpinnerMethod();
            
        });
        $A.enqueueAction(action);
    },
    
    previousArticles: function(component) {
        var action = component.get("c.nextArticle");
        var showArticle = component.get("v.dsg_articleCounter");
        var dsgn_sortBy = component.get("v.dsgn_sortBy");
        var dsg_articleCounter = parseInt(component.get("v.dsg_articleCounter"));
        var dsg_Offset = parseInt(component.get("v.c_offset"));
        var offsetval = component.get("v.c_offset");
        offsetval = dsg_Offset - dsg_articleCounter;
        offsetval = offsetval.toString();
        action.setParams({
            TopicName: component.get("v.dsg_topicName"),
            articleCounter: showArticle,
            counter: offsetval,
            sortBy: dsgn_sortBy
        });
        
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.knowledgeArticles", response.getReturnValue());
                component.set("v.dsg_articleCounter", showArticle);
                component.set("v.c_offset", offsetval);
            } else {
                var showToast = $A.get('e.force:showToast');
                showToast.setParams({
                    'type': 'other',
                    'message': 'No more records to display.',
                    'duration': 50,
                    'key': 'info'
                });
                showToast.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    displaytext: function(component) {
        $A.util.addClass(component, 'ToggleText');
    },
    
    showSpinner: function(component, event, helper) {
        var spinner = component.find('spinner');
        var spinner1 = component.find('spinner-div');
        $A.util.removeClass(spinner1, 'hideBlock');
        var evt = spinner.get("e.toggle");
        evt.setParams({
            isVisible: true
        });
        evt.fire();
    },
    hideSpinner: function(component, event, helper) {
        var spinner = component.find('spinner');
        var spinner1 = component.find('spinner-div');
        $A.util.addClass(spinner1, 'hideBlock');
        var evt = spinner.get("e.toggle");
        evt.setParams({
            isVisible: false
        });
        evt.fire();
    }
})