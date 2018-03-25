@isTest
public class DS_LaserUpdateLockedRecord_Test 
{
    Static testMethod void UnitTesT()
    {    
        Laser_Artwork_Order__c Lao = DS_TestObjects.NewLaserArtworkOrder_Inserted();
        Laser_Artwork_Order__c thisLAO = [select Contact__c, Ship_CMF_Info__r.Account__c from Laser_Artwork_Order__c limit 1];
        Contact_Relationship__c crt = IMP_TestFactory_Helper.buildContactRelationship(thisLAO.Ship_CMF_Info__r.Account__c, thisLAO.Contact__c);
        insert crt;
        ApexPages.StandardController sc = new ApexPages.StandardController(Lao);
        
        Test.startTest();
        
        DS_LaserUpdateLockedRecord_Extension instance = new DS_LaserUpdateLockedRecord_Extension(sc);
        instance.LaoId = Lao.Id;       
        instance.UpdateAndSave(); 
        
        instance.createNewLaserOrderedForms();
        instance.saveLaserOrderForm();
        instance.getLofFields();
        
        Test.stopTest();        
    }
}