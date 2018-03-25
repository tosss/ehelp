({
	initialize : function(component,helper) {
        var action = component.get("c.getLeadStatus");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" ) {
                var options = response.getReturnValue();
                component.set("v.statusOptions", options); 
                options = options.slice(0);
                var index = options.indexOf("Converted to Opportunity");
                options.splice(index,1);
                component.set("v.statusMassUpdateOptions", options); 
            }
            else
            {
                component.set("v.statusOptions", []);
                helper.showErrorMessage(component,"Could not fetch leads status","Error!!!");
            }
        });
        $A.enqueueAction(action);
	},
    
    getRecordCount : function(component,helper,selected, id, SearchString)
    {
        jQuery("#loadTable").show();
        jQuery("#tbody").hide();
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
                var pageNumber = component.get("v.PageNumber");
                pageNumber = pageNumber>totalPages ? totalPages : pageNumber;
                component.set("v.PageNumber",pageNumber);
                helper.getLeads(component,helper,selected, id, SearchString);
            }
            else
            {
                component.set("v.TotalRecordCount", 0);
                component.set("v.TotalPages", 0); 
                helper.showErrorMessage(component,"Unexpected Error occured","Error!!!");
                jQuery("#loadTable").hide();
                jQuery("#tbody").show();
            }
        });
        $A.enqueueAction(action);
    },
    getLeads : function(component,helper,selected, id, SearchString)
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
            var returnValue = response.getReturnValue();
            if(returnValue.length == 0)
            {
                component.set("v.leadsList", []);
                helper.showErrorMessage(component,"No Leads Found","Info!!!");
            }
            else if (component.isValid() && state === "SUCCESS" ) {
                component.set("v.leadsList", response.getReturnValue()); 
            }
                else
                {
                    component.set("v.leadsList", []);
                    helper.showErrorMessage(component,"Unexpected Error occured","Error!!!");
                }
            jQuery("#loadTable").hide();
            jQuery("#tbody").show();
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
        var selected = component.get("v.selectedLeadStatusToView");
        var id = component.get("v.CampaignId");
        var SearchString = component.get("v.searchInLeads");
        helper.getLeads(component,helper,selected, id, SearchString);
       	helper.getRecordCount(component,helper,selected, id, SearchString);
	},
    showErrorMessage: function(component,message,severity)
    {
        message = message==null || message==null ?"Unexpected Error!!!!":message;
        severity = severity==null ||severity==undefined ? "Error!!!!":severity;
        if(component.get("v.hardware")=="DESKTOP")
        {
            jQuery("#message").html(message);
            jQuery("#messageBox").fadeIn(1000, function(){
                jQuery(this).fadeOut(10000);
            });
        }
        else
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": severity,
                "message": message,
                "duration":10000
            });
            toastEvent.fire();
        }
    }
})