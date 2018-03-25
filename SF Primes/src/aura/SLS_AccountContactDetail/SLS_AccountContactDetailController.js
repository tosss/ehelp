({
    doInit : function(component, event, helper) {
        var AccountId = component.get('v.AccountId');
        var action = component.get('c.getAccountDetails');
        action.setParams({AccountId : AccountId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" ) {
                component.set("v.Account", response.getReturnValue()); 
            }
            else
            {
                component.set("v.Account", null);
                helper.showErrorMessage(component,"Account Details not found","Info!!!");
            }
        });
        $A.enqueueAction(action);
        var ContactId = component.get('v.ContactId');
        action = component.get('c.getContactDetails');
        action.setParams({ContactId : ContactId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" ) {
                component.set("v.Contact", response.getReturnValue()); 
            }
            else
            {
                component.set("v.Contact", null);
                helper.showErrorMessage(component,"Contact Details not found","Info!!!");
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getVendorSystem");
        action.setParams({AccountId : AccountId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" ) {
                component.set("v.VendorSystem", response.getReturnValue()); 
            }
            else
            {
                component.set("v.VendorSystem", null);
                helper.showErrorMessage(component,"Vendor not found","Info!!!");
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getISR");
        action.setParams({AccountId : AccountId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" ) {
                component.set("v.ISR", response.getReturnValue()); 
            }
            else
            {
                component.set("v.ISR", null);
                helper.showErrorMessage(component,"ISR not found","Info!!!");
            }
        });
        $A.enqueueAction(action);
        
        var LeadId  = component.get("v.LeadId");
        
        action = component.get("c.getOpenActivities");
        action.setParams({
            leadId : LeadId,
            accountId : AccountId,
            openActivityFilter : "all"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS" && response.getReturnValue().length == 0) 
            {
                helper.showErrorMessage(component,"No Open Activities Found","Info!!!");
            }
            else if (component.isValid() && state === "SUCCESS" ) {
                component.set("v.OpenActivities", response.getReturnValue()); 
            }
                else
                {
                    component.set("v.OpenActivities", null);
                    helper.showErrorMessage(component,"Unexpexted Error","Error!!!");
                }
        });
        
        $A.enqueueAction(action);
        
        action = component.get("c.getActivityHistory");
        action.setParams({
            leadId : LeadId,
            accountId : AccountId,
            activityHistoryFilter : "all"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS" && response.getReturnValue().length == 0) 
            {
                component.set("v.ActivitiesHistory", []);
                helper.showErrorMessage(component,"No Activities History Found","Info!!!");
            }
            else if (component.isValid() && state === "SUCCESS" ) {
                component.set("v.ActivitiesHistory", response.getReturnValue());
                if(component.get("v.hardware") != "DESKTOP")
                {
                    toastEvent.setParams({
                        "title": "Info!",
                        "message": "Scroll Top",
                        "duration":10000
                    });
                    toastEvent.fire();
                }
                jQuery(window).scrollTop(0);
                
            }
                else
                {
                    component.set("v.ActivitiesHistory", null);
                    helper.showErrorMessage(component,"Unexpected Error","Error!!!");
                }
        });
        
        $A.enqueueAction(action);
    },
    recordDetail : function(component, event, helper) {
        var cmpTarget = event.target;
        var hardware = component.get("v.hardware");
        if(hardware != "DESKTOP")
        {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": cmpTarget.getAttribute("id")
            });
            navEvt.fire();
        }
        else
        {
            window.open('/'+cmpTarget.getAttribute("id"))
        }
    },
    showActions : function(component, event, helper)
    {
        var showing = jQuery(event.target).parents('td').find('#actions').css('display');
        jQuery('.slds-dropdown').css('display','none');
        if(showing == 'none')
        {
            jQuery(event.target).parents('td').find('#actions').css('display','block');
        }
        else
        {
            jQuery(event.target).parents('td').find('#actions').css('display','none');
        }
    },
    hideActions : function(component, event, helper)
    {
        jQuery(event.target).parents('td').find('#actions').css('display','none');
    },
    toggleActivity : function(component, event, helper)
    {
        jQuery(event.target).parents('ul').find('.openActivityFilter').css('display','none');
        jQuery(event.target).parents('li').find('a').find('.openActivityFilter').css('display','inline');
        var actionFilter = jQuery(event.target).parents('li').find('a').attr('id');
        var isOpen = (actionFilter.indexOf("Open")>0 );
        var filter = actionFilter.indexOf("my") == 0 ? "my" : "all";
        var AccountId = component.get('v.AccountId');
        var LeadId  = component.get("v.LeadId");
        if(isOpen)
        {
            var action  = component.get("c.getOpenActivities");
            jQuery("#tbodyOpen").hide();
            jQuery("#loadTableOpen").show();
            action.setParams({
                leadId : LeadId,
                accountId : AccountId,
                openActivityFilter : filter
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state == "SUCCESS" && response.getReturnValue().length == 0) 
                {
                    helper.showErrorMessage(component,"No Open Activities Found","Info!!!");
                }
                else if(component.isValid() && state == "SUCCESS") 
                {
                    component.set("v.OpenActivities",response.getReturnValue());
                }
                    else
                    {
                        helper.showErrorMessage(component,"Unexpected Error","Error!!!");
                    }
                
                jQuery("#tbodyOpen").show();
                jQuery("#loadTableOpen").hide();
            });
            $A.enqueueAction(action);
            
        }
        else
        {
            var action  = component.get("c.getActivityHistory");
            action.setParams({
                leadId : LeadId,
                accountId : AccountId,
                activityHistoryFilter : filter
            });
            
            jQuery("#tbodyHistory").hide();
            jQuery("#loadTableHistory").show();
            action.setCallback(this, function(response){
                var state = response.getState();
                
                if(state == "SUCCESS" && response.getReturnValue().length == 0) 
                {
                    helper.showErrorMessage(component,"No Activities History Found","Info!!!");
                }
                else if(component.isValid() && state == "SUCCESS") 
                {
                    component.set("v.ActivitiesHistory",response.getReturnValue());
                }
                    else
                    {
                        helper.showErrorMessage(component,"Unexpected Error","Error!!!");
                    }
                jQuery("#tbodyHistory").show();
                jQuery("#loadTableHistory").hide();
            });
            $A.enqueueAction(action);
        }
        
    },
    sort : function(component, event, helper)
    {
        var colName=jQuery(event.target).parents('th').attr('id');
        var existingSort = jQuery(event.target).parents('tr').find('.sorted').attr('id');
        var OpenActivities = component.get("v.OpenActivities");
        if(colName == existingSort)
        {
            OpenActivities.reverse();
            jQuery(event.target).parents('th').find('.sortImage').toggle();
        }
        else
        {
            jQuery(event.target).parents('tr').find('.sorted').find('.upImage').css('display','block');
            jQuery(event.target).parents('tr').find('.sorted').find('.downImage').css('display','none');
            jQuery(event.target).parents('tr').find('.sorted').removeClass('sorted').addClass('slds-is-sortable');
            OpenActivities.sort(function(a, b)
                                {
                                    if(a[colName]!=undefined && b[colName]!=undefined) 
                                    {
                                        return a[colName]> b[colName] ? 1 : a[colName]< b[colName] ? -1 :0;
                                    }
                                    else if(a[colName]==undefined && b[colName]==undefined)
                                    {
                                        return 0;
                                    }
                                        else if(a[colName]==undefined)
                                        {
                                            return -1;
                                        }
                                            else
                                            {
                                                return 1;
                                            }
                                }); 
            jQuery(event.target).parents('th').addClass('sorted').removeClass('slds-is-sortable');
        }
        component.set("v.OpenActivities",OpenActivities);
    },
    sortHistory : function(component, event, helper)
    {
        var colName=jQuery(event.target).parents('th').attr('id');
        var existingSort = jQuery(event.target).parents('tr').find('.sorted').attr('id');
        var ActivitiesHistory = component.get("v.ActivitiesHistory");
        if(colName == existingSort)
        {
            ActivitiesHistory.reverse();
            jQuery(event.target).parents('th').find('.sortImage').toggle();
        }
        else
        {
            jQuery(event.target).parents('tr').find('.sorted').find('.upImage').css('display','block');
            jQuery(event.target).parents('tr').find('.sorted').find('.downImage').css('display','none');
            jQuery(event.target).parents('tr').find('.sorted').removeClass('sorted').addClass('slds-is-sortable');
            ActivitiesHistory.sort(function(a, b)
                                   {
                                       if(a[colName]!=undefined && b[colName]!=undefined) 
                                       {
                                           return a[colName]> b[colName] ? 1 : a[colName]< b[colName] ? -1 :0;
                                       }
                                       else if(a[colName]==undefined && b[colName]==undefined)
                                       {
                                           return 0;
                                       }
                                           else if(a[colName]==undefined)
                                           {
                                               return -1;
                                           }
                                               else
                                               {
                                                   return 1;
                                               }
                                   }); 
            jQuery(event.target).parents('th').addClass('sorted').removeClass('slds-is-sortable');
        }
        component.set("v.ActivitiesHistory",ActivitiesHistory);
    },
    editActivity : function(component,event,helper)
    {
        var recordId = jQuery(event.target).parents('li').find('a').attr('id');
        var hardware = component.get("v.hardware");
        if(hardware == 'DESKTOP')
        {
            window.open('/'+recordId+'/e?retURL=/apex/CloseMe','_blank');
        }
        else
        {
            var editRecordEvent = $A.get("e.force:editRecord");
            editRecordEvent.setParams({
                "recordId": recordId
            });
            editRecordEvent.fire();
        }
    },
    closeActivity : function(component,event,helper)
    {
        var recordId = jQuery(event.target).parents('li').find('a').attr('id');
        var hardware = component.get("v.hardware");
        if(hardware == 'DESKTOP')
        {
            window.open('/'+recordId+'/e?close=1&retURL=/apex/CloseMe','_blank');
        }
        else
        {
            var editRecordEvent = $A.get("e.force:editRecord");
            editRecordEvent.setParams({
                "recordId": recordId,
                close : 1
            });
            editRecordEvent.fire();
        }
    }
})