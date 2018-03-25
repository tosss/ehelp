@isTest
public class EMP_LeadershipCornerController_Test {
    testMethod static void test_LoadData()
    {
        generateContent();
        test.startTest();
        EMP_LeadershipCornerController controller = new EMP_LeadershipCornerController();
        test.stopTest();
        //record must be 5 even if the data in content is more than 5
       //Khan : Changed it to 3 based on recent change to restrict the count to 3 on the leadership tab
        system.assertEquals(3, controller.contentSource.size());
    }
    
    private static void generateContent()
    {
        String lib = System.Label.EMP_Library_Name;
        RecordType ContentRT = [select Id FROM RecordType WHERE Name = :lib]; 
        
        List<ContentVersion> listContentVersion = new List<ContentVersion>();
        for(Integer ctr=0;ctr<3;ctr++)
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
            content.TagCsv = 'Leadership Blog';
            content.content_Type__c='Leadership Blog';
            content.Content_Start_Date__c = date.today();
            content.Executive__c = UserInfo.getUserId();
        }
        
        insert workSpace;        
        update testContent;       
    }
}