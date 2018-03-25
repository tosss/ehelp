public class EMP_TrainingComponentController {
    public list<ContentVersion> lstContentVersions{get;set;}
    public static final String ContentLibraryName = System.Label.EMP_Library_Name;
    EMP_ContentDocumentHelper cdhelper = new EMP_ContentDocumentHelper(ContentLibraryName);
    set<Id> ContentDocumentIdSet = cdHelper.ContentDocumentIds;
    set<Id> latestVersion = cdHelper.LatestVersionIds;
    public ContentVersion objcvv {get;set;}
    public EMP_TrainingComponentController(){
        lstContentVersions = [
            Select id,ContentDocumentId, Title, Publish_Date__c, TagCsv, Document_Type__c, Video_File_Location__c, Content_Type__c,Display_Order__c 
            From ContentVersion 
            WHERE Id IN: latestVersion AND Content_Type__c = 'Training' AND Title != 'LP Course Request Form v1 4'
            AND ContentDocumentId IN: ContentDocumentIdSet
            ORDER BY Display_Order__c
        ];
        for(ContentVersion objc : [select id, title from contentVersion where content_type__c =:'Training']){
            if(objc.Title=='LP Course Request Form v1 4') 
                objcvv = objc;
        }
    } 
   
}