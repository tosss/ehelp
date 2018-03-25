// RQ-05985 
//2016-01-12     lakshmi.addanki@cdk.com    Created

public class EMP_ITSupport_TopDoc_Controller {
    public list<ContentVersion> lstTopContentVersions {get;set;}
    public List<contentWrapper> contentCritical { get; set; }
   
    public EMP_ITSupport_TopDoc_Controller(){
        
        lstTopContentVersions = new list<ContentVersion>(); 
        
        Map<Id, ContentDocument> contentDocuments = new map<Id, ContentDocument> ( [
            SELECT Title,  PublishStatus,  ParentId, OwnerId,  Id, LatestPublishedVersionId
            FROM ContentDocument
            WHERE ParentId IN: [
                SELECT Id 
                FROM ContentWorkspace 
                WHERE Name = 'IT Communication'
            ] 
        ]);
       
         
        Map<Id,ContentVersion> lstTopContentVersions = new Map<Id,ContentVersion> ([Select Title,Id, VersionNumber, ContentModifiedDate
                                                                              		From ContentVersion where ContentDocumentId in: contentDocuments.keyset() 
                                                                              		And Content_Type__c = 'Top 5 Questions'
                                                                            		]);
       
        contentCritical = new List<contentWrapper>();
        for(ContentDocument contentDoc : contentDocuments.values())
        {            
            if (lstTopContentVersions.containsKey(contentDoc.LatestPublishedVersionId))
            {
                ContentVersion latestContent = lstTopContentVersions.get(contentDoc.LatestPublishedVersionId);
                contentWrapper con = new contentWrapper();
                con.Title = latestContent.Title;
                con.contentId = latestContent.Id;
                con.Order = latestContent.ContentModifiedDate;
                system.debug('controller Top '+latestContent.Title );
                contentCritical.add(con);
            }
        }
      	contentCritical.sort();
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