/*
Purpose: This class generates a Map that will have sobject List for each code reference name (apex class name) as controlled in 
the Trigger Toggle custom settings. Trigger Toggle custom settings can control which record types can be passed through which 
code references (apex classes)

Programmer: Siva Pragada (Siva.Pragada@cdk.com)

Improvement Ideas: adding before insert, update, after insert, update for each toggle to increase the efficiency of the processing time.

History: This logic used to be with All_Case_Handler, separated to work generically for any sObject.

06-09-2015 - siva.pragada@cdk.com - Separated from ALL_Case_Handler and created this class 
12-01-2015 - siva.pragada@cdk.com - refactored the code to simplify the logic
12-07-2015 - reduced the number of for loops to 4 in original class the number is 9
04-26-2016 - siva.pragada@cdk.com added genericized ProfileFilter method from ALL_Case_Handler
*/
public class ALL_TriggerToggle_Handler 
{
    //this method references different methods and finally returns Map<String, List<sObject>> recordTypeToListofRecordsMap
    //Map<String, List<sObject>> =~ Map<codeReference, List<Case>> =~ Map<'caseTriggers', List<Case>>
    public static Map<String, List<sObject>> ToggleFilter(List<sObject> NewList)
    {   
        String sobjectType = null;
        
        //find the type of sObject
        if(NewList[0] != null)
        { 
            sobjectType = ALL_UtilitiesDescribe.sObjectTypeFinder(NewList[0]); 
        }
        system.debug(sobjectType);
        
        triggerTogglePack  triggerTogglePackObject = new triggerTogglePack();      
        Map<String, List<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise = new Map<String, List<Trigger_Toggle__c>>();
        
        //get all related trigger toggles for this sObject from the custom settings Trigger_Toggle__c
        if(sobjectType != null)
        { 
            triggerTogglePackObject = ALL_TriggerToggle_Handler.getOrganizedTriggerToggles(sobjectType); 
        }
       
        system.debug(triggerTogglePackObject);
        
        Map<String, List<sObject>> RecordTypeTosObjects = new Map<String, List<sObject>>();
        
        //get a Map of record type to List of records for this sObject
        //Map<String, List<sObject>> =~ Map<recordType, List<Case>> =~ Map<'Inquiry Creative', List<Case>>
        if(NewList != null) 
        { 
            RecordTypeTosObjects = ALL_UtilitiesDescribe.RecordTypeTosObjects(NewList); 
        }
        
        system.debug(RecordTypeTosObjects);
        
        Map<String, List<sObject>> recordTypeToListofRecordsMap = new Map<String, List<sObject>>();
        
        //send List<Trigger_Toggle__c> and Map<recordType, List<Case>> to recordWiseSobjectsOrganizer() to get 
        //Map<String, List<Case>> =~ Map<'CaseTriggers', List<Cases of all record types>>
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
        public Map<String, List<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise;
        public Map<String, boolean> codeReferenceToSwitchMap;
    }
    
    public static triggerTogglePack getOrganizedTriggerToggles(String sObjectType)
    {
        triggerTogglePack triggerTogglePackObject = new triggerTogglePack();
        
        Map<String, Trigger_Toggle__c> TriggerToggle = Trigger_Toggle__c.getAll();
        
        Map<String, List<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise = new Map<String, List<Trigger_Toggle__c>>();
        
        Map<String, boolean> codeReferenceToSwitchMap = new Map<String, boolean>();
        
        for(Trigger_Toggle__c tt: TriggerToggle.values())
        {            
            if(tt.sObject__c == sObjectType)
            {
                List<Trigger_Toggle__c> NullRecordTypeToggles = TriggerTogglesRecordTypeWise.get('TogglesWithNullRecordTypes');
                
                if(NullRecordTypeToggles == null)
                { 
                    NullRecordTypeToggles = new List<Trigger_Toggle__c>();
                }
                
                List<Trigger_Toggle__c> RecordTypeToggles = TriggerTogglesRecordTypeWise.get('TogglesWithRecordTypes');
                
                if(RecordTypeToggles == null)
                { 
                    RecordTypeToggles = new List<Trigger_Toggle__c>();
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
    
    public static Map<String, List<sObject>> recordWiseSobjectsOrganizer(triggerTogglePack triggerTogglePackObject, Map<String, List<sobject>> RecordTypeToSobjects)
    {
        system.debug(RecordTypeToSobjects);
        system.debug(triggerTogglePackObject);
        Map<String, List<sObject>> recordTypeToListofRecordsMap = new Map<String, List<sObject>> ();
        Map<String, Map<String, List<sObject>>> codeReferenceWiseMap = new Map<String, Map<String, List<sObject>>>();
        
        List<Trigger_Toggle__c> TriggerToggleList = 
            triggerTogglePackObject.TriggerTogglesRecordTypeWise.get('TogglesWithRecordTypes');
        
        List<Trigger_Toggle__c> NullRecordTypeToggles = 
            triggerTogglePackObject.TriggerTogglesRecordTypeWise.get('TogglesWithNullRecordTypes');
        
        Map<String, boolean> codeReferenceToSwitchMap = 
            triggerTogglePackObject.codeReferenceToSwitchMap;
        
        
        if(TriggerToggleList != null && !TriggerToggleList.isEmpty())
        {
            for(Trigger_Toggle__c tt: TriggerToggleList)
            {
                Map<String, List<sObject>> recordTypeMap = codeReferenceWiseMap.get(tt.Code_Reference__c);
                boolean defaultSettingForCodeReference = codeReferenceToSwitchMap.get(tt.Code_Reference__c);
                
                if(tt.On__c == true && defaultSettingForCodeReference!=null && defaultSettingForCodeReference == false)
                {
                    if(recordTypeMap == null){ recordTypeMap = new Map<String, List<sObject>>(); }
                    recordTypeMap.put(tt.RecordType_Name__c, RecordTypeToSobjects.get(tt.RecordType_Name__c));
                    codeReferenceWiseMap.put(tt.Code_Reference__c, recordTypeMap);
                    system.debug(codeReferenceWiseMap);
                }
                else if(tt.On__c == false && defaultSettingForCodeReference == true)
                {
                    if(recordTypeMap == null){ recordTypeMap = RecordTypeToSobjects.clone(); }
                    recordTypeMap.remove(tt.RecordType_Name__c);
                    codeReferenceWiseMap.put(tt.Code_Reference__c, recordTypeMap);
                    system.debug(codeReferenceWiseMap);
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
    
    public static Map<String, List<sObject>> collectAllRecordTypeWiseRecordsInaList(
        Map<String, Map<String, List<sObject>>> codeReferenceWiseMap)
    {
        Map<String, List<sObject>> recordTypeToListofRecordsMap = new Map<String, List<sObject>> ();
        
        if(codeReferenceWiseMap != null && !codeReferenceWiseMap.isEmpty())
        {
            for(String codeReference: codeReferenceWiseMap.keySet())
            {
                Map<String, List<sObject>> recordTypeWiseMap = codeReferenceWiseMap.get(codeReference);
                List<sObject> sObjectsList = recordTypeToListofRecordsMap.get(codeReference);
                if(sObjectsList == null){ sObjectsList = new List<sObject>(); }
                
                if(recordTypeWiseMap != null && !recordTypeWiseMap.isEmpty())
                {
                    for(List<sObject> sObjectList: recordTypeWiseMap.values())
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
    
    //Map<codeReference, List<Case>>
    public static list<sObject> ProfileFilter(map<string, list<sObject>> FinalRecordsMap, string sObjectType)
    { 
        system.debug(FinalRecordsMap);
        map<string, Trigger_Toggle_Profile__c> TpMap = Trigger_Toggle_Profile__c.getAll();
        list<sObject> recordsList = new list<sObject>();
        
        system.debug(TpMap);
        
        for(Trigger_Toggle_Profile__c tp: TpMap.values())
        {
           
            if(tp.sObject__c == sObjectType)
            {
                for(string CodeReference: FinalRecordsMap.keySet())
                {
                    if(tp.get('Code_Reference__c') != null && 
                       tp.get('Code_Reference__c') == CodeReference && 
                       !tp.On__c && tp.Profile_Id__c == userInfo.getProfileId())
                    { 
                        FinalRecordsMap.put(CodeReference, new list<sObject>());                        
                    }
                }
            }
        } 
        
        for(string key: FinalRecordsMap.keySet())
        {
            recordsList.addAll(FinalRecordsMap.get(key));
        }
        system.debug(recordsList);
        return recordsList;
    } 
    
    public static list<sObject> ProfileFilter(list<sObject> Records, string sObjectType)
    {
        map<string, list<sObject>> RecordsByCodeReference = new map<string, list<sObject>>();
        map<string, Trigger_Toggle__c> TpMap = Trigger_Toggle__c.getAll();
        
        for(string key : TpMap.keySet())
        {
            Trigger_Toggle__c tt = TpMap.get(key);
            
            if(tt.sObject__c == sObjectType)
            {
                RecordsByCodeReference.put(tt.Code_Reference__c, Records);
            }
        }
        
        return ProfileFilter(RecordsByCodeReference, sObjectType);
    }
    
    /*
    public static list<sObject> filterRecordTypeAndProfile(List<sObject> NewList)
    {
        string sobjectType = ALL_UtilitiesDescribe.sObjectTypeFinder(NewList[0]);
        map<string, list<sObject>> FinalRecordsMap = new map<string, list<sObject>>();
        
        FinalRecordsMap = ALL_TriggerToggle_Handler.ToggleFilter(NewList);
        
        list<sObject> recordsList = ALL_TriggerToggle_Handler.ProfileFilter(FinalRecordsMap, sobjectType);
        
        return recordsList;
    }
    */
   
   /* {
    //2016-04-26 - lalitha.adduru@cdk.com - method that gives a map of parameter -> List of custom setting records - RQ-06909
    //paramter can be any field in Trigger_Toggle_Profile__c custom setting i.e; code_Reference__c,
    //sObject__c,Profile_Name__c,Profile_Id__c,On__c
    
    private static Map<String, List<Trigger_Toggle_Profile__c>> fetchAnyParameterToRecordValues(String parameter)
    {
        Map<String, List<Trigger_Toggle_Profile__c>> anyParameterToRecordValues = new  Map<String, List<Trigger_Toggle_Profile__c>>();
        list<Trigger_Toggle_Profile__c> allData = Trigger_Toggle_Profile__c.getAll().values();
        
        for(Trigger_Toggle_Profile__c proTogle : allData)
        {
            string anyParameter = String.ValueOf(proTogle.get(parameter)).toLowerCase();
            
            if(anyParameterToRecordValues.containsKey(anyParameter))
            {
                anyParameterToRecordValues.get(anyParameter).add(proTogle);
            }
            else
            {
                anyParameterToRecordValues.put(anyParameter, new List<Trigger_Toggle_Profile__c>{ proTogle }); 
            }
        }
        
        return anyParameterToRecordValues;
    }
    
    //2016-04-26 - lalitha.adduru@cdk.com - method that gives a list of custom setting records on a particular sObject - RQ-06909
    
    public static List<Trigger_Toggle_Profile__c> fetchsObjectToRecordValues(String sObjectName)
    {
        Map<String, List<Trigger_Toggle_Profile__c>> anyParameterToRecordValues = new  Map<String, List<Trigger_Toggle_Profile__c>>();        
        anyParameterToRecordValues = fetchAnyParameterToRecordValues('sObject__c');
        
        List<Trigger_Toggle_Profile__c> settingsForsObject = new List<Trigger_Toggle_Profile__c>();
        
        settingsForsObject = anyParameterToRecordValues.isEmpty() ? 
            settingsForsObject : anyParameterToRecordValues.get(sObjectName.toLowerCase());
        
        return settingsForsObject;
    }
    
    //2016-04-26 - lalitha.adduru@cdk.com - method that gives a map of profileId -> on/off on a 
    //particular sObject for a particular codeReference - RQ-06909
    
    public static Map<ID, boolean> fetchProfileToSwitchMap(String codeReference, String sObjectName)
    {
        Map<ID, boolean> profileToSwitchMap = new Map<ID, boolean>();
        List<Trigger_Toggle_Profile__c> settingsForsObject = new List<Trigger_Toggle_Profile__c>();
        
        Map<String, List<Trigger_Toggle_Profile__c>> anyParameterToRecordValues = new  Map<String, List<Trigger_Toggle_Profile__c>>();        
        anyParameterToRecordValues = fetchAnyParameterToRecordValues('sObject__c');
        
        settingsForsObject = anyParameterToRecordValues.isEmpty() ? 
            settingsForsObject : anyParameterToRecordValues.get(sObjectName.toLowerCase());
        
        system.debug('settingsForsObject --> '+settingsForsObject);
        
        for(Trigger_Toggle_Profile__c setting : settingsForsObject )
        {
            if(setting.code_Reference__c == codeReference)
            {
                profileToSwitchMap.put(setting.Profile_Id__c , setting.On__c);
            }
        } 
        
        return profileToSwitchMap;    		
    }
        
    }*/

}