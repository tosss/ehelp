({
	initialize : function(component,helper) {
        var action = component.get("c.getLeadStatus");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" ) {
                component.set("v.optionsApp", response.getReturnValue()); 
            }
            else
            {
                component.set("v.optionsApp", []);
            }
        });
        helper.getLeads(component);
        $A.enqueueAction(action);
	},
    
    getRecordCount : function(component,selected, id, SearchString)
    {
        var action = component.get("c.getRecordsCount");
        action.setParams({
            CampaignId : id,
            leadStatus : selected,
            SearchString : SearchString
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" ) {
                var totalRecord = response.getReturnValue();
                var recordCount = component.get("v.RecordCount");
                component.set("v.TotalRecordCount", totalRecord); 
                var totalPages = Math.ceil(totalRecord/recordCount); 
                component.set("v.TotalPages", totalPages); 
            }
            else
            {
                component.set("v.TotalRecordCount", 0);
                component.set("v.TotalPages", 0); 
            }
        });
        $A.enqueueAction(action);
    },
    getLeads : function(component,selected, id, SearchString)
    {
        var pageNumber = component.get("v.PageNumber");
        var recordCount = component.get("v.RecordCount");
        var action = component.get("c.getLeads");
        action.setParams({
            CampaignId : id,
            leadStatus : selected,
            SearchString : SearchString,
            pageNumber : pageNumber,
            recordsLimit : recordCount
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" ) {
                component.set("v.leadsList", response.getReturnValue()); 
            }
            else
            {
                component.set("v.leadsList", []);
            }
        });
        $A.enqueueAction(action);
    },
    showDetailTab : function(component,event,helper)
    {
        component.find("tab2").set("v.body", []);
        jQuery('.slds-tabs--default').find('#detailTab').removeClass('slds-active').css("display","none");
        jQuery('.slds-tabs--default').find('#listTab').addClass('slds-active');
        jQuery('.slds-tabs--default').find('#tab2Container').css("display","none");
        jQuery('.slds-tabs--default').find('#tab1').css("display","block");
    },
    showListTab : function(component,event,helper)
    {
        jQuery('.slds-tabs--default').find('#listTab').removeClass('slds-active');
        jQuery('.slds-tabs--default').find('#detailTab').addClass('slds-active').css("display","block");
        jQuery('.slds-tabs--default').find('#tab1').css("display","none");
        jQuery('.slds-tabs--default').find('#tab2Container').css("display","block");
        
        var leadName = event.getParam("leadName");
        jQuery('.slds-tabs--default').find('#detailTab').find('a').html(leadName);
        
    },
	showLeads : function(component, event, helper) {
        var selected = component.get("v.SelectedOptionsApp");
        var id = component.get("v.CampaignId");
        var SearchString = component.get("v.searchingStringApp");
        helper.getLeads(component,selected, id, SearchString);
       	helper.getRecordCount(component,selected, id, SearchString);
	}
})