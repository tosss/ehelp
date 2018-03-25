({
    doInit: function(component, event, helper) {
        helper.helper_countArticles(component, event, helper);
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'spinner');
        var hashes = window.location.href.split('/').slice(-2)[0];
        var topicId = window.location.href.split('/').slice(-1)[0];
        var topicName;
        if(component.get("v.dsg_topicName") ==='' && hashes.length == '18'){
            topicName = hashes;
        }else if(topicId.length == '18'){
            topicName = topicId;
        }else{
          topicName =  component.get("v.dsg_topicName");
        }
                component.showSpinnerMethod();

        var action = component.get("c.KnowledgeArticleVersionImage");
        var showArticle = component.get("v.dsg_articleCounter");
        var counter = component.get("v.c_offset");
        var showPagination = component.get("v.showPagination");
        var dsgn_sortBy = component.get("v.dsgn_sortBy");
        
        action.setParams({
            TopicName: topicName,
            articleCounter: showArticle,
            dsg_isValid: component.get("v.isValid"),
            counter: counter,
            showPagination: showPagination,
            sortBy: dsgn_sortBy
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.knowledgeArticles", response.returnValue);
                component.set("v.dsg_articleCounter", showArticle);
                var doctype = response.returnValue.ContentType;
                component.set("v.c_offset", counter);
                        component.hideSpinnerMethod();

            }
        });
        $A.enqueueAction(action);
    },
    
    nextArticles: function(component, event, helper) {
        var action = component.get("c.KnowledgeArticleVersionImage");
        var showArticle = component.get("v.dsg_articleCounter");
        var dsgn_sortBy = component.get("v.dsgn_sortBy");
        var dsg_articleCounter = parseInt(component.get("v.dsg_articleCounter"));
        var dsg_Offset = parseInt(component.get("v.c_offset"));
        var offsetval = component.get("v.c_offset");
        var idx = event.target.id;
        helper.helper_countArticles(component, event, helper);
        offsetval = dsg_Offset + dsg_articleCounter;
        offsetval = offsetval.toString();
            var hashes = window.location.href.split('/').slice(-2)[0];
        var topicId = window.location.href.split('/').slice(-1)[0];
        var topicName;
                component.showSpinnerMethod();

        if(component.get("v.dsg_topicName") ==='' && hashes.length == '18'){
            topicName = hashes;
        }else if(topicId.length == '18'){
            topicName = topicId;
        }else{
          topicName =  component.get("v.dsg_topicName");
        }
        
        action.setParams({
            TopicName:topicName,
            articleCounter: offsetval,
            dsg_isValid: component.get("v.isValid"),
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
                        component.hideSpinnerMethod();

            }
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
            dsg_isValid: component.get("v.isValid"),
            counter: offsetval,
            sortBy: dsgn_sortBy
        });
        
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.knowledgeArticles", response.returnValue);
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
        var evt = spinner.get("e.toggle");
        evt.setParams({
            isVisible: true
        });
        evt.fire();
    },
    hideSpinner: function(component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({
            isVisible: false
        });
        evt.fire();
    }
})