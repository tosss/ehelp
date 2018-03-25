public class EMP_CommunityController {
    
    public List<EMP_Community_Item__c> communityDataCol1 { get; set; }
    public List<EMP_Community_Item__c> communityDataCol2{ get; set; }
    public List<EMP_Community_Item__c> communityDataCol3{ get; set; }
    public Boolean showDefault { get; set; }
    public Boolean showSOC { get; set; }
    
    //9 Feb 2015 Hemanth Added class variables to store groups that are created on communities
    public Boolean displayCollabGroups {get;set;}
    public  List<CollaborationGroupWrapper> CollabGroupWrapperList {get;set;}
    
    public EMP_CommunityController() {
        String showComponent = ApexPages.CurrentPage().getParameters().get('page');
        
        // 2015-02-15 MK added for collaboration groups
        this.collabGroupWrapperList = getCollaborationGroups();
        if(collabGroupWrapperList==null || collabGroupWrapperList.isEmpty())
        {
            displayCollabGroups = false;
        }
        
        showComponents(showComponent);
        if (showDefault == true)       
        {
            //load data from custom settings
            List<EMP_Community_Item__c> lstContent = EMP_Community_Item__c.getAll().values(); 
            //compute the number of items per column
            Integer seperateCount = lstContent.size() / 3;
            
            List<CommunityWrapper> sortedList = sortManual(lstContent);
            
            communityDataCol1 =  new List<EMP_Community_Item__c>();
            communityDataCol2 =  new List<EMP_Community_Item__c>();
            communityDataCol3 = new List<EMP_Community_Item__c>();
            Integer ctr = 1;
            Integer cnt = 1;
            //seperate the content into 3 column
            //ctr represent the column number
            //cnt represent the count of records
            for(CommunityWrapper comWrap : sortedList){   
                EMP_Community_Item__c setting = comWrap.content;    
                if (ctr == 1)
                {
                    communityDataCol1.add(setting);           
                }else if(ctr == 2)
                {
                    communityDataCol2.add(setting);           
                }else
                {
                    communityDataCol3.add(setting);           
                }
                //increment cnt when number of record match the number of the seperateCount
                //reset the cnt
                if (cnt == seperateCount)
                {
                    ctr++;
                    cnt = 1;
                }else
                {
                    cnt++;
                }
            }
        }
    }
    

    private void showComponents(String showComponent)
    {
        showDefault = false;
        showSOC = false;
        
        // 2015-02-11 MK - allowed for LowerCase
        if(showComponent != null && showComponent.toLowerCase() == 'soc') { 
            showSOC = true;
        } else {
            showDefault = true;
        }
    }
    
    public List<CommunityWrapper> sortManual(List<EMP_Community_Item__c> lstCom)
    {
        //sort by Community_Name__c
        List<CommunityWrapper> sortedList = new List<CommunityWrapper>();
        for(EMP_Community_Item__c setting : lstCom){
            CommunityWrapper community = new CommunityWrapper();
            community.communityName = setting.Community_Name__c;
            community.content = setting;
            sortedList.add(community);
        }
        sortedList.sort();        
        return sortedList;
    }
    
    /*This method fetches all the groups that exists on a community 
        which are not restricted to the logged in user. */
    public List<CollaborationGroupWrapper> getCollaborationGroups()
    {
        List<CollaborationGroupMember> groupMemberList  = [
            select CollaborationGroupId, MemberId 
            from CollaborationGroupMember 
            where MemberId = :UserInfo.getUserId()
        ];
        
        if(!groupMemberList.isEmpty() || groupMemberList!=null)
        {
            List<Id> groupIdList = new List<Id>();
            for(CollaborationGroupMember CollaborationGroupMemberObj : groupMemberList)
            {
                groupIdList.add(CollaborationGroupMemberObj.CollaborationGroupId);
            }
            
            List<CollaborationGroup> groupList = [
                select NetworkId, Id, Name 
                from CollaborationGroup 
                where NetworkId != null 
                and Id IN :groupIdList
            ];
            
            if(!groupList.isEmpty() || groupList != null)
            {
                List<CollaborationGroupWrapper> wrapperList = new  List<CollaborationGroupWrapper>();
                
                // use getall().values() for retrieving custom settings
                List<EMP_Group_And_Team_Page__c> groupTeamMappingList = EMP_Group_And_Team_Page__c.getall().values();
                
                Map<Id,String> groupIdURLMap = new Map<Id,String>();
                if (groupTeamMappingList != null || !groupTeamMappingList.isEmpty())
                {
                    for(EMP_Group_And_Team_Page__c groupTeamMappingObj : groupTeamMappingList)
                    {
                        groupIdURLMap.put(groupTeamMappingObj.Collaboration_Group_Id__c, groupTeamMappingObj.Team_Page_URL__c);
                    }
                    
                    for(CollaborationGroup groupObj : groupList)
                    {
                        CollaborationGroupWrapper wrapperObj = new CollaborationGroupWrapper();
                        wrapperObj.groupId = groupObj.Id;
                        wrapperObj.groupName = groupObj.Name;
                        
                        if(groupIdURLMap.containsKey(groupObj.Id))
                        {
                            wrapperObj.groupURL = groupIdURLMap.get(groupObj.Id);
                            wrapperList.add(wrapperObj);
                        }
                    }
                    
                    //Set to true to enable divs/data table on visualforce page
                    displayCollabGroups = true;
                    return wrapperList;
                }
                else
                {
                    System.debug('$$ Group Id or Url does not exists in Custom Settings');
                    //Set to false to disable divs/data table on visualforce page
                    displayCollabGroups = false;
                    return null;
                }
                
            }
            else
            {
                displayCollabGroups = false;
                System.debug('$$ No chatter groups exists on the Community');
                return null;
            }
        }
        else
        {
            displayCollabGroups = false;
            System.debug('$$ '+UserInfo.getUserId()+  ' do not have access to chatter groups');
            return null;
        }
    }
    
    //Class to wrap Group Id, Group Name and Group URL
    public class CollaborationGroupWrapper
    {
        public String groupId{get;set;}
        public String groupURL{get;set;}
        public String groupName{get;set;}
    }
    
    public class CommunityWrapper implements Comparable
    {
        public String communityName { get; set; }
        public EMP_Community_Item__c content { get; set; }
        public Integer compareTo(Object compareTo)
        {
            CommunityWrapper comWrap = (CommunityWrapper) compareTo;
            if (communityName == comWrap.communityName) return 0;
            if (communityName > comWrap.communityName) return 1;
            return -1;  
        }
    }
}