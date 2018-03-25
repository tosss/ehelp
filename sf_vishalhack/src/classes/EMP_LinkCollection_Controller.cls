// 2016-07-26- anirudh.singh@cdk.com- Created this class for RQ-07332
// 2017-04-12 matt.keefe@cdk.com - Added Current User ADID to Links - RQ-08957
public class EMP_LinkCollection_Controller
{
    @AuraEnabled
    public static List<LinkWrapper> fetchLinkCollection(String linkCollectionName)
    {
        system.debug('Start fetchLinkCollection---->');
        List<LinkWrapper> linksWrapperList=new List<LinkWrapper>();
        
        if(linkCollectionName=='My Links')
        {
            linksWrapperList=fetchUserLinksList();
        }
        else
        {
            linksWrapperList=fetchLinksListForCollection(linkCollectionName);
        }
        
        system.debug('End fetchLinkCollection---->');
        return linksWrapperList;
    }
    
    private static List<LinkWrapper> fetchUserLinksList()
    {
    	User CurrentUser = fetchCurrentUser();
    	
        system.debug('Start fetchUserLinksList---->');
        List<LinkWrapper> linksWrapperList=new List<LinkWrapper>();
        
        //Fetch the Links with Linked_to_User__c as Current User Id.
        for(Page_Component__c currentUserLink: [
            SELECT Link_Text__c, Link_URL__c, Link_Use_ADID__c, Link_Target__c, Parent_Component__r.Name, Order__c
            FROM Page_Component__c 
            WHERE Linked_to_User__c=:UserInfo.getUserId()
            ORDER BY Order__c
        ])
        {
            LinkWrapper linkWrapperRecord=new LinkWrapper();
            
            // 2017-04-12 matt.keefe@cdk.com - added check for whether or not to append ADID
            if(currentUserLink.Link_Use_ADID__c == true) { currentUserLink.Link_URL__c += '?ADID=' + CurrentUser.ADID__c; } 
            linkWrapperRecord.link=currentUserLink;
            linksWrapperList.add(linkWrapperRecord);
        }
        
        return linksWrapperList;
    }
    
    private static List<LinkWrapper> fetchLinksListForCollection(String linkCollectionName)
    {
        List<LinkWrapper> linksWrapperList=new List<LinkWrapper>();
        
        User CurrentUser = fetchCurrentUser();
        
        //Fetch the Links with Parent as linkCollectionName.
        String linksListQuery = ' ' +
            'SELECT Link_Text__c, Link_URL__c, Link_Use_ADID__c, Link_Target__c, Link_Permission_Set_Id__c, Order__c, Parent_Component__r.Name ' +
            'FROM Page_Component__c ' +
            'WHERE Parent_Component__r.Name = \'' + linkCollectionName + '\' ' + 
            'ORDER BY Order__c ' +
            '';
        
        Map <Id, Page_Component__c> linksMap = new Map<Id, Page_Component__c>(
            (List<Page_Component__c>)Database.query(linksListQuery)
        );
        
        list<Page_Component__c> permissionSetLinks = new list<Page_Component__c>();
        for(Page_Component__c link : linksMap.values()) {
            if(link.Link_Permission_Set_ID__c != null) {
                permissionSetLinks.add(link);
            }
        }
        
        if(!permissionSetLinks.isEmpty()) 
        {
            // get permission sets for the current user
            List<PermissionSetAssignment> currentUserPermissionSets = [   
                SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :Userinfo.getUserId() 
            ];
            
            Set<Id> currentUserPermissionSetIds = new Set<Id>();
            if(currentUserPermissionSets != null && !currentUserPermissionSets.isEmpty()) {
                for(PermissionSetAssignment psa : currentUserPermissionSets) {
                    currentUserPermissionSetIds.add(psa.PermissionSetId);
                }
            }
            
            if(!currentUserPermissionSetIds.isEmpty()) 
            {
                for(Page_Component__c psl : permissionSetLinks) 
                {
                    if(!currentUserPermissionSetIds.contains(psl.Link_Permission_Set_ID__c)) 
                    {
                        linksMap.remove(psl.Id);
                    }
                }
            }
        }
        
        list<Page_Component__c> linksList = linksMap.values();
        
        // Used to see which of the collection links the current User is subscribed to
        //Fetch the Links with Linked_to_User__c as Current User Id and Original Link Parent Collection Name as linkCollectionName.
        String currentUserLinksQuery = ' ' +
            'SELECT Link_Text__c, Link_URL__c, Link_Use_ADID__c ' +
            'FROM Page_Component__c ' +
            'WHERE Linked_to_User__c = \'' + UserInfo.getUserId() + '\' ' + 
            'AND Original_Link_Name__r.Parent_Component__r.Name = \'' + linkCollectionName + '\' ' + 
            '';
        
        List<Page_Component__c> currentUserLinksForCollectionList = Database.query(currentUserLinksQuery);
        
        for(Integer i=0; i<linksList.size(); i++)
        {
            LinkWrapper linkWrapperRecord=new LinkWrapper();
            
            // 2017-04-12 matt.keefe@cdk.com - added check for whether or not to append ADID
            if(linksList[i].Link_Use_ADID__c == true) { linksList[i].Link_URL__c = linksList[i].Link_URL__c + '?ADID=' + CurrentUser.ADID__c; } 
            linkWrapperRecord.link=linksList[i];
            
            Boolean match=false;
            
            for(Integer j=0; j<currentUserLinksForCollectionList.size(); j++)
            {
                if(linksList[i].Link_Text__c==currentUserLinksForCollectionList[j].Link_Text__c)
                {
                    match=true;
                    break;
                }
            }
            
            linkWrapperRecord.addedToMyLinks=((match==true)? 'Yes' : 'No');
            linksWrapperList.add(linkWrapperRecord);
        }
        
        return linksWrapperList;
    }
    
    @AuraEnabled
    public static List<LinkWrapper> addSelectedLinkToUserLinks(String linkId, String linkCollectionName)
    {
        Page_Component__c linkRecord=[
            SELECT Name, Link_Text__c, Link_URL__c, Link_Use_ADID__c, Link_Target__c, Parent_Component__r.Name, Order__c, RecordTypeId
            FROM Page_Component__c 
            WHERE Id=:linkId
        ];
        
        Page_Component__c newLinkRecord=new Page_Component__c();
        newLinkRecord=linkRecord.clone();
        newLinkRecord.Name=linkRecord.Link_Text__c+' - '+UserInfo.getUserName();
        newLinkRecord.Parent_Component__c=Null;
        newLinkRecord.Original_Link_Name__c=linkRecord.Id;
        newLinkRecord.Linked_to_User__c=UserInfo.getUserId();
        insert newLinkRecord;
        
        return fetchLinksListForCollection(linkCollectionName);
    }
    
    @AuraEnabled
    public static List<LinkWrapper> removeSelectedLinkFromUserLinks(String linkId)
    {
        delete [SELECT Id FROM Page_Component__c WHERE Id=:linkId];
        
        return fetchUserLinksList();
    }
    
    // 2017-04-12 matt.keefe@cdk.com - added user query for getting ADID__c
    public static User fetchCurrentUser()
    {
        return [SELECT Id, Name, UserName, Email, ADID__c From User Where Id = :UserInfo.getUserId()];
    } 
    
    public class LinkWrapper
    {
        @AuraEnabled
        public Page_Component__c link{get; set;}
        
        @AuraEnabled
        public String addedToMyLinks{get; set;}
    }
}