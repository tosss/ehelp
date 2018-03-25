({
    setup : function(component, event, helper) {
		jQuery("#fullPage").css("display","block");
	},
    toggleTab : function(component, event, helper)
    {
        helper.toggleTab(component, event, helper);
    },
    showListTab : function(component,event,helper)
    {
        helper.showListTab(component,event,helper);
    },
    showDetailTab : function(component,event,helper)
    {
        helper.showDetailTab(component,event,helper);
    },
	showLeads : function(component, event, helper) {
        var selected = component.get("v.SelectedOptionsApp");
        var id = component.get("v.CampaignId");
        var SearchString = component.get("v.searchingStringApp");
        helper.getLeads(component,selected, id, SearchString);
       	helper.getRecordCount(component,selected, id, SearchString);
	},
    doInit : function(component, event, helper)
    {
        helper.initialize(component, helper);
    },
    massUpdate : function(component, event, helper)
    {
        var selectedStaus =  component.get("v.SelectedOptionApp");
        var selected = component.get("v.selectedLeadsList");
        var allStatus = component.get("v.SelectedOptionsApp");
        var id = component.get("v.CampaignId");
         var SearchString = component.get("v.searchingStringApp");
        var pageNumber = component.get("v.PageNumber");
        var recordCount = component.get("v.RecordCount");
         var action = component.get("c.updateStatus");
        action.setParams({
            CampaignId : id,
            leadStatus : allStatus,
            leadIds : selected,
            Status : selectedStaus,
            SearchString : SearchString,
            pageNumber : pageNumber,
            recordsLimit : recordCount            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" ) {
                component.set("v.leadsList", response.getReturnValue()); 
                component.set("v.selectedLeadsList",[]);
                jQuery("#leadsTable").find("#SelectAll").prop("checked",false);
            }
            else
            {
                component.set("v.selectedLeadsList",[]);
                component.set("v.leadsList", []);
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Unexpected Error occured",
                        "duration":500
                    });
                    toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    showAccountAndContact : function(component,event,helper)
    {
        component.find("tab2").set('v.body',[]);
        var accountId = component.get("v.CurrentAccount");
        var contactId = component.get("v.CurrentContact");
        var campaignId = component.get("v.CampaignId");
        var leadId = event.getParam("LeadId");
         $A.createComponent(
                "c:SLS_AccountContactDetail",
                {AccountId : accountId,
                 ContactId : contactId,
                 CampaignId : campaignId,
                 LeadId : leadId
                },
                function(newComponent){
                    if (component.isValid()) {
                        var body = component.find("tab2").get("v.body");
                        body.push(newComponent);
                        component.find("tab2").set("v.body", body);
                        helper.showListTab(component, event, helper);
                        jQuery('body').scrollTop(0);
                    }
                }
            );
    },
    findMatch : function(component, event, helper)
    {
        var leadId = event.getParam('leadId');
        $A.createComponent(
                "c:SLS_LeadLink",
                {leadId:leadId},
                function(matchComponent){
                    if (component.isValid()) {
                        component.find("FindMatchPageContent").set("v.body",[]);
                        var body = component.find("FindMatchPageContent").get("v.body");
                        body.push(matchComponent);
                        component.find("FindMatchPageContent").set("v.body", body);
                        jQuery(".Page").toggle();
                    }
                }
            );
    },
    showLeadsList : function(component, event, helper)
    {
         component.find("FindMatchPageContent").set("v.body", []);
        jQuery(".Page").toggle();
    },
    waiting : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Info!",
                        "message": "Loading",
                        "duration":800
                    });
                    toastEvent.fire();
    },
    doneWaiting : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Info!",
                        "message": "Loaded",
                        "duration":800
                    });
                    toastEvent.fire();
    }
})