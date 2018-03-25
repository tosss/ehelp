/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: 
Test Class: EMP_ITSupportCommunication_Test
History
1/21/15    Rey Austral      Created
2016-01-12 lakshmi.addanki@cdk.com   RQ-05985 Changed Content_Type_c
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
            ] 
        ]);
        Map<Id,ContentVersion> contentVersions = new Map<Id,ContentVersion> ([Select Title,Id, VersionNumber, ContentModifiedDate
                                                                              From ContentVersion where ContentDocumentId in: contentDocuments.keyset() 
                                                                              And Content_Type__c = 'IT Support Communications'
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
                system.debug('controller '+latestContent.Title );
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