({
    fetchRecords: function(component, event, helper)
    {
        helper.showSpinner(component, event, helper);
        var action=component.get("c.fetchRecords");
        var leadId=component.get("v.leadId");
        var accountId=component.get("v.accountId");
        var contactId=component.get("v.contactId");
        
        action.setParams({
            leadId : leadId,
            accountId : accountId,
            contactId : contactId
        });
        
        action.setCallback(this, function(response)
        {
            var state=response.getState();
            
            if(component.isValid() && state==="SUCCESS")
            {
                component.set("v.recWrapper", response.getReturnValue());
                console.log(response.getReturnValue());
                
                component.find("reminderTimesMap").set("v.options", helper.populateLists(component, event, helper, component.get("v.recWrapper.reminderTimesMap")));
                
                var appEvent=$A.get("e.c:initializeValues");
                appEvent.fire();
                helper.hideSpinner(component, event, helper);
                
                if(component.get("v.hardware")=="DESKTOP")
                {
                    console.clear();
                    var taskResult=sforce.connection.describeLayout('Task');
                    var taskRecordTypeName=component.get("v.recWrapper.taskRecordTypeName");
                    component.find("taskSubjectOptionsMap").set("v.options", helper.populatePicklistsByRecordType(component, event, helper, taskRecordTypeName, taskResult, 'Subject', component.get("v.recWrapper.newTask.Subject")));
                    component.find("taskTypeMap").set("v.options", helper.populatePicklistsByRecordType(component, event, helper, taskRecordTypeName, taskResult, 'Type', component.get("v.recWrapper.newTask.Type")));
                    
                    var eventResult=sforce.connection.describeLayout('Event');
                    var eventRecordTypeName=component.get("v.recWrapper.eventRecordTypeName");
                    component.find("eventSubjectOptionsMap").set("v.options", helper.populatePicklistsByRecordType(component, event, helper, eventRecordTypeName, eventResult, 'Subject', component.get("v.recWrapper.newEvent.Subject")));
                    component.find("eventTypeMap").set("v.options", helper.populatePicklistsByRecordType(component, event, helper, eventRecordTypeName, eventResult, 'Type', component.get("v.recWrapper.newEvent.Type")));
                    component.find("eventShowAsMap").set("v.options", helper.populatePicklistsByRecordType(component, event, helper, eventRecordTypeName, eventResult, 'ShowAs', component.get("v.recWrapper.newEvent.ShowAs")));
                }
            }
            else
            {
                component.set("v.recWrapper", null);
                helper.hideSpinner(component, event, helper);
            }
        });
        
        $A.enqueueAction(action);
    },
    populatePicklistsByRecordType: function(component, event, helper, recordTypeName, result, fieldAPIName, fieldValue)
    {
        var picklistsOptionsArray=new Array();
        
        if(fieldAPIName=='Type' || fieldAPIName=='ShowAs')
        {
            var picklistOption=new Object();
            picklistOption.class="optionClass";
            picklistOption.label='--None--';
            picklistOption.value='';
            picklistsOptionsArray.push(picklistOption);
        }
        
        var defaultSelected='false';
        if(fieldValue!=null)
        {
            var picklistOption=new Object();
            picklistOption.class="optionClass";
            picklistOption.label=fieldValue;
            picklistOption.value=fieldValue;
            picklistOption.selected='true';
            defaultSelected='true';
            picklistsOptionsArray.push(picklistOption);
        }
        
        for(var i in result.recordTypeMappings)
        {
            if(recordTypeName==result.recordTypeMappings[i].name)
            {
                for(var j in result.recordTypeMappings[i].picklistsForRecordType)
                {
                    if(fieldAPIName==result.recordTypeMappings[i].picklistsForRecordType[j].picklistName)
                    {
                        for(var k in result.recordTypeMappings[i].picklistsForRecordType[j].picklistValues)
                        {
                            if(fieldValue!=result.recordTypeMappings[i].picklistsForRecordType[j].picklistValues[k].value 
                               && result.recordTypeMappings[i].picklistsForRecordType[j].picklistValues[k].active=='true')
                            {
                                var picklistOption=new Object();
                                picklistOption.class="optionClass";
                                picklistOption.label=result.recordTypeMappings[i].picklistsForRecordType[j].picklistValues[k].label;
                                picklistOption.value=result.recordTypeMappings[i].picklistsForRecordType[j].picklistValues[k].value;
                                if(defaultSelected=='false' && result.recordTypeMappings[i].picklistsForRecordType[j].picklistValues[k].defaultValue=='true')
                                {
                                    picklistOption.selected='true';
                                }
                                
                                picklistsOptionsArray.push(picklistOption);
                            }
                        }
                        break;
                    }
                }
                break;
            }
        }
        
        return picklistsOptionsArray;
    },
    populateLists: function(component, event, helper, optionsMap)
    {
        var optionsArray=new Array();
        
        for(var i in optionsMap)
        {
            var subjectOption=new Object();
            subjectOption.class="optionClass";
            subjectOption.label=i;
            subjectOption.value=optionsMap[i];
            optionsArray.push(subjectOption);
        }
        
        return optionsArray;
    },
    saveDetails: function(component, event, helper)
    {
        helper.showSpinner(component, event, helper);
        var action=component.get("c.saveDetails");
        var recWrapperWithChanges=JSON.stringify(component.get("v.recWrapper"));
        
        action.setParams({
            recWrapperWithChanges : recWrapperWithChanges
        });
        
        action.setCallback(this, function(response)
        {
            var state=response.getState();
            
            if(component.isValid() && state==="SUCCESS")
            {
                helper.hideSpinner(component, event, helper);
            }
            else
            {
                helper.hideSpinner(component, event, helper);
            }
        });
        
        helper.validateUserInputs(component, event, helper);
        
        $A.enqueueAction(action);
    },
    showHideEventSectionAndFlipButtons: function(component, event, helper)
    {
        var showEventSection=component.get("v.recWrapper.showEventSection");
        component.set("v.recWrapper.showEventSection", !showEventSection);
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
    showSpinner: function(component, event, helper)
    {
        var spinnerActivityOpportunity=component.find("spinnerActivityOpportunity");
        $A.util.removeClass(spinnerActivityOpportunity, "slds-hide");
    },
    hideSpinner: function(component, event, helper)
    {
        var spinnerActivityOpportunity=component.find("spinnerActivityOpportunity");
        $A.util.addClass(spinnerActivityOpportunity, "slds-hide");
    },
    validateUserInputs: function(component, event, helper)
    {
        var validInputs=true;
        var allErrorMessages='';
        //Assigned To Check for new Task.
        if(component.get("v.recWrapper.newTask.OwnerId")==null || component.get("v.recWrapper.newTask.OwnerId")=='')
        {
            allErrorMessages="Please enter a valid Assigned To value for the Completed Activity Information section.";
            var taskAssignedTo=component.find("taskAssignedTo");
            $A.util.addClass(taskAssignedTo, "is-required slds-has-error");
            validInputs=false;
        }
        else
        {
            var taskAssignedTo=component.find("taskAssignedTo");
            $A.util.removeClass(taskAssignedTo, "is-required slds-has-error");
        }
        
        //Subject Check for new Task.
        if(component.get("v.recWrapper.newTask.Subject")==null || component.get("v.recWrapper.newTask.Subject")=='')
        {
            allErrorMessages+=((allErrorMessages=='')? "Please enter a valid Subject value for the Completed Activity Information section." : "\nPlease enter a valid Subject value for the Completed Activity Information section.");
            var taskSubjectOptionsMapDiv=component.find("taskSubjectOptionsMapDiv");
            $A.util.addClass(taskSubjectOptionsMapDiv, "is-required slds-has-error");
            validInputs=false;
        }
        else
        {
            var taskSubjectOptionsMapDiv=component.find("taskSubjectOptionsMapDiv");
            $A.util.removeClass(taskSubjectOptionsMapDiv, "is-required slds-has-error");
        }
        
        //Name Check for new Task.
        if(component.get("v.recWrapper.newTask.WhoId")==null || component.get("v.recWrapper.newTask.WhoId")=='')
        {
            allErrorMessages+=((allErrorMessages=='')? "Please enter a valid Name value for the Completed Activity Information section." : "\nPlease enter a valid Name value for the Completed Activity Information section.");
            var taskWhoId=component.find("taskWhoId");
            $A.util.addClass(taskWhoId, "is-required slds-has-error");
            validInputs=false;
        }
        else
        {
            var taskWhoId=component.find("taskWhoId");
            $A.util.removeClass(taskWhoId, "is-required slds-has-error");
        }
        
        //Assigned To Check for new Event.
        if(component.get("v.recWrapper.showEventSection")==true && component.get("v.recWrapper.newEvent.OwnerId")==null || component.get("v.recWrapper.newEvent.OwnerId")=='')
        {
            allErrorMessages+=((allErrorMessages=='')? "Please enter a valid Assigned To value for the Campaign - Account Status section." : "\nPlease enter a valid Assigned To value for the Campaign - Account Status section.");
            var eventAssignedTo=component.find("eventAssignedTo");
            $A.util.addClass(eventAssignedTo, "is-required slds-has-error");
            validInputs=false;
        }
        else
        {
            var eventAssignedTo=component.find("eventAssignedTo");
            $A.util.removeClass(eventAssignedTo, "is-required slds-has-error");
        }
        
        //Subject Check for new Event.
        if(component.get("v.recWrapper.showEventSection")==true && component.get("v.recWrapper.newEvent.Subject")==null || component.get("v.recWrapper.newEvent.Subject")=='')
        {
            allErrorMessages+=((allErrorMessages=='')? "Please enter a valid Subject value for the Campaign - Account Status section." : "\nPlease enter a valid Subject value for the Campaign - Account Status section.");
            var eventSubjectOptionsMapDiv=component.find("eventSubjectOptionsMapDiv");
            $A.util.addClass(eventSubjectOptionsMapDiv, "is-required slds-has-error");
            validInputs=false;
        }
        else
        {
            var eventSubjectOptionsMapDiv=component.find("eventSubjectOptionsMapDiv");
            $A.util.removeClass(eventSubjectOptionsMapDiv, "is-required slds-has-error");
        }
        
        //If End Date Time is greater than Start Date Time.
        if(component.get("v.recWrapper.showEventSection")==true && component.get("v.recWrapper.newEvent.StartDateTime")!=null 
           && component.get("v.recWrapper.newEvent.EndDateTime")!=null
           && component.get("v.recWrapper.newEvent.StartDateTime")>component.get("v.recWrapper.newEvent.EndDateTime"))
        {
            allErrorMessages+=((allErrorMessages=='')? "Start Date/Time cannot be later than End Date/Time." : "\nStart Date/Time cannot be later than End Date/Time.");
            validInputs=false;
        }
        
        if(allErrorMessages!='')
        {
            component.set("v.errorMessageValue", allErrorMessages);
            helper.showErrorMessage(component, event, helper);
        }
        else
        {
            component.set("v.errorMessageValue", '');
            helper.hideErrorMessage(component, event, helper);
        }
    },
    showErrorMessage: function(component, event, helper)
    {
        var errorMessage=component.find("errorMessage");
        
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
                //Replace div body with the dynamic component.
                errorMessage.set("v.body", outputText);
            }
        });
        
        $A.util.removeClass(errorMessage, "slds-hide");
        
        if(component.get("v.hardware")!="DESKTOP")
        {
            var toastEvent=$A.get("e.force:showToast");
            toastEvent.setParams({
                "message": "Please scroll to top of the page.",
                "duration": 5000
            });
            toastEvent.fire();
        }
    },
    hideErrorMessage: function(component, event, helper)
    {
        var errorMessage=component.find("errorMessage");
        $A.util.addClass(errorMessage, "slds-hide");
    }
})