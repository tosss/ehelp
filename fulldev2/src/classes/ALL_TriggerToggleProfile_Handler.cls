//2016-04-26 - lalitha.adduru@cdk.com - created this class to perform operations on Trigger Toggle Profile custom setting- RQ-06909 

public class ALL_TriggerToggleProfile_Handler 
{
    //2016-04-26 - lalitha.adduru@cdk.com - method that gives a map of parameter -> List of custom setting records - RQ-06909
    //paramter can be any field in Trigger_Toggle_Profile__c custom setting i.e; code_Reference__c,sObject__c,Profile_Name__c,Profile_Id__c,On__c
    private static Map<String, List<Trigger_Toggle_Profile__c>> fetchAnyParameterToRecordValues(String parameter)
    {
        Map<String, List<Trigger_Toggle_Profile__c>> AnyParameterToRecordValues = new  Map<String, List<Trigger_Toggle_Profile__c>>();
        Map<string, Trigger_Toggle_Profile__c> allData = Trigger_Toggle_Profile__c.getAll();
        for(Trigger_Toggle_Profile__c triggerToggleProfileRecord : allData.values())
        {
            if(AnyParameterToRecordValues.containsKey(String.ValueOf(triggerToggleProfileRecord.get(parameter)).toLowerCase()))
            {
            	AnyParameterToRecordValues.get(String.valueOf(triggerToggleProfileRecord.get(parameter)).toLowerCase()).add(triggerToggleProfileRecord);
            }
            else
            {
                AnyParameterToRecordValues.put(String.valueOf(triggerToggleProfileRecord.get(parameter)).toLowerCase(), new List<Trigger_Toggle_Profile__c>{triggerToggleProfileRecord}); 
            }
        }
        system.debug('AnyParameterToRecordValues -->'+AnyParameterToRecordValues);
        return AnyParameterToRecordValues;
    }
    
    //2016-04-26 - lalitha.adduru@cdk.com - method that gives a list of custom setting records on a particular sObject - RQ-06909
    public static List<Trigger_Toggle_Profile__c> fetchsObjectToRecordValues(String sObjectName)
    {
        List<Trigger_Toggle_Profile__c> settingsForsObject = new List<Trigger_Toggle_Profile__c>();
        settingsForsObject = fetchAnyParameterToRecordValues('sObject__c').isEmpty() ? settingsForsObject : fetchAnyParameterToRecordValues('sObject__c').get(String.ValueOf(sObjectName).toLowerCase());
        return settingsForsObject;
    }
    
    //2016-04-26 - lalitha.adduru@cdk.com - method that gives a map of profileId -> on/off on a particular sObject for a particular codeReference - RQ-06909
    public static Map<ID, boolean> fetchProfileToSwitchMap(String codeReference, String sObjectName)
    {
        Map<ID, boolean> ProfileToSwitchMap = new Map<ID, boolean>();
        List<Trigger_Toggle_Profile__c> settingsForsObject = new List<Trigger_Toggle_Profile__c>();
        settingsForsObject = fetchAnyParameterToRecordValues('sObject__c').isEmpty() ? settingsForsObject : fetchAnyParameterToRecordValues('sObject__c').get(String.ValueOf(sObjectName).toLowerCase());
        system.debug('settingsForsObject --> '+settingsForsObject);
        for(Trigger_Toggle_Profile__c setting : settingsForsObject )
        {
            if(setting.code_Reference__c == codeReference)
            {
                ProfileToSwitchMap.put(setting.Profile_Id__c , setting.On__c);
            }
        }      
        return ProfileToSwitchMap;    		
	}
    
}