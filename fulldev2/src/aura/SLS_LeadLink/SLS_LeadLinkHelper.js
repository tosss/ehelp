//2016-03-16- anirudh.singh@cdk.com- Created this lightning helper for Request RQ-06471 NADA Leads Process - Work My Leads.
({
    fetchLeadAndLeadMatches: function(component, event, helper)
    {
        helper.showSpinner(component, event, helper);
        var action=component.get("c.fetchLeadAndLeadMatches");
        var leadId=component.get("v.leadId");
        
        action.setParams({
            leadId : leadId
        });
        
        action.setCallback(this, function(response)
        {
            var state=response.getState();
            
            if(component.isValid() && state==="SUCCESS")
            {
                component.set("v.leadAndLeadMatchesRecord", response.getReturnValue());
                helper.hideSpinner(component, event, helper);
            }
            else
            {
                component.set("v.leadAndLeadMatchesRecord", null);
                helper.hideSpinner(component, event, helper);
            }
        });
        
        $A.enqueueAction(action);
    },
    linkLeadAndRedirect: function(component, event, helper)
    {
        helper.showSpinner(component, event, helper);
        var action=component.get("c.linkLeadAndRedirect");
        var leadMatchId=event.target.getAttribute("id");
        var leadId=component.get("v.leadId");
        
        action.setParams({
            leadMatchId : leadMatchId,
            leadId : leadId
        });
        
        action.setCallback(this, function(response)
        {
            var state=response.getState();
            
            if(component.isValid() && state==="SUCCESS")
            {
                if(response.getReturnValue()=='Link Success')
                {
                    //Redirect to Lead List Page.
                    helper.redirectToLeadListPage(component, event, helper);
                    helper.hideSpinner(component, event, helper);
                    helper.refetchLeads(component, event, helper);
                }
                else
                {
                    component.set("v.errorMessageValue", response.getReturnValue());
                    helper.hideSpinner(component, event, helper);
                    helper.showErrorMessage(component, event, helper);
                }
            }
            else
            {
                component.set("v.errorMessageValue", "Some error occured during the operation.");
                helper.hideSpinner(component, event, helper);
                helper.showErrorMessage(component, event, helper);
            }
        });
        
        $A.enqueueAction(action);
    },
    matchSelectedAccountRecord: function(component, event, helper)
    {
        helper.showSpinner(component, event, helper);
        var action=component.get("c.matchSelectedAccountRecord");
        var leadId=component.get("v.leadId");
        var accountRecordId=component.get("v.leadAndLeadMatchesRecord.leadRecord.Current_Account__c");
        
        action.setParams({
            accountRecordId : accountRecordId,
            leadId : leadId
        });
        
        action.setCallback(this, function(response)
        {
            var state=response.getState();
            
            if(component.isValid() && state==="SUCCESS")
            {
                if(response.getReturnValue()=='Link Success')
                {
                    //Redirect to Lead List Page.
                    helper.redirectToLeadListPage(component, event, helper);
                    helper.hideSpinner(component, event, helper);
                    helper.refetchLeads(component, event, helper);
                }
                else
                {
                    component.set("v.errorMessageValue", response.getReturnValue());
                    helper.hideSpinner(component, event, helper);
                    helper.showErrorMessage(component, event, helper);
                }
            }
            else
            {
                component.set("v.errorMessageValue", "Some error occured during the operation.");
                helper.hideSpinner(component, event, helper);
                helper.showErrorMessage(component, event, helper);
            }
        });
        
        if(accountRecordId!=null)
        {
            $A.enqueueAction(action);
        }
        else
        {
            component.set("v.errorMessageValue", "Please select a valid Account.");
            helper.hideSpinner(component, event, helper);
            helper.showErrorMessage(component, event, helper);
        }
    },
    matchSelectedContactRecord: function(component, event, helper)
    {
        helper.showSpinner(component, event, helper);
        var action=component.get("c.matchSelectedContactRecord");
        var leadId=component.get("v.leadId");
        var contactRecordId=component.get("v.leadAndLeadMatchesRecord.leadRecord.Contact__c");
        
        action.setParams({
            contactRecordId : contactRecordId,
            leadId : leadId
        });
        
        action.setCallback(this, function(response)
        {
            var state=response.getState();
            
            if(component.isValid() && state==="SUCCESS")
            {
                if(response.getReturnValue()=='Link Success')
                {
                    //Redirect to Lead List Page.
                    helper.redirectToLeadListPage(component, event, helper);
                    helper.hideSpinner(component, event, helper);
                    helper.refetchLeads(component, event, helper);
                }
                else
                {
                    component.set("v.errorMessageValue", response.getReturnValue());
                    helper.hideSpinner(component, event, helper);
                    helper.showErrorMessage(component, event, helper);
                }
            }
            else
            {
                component.set("v.errorMessageValue", "Some error occured during the operation.");
                helper.hideSpinner(component, event, helper);
                helper.showErrorMessage(component, event, helper);
            }
        });
        
        if(contactRecordId!=null)
        {
            $A.enqueueAction(action);
        }
        else
        {
            component.set("v.errorMessageValue", "Please select a valid Contact.");
            helper.hideSpinner(component, event, helper);
            helper.showErrorMessage(component, event, helper);
        }
    },
    redirectToLeadListPage: function(component, event, helper)
    {
        component.set("v.body", []);
        var listHeight=jQuery("#LeadsListPage").height();
        var matchHeight=jQuery("#FindMatchPage").height();
        if(listHeight<matchHeight)
        {
            jQuery("#LeadsListPage").height(listHeight);
        }
        jQuery(".Page").toggle();
    },
    openRecordDetailPage: function(component, event, helper)
    {
        var navigateEvent=$A.get("e.force:navigateToSObject");
        var recordId=event.target.getAttribute("id");
        navigateEvent.setParams({
            "recordId": recordId
        });
        navigateEvent.fire();
    },
    showErrorMessage: function(component, event, helper)
    {
        $A.createComponents([
            ["ui:outputText",{
                "value" : component.get("v.errorMessageValue")
            }]
        ],
        function(components, status)
        {
            if(status==="SUCCESS")
            {
                var outputText=components[0];
                
                var errorMessage=component.find("errorMessage");
                
                //Replace div body with the dynamic component.
                errorMessage.set("v.body", outputText);
            }
        });
        
        $A.util.removeClass(component.find('errorOuterDiv'), 'noDisplay');
        
        if(component.get("v.hardware")!="DESKTOP")
        {
            var toastEvent=$A.get("e.force:showToast");
            toastEvent.setParams({
                "message": "Please scroll to top of the page.",
                "duration": 5000
            });
            toastEvent.fire();
        }
        component.find('errorDiv').getElement().focus();
    },
    hideErrorMessage: function(component, event, helper)
    {
        $A.util.addClass(component.find('errorOuterDiv'), 'noDisplay');
        component.set("v.errorMessageValue", "");
    },
    showSpinner: function(component, event, helper)
    {
        var spinnerLeadLink=component.find("spinnerLeadLink");
        $A.util.removeClass(spinnerLeadLink, "noDisplay");
    },
    hideSpinner: function(component, event, helper)
    {
        var spinnerLeadLink=component.find("spinnerLeadLink");
        $A.util.addClass(spinnerLeadLink, "noDisplay");
    },
    refetchLeads: function(component, event, helper)
    {
        var showLeadsListEvent=component.getEvent("showLeads");
        showLeadsListEvent.fire();
    }
})