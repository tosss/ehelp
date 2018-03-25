public with sharing class EMP_ShowmoreController {
   public list<ContentVersion> lstContentVersions {get;set;}
   public boolean showsection{get;set;}
   public boolean showleadership{get;set;}
   
   public Set<String> subHeaderTitle = new Set<String>();
   public List<ContentWrapper> contentSource { get; set; }
   
   public EMP_ShowmoreController(){
	
		lstContentVersions = new list<ContentVersion>(); 
        contentSource = new List<ContentWrapper>();
		
        String ContentLibraryName = System.Label.EMP_Library_Name;
        String CurrPageName=apexpages.currentpage().getparameters().get('PageName');
       			CurrPageName = '%'+CurrPageName+'%';
       system.debug('******** current page' +CurrPageName);
        EMP_ContentDocumentHelper cdhelper = new EMP_ContentDocumentHelper(ContentLibraryName);
        set<Id> ContentDocumentIdSet = cdHelper.ContentDocumentIds;
        set<Id> latestVersion = cdHelper.LatestVersionIds;
  		String ContentType;
  		
        list<ContentVersion> ContentVersions = [
            Select ContentDocumentId, Title, Publish_Date__c, TagCsv, Document_Type__c, Video_File_Location__c,Content_Type__c ,Executive__c
            From ContentVersion 
            WHERE Id IN: latestVersion AND content_Type__c LIKE : CurrPageName 
            AND ContentDocumentId IN: ContentDocumentIdSet
            ORDER BY Publish_Date__c DESC 
        ];  
        system.debug('********** contentVersion content_Type__c  ' +ContentVersions[0].content_Type__c);
       			if(ContentVersions[0].content_Type__c =='Latest News' || ContentVersions[0].content_Type__c =='Ceo Recaps' || ContentVersions[0].content_Type__c =='IT Communication'){showsection = true;} 
       			
       			if(ContentVersions[0].content_Type__c =='Leadership Blog'){
       				showleadership= true;
       			system.debug('************** currentpage leadership' +currPageName);
                Map<Id,ContentWrapper> userUrl = mapUser(ContentVersions);
                for(ContentVersion objContentVersion : ContentVersions)
                
                {   
                	system.debug('************** forloop debug' +objContentVersion.title);
                       subHeaderTitle.add(objContentVersion.Title);                               
                       ContentWrapper execInfo =  userUrl.get(objContentVersion.Executive__c);                                
                       ContentWrapper contents = new ContentWrapper();
                       contents.userFullName = execInfo.userFullName;
                       contents.userUrl  = execInfo.userUrl;                                   
                       contents.content = objContentVersion;
                       contentSource.add(contents); 
                       system.debug('*************** contentSource'+contentSource);  
                }
            
        }  
      if(ContentVersions != null && !ContentVersions.isEmpty())
        {
            lstContentVersions = ContentVersions;
        }
    }
    
    
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