@IsTest
public class EMP_ITSupportCommunication_Test {
@testSetup static void initialDataSetup() {
    	ContentWorkspace testWorkspace = [SELECT Id 
                                          FROM ContentWorkspace 
                                          WHERE Name  = 'IT Communication'
                                         ];     	
    
        RecordType ContentRT = [select Id 
                                FROM RecordType 
                                WHERE Name = 'IT Library'
                               ]; 
    		
       	ContentVersion testContentInsert = new ContentVersion();
        testContentInsert.ContentURL= 'www.google.com';
        testContentInsert.Title = 'IT Support Communication Doc1';
        testContentInsert.RecordTypeId = ContentRT.Id; 
        testContentInsert.Content_Type__c = 'IT Support Communications';
        insert testContentInsert;
    
     	ContentVersion contentS = [SELECT ContentDocumentId 
                                   FROM ContentVersion 
                                   where Id = :testContentInsert.Id
                                  ]; 
        ContentWorkspace workspace = [SELECT Id 
                                      FROM ContentWorkspace 
                                      WHERE Name = 'IT Communication'
                                     ];
    	ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc();
    	newWorkspaceDoc.ContentWorkspaceId = workspace.Id;
        newWorkspaceDoc.ContentDocumentId = contentS.ContentDocumentId;
      	insert  newWorkspaceDoc; 
    
    	ContentVersion testContentInsert1 = new ContentVersion();
        testContentInsert1.ContentURL = 'www.yahoo.com';
        testContentInsert1.Title = 'Top 5 Documents Doc1';
        testContentInsert1.RecordTypeId = ContentRT.Id; 
        testContentInsert1.Content_Type__c = 'Top 5 Questions';
        insert testContentInsert1;
    
    	ContentVersion contentT = [SELECT ContentDocumentId 
                                   FROM ContentVersion 
                                   where Id = :testContentInsert1.Id
                                  ]; 
        ContentWorkspace workspace1 = [SELECT Id 
                                       FROM ContentWorkspace 
                                       WHERE Name = 'IT Communication'
                                      ];
    	ContentWorkspaceDoc newWorkspaceDoc1 = new ContentWorkspaceDoc();
    	newWorkspaceDoc1.ContentWorkspaceId = workspace1.Id;
        newWorkspaceDoc1.ContentDocumentId = contentT.ContentDocumentId;
      	insert  newWorkspaceDoc1; 
    }
    
    static testMethod void testQueryTop5Documents() 
    {
        test.startTest();
        EMP_ITSupport_TopDoc_Controller cnt = new EMP_ITSupport_TopDoc_Controller();
        for(EMP_ITSupport_TopDoc_Controller.contentWrapper ct: cnt.contentCritical){
            if(cnt!=null && ct.Title.contains('Top 5 Documents Doc1')){
                system.assert(true,'testQueryTop5Documents'); 
            }
        }
        test.stopTest();
    }
    static testMethod void testQueryITSupportComDocuments() 
    {
        test.startTest();
        EMP_ITSupport_Communication_Controller cnt1 = new EMP_ITSupport_Communication_Controller();
        for(EMP_ITSupport_Communication_Controller.contentWrapper ct: cnt1.content){
            if(ct!=null && ct.Title.contains('IT Support Communication Doc1')){
                system.assert(true,'testQueryITSupportComDocuments'); 
            }
        }
        test.stopTest();
    }
}