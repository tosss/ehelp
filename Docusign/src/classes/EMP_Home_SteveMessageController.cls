public class EMP_Home_SteveMessageController {
    

    public list<ContentVersion> lstContentVersions {get;set;}
    public String EMP_StockTicker {get; set;}
    public Boolean showRealAllLink{get;set;}     
    public EMP_Home_SteveMessageController(){
    	
        // query all ContentVersion
        lstContentVersions = new list<ContentVersion>(); 
        
        String ContentLibraryName = System.Label.EMP_Library_Name;
        EMP_ContentDocumentHelper cdhelper = new EMP_ContentDocumentHelper(ContentLibraryName);
        set<Id> ContentDocumentIdSet = cdHelper.ContentDocumentIds;
        set<Id> latestVersion = cdHelper.LatestVersionIds;
  
       
        list<ContentVersion> queriedContentVersions = [
            Select ContentDocumentId, Title, Publish_Date__c, TagCsv, Document_Type__c, Video_File_Location__c,content_Type__c 
            From ContentVersion 
            WHERE Id IN: latestVersion AND content_Type__c = 'CEO Recaps' 
            AND ContentDocumentId IN: ContentDocumentIdSet
            AND Expiration_Date__c >: system.Today()
            AND Content_Start_Date__c <=: system.Today()
            ORDER BY Publish_Date__c DESC 
        ];  
         if(queriedContentVersions.size() > 1 ){showRealAllLink=true;}
        
        if(queriedContentVersions != null && !queriedContentVersions.isEmpty())
        {
            lstContentVersions = queriedContentVersions;
        }
                EMP_StockTicker ='EMP_StockTicker';
        
    }
}