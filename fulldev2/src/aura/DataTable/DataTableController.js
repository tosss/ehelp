({
    doInit : function(component, event, helper)
    {
        var action = component.get("c.getCurrentUser");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" ) {
                component.set("v.CurrentUser", response.getReturnValue()); 
                var currentUser = response.getReturnValue();
                var currentUserProfile = currentUser['Profile']['Name'];
                if(currentUserProfile.indexOf('Cobalt Sales Ops') == 0 
                   || currentUserProfile.indexOf('Cobalt Sales Management') == 0 
                   || currentUserProfile.indexOf('Cobalt Sales Account') == 0
                   || currentUserProfile.indexOf('ADPDS') == 0
                  )
                {
                    component.set('v.canFindMatch',true);
                }
            }
            else
            {
                component.set("v.CurrentUser", {});
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
    showLeads : function(component, event, helper)
    {
        var showLeadEvent = component.getEvent("showLeads");
        showLeadEvent.fire();
    },
    sort : function(component, event, helper)
    {
        var colName=jQuery(event.target).parents('th').attr('id');
        var existingSort = jQuery(event.target).parents('tr').find('.sorted').attr('id');
        var leadsList = component.get("v.leadsList");
        if(colName == existingSort)
        {
            leadsList.reverse();
            jQuery(event.target).parents('th').find('.sortImage').toggle();
        }
        else
        {
            jQuery(event.target).parents('tr').find('.sorted').find('.upImage').css("display","block");
            jQuery(event.target).parents('tr').find('.sorted').find('.downImage').css("display","none");
            jQuery(event.target).parents('tr').find('.sorted').removeClass('sorted').addClass('slds-is-sortable');
            leadsList.sort(function(a, b)
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
        component.set("v.leadsList",leadsList);
    },
    selectRow : function(component, event, helper)
    {
        var cmptarget = jQuery(event.target);
        var id = event.target.getAttribute('id');
        var selectedLeads = component.get("v.selectedLeads");
        if(cmptarget.prop( "checked" ))
        {
          /*  var pillName = event.target.getAttribute('name');
            $A.createComponent(
                "c:Pill",
                {id:id,
                 name : pillName},
                function(newPill){
                    if (component.isValid()) {
                        var body = component.find("pill").get("v.body");
                        body.push(newPill);
                        component.find("pill").set("v.body", body);
                        newPill.addHandler("click",component,"c.deselectRow")
                    }
                }
            );*/
            cmptarget.parents('tr').addClass('slds-is-selected');
            selectedLeads.push(id);
            var recordCount = component.get('v.TotalRecordCount');
            if(selectedLeads.length == recordCount)
            {
                jQuery('#SelectAll').prop('checked',true);
            }
        }
        else
        {
            var index=selectedLeads.indexOf(id);
            selectedLeads.splice(index,1);
            cmptarget.parents('tr').removeClass('slds-is-selected');
            jQuery('#SelectAll').prop('checked',false);
            
        }
        component.set("v.selectedLeads",selectedLeads);
    },
    selectAllRows : function(component, event, helper)
    {
        var cmptarget = jQuery(event.target);
        var id = event.target.getAttribute('id');
        var selectedLeads = component.get("v.selectedLeads");
        selectedLeads = [];
        if(cmptarget.prop( "checked" ))
        {
            jQuery('.RowSelector').each(function(element){
               selectedLeads.push(jQuery(this).attr('id'));
            });
            jQuery('.RowSelector').prop('checked',true);
            cmptarget.parents('table').find('tbody').find('tr').addClass('slds-is-selected');
        }
        else
        {
            jQuery('.RowSelector').prop('checked',false);
            cmptarget.parents('table').find('tbody').find('tr').removeClass('slds-is-selected');
        }
        component.set("v.selectedLeads",selectedLeads);
    },
    deselectRow : function(component, event, helper)
    {
        var id = event.target.getAttribute('id');
        jQuery(event.target).parents('a').remove();
        jQuery("#leadsTable").find('input[id="'+id+'"]').prop('checked',false);
        jQuery("#leadsTable").find('input[id="'+id+'"]').parents('tr').removeClass('slds-is-selected');
        var selectedLeads = component.get("v.selectedLeads");
        var index=selectedLeads.indexOf(id);
        selectedLeads.splice(index,1);
        
    },
    showActions : function(component, event, helper)
    {
        var showing = jQuery(event.target).parents('td').find('#actions').css('display');
        jQuery('.slds-dropdown').css("display","none");
        if(showing == 'none')
        {
            jQuery(event.target).parents('td').find('#actions').css("display","block");
        }
        else
        {
            jQuery(event.target).parents('td').find('#actions').css("display","none");
        }
    },
    hideActions : function(component, event, helper)
    {
        jQuery(event.target).parents('td').find('#actions').css("display","none");
    },
    findMatch : function(component, event, helper)
    {
        var leadId = jQuery(event.target).parents('li').find('a').attr('id');
        var showAccoutnandContactEvent = component.getEvent("showFindMatch");
        showAccoutnandContactEvent.setParams({leadId :leadId});
        showAccoutnandContactEvent.fire();
    },
    gotoURL : function (component, event, helper) {
        var ids = jQuery(event.target).parents("li").find("a").attr("id");
        var accountId = ids.split("_");
        var contactId = accountId[1];
        var campaignId = accountId[2];
        accountId = accountId[0];
        window.open('/apex/activityOpportunity?accountId='+accountId+'&contactId='+contactId+'&campaignId='+campaignId+'&retURL=/apex/CloseMe','_blank');
    },
    showEntryOptions : function(component, event, helper)
    {
        jQuery('#recordCount').css('display','block');
    },
    selectEntryOption : function(component, event, helper)
    {
        var entries = jQuery(event.target).parents('li').find('p').html();
        var prevPageNumber = component.get("v.PageNumber");
        var prevRecordCount = component.get("v.RecordCount");
        jQuery('#displayEntries').html('Show '+entries);
        entries = entries.toLowerCase().replace('entries','').trim();
        var newPageNumber = Math.floor(prevPageNumber*prevRecordCount/entries);
        newPageNumber = newPageNumber==0?1:newPageNumber;
        component.set("v.PageNumber",newPageNumber);
        component.set("v.RecordCount",entries);
        jQuery('#recordCount').css("display","none");
        var showLeadEvent = component.getEvent("showLeads");
        showLeadEvent.fire();
    },
    goToFirstPage : function(component, event, helper)
    {
        component.set("v.PageNumber",1);
        var showLeadEvent = component.getEvent("showLeads");
        showLeadEvent.fire();
    },
    goToPrevPage : function(component, event, helper)
    {
        var currentPage  = component.get("v.PageNumber");
        component.set("v.PageNumber",currentPage-1);
        var showLeadEvent = component.getEvent("showLeads");
        showLeadEvent.fire();
    },
    goToNextPage : function(component, event, helper)
    {
        var currentPage  = component.get("v.PageNumber");
        component.set("v.PageNumber",currentPage+1);
        var showLeadEvent = component.getEvent("showLeads");
        showLeadEvent.fire();
    },
    goToLastPage : function(component, event, helper)
    {
        var lastPage  = component.get("v.TotalPages");
        component.set("v.PageNumber",lastPage);
        var showLeadEvent = component.getEvent("showLeads");
        showLeadEvent.fire();
    },
    viewAccountAndContactDetails : function(component,event,helper)
    {
        var accountId = jQuery(event.target).parents('li').find('a').attr('Id');
        var contactId = accountId.split('_')[1];
        var leadId = accountId.split('_')[2];
        var leadName = accountId.split('_')[3];
        accountId = accountId.split('_')[0];
        component.set("v.CurrentAccount",accountId);
        component.set("v.CurrentContact",contactId);
        var showAccoutnandContactEvent = component.getEvent("showAccountandContact");
        showAccoutnandContactEvent.setParams({LeadId :leadId, leadName: leadName});
        showAccoutnandContactEvent.fire();
    }
})