@isTest
public class EMP_LeadershipCornerController_Test 
{
    @TestSetup
    public static void generateContent()
    {
        // Leadership Messages
        String lib = System.Label.EMP_Library_Name;
        RecordType ContentRT = [select Id FROM RecordType WHERE Name = :lib]; 
        
        List<ContentVersion> listContentVersion = new List<ContentVersion>();
        for(Integer ctr=0;ctr<3;ctr++)
        {
            ContentVersion testContentInsert = new ContentVersion();
            testContentInsert.ContentURL='http://www.google.com/';
            testContentInsert.Title = 'Google.com ' + String.valueOf(ctr);
            testContentInsert.RecordTypeId = ContentRT.Id; 
            listContentVersion.add(testContentInsert);
        }
        
        system.debug(listContentVersion);
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
            content.TagCsv = 'Leadership Blog';
            content.content_Type__c='Leadership Blog';
            content.Content_Start_Date__c = date.today();
            content.Executive__c = UserInfo.getUserId();
        }
        
        insert workSpace;        
        update testContent;       
    }
    
    testMethod static void testLeadershipCorner()
    {
        test.startTest();
        EMP_LeadershipCornerController controller = new EMP_LeadershipCornerController();
        test.stopTest();
        
        system.debug(controller.CEOMessagesSource);
        system.debug(controller.LeadershipSource);
        
        system.assertEquals(EMP_LeadershipCornerController.LEADERSHIP_MAX_RECORDS, controller.LeadershipSource.size());
    }
}