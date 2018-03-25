({
	initialize: function(component, event, helper)
    {
        helper.initializeComponent(component, event, helper);
    },
    openIdea: function(component, event, helper) 
    {
        helper.openIdeaDetail(component, event, helper);
    },
    submitUpVote: function(component, event, helper) 
    {
        helper.submitVote(component, event, helper, 'up');
    },
    submitDownVote: function(component, event, helper) 
    {
        helper.submitVote(component, event, helper, 'down');
    },
    postIdeaComment: function(component, event, helper) 
    {
        helper.saveIdeaComment(component, event, helper);
    },
    submitIdea: function(component, event, helper) 
    {
        helper.saveIdea(component, event, helper);
    }
})