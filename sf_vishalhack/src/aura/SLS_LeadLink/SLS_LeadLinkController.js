//2016-03-16- anirudh.singh@cdk.com- Created this lightning controller for Request RQ-06471 NADA Leads Process - Work My Leads.
({
    initialize: function(component, event, helper)
    {
        //Fetch Lead Record.
        helper.fetchLeadAndLeadMatches(component, event, helper);
    },
    linkAndRedirect: function(component, event, helper)
    {
        //Link Lead and re-direct.
        helper.linkLeadAndRedirect(component, event, helper);
    },
    openRecordDetail: function(component, event, helper)
    {
        //Re-direct to Account Detail Page.
        helper.openRecordDetailPage(component, event, helper);
    },
    hideError: function(component, event, helper)
    {
        //Hide Error Message.
        helper.hideErrorMessage(component, event, helper);
    },
    matchSelectedAccount: function(component, event, helper)
    {
        //Match Selected Account And Create New Contact.
        helper.matchSelectedAccountRecord(component, event, helper);
    },
    matchSelectedContact: function(component, event, helper)
    {
        //Match Selected Contact.
        helper.matchSelectedContactRecord(component, event, helper);
    },
    redirectToLeadList: function(component, event, helper)
    {
        //Redirect to Lead List Page.
        helper.redirectToLeadListPage(component, event, helper);
    }
})