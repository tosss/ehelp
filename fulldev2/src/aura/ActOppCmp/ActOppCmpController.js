({
    initialize: function(component, event, helper)
    {
        //Fetch Lead Record.
        console.log('initialize values');
        helper.fetchRecords(component, event, helper);
    },
    showHideEventSection: function(component, event, helper)
    {
        //Show or Hide Event Section.
        helper.showHideEventSectionAndFlipButtons(component, event, helper);
    },
    openRecordDetail: function(component, event, helper)
    {
        //Re-direct to Record Detail Page.
        helper.openRecordDetailPage(component, event, helper);
    },
    saveChanges: function(component, event, helper)
    {
        //Save Changes made by the User.
        helper.saveDetails(component, event, helper);
    },
    cancelChanges: function(component, event, helper)
    {
        //Cancel Changes made by the User.
        window.close(component, event, helper);
    }
})