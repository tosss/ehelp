({
    setup : function(component, event, helper) 
    {
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
        var selected = component.get("v.selectedLeadStatusToView");
        var id = component.get("v.CampaignId");
        if(id==null || id == undefined || id=="")
        {
            helper.showErrorMessage(component,"Please select a Campaign","Info!!!!");
        }
        else if(selected.length == 0)
        {
            helper.showErrorMessage(component,"Please select lead status","Info!!!!");
        }
        else
        {
            var SearchString = component.get("v.searchInLeads");
            helper.getRecordCount(component,helper,selected, id, SearchString);
        }
    },
    doInit : function(component, event, helper)
    {
        helper.initialize(component, helper);
    },
    massUpdate : function(component, event, helper)
    {
        var selectedStaus =  component.get("v.selectedLeadsStatusToUpdate");
        var selected = component.get("v.selectedLeadsList");
        var allStatus = component.get("v.selectedLeadStatusToView");
        var id = component.get("v.CampaignId");
        var SearchString = component.get("v.searchInLeads");
        var pageNumber = component.get("v.PageNumber");
        var recordCount = component.get("v.RecordCount");
        var action = component.get("c.updateStatus");
        var orderBy = component.get("v.orderBy");
        var ascending = component.get("v.ascending");
        action.setParams({
            CampaignId : id,
            leadStatus : allStatus,
            leadIds : selected,
            Status : selectedStaus,
            SearchString : SearchString,
            pageNumber : pageNumber,
            recordsLimit : recordCount,
            orderBy : orderBy,
            ascending : ascending            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" ) {
                component.set("v.leadsList", response.getReturnValue()); 
                component.set("v.selectedLeadsList",[]);
                jQuery("#leadsTable").find("#SelectAll").prop("checked",false);
                var selected = component.get("v.selectedLeadStatusToView");
                var id = component.get("v.CampaignId");
                var SearchString = component.get("v.searchInLeads");
                helper.getRecordCount(component,helper,selected, id, SearchString);
            }
            else
            {
                helper.showErrorMessage(component,"Unable Access User Details","Error!!!");
                component.set("v.CurrentUser", {});
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
                    var hardware = component.get("v.hardware");
                    if(hardware != "DESKTOP")
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": 'Info!!!',
                            "message": 'Please scroll to top',
                            "duration":10000
                        });
                        toastEvent.fire();
                    }
                    
                }
                else
                {
                    helper.showErrorMessage(component,"Unable to fetch Account and Contact Detials","Error!!!");
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
                        matchComponent.addHandler("showLeads", component, "c.showLeads");
                        component.find("FindMatchPageContent").set("v.body", body);
                        var hardware = component.get("v.hardware");
                        if(hardware != "DESKTOP")
                        {
                            var listHeight = jQuery("#LeadsListPage").height();
                            var matchHeight = jQuery("#FindMatchPage").height();
                            if(listHeight < matchHeight)
                            {
                                jQuery("#LeadsListPage").height(matchHeight);
                            } 
                        }
                        jQuery(".Page").toggle();
                    }
                    else
                    {
                        helper.showErrorMessage(component,"Unable to find Match","Error!!!");
                    }
                }
            );
    },
    showLeadsList : function(component, event, helper)
    {
        component.find("FindMatchPageContent").set("v.body",[]);
        /*var selected = component.get("v.selectedLeadStatusToView");
        var id = component.get("v.CampaignId");
        var SearchString = component.get("v.searchInLeads");
        helper.getLeads(component,helper,selected, id, SearchString);
        helper.getRecordCount(component,helper,selected, id, SearchString);*/
    },
    convertToOpportunity : function(component, event, helper)
    {
        
        var leadId = event.getParam("leadId");
        var selected = component.get("v.selectedLeadsList");
        var allStatus = component.get("v.selectedLeadStatusToView");
        var id = component.get("v.CampaignId");
        var SearchString = component.get("v.searchInLeads");
        var pageNumber = component.get("v.PageNumber");
        var recordCount = component.get("v.RecordCount");
        var orderBy = component.get("v.orderBy");
        var ascending = component.get("v.ascending");
        
        var action = component.get("c.convertLeadToOpportunity");
        action.setParams({
            CampaignId : id,
            leadStatus : allStatus,
            leadId : leadId,
            SearchString : SearchString,
            pageNumber : pageNumber,
            recordsLimit : recordCount,
            orderBy : orderBy,
            ascending : ascending                
        });
        
        action.setCallback(this,function(actionResult){
            var state = actionResult.getState();
            if(component.isValid() && state=="SUCCESS")
            {
                component.set("v.leadsList", actionResult.getReturnValue());
                var selected = component.get("v.selectedLeadStatusToView");
                var id = component.get("v.CampaignId");
                var SearchString = component.get("v.searchInLeads");
                helper.getRecordCount(component,helper,selected, id, SearchString);
            }
            else
            {
                component.set("v.leadsList", []);
                helper.showErrorMessage(component,"Could not convert lead to Opportunity","Error!!!");
            }
        });
        $A.enqueueAction(action);
    }
    
})