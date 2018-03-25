//2016-02-08- lalitha.adduru@cdk.com- created the handler class for All_SLSARMVisit Trigger on SLS_ARM_Visit__c
//2017-01-30 - ragashalini.koka@cdk.com - added method assign ARM and ARM Supervisor field for RQ-08537
//2017-01-30 - ragashalini.koka@cdk.com - added code to automate the submission of Approval Process for RQ-08537
//2017-04-11 - ragashalini.koka@cdk.com - added setKeyDOSEmail method to populate Key_DOS_Email__c for RQ-09007
public class ALL_SLSARMVisit_Handler {
    
    // before insert, set supervisor
    public static void setSupervisor(List<SLS_ARM_Visit__c> triggerNew)
    {
        // get all accountIds from Visits into a list 
        List<id> accountIdList = new List<id>();
        for(SLS_ARM_Visit__c visit : triggerNew)
        {
            accountIdList.add(visit.Account__c);
        }
        
        // account to region Map
        Map<id,Account> accountMap = new Map<id,Account>([select id, Region__c from Account where id in :accountIdList]);
        
        // get All AVP_RGM_Link list to find the required link
        List<AVP_RGM_Link__c> rgmLinkList = new List<AVP_RGM_Link__c>();
        rgmLinkList = [
            select id, ARM_Supervisor__c , Region__c
            from AVP_RGM_Link__c
        ];
        
        // AVP_RGM_Link__c.region to AVP_RGM_Link__c.supervisor Map
        Map<string,id> regionToSupervisorMap = new Map<String,id>();
        if(rgmLinkList != null && !rgmLinkList.isEmpty())
        {
            for(AVP_RGM_Link__c rgmLink : rgmLinkList)
            {
                regionToSupervisorMap.put(rgmLink.Region__c, rgmLink.ARM_Supervisor__c);
            }
        }
        
        if(regionToSupervisorMap != null && !regionToSupervisorMap.isEmpty())
        {
            for(SLS_ARM_Visit__c ARMVisit : triggerNew)
            {
                // check if ARMVisit.Account__r.region__c is equal to any AVPRGMLink.Region__c
                if(regionToSupervisorMap.get(accountMap.get(ARMVisit.Account__c).region__c) != null)
                {
                    // assign AVP_RGM_Link__c.supervisor to ARMVisit.ARM_Supervisor__c
                    ARMVisit.ARM_Supervisor__c = regionToSupervisorMap.get(accountMap.get(ARMVisit.Account__c).region__c );
                }
            }
        }        
    }
    
    //populates ARM Assigned and ARM Supervisor fields if Created User's title is ARM
    public static void populateARMSupervisor(List<SLS_ARM_Visit__c> newList)
    {
        User currentUser = checkARMUser();
        if(currentUser != null) {
            for(SLS_ARM_Visit__c ARMVisitRec : newList) 
            {
                ARMVisitRec.ARM_Assigned__c = currentUser.Id;
                ARMVIsitRec.ARM_Supervisor__c = currentUser.ManagerId;
                
            }
        }
        
    }
    
    public static void updateStatus(List<SLS_ARM_Visit__c> oldList, List<SLS_ARM_Visit__c> newList)
    {
        
        User currentUser = checkARMUser();
        System.debug('currentUser : ' + currentUser);
        if(currentUser != null) 
        {
            for(Integer i = 0;i < newList.size();i++) 
            {
                System.debug('Tracking ---' + newList[i].Status__c + '---' + oldList[i].Status__c);
                if(newList[i].Visit_Report_Completed__c && newList[i].Status__c == 'Visit Approved' && newList[i].Status__c != oldList[i].Status__c) 
                {
                    newList[i].Status__c = 'Visit Completed';
                }
            }
        }
        
    }
    
    private static User checkARMUser() 
    {
        
        User currentUser = [SELECT Id, Title, ManagerId FROM User WHERE Id = :UserInfo.getUserId()];
        if(currentUser.Title != null && currentUser.Title.equalsIgnoreCase('ARM')) 
        {
            return currentUser;
        }
        else
        {
            return null;
        }
    }
    
    //automatically submits the record for approval on creation
    public static void submitForApproval(List<SLS_ARM_Visit__c> oldList, List<SLS_ARM_Visit__c> newList) 
    {
        
        List<Approval.ProcessSubmitRequest> requestList = new List<Approval.ProcessSubmitRequest>();
        
        for(Integer i = 0;i < newList.size(); i++) 
        {
            if(newList[i].Status__c == 'Visit Requested' && (oldList == null || newList[i].Status__c != oldList[i].Status__c)) 
            {
                Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setObjectId(newList[i].Id);
                requestList.add(request);
            }
            
            //System.debug('owner id :' + newList[i].OwnerId + 'ARM Assigned : ' + newList[i].ARM_Assigned__c);
        }
        
        
        
        if(requestList.size() > 0)
        {
            List<Approval.ProcessResult> resultList = Approval.Process(requestList);
        }
    }
    
    public static void postOnChatter(Map<Id,SLS_ARM_Visit__c> oldMap, List<SLS_ARM_Visit__c> newList)
    {
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        for(SLS_ARM_Visit__c visit : newList)
        {
            if(oldMap == null || oldMap.get(visit.Id).ARM_Assigned__c != visit.ARM_Assigned__c) 
            {
                userIdSet.add(visit.ARM_Assigned__c);
                accIdSet.add(visit.Account__c);
            }
        }
        System.debug('userIdSet :' + userIdSet);
        userIdSet.remove(null);
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id,Name FROM User WHERE Id IN : userIdSet]);
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,Name FROM Account WHERE Id IN : accIdSet]);
        String msgTemplate = 'Hi {0},\n ARM Visit : ( {1} )for {2} located at {3} has been assigned to you!!';  
        
        List<FeedItem> feedItemList = new List<FeedItem>();
        for(SLS_ARM_Visit__c visit : newList)
        {
            if((oldMap == null || oldMap.get(visit.Id).ARM_Assigned__c != visit.ARM_Assigned__c) &&  userMap.containsKey(visit.ARM_Assigned__c)) 
            {
                List<String> substituteStringList = new List<String>(); 
                substituteStringList.add(userMap.get(visit.ARM_Assigned__c).Name);
                substituteStringList.add(visit.Visit_Link__c);
                substituteStringList.add(accMap.get(visit.Account__c).Name);
                substituteStringList.add(visit.Dealership_Address__c);
                FeedItem item = new FeedItem();
                item.Body = String.format(msgTemplate, substituteStringList);
                item.ParentId = visit.ARM_Assigned__c ;
                feedItemList.add(item);
            }
            
        }
        
        
        insert feedItemList;
        
        
    }
    
    public static void setKeyDOSEmail(List<SLS_ARM_Visit__c> newList)
    {
        Set<Id> accIdSet = new Set<Id>(); 
        for(Integer i = 0 ;i < newList.size();i++)
        {
            accIdSet.add(newList[i].Account__c);
        }
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id, Key_DOS__r.Email FROM Account WHERE Id IN :accIdSet]);
        
        for(Integer i = 0;i < newList.size();i++)
        {
            Account currentAcc = accMap.get(newList[i].Account__c);
            if(newList[i].Key_DOS_Email__c == null || newList[i].Key_DOS_Email__c != currentAcc.Key_DOS__r.Email)
            {
                newList[i].Key_DOS_Email__c = currentAcc.Key_DOS__r.Email;
            }
            
        }
    }
    
}