@isTest
public class ALL_UtilitiesDescribe_Test 
{
    public static testmethod void getRecordTypeIdOfAnySObject()
    {
        ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account','ADPDS Customer');
    }
    
    public static testMethod void getRecordTypeNameOfAnySObject()
    {
        ID aAaccountPlanID = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account_Plan__c', 'AA Account Plan');
        string RecordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Account_Plan__c', aAaccountPlanID);
        
        system.assertEquals('AA Account Plan', RecordTypeName);
    }
    
    public static testMethod void sObjectTypeFinder()
    {
        Account acc = new Account();
        string sObjectType = ALL_UtilitiesDescribe.sObjectTypeFinder(acc);
        
        system.assertEquals('Account', sObjectType);
    }
    
    public static testMethod void getRecordTypeInfosByName()
    {
        ALL_UtilitiesDescribe.getRecordTypeInfosByName('Account');        
    }
    
    public static testMethod void getRecordTypeInfosByID()
    {
        ALL_UtilitiesDescribe.getRecordTypeInfosByID('Account');        
    }
    
    public static testMethod void RecordTypeTosObjects()
    {
        
        ALL_UtilitiesDescribe.RecordTypeTosObjects(new list<Account>{ new Account() });        
    }
}