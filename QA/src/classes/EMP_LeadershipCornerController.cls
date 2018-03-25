// 2016-01-26 matt.keefe@cdk.com - added CEO Messages
public class EMP_LeadershipCornerController
{    
    // 2016-01-25 matt.keefe@cdk.com - trimmed variables, added sections
    
    // constants
    public static final String CEO_MESSAGES_WORKSPACE = System.Label.EMP_Library_Name;
    public static final String CEO_CONTENT_TYPE = 'CEO Recaps';
    public static final Integer CEO_MAX_RECORDS = 1;
    public static final String LEADERSHIP_WORKSPACE = System.Label.EMP_Library_Name;
    public static final String LEADERSHIP_CONTENT_TYPE = 'Leadership Blog';
    public static final Integer LEADERSHIP_MAX_RECORDS = 2;
    
    // page variables
    public List<ContentWrapper> LeadershipSource {get;set;}
    public List<ContentWrapper> CEOMessagesSource {get;set;} // 2016-01-25 matt.keefe@cdk.com - added CEOMessages
    public String CEOUserPhotoURL {get;set;}
    
    public EMP_LeadershipCornerController()
    {
        // Leadership Corner
        // 2016-01-25 matt.keefe@cdk.com - modified Leadership Corner Section, 
        //   genericized content version query and added to separatemethod
        
        // CEO Messages
        List<ContentVersion> CEOMessages = QueryContentVersionMessages(CEO_MESSAGES_WORKSPACE, CEO_CONTENT_TYPE); // query
        CEOMessagesSource = WrapContent(CEOMessages, CEO_MAX_RECORDS); // wrap
        if(CEOMessagesSource != null && CEOMessagesSource.size() > 0) { CEOUserPhotoURL = CEOMessagesSource.get(0).userUrl; } // set photo url
        
        // Leadership Messages
        List<ContentVersion> LeadershipMessages = QueryContentVersionMessages(LEADERSHIP_WORKSPACE, LEADERSHIP_CONTENT_TYPE); // query
        LeadershipSource = WrapContent(LeadershipMessages, LEADERSHIP_MAX_RECORDS); // wrap
        
    } // end of contstructor
    
    // 2016-01-25 matt.keefe@cdk.com - added generic content version query
    public static list<ContentVersion> QueryContentVersionMessages(String workspace, String contentType)
    {
        EMP_ContentDocumentHelper cdhelper = new EMP_ContentDocumentHelper(workspace);
        set<Id> ContentDocumentIdSet = cdHelper.ContentDocumentIds;
        set<Id> latestVersion = cdHelper.LatestVersionIds;
        
        // query all ContentVersion
        list<ContentVersion> messages = new list<ContentVersion>();
        if(ContentDocumentIdSet != null && !ContentDocumentIdSet.isEmpty())
        {
            messages = [
                Select ContentDocumentId, Title, Publish_Date__c, TagCsv, Document_Type__c, Video_File_Location__c, Executive__c, Content_Type__c 
                From ContentVersion 
                WHERE Id IN: latestVersion AND content_Type__c = :contentType
                AND ContentDocumentId IN :ContentDocumentIdSet
                AND Expiration_Date__c > :system.Today()
                AND Content_Start_Date__c <= :system.Today()
                ORDER BY Publish_Date__c DESC 
            ];
        }
        
        return messages;
    }
    
    public static map<Id,ContentWrapper> mapUser(List<ContentVersion> contentVersions)
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
        
        List<User> listUser = [Select Id,Name, smallphotourl from User where Id in : userId.keySet()];
        for (User users : listUser)
        {
            ContentWrapper content = new ContentWrapper();
            content.userUrl = users.smallphotourl;
            content.userFullName = users.Name;
            mapItem.put(users.Id,content);
        }
        
        return mapItem;
    }
    
    public static list<ContentWrapper> WrapContent(list<ContentVersion> ContentVersions, Integer maxRecords)
    {
        list<ContentWrapper> source = new list<ContentWrapper>();
        
        if(ContentVersions != null && !ContentVersions.isEmpty())
        {
            Integer numberOfRecords = 0;
            Map<Id,ContentWrapper> userUrl = EMP_LeadershipCornerController.mapUser(ContentVersions);
            Set<String> subHeaderTitle = new Set<String>();
            
            for(ContentVersion objContentVersion : ContentVersions)
            {   
                //checks that there are no duplicate title
                if (!subHeaderTitle.contains(objContentVersion.Title))
                { 
                    // 2016-01-25 matt.keefe@cdk.com - changed to 2 from 3, removed commented code
                    //get only 3 records (Lalitha changed it to 3 from 5)
                    if (numberOfRecords == maxRecords)
                    {
                        break;
                    } 
                    else
                    {
                        numberOfRecords++;
                        subHeaderTitle.add(objContentVersion.Title);
                        ContentWrapper execInfo = userUrl.get(objContentVersion.Executive__c);
                        ContentWrapper contents = new ContentWrapper();
                        if(execInfo != null) {
                            contents.userFullName = execInfo.userFullName;
                            contents.userUrl  = execInfo.userUrl;
                        }
                        contents.content = objContentVersion;
                        source.add(contents);   
                    } 
                } 
            }
        }
        
        return source;
    }
    
    public class ContentWrapper 
    {  
        public String userUrl { get; set; }
        public String userFullName { get; set; }
        public ContentVersion content { get; set; }
        
    }
}