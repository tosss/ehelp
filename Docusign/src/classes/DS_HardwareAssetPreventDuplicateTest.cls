@isTest
public class DS_HardwareAssetPreventDuplicateTest
{
    static testMethod void validateHardwareAssetName() 
    {
        Hardware_Asset__c ObjHA = new Hardware_Asset__c();
        ObjHA.Name = 'Testing';
        insert ObjHA;
    }
}