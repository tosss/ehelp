public class EMP_LeadershipCornerController {
    
    public id contentVersionId {get;set;}
    public Set<Id> cVersionID = new Set<Id>();
    public Set<String> cTitle = new Set<String>(); //contains contentversion titles
    public Set<Id> setContentDocumentIds = new Set<Id>(); //contains set of contentDocument Ids
    public list<ContentVersion> recentUpdates {get;set;}
    public Set<String> subHeaderTitle = new Set<String>();
    public Set<Id> latestVersion = new Set<Id>();
    public static final String workspace = System.Label.EMP_Library_Name;
    public List<ContentWrapper> contentSource { get; set; }
    public Boolean showRealAllLink { get; set; }
    public EMP_LeadershipCornerController()
    {
        recentUpdates = new List<ContentVersion>();
        contentSource = new List<ContentWrapper>();
        //query all contentDocument Id
        //query all contentDocument Id and add to the linksId
        EMP_ContentDocumentHelper  cdhelper = new EMP_ContentDocumentHelper (workspace);
        
        setContentDocumentIds = cdHelper.ContentDocumentIds;
        latestVersion = cdHelper.LatestVersionIds;  
        
        // validates that set(setContentDocumentIds) contains value
        if(!setContentDocumentIds.isEmpty() || setContentDocumentIds.size() > 0)
        {
            // query all ContentVersion 
            list<ContentVersion> ContentVersions = [
                Select ContentDocumentId, Title, Publish_Date__c, TagCsv, Document_Type__c, Video_File_Location__c , Executive__c
                From ContentVersion 
                WHERE Id IN: latestVersion AND content_Type__c = 'Leadership Blog' 
                AND ContentDocumentId IN:setContentDocumentIds               
                AND Expiration_Date__c >: system.Today()
                AND Content_Start_Date__c <=: system.Today()               
                ORDER BY Publish_Date__c DESC 
            ];
            showRealAllLink = false;
            
            if(ContentVersions != null && !ContentVersions.isEmpty())
            {
                Integer cnt = 0;
                Map<Id,ContentWrapper> userUrl = mapUser(ContentVersions);
                for(ContentVersion objContentVersion : ContentVersions)
                {   
                    //checks that there are no duplicate title
                    if (!subHeaderTitle.contains(objContentVersion.Title))
                    {  
                        // modified by Lalitha Adduru on 17th Feb 2015 to check 
                        // if the tag 'contains' leadership blog rather than 'equal to' ,
                        //  and an if condition prior to that, to prevent null pointer exception. 
                      //  if(objContentVersion.TagCsv != null)
                       // {
                          //  if (string.valueof(objContentVersion.TagCsv).contains('Leadership Blog'))
                        //    {
                                //get only 3 records ( Lalitha changed it to 3 from 5)
                                if (cnt == 3)
                                {
                                    showRealAllLink = true;
                                    break;
                                } 
                                else
                                {
                                    cnt++;    
                                    subHeaderTitle.add(objContentVersion.Title);                               
                                    ContentWrapper execInfo =  userUrl.get(objContentVersion.Executive__c);                                
                                    ContentWrapper contents = new ContentWrapper();
                                    contents.userFullName = execInfo.userFullName;
                                    contents.userUrl  = execInfo.userUrl;                                   
                                    contents.content = objContentVersion;
                                    contentSource.add(contents);   
                                }                              
                          //  }
                       // }
                    } 
                }
            }
        } // end of if condition
       
    } // end of contstructor
    
    public map<Id,ContentWrapper> mapUser(List<ContentVersion> contentVersions)
    {
        //get information of the user, and get the image url
        Map<Id,ContentWrapper> mapItem = new Map<Id,ContentWrapper>();
        Map<Id,Id> userId = new Map<Id,Id>();
        for(ContentVersion objContentVersion : contentVersions)
        {
            if (!userId.containsKey(objContentVersion.Executive__c)) {
                userId.put(objContentVersion.Executive__c,objContentVersion.Executive__c);
            }
        }
        
        List<User> listUser = [Select Id,Name, smallphotourl from User where Id in : userId.keySet() ];
        for (User users : listUser)
        {
            ContentWrapper content = new ContentWrapper();
            content.userUrl = users.smallphotourl;
            content.userFullName = users.Name;
            mapItem.put(users.Id,content);
        }
        
        return mapItem;
    }
    
    public class ContentWrapper {  
        public String userUrl { get; set; }
        public String userFullName { get; set; }
        public ContentVersion content { get; set; }
        
    }
}