//2017-05-04 - siva.pragad@cdk.com - created
//2017-05-05 - siva.pragad@cdk.com - edited
@isTest
public class ALL_Attachment_Test 
{
    static testMethod void unitest()
    {
        ID serviceConnectType = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Service Connect'); 
        Case svCase = DS_TestObjects.NewCase();
        svCase.RecordTypeId = serviceConnectType;
        
        Insert svCase;
        
        String blobString = 'Convert me to Bob';
        Blob attachme = Blob.valueOf(blobString);
        
        Attachment att = new Attachment();
        att.Body = attachme;
        att.ParentId = svCase.ID;
        att.IsPrivate = false;
        att.OwnerId = userInfo.getUserId();
        att.Name = 'Att008';
        Insert att;
        
        Insert new GlobalSettings__c(Name='Test', Email_2_Case_Prevent_Delete__c=true);
        
        delete att;
    }
}