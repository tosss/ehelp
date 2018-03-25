@isTest
public class EMP_CommunityController_Test {
  testMethod static void test_PopulateData()
    {
        generateLinks();
        test.startTest();
        EMP_CommunityController controller = new EMP_CommunityController();
        test.stopTest();
        //check if all list variable has value
        system.assertEquals(5, controller.communityDataCol1.size());
        system.assertEquals(5, controller.communityDataCol2.size());
        system.assertEquals(6, controller.communityDataCol3.size());
    }
    
    private static void generateLinks()
    {
        List<EMP_Community_Item__c> lstCom = new List<EMP_Community_Item__c>();
        
        for (Integer ctr = 0; ctr< 16; ctr++)
        {
            EMP_Community_Item__c top = new EMP_Community_Item__c();
            top.Name = String.valueOf(ctr);
            top.Community_Name__c = String.valueOf(ctr);
            top.Community_URL__c = 'http://www.google.com';
            lstCom.add(top);
        }
        insert lstCom;
    }
}