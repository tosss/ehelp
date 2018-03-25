@isTest
public class COM_SearchLinks_Test {

    
    @testSetup static void prepareTestData()
    {
        List<Page_Component__c> pageComponents = new List<Page_Component__c>();
        for(Integer ctr=0; ctr < 21; ctr++)
        {
            Page_Component__c pgComponent = new Page_Component__c();
            pgComponent.name ='test';
            String orderCtr = '';
            if(ctr < 10)
            {
                orderCtr = '0'+ string.valueof(ctr);
            }else{ 
                orderCtr = string.valueof(ctr);
            }
            pgComponent.Component_Order_Picklist__c = orderCtr;
            pgComponent.VFPageName__c='EMP_Nopage';
			pgComponent.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Page_Component__c', 'Link');
            pageComponents.add(pgComponent);
        }
        insert pageComponents;
    }
    
    static testMethod void testStart() {        
        test.startTest();  
        
        COM_SearchLinks_Controller.searchLinks('test');
        test.stopTest();
    }
}