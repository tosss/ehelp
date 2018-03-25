@isTest
public class DS_LaserUpdateLockedRecord_Test 
{
    Static testMethod void UnitTesT()
    {    
        Laser_Artwork_Order__c Lao = DS_TestObjects.NewLaserArtworkOrder_Inserted();
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