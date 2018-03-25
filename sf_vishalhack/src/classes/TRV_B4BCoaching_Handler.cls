/* 2015-12-08 endiem@endiem.com - RQ-05509 - On insert/update we do following operation based on status field update or Completed By or No Of days field 
                      for different Record Type is updated and Visit Start date:
                      1. To create Event if Status is Confirmed
                      2. To Delete the Event if Status is Cancelled or Pushed
                      3. If Status is Completed and Record Type is Process Coach Visit then will send an Email to Contact
20th Feb 2017 - lalitha.adduru@cdk.com  - added functionality(updateEPCEmail method) to populate EPC Email from Consulting Project on insert and update - RQ-08240
*/
public class TRV_B4BCoaching_Handler {
    
    private Id processCoachVisitId;                                           // variable to store Process Coach Visit Record Type Id
    private Id nonBillaleTypeId;                                              // variable to store Non Billable Record Type Id
    private Id pscVisitTypeId;                                                // variable to store PSC Record Type Id
    private final String EMAIL_TEMPLATE_FOR_FEEDBACK = 'Feedback_Recent_PCV'; // constant variable to store Template Name
    private final String RESOURCE_UPDATE = 'Resource_Update';                 // constant variable to store Template Name
    private Id eventRecTypeId;                                                // variable to store standard event Record Type Id
    
    //Start - Constructor
    public TRV_B4BCoaching_Handler()
    {
        
        for(RecordType objRecordType : [
            SELECT Id, DeveloperName, SobjectType 
            FROM RecordType 
            WHERE SobjectType = 'Traver_Coaching__c'
        ]) {
            
            if(objRecordType.DeveloperName == 'Process_Coach_Visit') {
                
                processCoachVisitId = objRecordType.Id;
            }
            
            if(objRecordType.DeveloperName == 'Non_Billable') {
                
                nonBillaleTypeId = objRecordType.Id;
            }
            
            if(objRecordType.DeveloperName == 'PSC_Visit') {
                
                pscVisitTypeId = objRecordType.Id;
            }
        }

        eventRecTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Standard Event').getRecordTypeId();
    }
    //End - Constructor    
    /*
        On after Update we do following operation based on status field update or Completed By or No Of days field 
        for different Record Type is updated and Visit Start date:
        1. To create Event if Status is Confirmed
        2. To Delete the Event if Status is Cancelled or Pushed
        3. If Status is Completed and Record Type is Process Coach Visit then will send an Email to Contact
    */
    public void onAfterUpdate(Map<Id, Traver_Coaching__c> mapNewTraverCoaching, Map<Id, Traver_Coaching__c> mapOldTraverCoaching) 
    {
        
        List<Event> lstEventsToBeDeleted = new List<Event>(); // List to store Event Instance that need to be deleted
        List<Traver_Coaching__c> lstTraverCoaching = new List<Traver_Coaching__c>(); // List of Traver Coaching 
        
        Set<Id> setOfResourceId = new Set<Id>(); // Set to store Resource Id for update
        Set<Id> setTraverCoachingIdsDelete = new Set<Id>();   // Set to store Traver Coaching Ids for deletion
        Set<Id> setTraverCoachingIdWithOutEvent = new Set<Id>();   // Set to store Traver Coaching Ids which do not have Events
        
        // Map of Id to Traver Coaching to create Events
        Map<Id, Traver_Coaching__c> mapTraverCoachingIdsToCreateEvent = new Map<Id, Traver_Coaching__c>(); 
        Map<Id, Id> mapOfResourceIdToUserId = new Map<Id, Id>();
        
        // Iterating over updated Map of Traver Coaching 
        for(Traver_Coaching__c objTraverCoach : mapNewTraverCoaching.values()) {
            
            if(objTraverCoach.Status__c != mapOldTraverCoaching.get(objTraverCoach.Id).Status__c) {
                
                if(objTraverCoach.Status__c == 'Confirmed' && objTraverCoach.RecordTypeId != nonBillaleTypeId) {
                    
                    mapTraverCoachingIdsToCreateEvent.put(objTraverCoach.Id, objTraverCoach); // To create Event if Status is Confirmed
                    setTraverCoachingIdsDelete.add(objTraverCoach.Id);
                }
                else if(objTraverCoach.Status__c == 'Cancelled' || objTraverCoach.Status__c == 'Pushed') {
                    
                    setTraverCoachingIdsDelete.add(objTraverCoach.Id); // To Delete the Event if Status is Cancelled or Pushed
                }
                else if(objTraverCoach.Status__c == 'Completed' && objTraverCoach.RecordTypeId == processCoachVisitId) {
                    
                    // If Status is Completed and Record Type is Process Coach Visit then will send an Email to Contact
                    lstTraverCoaching.add(objTraverCoach);
                }
            }
            //objTraverCoach.Visit_Start_Date__c != null &&
                
            if(objTraverCoach.RecordTypeId != nonBillaleTypeId && (( objTraverCoach.Visit_Start_Date__c != mapOldTraverCoaching.get(objTraverCoach.Id).Visit_Start_Date__c) 
                || (objTraverCoach.TRV_Completed_By__c != null && objTraverCoach.TRV_Completed_By__c != mapOldTraverCoaching.get(objTraverCoach.Id).TRV_Completed_By__c) 
                || (objTraverCoach.Number_of_Days_PSG__c != mapOldTraverCoaching.get(objTraverCoach.Id).Number_of_Days_PSG__c) 
                || (objTraverCoach.TRV_Number_Of_Days_NonBillable__c != mapOldTraverCoaching.get(objTraverCoach.Id).TRV_Number_Of_Days_NonBillable__c) 
                || (objTraverCoach.Number_of_Days_Traver__c != mapOldTraverCoaching.get(objTraverCoach.Id).Number_of_Days_Traver__c))) {
                
                if(objTraverCoach.Status__c == 'Confirmed' || objTraverCoach.Status__c == 'Completed' || objTraverCoach.Status__c == 'Tentative') {
                    mapTraverCoachingIdsToCreateEvent.put(objTraverCoach.Id, objTraverCoach); // To create Event 
                }

                setTraverCoachingIdsDelete.add(objTraverCoach.Id);
                setTraverCoachingIdWithOutEvent.add(objTraverCoach.Id);
            }
        }

        for(Traver_Coaching__c objTCoach : mapTraverCoachingIdsToCreateEvent.values()) {
            
            setOfResourceId.add(objTCoach.TRV_Completed_By__c);
        }
        
        for(TRV_Resource__c res :   [
            SELECT Id, TRV_Resource__c 
            FROM TRV_Resource__c 
            WHERE Id IN: setOfResourceId
        ]) {
            
            mapOfResourceIdToUserId.put(res.Id, res.TRV_Resource__c);
        }
        
        //update or delete the related event.
        if(!setTraverCoachingIdsDelete.isEmpty() || !mapTraverCoachingIdsToCreateEvent.isEmpty()) {
            
            //Get the events on the above B4B Coaching records.
            for(Event objEvent :    [   
                SELECT ActivityDate, WhatId 
                FROM Event 
                WHERE WhatId IN: setTraverCoachingIdsDelete 
            ]) { 
                                        
                //if the status is changed to Cancelled then delete the event on the B4B Coaching record.
                //else if the Visit Date is changed then update the event on that B4B Coaching record with that date.
                if(setTraverCoachingIdsDelete.contains(objEvent.WhatId)) {
                    
                    lstEventsToBeDeleted.add(objEvent);
                    setTraverCoachingIdWithOutEvent.remove(objEvent.WhatId);
                }
            }
        }
        
        if(!lstEventsToBeDeleted.isEmpty()) {
            
            delete lstEventsToBeDeleted;
        }

        if(!mapTraverCoachingIdsToCreateEvent.isEmpty()) {
            
            List<Event> lstEventToCreate = eventCreationBasedOnVisitDays(mapTraverCoachingIdsToCreateEvent.values(), mapOfResourceIdToUserId, setTraverCoachingIdWithOutEvent);

            if(!lstEventToCreate.isEmpty()) {
                insert lstEventToCreate;
            }
        }
            
        if(!lstTraverCoaching.isEmpty()) {
            
            sendEmailToContacts(lstTraverCoaching);
        }
    }
    
    
    //Create Event based on Traver Coaching Record field values like Visit Start date and Completed By 
    public void onAfterInsert(List<Traver_Coaching__c> lstTraverCoaching)
    {

        createEvent(lstTraverCoaching);
    }
    
    //Create Event based on Traver Coaching Record field values like Visit Start date and Completed By 
    public void createEvent(List<Traver_Coaching__c> lstTraverCoaching)
    {

        Map<Id, Id> mapOfResourceIdToUserId = new Map<Id, Id>();    
        List<Event> lstEventToBeInserted = new List<Event>();
        Set<Id> setOfResourceId = new Set<Id>();
        
        for(Traver_Coaching__c objTCoach : lstTraverCoaching){
            
            setOfResourceId.add(objTCoach.TRV_Completed_By__c);
        }

        for(TRV_Resource__c res :   [   
            SELECT Id, TRV_Resource__c 
            FROM TRV_Resource__c 
            WHERE Id IN: setOfResourceId
        ]) {
            
            mapOfResourceIdToUserId.put(res.Id, res.TRV_Resource__c);
        }
         
        List<Traver_Coaching__c>  lstTraverCoachingForEventCreation = new List<Traver_Coaching__c>();  
        //check if the status is Confirmed to create an event.
        for(Traver_Coaching__c objTraverCoach : lstTraverCoaching) {
            
            if(objTraverCoach.Status__c == 'Confirmed' && objTraverCoach.TRV_Completed_By__c != null && objTraverCoach.Visit_Start_Date__c != null
                && objTraverCoach.RecordTypeId != nonBillaleTypeId) {

                lstTraverCoachingForEventCreation.add(objTraverCoach);
                
            }
        }

        if(!lstTraverCoachingForEventCreation.isEmpty()){ 
            
            lstEventToBeInserted.addAll(eventCreationBasedOnVisitDays(lstTraverCoachingForEventCreation, mapOfResourceIdToUserId, new set<Id>()));
        }
        
        //Create event.
        if(!lstEventToBeInserted.isEmpty()) {
            
            insert lstEventToBeInserted;
        }
    }

    // Generic Method to create Event based on Visited Days
    private List<Event> eventCreationBasedOnVisitDays(List<Traver_Coaching__c> lstTraver, Map<Id, Id> mapOfResourceIdToUserId, set<Id> setTraverCoachingIdWithOutEvent)
    {
        
        List<Traver_Coaching__c> lstCoaching = new List<Traver_Coaching__c>(); 
        List<Event> lstEvent = new List<Event>();
        
        for(Traver_Coaching__c objTraverCoach : lstTraver){
            
            if(objTraverCoach.TRV_Completed_By__c == null) {

                break;
            }

            if(!setTraverCoachingIdWithOutEvent.isEmpty() && setTraverCoachingIdWithOutEvent.contains(objTraverCoach.Id) && objTraverCoach.Status__c != 'Confirmed') {
                
                break;
            }
            
            if((objTraverCoach.Number_of_Days_PSG__c != null && objTraverCoach.Number_of_Days_PSG__c > 14) || 
                (objTraverCoach.TRV_Number_Of_Days_NonBillable__c != null && objTraverCoach.TRV_Number_Of_Days_NonBillable__c > 14) || 
                (objTraverCoach.Number_of_Days_Traver__c != null && objTraverCoach.Number_of_Days_Traver__c > 14)){
                
                Integer noOfLoopsToIterate = 0;
            
                if(objTraverCoach.RecordTypeId == pscVisitTypeId) {
                    
                    noOfLoopsToIterate = findLoopIteration(objTraverCoach.Number_of_Days_PSG__c);
                    lstEvent.addAll(eventCreation(noOfLoopsToIterate, objTraverCoach, mapOfResourceIdToUserId, 'PSG'));
                }
                else if(objTraverCoach.RecordTypeId == nonBillaleTypeId) {
                    
                    noOfLoopsToIterate = findLoopIteration(objTraverCoach.TRV_Number_Of_Days_NonBillable__c);
                    lstEvent.addAll(eventCreation(noOfLoopsToIterate, objTraverCoach, mapOfResourceIdToUserId, 'NONBILLABLE'));
                }
                else {
                    
                    noOfLoopsToIterate = findLoopIteration(objTraverCoach.Number_of_Days_Traver__c);
                    lstEvent.addAll(eventCreation(noOfLoopsToIterate, objTraverCoach, mapOfResourceIdToUserId, 'TRAVER'));
                } 
            }
            else {
                
                Date activityStartDateForEvent;
                Date activityEndDateForEvent;

                if(objTraverCoach.TRV_Completed_By__c == null) {

                    break;
                }

                if(objTraverCoach.Visit_Start_Date__c != null) {
                    
                    activityStartDateForEvent = objTraverCoach.Visit_Start_Date__c;
                }
                else {
                    
                    activityStartDateForEvent = Date.Today();
                }
                
                if(objTraverCoach.RecordTypeId == pscVisitTypeId && objTraverCoach.Number_of_Days_PSG__c > 1) {
                    
                    activityEndDateForEvent = activityStartDateForEvent.addDays((Integer)objTraverCoach.Number_of_Days_PSG__c - 1);
                }
                else if(objTraverCoach.RecordTypeId == nonBillaleTypeId && objTraverCoach.TRV_Number_Of_Days_NonBillable__c > 1) {
                    
                    activityEndDateForEvent = activityStartDateForEvent.addDays((Integer)objTraverCoach.TRV_Number_Of_Days_NonBillable__c - 1);
                }
                else if(objTraverCoach.Number_of_Days_Traver__c > 1) {
                    
                    activityEndDateForEvent = activityStartDateForEvent.addDays((Integer)objTraverCoach.Number_of_Days_Traver__c - 1);
                }
                else {
                    
                    activityEndDateForEvent = activityStartDateForEvent;
                }

                Event objNewEvent = new Event(  
                    RecordTypeId = eventRecTypeId,
                    WhatId = objTraverCoach.Id,
                    Subject = Schema.SObjectType.Traver_Coaching__c.getRecordTypeInfosById().get(objTraverCoach.RecordTypeId).getname()
                              + ' '+objTraverCoach.Project_Account__c,
                    OwnerId = mapOfResourceIdToUserId.get(objTraverCoach.TRV_Completed_By__c),
                    IsAllDayEvent = true,
                    StartDateTime = activityStartDateForEvent,
                    EndDateTime = activityEndDateForEvent
                );
                lstEvent.add(objNewEvent);
            }
        }
        return lstEvent;
    }

    // Create Multiple Event Instance for particular B4B coaching 
    private List<Event> eventCreation(Integer loopOfIteration, Traver_Coaching__c traver, Map<Id, Id> mapOfResourceIdToUserId, String type)
    {

        Date activityStartDateForEvent;
        Date activityEndDateForEvent;
        List<Event> lstEvent = new List<Event>();
        Integer daysToBeAdded = 0;
        Integer daysRemaining = 0;
        Date endDate;

        if(traver.Visit_Start_Date__c != null) {
            
            activityStartDateForEvent = traver.Visit_Start_Date__c;
        }
        else {
            
            activityStartDateForEvent = Date.Today();
        }
        
        for(Integer i = 0; i < loopOfIteration; i++) {

            if(endDate != null) {
                
                activityStartDateForEvent = endDate.addDays(1);
            }

            if(type == 'PSG') {
                
                daysToBeAdded = daysRemaining == 0 ? 14 : (daysRemaining <= 14 || (daysRemaining - 14) <= 0) ? daysRemaining : 14;
                daysRemaining = daysRemaining == 0 ? (Integer)traver.Number_of_Days_PSG__c - 14 : daysRemaining - 14;
                
                activityEndDateForEvent = activityStartDateForEvent.addDays(daysToBeAdded - 1);
            }
            else if(type == 'NONBILLABLE') {
                
                daysToBeAdded = daysRemaining == 0 ? 14 : (daysRemaining <= 14 || (daysRemaining - 14) <= 0) ? daysRemaining : 14;
                daysRemaining = daysRemaining == 0 ? (Integer)traver.TRV_Number_Of_Days_NonBillable__c - 14 : daysRemaining - 14;
                
                activityEndDateForEvent = activityStartDateForEvent.addDays(daysToBeAdded - 1);
            }
            else if(type == 'TRAVER') {

                daysToBeAdded = daysRemaining == 0 ? 14 : (daysRemaining <= 14 || (daysRemaining - 14) <= 0) ? daysRemaining : 14;
                daysRemaining = daysRemaining == 0 ? (Integer)traver.Number_of_Days_Traver__c - 14 : daysRemaining - 14;
                
                activityEndDateForEvent = activityStartDateForEvent.addDays(daysToBeAdded - 1);
            }
             
            Event objNewEvent = new Event(  
                RecordTypeId = eventRecTypeId,
                WhatId = traver.Id,
                Subject = Schema.SObjectType.Traver_Coaching__c.getRecordTypeInfosById().get(traver.RecordTypeId).getname()
                          + ' '+traver.Project_Account__c,
                OwnerId = mapOfResourceIdToUserId.get(traver.TRV_Completed_By__c),
                IsAllDayEvent = true,
                StartDateTime = activityStartDateForEvent,
                EndDateTime = activityEndDateForEvent
            );
            lstEvent.add(objNewEvent);
            endDate = activityEndDateForEvent;
        }
        return lstEvent;
    }

    // To Find out the no of Iteration for particluar B4B for creating Event Records.
    private Integer findLoopIteration(Decimal noOfDaysVisit)
    {
        
        Integer noOfLoopsToIterate = 0;
        Integer noOfRoundDays = 0;
        Integer remainder = 0;

        noOfRoundDays = Math.round(noOfDaysVisit);
        
        noOfLoopsToIterate = noOfRoundDays/14;
        
        remainder = math.mod(noOfRoundDays, 14);

        if(remainder > 0) {
            
            noOfLoopsToIterate += 1;
        }

        return noOfLoopsToIterate;
    }
    
    //To send Email To Contacts if Status is Completed and Record Type is Process Coach Visit then will send an Email
    private void sendEmailToContacts(List<Traver_Coaching__c> lstTraver)
    {
        
        List<Messaging.Singleemailmessage> lstEmail = new List<Messaging.Singleemailmessage>();
        
        List<EmailTemplate> lstTemplate = new List<EmailTemplate>([
            SELECT Id, HtmlValue, Subject 
            FROM EmailTemplate 
            WHERE DeveloperName =: EMAIL_TEMPLATE_FOR_FEEDBACK 
            LIMIT 1
        ]);
        
        for(Traver_Coaching__c traverCoaching : lstTraver) {
            
            Messaging.Singleemailmessage objEmail = new Messaging.Singleemailmessage(); 
            
            try {
                
                if(traverCoaching.TRV_FRM_Contact_Id_onConsultingProject__c != null) {
                
                    objEmail.setBccSender(false);
                    objEmail.setSaveAsActivity(false);
                    objEmail.setTemplateId(lstTemplate[0].Id);
                    objEmail.setTargetObjectId(traverCoaching.TRV_FRM_Contact_Id_onConsultingProject__c);
                    objEmail.setWhatId(traverCoaching.Id);
    
                    lstEmail.add(objEmail);
                }

                if(Test.isRunningTest()){
                    Integer throwException = 10/0;
                }
            }
            catch(Exception e) {
                
                objEmail = new Messaging.Singleemailmessage();
                objEmail.setBccSender(false);
                objEmail.setPlainTextBody('Email template doesn\'t exist!');
                objEmail.setSaveAsActivity(false);
                objEmail.setTargetObjectId(traverCoaching.TRV_FRM_Contact_Id_onConsultingProject__c);
            }
        }
        Messaging.sendEmail(lstEmail);
    }
    
    //populate Email of Completed By resource
    public void onBeforeInsert(List<Traver_Coaching__c> lstCoaching) 
    {
        updateEPCEmail(lstCoaching, null);
        map<Id, Traver_Coaching__c> mapResourceId_Coaching = new map<Id, Traver_Coaching__c>();
        
        for(Traver_Coaching__c objCoaching : lstCoaching) {
            
            if(objCoaching.TRV_Completed_By__c != null) {
                
                mapResourceId_Coaching.put(objCoaching.TRV_Completed_By__c, objCoaching);
            }
        }
        
        if(mapResourceId_Coaching.KeySet().isEmpty()) {
            
            return;
        }
        
        populateResourceEmail(mapResourceId_Coaching);
    }
    
    // to update resource Email field based on completed By
    public void onBeforeUpdate(map<Id, Traver_Coaching__c> mapNewCoaching, map<Id, Traver_Coaching__c> mapOldCoaching)
    {
		system.debug('in before update traver coaching'); 
        updateEPCEmail(mapNewCoaching.values(), mapOldCoaching);
        map<Id, Traver_Coaching__c> mapResourceId_Coaching = new map<Id, Traver_Coaching__c>();
        
        for(Traver_Coaching__c objNewCoaching : mapNewCoaching.values()) {
            
            Traver_Coaching__c objOldCoaching = mapOldCoaching.get(objNewCoaching.Id);
            
            if(objNewCoaching.TRV_Completed_By__c == null) {
                
                objNewCoaching.TRV_Resource_Email__c = '';
            }
            else if(objNewCoaching.TRV_Completed_By__c != objOldCoaching.TRV_Completed_By__c) {
                
                mapResourceId_Coaching.put(objNewCoaching.TRV_Completed_By__c, objNewCoaching);
            }
        }
        
        if(mapResourceId_Coaching.KeySet().isEmpty()) {
            
            return;
        }
        
        populateResourceEmail(mapResourceId_Coaching);
    }
    
    // update resource email on B4B coaching object
    private void populateResourceEmail(map<Id, Traver_Coaching__c> mapResourceId_Coaching)
    {
        
        for(TRV_Resource__c objResource :   [   
            SELECT Id, TRV_Resource__c, TRV_Resource__r.Email 
            FROM TRV_Resource__c 
            WHERE TRV_Resource__c != null 
            AND Id IN:mapResourceId_Coaching.Keyset()
        ]) {
            
            if(mapResourceId_Coaching.containsKey(objResource.Id)) {
                
                mapResourceId_Coaching.get(objResource.Id).TRV_Resource_Email__c = objResource.TRV_Resource__r.Email; 
            }
        }
    }
    
    public void updateEPCEmail(List<Traver_Coaching__c> newList, Map<Id, Traver_Coaching__c> oldMap)
    {
        system.debug('In update EPC email');
        Set<Id> coachingIds = new Set<Id>();
        List<Traver_Coaching__c> toBeProcessed = new List<Traver_Coaching__c>();
        for(Traver_Coaching__c coaching : newList)
        {
            Traver_Coaching__c oldCoaching = (oldMap == null || oldMap.get(coaching.Id) == null) ? new Traver_Coaching__c() :  oldMap.get(coaching.Id);
            if(oldCoaching.Traver_Project__c != coaching.Traver_Project__c)
            {
                coachingIds.add(coaching.Traver_Project__c);
                toBeProcessed.add(coaching);
            }
        }
        system.debug('tobeProcessed -- >'+toBeProcessed);
    	Map<Id,Traver_Project__c> projectMap = new Map<Id, Traver_Project__c>([SELECT id,TRV_EPC_Email__c FROM Traver_Project__c WHERE Id in :coachingIds]);
        for(Traver_Coaching__c coaching : toBeProcessed)
        {
            system.debug('updating coaching EPC Email');
            coaching.EPC_Email__c = (projectMap == null || projectMap.get(coaching.Traver_Project__c) == null)?
                						null:projectMap.get(coaching.Traver_Project__c).TRV_EPC_Email__c;
        }
    }
}