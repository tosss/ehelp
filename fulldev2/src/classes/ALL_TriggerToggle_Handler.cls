/*
Purpose: This class generates a map that will have sobject list for each code reference name (apex class name) as controlled in 
the Trigger Toggle custom settings. Trigger Toggle custom settings can control which record types can be passed through which 
code references (apex classes)

Programmer: Siva Pragada (Siva.Pragada@cdk.com)

Improvement Ideas: 1. adding before insert, update, after insert, update for each toggle to increase the efficiency of the processing time.
                   2. Find a way to run custom settings data to run only once during the trigger context.

History: This logic used to be with All_Case_Handler, separated to work generically for any sObject.

06-09-2015 - siva.pragada@cdk.com - Separated from ALL_Case_Handler and created this class 
12-01-2015 - siva.pragada@cdk.com - refactored the code to simplify the logic
12-07-2015 - reduced the number of for loops to 4 in original class the number is 9
*/
public class ALL_TriggerToggle_Handler 
{
    //this method references different methods and finally returns map<string, list<sObject>> recordTypeToListofRecordsMap
    //map<string, list<sObject>> =~ map<codeReference, list<Case>> =~ map<'caseTriggers', list<Case>>
    public static map<string, list<sObject>> ToggleFilter(list<sObject>NewList)
    {   
        string sobjectType = null;
        
        //find the type of sObject
        if(NewList[0] != null){ sobjectType = ALL_UtilitiesDescribe.sObjectTypeFinder(NewList[0]); }
        
        triggerTogglePack  triggerTogglePackObject = new triggerTogglePack();      
        map<string, list<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise = new map<string, list<Trigger_Toggle__c>>();
        
        //get all related trigger toggles for this sObject from the custom settings Trigger_Toggle__c
        if(sobjectType != null){ triggerTogglePackObject = ALL_TriggerToggle_Handler.getOrganizedTriggerToggles(sobjectType); }
       
        map<string, list<sObject>> RecordTypeTosObjects = new map<string, list<sObject>>();
        
        //get a map of record type to list of records for this sObject
        //map<string, list<sObject>> =~ map<recordType, list<Case>> =~ map<'Inquiry Creative', list<Case>>
        if(NewList != null) { RecordTypeTosObjects = ALL_UtilitiesDescribe.RecordTypeTosObjects(NewList); }
        
        map<string, list<sObject>> recordTypeToListofRecordsMap = new map<string, list<sObject>>();
        
        //send list<Trigger_Toggle__c> and map<recordType, list<Case>> to recordWiseSobjectsOrganizer() to get 
        //map<string, list<Case>> =~ map<'CaseTriggers', list<Cases of all record types>>
        if(triggerTogglePackObject != null && RecordTypeTosObjects != null)
        {
            recordTypeToListofRecordsMap = ALL_TriggerToggle_Handler.recordWiseSobjectsOrganizer(
                triggerTogglePackObject, RecordTypeTosObjects
            );
        }
        
        return recordTypeToListofRecordsMap;
    }
    
    public class triggerTogglePack
    {
        public map<string, list<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise;
        public map<string, boolean> codeReferenceToSwitchMap;
    }
    
    public static triggerTogglePack getOrganizedTriggerToggles(string sObjectType)
    {
        triggerTogglePack triggerTogglePackObject = new triggerTogglePack();
        
        map<string, Trigger_Toggle__c> TriggerToggle = Trigger_Toggle__c.getAll();
        
        map<string, list<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise = new map<string, list<Trigger_Toggle__c>>();
        
        map<string, boolean> codeReferenceToSwitchMap = new map<string, boolean>();
        
        for(Trigger_Toggle__c tt: TriggerToggle.values())
        {            
            if(tt.sObject__c == sObjectType)
            {
                list<Trigger_Toggle__c> NullRecordTypeToggles = TriggerTogglesRecordTypeWise.get('TogglesWithNullRecordTypes');
                
                if(NullRecordTypeToggles == null)
                { 
                    NullRecordTypeToggles = new list<Trigger_Toggle__c>();
                }
                
                list<Trigger_Toggle__c> RecordTypeToggles = TriggerTogglesRecordTypeWise.get('TogglesWithRecordTypes');
                
                if(RecordTypeToggles == null)
                { 
                    RecordTypeToggles = new list<Trigger_Toggle__c>();
                }
                
                if(tt.RecordType_Name__c == null) 
                {
                    NullRecordTypeToggles.add(tt);
                    codeReferenceToSwitchMap.put(tt.Code_Reference__c, tt.On__c);                    
                }
                
                if(tt.RecordType_Name__c != null) 
                {
                    RecordTypeToggles.add(tt); 
                }
                
                TriggerTogglesRecordTypeWise.put('TogglesWithNullRecordTypes', NullRecordTypeToggles);
                TriggerTogglesRecordTypeWise.put('TogglesWithRecordTypes', RecordTypeToggles);
            }
        } 
        
        triggerTogglePackObject.TriggerTogglesRecordTypeWise = TriggerTogglesRecordTypeWise;
        triggerTogglePackObject.codeReferenceToSwitchMap = codeReferenceToSwitchMap;
        
        return triggerTogglePackObject;
    }
    
    public static map<string, list<sObject>> recordWiseSobjectsOrganizer(
        triggerTogglePack triggerTogglePackObject, map<string, list<sobject>> RecordTypeToSobjects)
    {
        map<string, list<sObject>> recordTypeToListofRecordsMap = new map<string, list<sObject>> ();
        map<string, map<string, list<sObject>>> codeReferenceWiseMap = new map<string, map<string, list<sObject>>>();
        
        list<Trigger_Toggle__c> TriggerToggleList = 
            triggerTogglePackObject.TriggerTogglesRecordTypeWise.get('TogglesWithRecordTypes');
        
        list<Trigger_Toggle__c> NullRecordTypeToggles = 
            triggerTogglePackObject.TriggerTogglesRecordTypeWise.get('TogglesWithNullRecordTypes');
        
        map<string, boolean> codeReferenceToSwitchMap = 
            triggerTogglePackObject.codeReferenceToSwitchMap;
        
        if(TriggerToggleList != null && !TriggerToggleList.isEmpty())
        {
            for(Trigger_Toggle__c tt: TriggerToggleList)
            {
                map<string, list<sObject>> recordTypeMap = codeReferenceWiseMap.get(tt.Code_Reference__c);
                boolean defaultSettingForCodeReference = codeReferenceToSwitchMap.get(tt.Code_Reference__c);
                
                if(tt.On__c && !defaultSettingForCodeReference)
                {
                    if(recordTypeMap == null){ recordTypeMap = new map<string, list<sObject>>(); }
                    recordTypeMap.put(tt.RecordType_Name__c, RecordTypeToSobjects.get(tt.RecordType_Name__c));
                    codeReferenceWiseMap.put(tt.Code_Reference__c, recordTypeMap);
                }
                else if(!tt.On__c && defaultSettingForCodeReference)
                {
                    if(recordTypeMap == null){ recordTypeMap = RecordTypeToSobjects.clone(); }
                    recordTypeMap.remove(tt.RecordType_Name__c);
                    codeReferenceWiseMap.put(tt.Code_Reference__c, recordTypeMap);
                }
            }
        }
        
        system.debug(codeReferenceWiseMap);
        
        if(codeReferenceWiseMap != null && !codeReferenceWiseMap.isEmpty())
        {
            recordTypeToListofRecordsMap = collectAllRecordTypeWiseRecordsInaList(codeReferenceWiseMap);
        }
        system.debug(recordTypeToListofRecordsMap);
        return recordTypeToListofRecordsMap;
    }
    
    public static map<string, list<sObject>> collectAllRecordTypeWiseRecordsInaList(
        map<string, map<string, list<sObject>>> codeReferenceWiseMap)
    {
        map<string, list<sObject>> recordTypeToListofRecordsMap = new map<string, list<sObject>> ();
        
        if(codeReferenceWiseMap != null && !codeReferenceWiseMap.isEmpty())
        {
            for(string codeReference: codeReferenceWiseMap.keySet())
            {
                map<string, list<sObject>> recordTypeWiseMap = codeReferenceWiseMap.get(codeReference);
                list<sObject> sObjectsList = recordTypeToListofRecordsMap.get(codeReference);
                if(sObjectsList == null){ sObjectsList = new list<sObject>(); }
                
                if(recordTypeWiseMap != null && !recordTypeWiseMap.isEmpty())
                {
                    for(list<sObject> sObjectList: recordTypeWiseMap.values())
                    {
                        if(sObjectList != null)
                        {
                            sObjectsList.addAll(sObjectList);
                        }
                    }
                }
                recordTypeToListofRecordsMap.put(codeReference, sObjectsList);
            }
        }
        
        return recordTypeToListofRecordsMap;
    }
}