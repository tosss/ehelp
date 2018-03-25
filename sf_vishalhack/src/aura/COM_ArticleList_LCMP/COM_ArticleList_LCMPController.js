({
    doInit: function(component) {
        var spinner = component.find('spinner');
        console.log(spinner);
        $A.util.removeClass(spinner, 'spinner');
        component.showSpinnerMethod();
        var action = component.get("c.KnowledgeArticleVersion");
        var showArticle = component.get("v.dsg_articleCounter");
        var counter = component.get("v.c_offset");
        var showPagination = component.get("v.showPagination");
        var dsgn_sortBy = component.get("v.dsgn_sortBy");
        if(showPagination === 'Yes'){
             component.countArticlesMethod();
        }
       
        action.setParams({
            TopicName: component.get("v.dsg_topicName"),
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
                component.set("v.c_offset", counter);
                component.hideSpinnerMethod();
            }
        });
        $A.enqueueAction(action);
    },

    countArticles: function(component) {
        var actioncount = component.get("c.knowledgeArticleVersionCount");
        var showArticle = component.get("v.dsg_articleCounter");
        actioncount.setParams({
            TopicName: component.get("v.dsg_topicName"),
            articleCounter: showArticle
        });
        actioncount.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                var lists = [];
                for (var i = 1; i <= response.returnValue; i++) {
                    lists.push(i);
                }
                component.set("v.knowledgeArticlesCount", lists);
            }
        });
        $A.enqueueAction(actioncount);
    },

    nextArticles: function(component) {
        component.showSpinnerMethod();

        var action = component.get("c.nextArticle");
        var showArticle = component.get("v.dsg_articleCounter");
        var dsgn_sortBy = component.get("v.dsgn_sortBy");

        var dsg_articleCounter = parseInt(component.get("v.dsg_articleCounter"));
        var dsg_Offset = parseInt(component.get("v.c_offset"));
        var offsetval = component.get("v.c_offset");
        var idx = event.target.id;

        if (idx === 'Next') {
            offsetval = dsg_Offset + dsg_articleCounter;
        } else {
            offsetval = dsg_articleCounter * idx;
        }
        offsetval = offsetval.toString();

        action.setParams({
            TopicName: component.get("v.dsg_topicName"),
            articleCounter: showArticle,
            dsg_isValid: component.get("v.isValid"),
            counter: offsetval,
            sortBy: dsgn_sortBy
        });

        action.setCallback(this, function(response) {
            var showToast = $A.get('e.force:showToast');
            var state = response.state;
            if (state === "SUCCESS") {
                if (response.returnValue === '') {
                    showToast.setParams({
                        'type': 'other',
                        'message': 'No more records to display.',
                        'duration': 50,
                        'key': 'info'
                    });
                    showToast.fire();
                } else {
                    component.set("v.knowledgeArticles", response.returnValue);
                }
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