/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Test Class for EMP_ITCommunicationAll_Controller
History
1/21/15    Rey Austral      Created
------------------------------------------------------------*/
@isTest
public class EMP_ITSupportCommunicationAll_Test {
    testMethod static void testLoad()
    {
        for (Integer ctr=0;ctr<6;ctr++) {
            generateContent('Test Content ' + ctr);
        }
        test.startTest();
        EMP_ITCommunicationAll_Controller controller = new EMP_ITCommunicationAll_Controller();
        test.stopTest();
        system.assertEquals(6, controller.content.size());
        
    }
    
    private static void generateContent(String title) 
    {
        RecordType ContentRT = [select Id FROM RecordType WHERE Name = 'IT Library']; 
        
        ContentVersion testContentInsert = new ContentVersion();
        testContentInsert.ContentURL= 'www.google.com';
        testContentInsert.Title = 'Test Title ' + title;
        testContentInsert.RecordTypeId = ContentRT.Id; 
        
        insert testContentInsert;
        
        ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testContentInsert.Id];        
        ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name  = 'IT Communication'];
        
        ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc();        
        newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id;
        newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId;
        
        insert newWorkspaceDoc;    
        
    }
}