public class EMP_latestNews_Controller {
    public list<ContentVersion> lstContentVersions {get;set;}
    //public boolean showsection{get;set;}
    public boolean showRealAllLink{get;set;}
    public EMP_latestNews_Controller(){
        
        lstContentVersions = new list<ContentVersion>(); 
        
        String ContentLibraryName = System.Label.EMP_Library_Name;
        EMP_ContentDocumentHelper cdhelper = new EMP_ContentDocumentHelper(ContentLibraryName);
        set<Id> ContentDocumentIdSet = cdHelper.ContentDocumentIds;
        set<Id> latestVersion = cdHelper.LatestVersionIds;
        
        list<ContentVersion> queriedContentVersions = [
            Select ContentDocumentId, Title, Publish_Date__c, TagCsv, Document_Type__c, Video_File_Location__c 
            From ContentVersion 
            WHERE Id IN: latestVersion AND content_Type__c = 'Latest News' 
            AND ContentDocumentId IN: ContentDocumentIdSet
            ORDER BY Publish_Date__c DESC 
        ];              if(queriedContentVersions.size() > 8 ){showRealAllLink=true;}

        if(queriedContentVersions != null && !queriedContentVersions.isEmpty())
        {
            lstContentVersions = queriedContentVersions;
        }
    }	
    
    
}