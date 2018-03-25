@isTest
public class EMP_TrainingComponentController_Test {
    testMethod static void test_LoadData()
    {
        generateContent();
        test.startTest();
        EMP_TrainingComponentController controller = new EMP_TrainingComponentController();
        test.stopTest();
    }
    
    private static void generateContent()
    {
        String lib = System.Label.EMP_Library_Name;
        RecordType ContentRT = [select Id FROM RecordType WHERE Name = :lib]; 
        
        List<ContentVersion> listContentVersion = new List<ContentVersion>();
        ContentVersion testContentInsert = new ContentVersion();
        testContentInsert.ContentURL='http://www.google.com/';
        testContentInsert.Title = 'LP Course Request Form v1 4';
        testContentInsert.RecordTypeId = ContentRT.Id; 
        testContentInsert.content_type__c ='Training';
        listContentVersion.add(testContentInsert);
        insert listContentVersion;
        
        /*for(Integer ctr=0;ctr<6;ctr++)
        {
            ContentVersion testContentInsert = new ContentVersion();
            testContentInsert.ContentURL='http://www.google.com/';
            testContentInsert.Title = 'Google.com' + String.valueOf(ctr);
            testContentInsert.RecordTypeId = ContentRT.Id; 
            listContentVersion.add(testContentInsert);
        }
        insert listContentVersion;*/
        
        List<ContentVersion> testContent = [SELECT ContentDocumentId FROM ContentVersion where Id in :listContentVersion];        
        ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = :lib];
        List<ContentWorkspaceDoc> workSpace = new List<ContentWorkspaceDoc>();
        for(ContentVersion content : testContent)
        {
            
            content.Expiration_Date__c = date.today().addDays(3);        
            content.Content_Start_Date__c = date.today();
			content.Content_Type__c='Training';
            content.Title='LP Course Request Form v1 4';
            content.Display_Order__c= 01;
            content.Executive__c = UserInfo.getUserId();
        }
		ContentVersion objcvv = new ContentVersion();
		objcvv.Title='LP Course Request Form v1 4';        
        insert workSpace;        
        update testContent;       
    }
}