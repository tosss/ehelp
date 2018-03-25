@isTest
public class EMP_PolicyAcknowledgementController_Test {
   testMethod static void test_LoadData()
    {
        generateContent(true);
        test.startTest();
        EMP_PolicyAcknowledgementPageController controller = new EMP_PolicyAcknowledgementPageController();
        test.stopTest();
        system.assert(1 <= controller.policyList.size());
    }

    testMethod static void test_acknowledge()
    {
        Id usrID = userInfo.getUserId();
        generateContent(true);
        
        /*EMP_Policy__c objemp = new EMP_Policy__c();
        objemp.User_Name__c = usrID;
        objemp.name='test';
        insert objemp;*/
        
        //get the id of the created policy acknowledgement
        Id ackId;
        List<EMP_Policy__c> policies = [Select Id from EMP_Policy__c where User_Name__c = : usrID];
        for (EMP_Policy__c empPo : policies)
        {
            ackId = empPo.Id;
        }
        test.startTest();
        EMP_PolicyAcknowledgementPageController controller = new EMP_PolicyAcknowledgementPageController();
        controller.policyID = ackId;
        controller.acknowledge();
        controller.ContentLoad();
        String policys = controller.policy;
        ID selectedPolicy = controller.selectedPolicy;
        
        test.stopTest();
        
        List<EMP_Policy__c> policy = [Select Id, Acknowledgement_Status__c from EMP_Policy__c where User_Name__c = : usrID];
        for (EMP_Policy__c empPolicy : policy)
        {
            system.assert(empPolicy.Acknowledgement_Status__c);
        }
    }

    private static id generateContent(Boolean enableAcknowledge)
    {
        Contact con = new Contact();
        con.LastName = 'testL';
        con.FirstName = 'testF'; 
        con.Email = 'tbd@test.com';
        con.User__c = userInfo.getUserId();
        insert con;
        
        RecordType ContentRT = [select Id FROM RecordType WHERE Name = 'Policy']; 
        
        ContentVersion testContentInsert = new ContentVersion();
        testContentInsert.ContentURL='http://www.google.com/';
        testContentInsert.Title = 'Google.com';
        testContentInsert.RecordTypeId = ContentRT.Id; 
        
        insert testContentInsert;
        
        ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testContentInsert.Id];        
        ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = 'Policy'];
        
        ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc();        
        newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id;
        newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId;
        
        insert newWorkspaceDoc;
        
         EMP_Policy__c objemp = new EMP_Policy__c();
        objemp.User_Name__c = userInfo.getUserId();
        objemp.Employee_Contact__c = con.id;
        objemp.name='test';
        objemp.Acknowledgement_Status__c = true;
        insert objemp;
        
        testContent.Acknowledgement_Required__c = enableAcknowledge;
        testContent.Geographic_Applicability__c = 'Global';
        testContent.Expiration_Date__c = date.today().addDays(3);
        testContent.Policy_Effective_Date__c = date.today();
        
        update testContent; 
        return testContent.id;
    }
}