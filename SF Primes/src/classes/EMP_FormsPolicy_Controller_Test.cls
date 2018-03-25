@isTest
public class EMP_FormsPolicy_Controller_Test {
 testMethod static void test_LoadData()
    {
        User u = [Select Id, Name From User Where Name = 'Irfan Siddiqui' limit 1];
        system.runAs(u)
        {
            generateContent();
            
            test.startTest();
            apexpages.currentpage().getparameters().put('page','policy');
            EMP_FormsPolicy_Controller controllerWithoutParameter = new EMP_FormsPolicy_Controller();
            
            apexpages.currentpage().getparameters().put('type','Associate Community Content');
            apexpages.currentpage().getparameters().put('page','');
            EMP_FormsPolicy_Controller controller = new EMP_FormsPolicy_Controller();
            Boolean showHeader = controller.showHeader;
            Boolean showtabs = controller.showtabs;
            test.stopTest();
        }
    }
    
    private static void generateContent()
    {
        String lib = System.Label.EMP_Library_Name;
        RecordType ContentRT = [select Id FROM RecordType WHERE Name = :lib]; 
        
        List<ContentVersion> listContentVersion = new List<ContentVersion>();
        for(Integer ctr=0;ctr<6;ctr++)
        {
            ContentVersion testContentInsert = new ContentVersion();
            testContentInsert.ContentURL='http://www.google.com/';
            testContentInsert.Title = 'Google.com' + String.valueOf(ctr);
            testContentInsert.RecordTypeId = ContentRT.Id; 
            listContentVersion.add(testContentInsert);
        }
        insert listContentVersion;
        
        List<ContentVersion> testContent = [SELECT ContentDocumentId FROM ContentVersion where Id in :listContentVersion];        
        ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = :lib];
        List<ContentWorkspaceDoc> workSpace = new List<ContentWorkspaceDoc>();
        for(ContentVersion content : testContent)
        {
            ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc();        
            newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id;
            newWorkspaceDoc.ContentDocumentId = content.ContentDocumentId;
            workSpace.add(newWorkspaceDoc);
            
            content.Expiration_Date__c = date.today().addDays(3);        
            content.TagCsv = 'Company Announcement';
            content.Content_Start_Date__c = date.today();
            content.Executive__c = UserInfo.getUserId();
            content.Document_Type__c='CEO Recaps';
            content.content_Type__c = 'Latest News';
            content.Geographic_Applicability__c='test';
            content.Category__c='test';
        }
        
        insert workSpace;        
        update testContent;       
    }
}