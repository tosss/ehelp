/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: 
Test Class: EMP_ITSupportCommunication_Test
History
1/21/15    Rey Austral      Created
------------------------------------------------------------*/
public class EMP_ITSupport_Communication_Controller {
    public String communityUrl { get; set; }
    public List<contentWrapper> content { get; set; }
    public Boolean showAll { get; set; }
    public EMP_ITSupport_Communication_Controller() 
    {
        communityUrl = Site.getBaseUrl();
        
         Map<Id, ContentDocument> contentDocuments = new map<Id, ContentDocument> ( [
            SELECT Title,  PublishStatus,  ParentId, OwnerId,  Id, LatestPublishedVersionId
            FROM ContentDocument
            WHERE ParentId IN: [
                SELECT Id 
                FROM ContentWorkspace 
                WHERE Name = 'IT Communication'
            ] Limit 5
        ]);
        Map<Id,ContentVersion> contentVersions = new Map<Id,ContentVersion> ([Select Title,Id, VersionNumber, ContentModifiedDate
                                                                              From ContentVersion where ContentDocumentId in: contentDocuments.keyset() 
                                                                            ]); 
        content = new List<contentWrapper>();
        //only get the latest uploaded file
        for(ContentDocument contentDoc : contentDocuments.values())
        {            
            if (contentVersions.containsKey(contentDoc.LatestPublishedVersionId))
            {
                ContentVersion latestContent = contentVersions.get(contentDoc.LatestPublishedVersionId);
                contentWrapper con = new contentWrapper();
                con.Title = latestContent.Title;
                con.contentId = latestContent.Id;
                con.Order = latestContent.ContentModifiedDate;
                content.add(con);
            }
        }
      	content.sort();
        showAll = false;
        if (content.size() == 5) {
            showAll = true;
        }
    }
    
    public class contentWrapper implements comparable
    {
        public string Title { get; set; }
        public string contentId { get; set; }       
        public DateTime Order { get; set; }
        public Integer compareTo(Object compareTo)
        {
            contentWrapper comWrap = (contentWrapper) compareTo;
            if (Order == comWrap.Order) return 0;
            if (Order < comWrap.Order) return 1;
            return -1;  
        }
    }
}