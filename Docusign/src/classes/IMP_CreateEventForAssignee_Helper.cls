/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Responsible for creating, updating, and deleting Events which are related to the project activity
History
10/09/14     Samuel Oberes      Created
------------------------------------------------------------*/

public class IMP_CreateEventForAssignee_Helper {
    
    public static final String FIELD_SERVICE_LITERAL = 'Field Service';

    /*------------------------------------------------------------
      Author:      Samuel Oberes
      Company:     Cloud Sherpas
      Description: Refer to the calling trigger for complete description
      Parameters:  newTriggerMap - accepts the Trigger.newMap values
                   oldTriggerMap - accepts the Trigger.oldMap values
                   newTriggerValueList - accepts the Trigger.new values
      Returns:     Void
      History
      10/09/14     Samuel Oberes        Created
      11/13/14     Samuel Oberes        Added logic to capture error on Event insertion and upsertion
      ------------------------------------------------------------*/
    public static void createOrUpdateAssigneeEvent (Map<Id, Project_Activity__c> newTriggerMap, Map<Id, Project_Activity__c> oldTriggerMap, List<Project_Activity__c> newTriggerValueList) {
        
        // First, let's create 3 lists to insert, update, and delete (respectively), based upon the tested criteria
        list<Event> EventsToInsert = new list<Event>();
        list<Event> EventsToUpdate = new list<Event>();
        list<Event> EventsToDelete = new list<Event>();
        
        // Next, create a map to associate the existing events by Project Id unique identifier. The map will enable us to confirm if an event already
        // exists for the Project Activity, and therefore may only potentially require an update.
        map<Id, Event> ExistingEventsByProjectActivityId = new map<Id, Event>();
        
        // So, we're going to soql query for all events that are not yet deleted WHERE its WhatId matches the unique Ids in our Trigger.New
        if(newTriggerMap != null) 
        {
            list<Event> ProjectActivityExistingEvents = [
                select Id, Subject, WhatId 
                from Event 
                where WhatId IN : newTriggerMap.values()
                and Subject like 'Onsite Visit%'
                and isDeleted = false
            ]; 
            
            // Once we have those existing events, we'll add them along with the found Project Activity unique ID represented by WhatId 
            for(Event e : ProjectActivityExistingEvents) { 
                ExistingEventsByProjectActivityId.put(e.WhatId, e); 
            } 
            
        }
        
        Timezone tz = UserInfo.getTimeZone();
        DateTime dt = DateTime.now();

        Set<Project_Activity__c> projectActivityWithEventsToInsertSet = new Set<Project_Activity__c>();
        Map<Id, Project_Activity__c> eventsIdToUpsertToProjectActivityMap = new Map<Id, Project_Activity__c>();
        
        // getOffset returns milliseconds, dividing by 1000 gets seconds
        //   multiplied by -1 to reverse the automatic timezone offset when converting from Date fields
        Integer tzOffset = ((tz.getOffset(dt)/1000)*-1);
        
        // Iterate through the Project Activities in the Trigger.New, and for each, ensure we have a comparable Trigger.Old value to determine
        // if anything has changed in the Project Activity to drive either an Event Insert, Update, or Delete
        for(Project_Activity__c ProjectActivityNew : newTriggerValueList)
        {
            // If we're working with an existing Project Activity that was updated, find it's old value from the oldmap; otherwise, assign null
            Project_Activity__c ProjectActivityOld = oldTriggerMap != null ? oldTriggerMap.get(ProjectActivityNew.Id) : null;
            
            // If the ProjectActivityOld is null, temporarily instantiate a Project Activity to allow the comparisons between old and new to be performed.
            // The instantiated, empty object will simply have no values, and when compared to the new values, demonstrate that changes have occurred.
            if(ProjectActivityOld == null) { ProjectActivityOld = new Project_Activity__c(); }
            
            // Here is where the first check occurs - do we have an Event already?  Here, we test that the Project Activity Id is not in the map of existing Events by Project Activity Id.
            // We extend the test to see if anything changed.  Therefore, if the overall test is TRUE, we'll create new event.
            if (!ExistingEventsByProjectActivityId.keySet().contains(ProjectActivityNew.Id) // if an Onsite Visit Event does not exist
                && (ProjectActivityNew.CDK_Assignee__c != null && ProjectActivityNew.CDK_Assignee_Role__c !=null && ProjectActivityNew.Planned_Start_Date__c != null) // and all fields not blank
                && (ProjectActivityNew.CDK_Assignee_Role__c != ProjectActivityOld.CDK_Assignee_Role__c || ProjectActivityNew.CDK_Assignee__c != ProjectActivityOld.CDK_Assignee__c || ProjectActivityNew.Planned_Start_Date__c != ProjectActivityOld.Planned_Start_Date__c || ProjectActivityNew.Planned_End_Date__c != ProjectActivityOld.Planned_End_Date__c)
                && (ProjectActivityNew.CDK_Assignee_Role__c == FIELD_SERVICE_LITERAL)) {

                    projectActivityWithEventsToInsertSet.add(ProjectActivityNew);

                    // The above IF clause was TRUE overall - create a new Event.
                    Event e = new Event();
                    e.Subject = 'Onsite Visit: ' + ProjectActivityNew.Description__c;
                    e.ActivityDate = ProjectActivityNew.Planned_Start_Date__c;
                    e.StartDateTime = ProjectActivityNew.Planned_Start_Date__c;
                    e.EndDateTime = ProjectActivityNew.Planned_End_Date__c;
                    e.OwnerId = ProjectActivityNew.CDK_Assignee__c;
                    e.IsAllDayEvent = true;
                    e.WhatId = ProjectActivityNew.Id != null ? ProjectActivityNew.Id : ProjectActivityOld.Id;

                    // Add the Event to the list of events to insert
                    EventsToInsert.add(e);
                }
            // If we've reached this ELSE IF clause, it should mean that prior IF clause was FALSE overall.
            // Here, we exclude the test whether the Project Activity Id was in the existing events by Project Id map
            // If this ELSE IF test proves TRUE overall, we will update the existing Event found in the same map.
            else if ((ProjectActivityNew.CDK_Assignee__c != null && ProjectActivityNew.CDK_Assignee_Role__c !=null && ProjectActivityNew.Planned_Start_Date__c != null) // and all fields are not blank
                     && (ProjectActivityNew.CDK_Assignee__c != ProjectActivityOld.CDK_Assignee__c || ProjectActivityNew.Planned_Start_Date__c != ProjectActivityOld.Planned_Start_Date__c || ProjectActivityNew.Planned_End_Date__c != ProjectActivityOld.Planned_End_Date__c)
                     && (ProjectActivityNew.CDK_Assignee_Role__c == FIELD_SERVICE_LITERAL)) {
                         
                         // The above ELSE IF clause was TRUE overall - let's update the existing Event.
                         //First, let's get the existing event from the map
                         Event e = ExistingEventsByProjectActivityId.get(ProjectActivityNew.Id);
                         
                         // Next, let's update the found Event's values with the updated values from the Project Activity
                         e.Subject = 'Onsite Visit: ' + ProjectActivityNew.Description__c;
                         e.ActivityDate = ProjectActivityNew.Planned_Start_Date__c;
                         e.StartDateTime = ProjectActivityNew.Planned_Start_Date__c;
                         e.EndDateTime = ProjectActivityNew.Planned_End_Date__c;
                         e.OwnerId = ProjectActivityNew.CDK_Assignee__c;
                         
                         // Add the Event to the list of events to update
                         EventsToUpdate.add(e);

                         eventsIdToUpsertToProjectActivityMap.put(e.Id, ProjectActivityNew);
                     }
            // Finally, let's identify existing Events that should be deleted,
            // based upon the role having changed from the its previous value, and no longer being Field Service.
            else if ((ProjectActivityOld.CDK_Assignee__c != NULL && ProjectActivityNew.CDK_Assignee_Role__c != FIELD_SERVICE_LITERAL)
                     && (ProjectActivityOld.CDK_Assignee_Role__c == FIELD_SERVICE_LITERAL)) {
                         
                         
                         // update activity with details of visit
                         if (ExistingEventsByProjectActivityId.size() > 0) {
                             Event e = ExistingEventsByProjectActivityId.get(ProjectActivityNew.Id);
                             
                             // Add the Event to the list of events to delete
                             EventsToDelete.add(e);
                         }
                     }
            
        }
        
        // -----------------------------------------------------------------------------------------------------------------
        // INIT
        String errorMessage;

        // EVENT INSERTION -- Captures event insertion error, then flags an error on the related project activity
        Boolean foundUnsuccessfulInsertion = false;
        errorMessage = '';
        Database.SaveResult[] srl = Database.insert(EventsToInsert, false);
        for (Database.SaveResult sr : srl) {
            if (!sr.isSuccess()) {
                foundUnsuccessfulInsertion = true;
                errorMessage = sr.getErrors()[0].getMessage();
                break;
            }
        }
        if (foundUnsuccessfulInsertion) {
            List<Event> successfullySavedEventsList = [SELECT WhatId FROM Event WHERE WhatId IN :projectActivityWithEventsToInsertSet];
            Set<Id> successfullySavedEventsWhatIDsSet = new Set<Id>();
            for (Event e : successfullySavedEventsList) {
                successfullySavedEventsWhatIDsSet.add(e.WhatId);
            }
            for (Project_Activity__c p : projectActivityWithEventsToInsertSet) {
                if (!successfullySavedEventsWhatIDsSet.contains(p.Id)) {
                    p.addError(errorMessage);
                }
            }
        }

        // EVENT UPSERTION -- Captures event upsertion error, then flags an error on the related project activity
        Boolean foundUnsuccessfulUpsertion = false;
        errorMessage = '';
        Database.UpsertResult[] url = Database.upsert(EventsToUpdate, false);
        Set<Id> savedEventIds = new Set<Id>();
        for (Database.UpsertResult ur : url) {
            if (ur.isSuccess()) {
                savedEventIds.add(ur.getId());
            } else {
                foundUnsuccessfulUpsertion = true;
                errorMessage = ur.getErrors()[0].getMessage();
            }
        }
        if (foundUnsuccessfulUpsertion) {
            for (Event e : EventsToUpdate) {
                if (!savedEventIds.contains(e.Id)) {
                    Project_Activity__c pa = eventsIdToUpsertToProjectActivityMap.get(e.Id);
                    pa.addError(errorMessage);
                }
            }
        }

        if(EventsToDelete != null && ! EventsToDelete.isEmpty()){
            delete EventsToDelete;
        } 

    }
    
}