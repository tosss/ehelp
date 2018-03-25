//2016-09-26 ragashalini.koka@cdk.com - added method updateOwnerHierarchy to update the hierarchy fields of Owner on Opportunity for CPQ - RQ-07879
//2016-09-30 ragashalini.koka@cdk.com - added method addOpportunityLocations to insert an Opportunity Location for each Opportunity - RQ-07919
//2016-10-25 ragashalini.koka@cdk.com - added method handleOwnershipChanges and getOwnershipChanges - RQ-08086
public class DS_Opportunity_Handler 
{
    // 2011-11-08: Added a condition to only process those with Forecase in the team role -MK 
    // 2011-11-08: Made changes to exclude any Opportunity with a BZ Migration record type -MK (matt_keefe@adp.com)
    public static list<Opportunity> FilterBZMigrationOpportunities(list<Opportunity> TriggerNew)
    {
        list<Opportunity> OpportunitiesToProcess = new list<Opportunity>();
        
        // 1 describe
        Id BZMigrationRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity', 'BZ Migration');
        
        for(Opportunity o : TriggerNew)
        {
            if(BZMigrationRecordTypeId != null) {
                if(o.RecordTypeId != BZMigrationRecordTypeId) {
                    OpportunitiesToProcess.add(o); //system.debug('Adding to Process List: '+o); 
                }
            } 
            else { 
                OpportunitiesToProcess.add(o); //system.debug('Adding to Process List: '+o); 
            }
        }
        
        return OpportunitiesToProcess;
    }
    
    // Inserts a Sales Team for an Opportunity when it is updated.
    public static void AddSalesTeam(list<Opportunity> OpportunitiesToProcess)
    {
        set<Id> accountSet = new set<Id>();
        set<Id> opportunitySet = new set<Id>();
        list<Opportunity> notForecast = new list<Opportunity>();
        list<Id> ownerIdWithOppShare = new List<Id>();
        list<Id> opportunityId = new List<Id>();
        
        for(Opportunity newOppty : OpportunitiesToProcess)
        {
            if(newOppty.AccountId != null)
            {
                notForecast.add(newOppty);
                accountSet.add(newOppty.AccountId);
                opportunitySet.add(newOppty.Id);
            }
        }
        
        if(notForecast.size() == 0) return;
        
        List<Sales_Team__c> addSalesTeam = new List<Sales_Team__c>();
        Sales_Team__c salesTeamMem;
        
        // 1 soql
        List<Account_Team__c> accountTeamMems = [
            Select Id, Team_Member__c, Team_Role__c, Opportunity_Access__c, Account__c 
            From Account_Team__c 
            Where Account__c in :accountSet
            And Team_Role__c like '%Forecast%' 
        ]; 
        
        for(Opportunity oneOpp : notForecast) 
        {
            Boolean ownerHasSharing = false;
            for(Account_Team__c accountTeamMem : accountTeamMems)
            {
                if(oneOpp.AccountId == accountTeamMem.Account__c)
                {
                    if(!ownerHasSharing) 
                    {
                        ownerHasSharing = (accountTeamMem.Team_Member__c == oneOpp.CreatedById);
                    }
                    
                    salesTeamMem = new Sales_Team__c();
                    salesTeamMem.User__c = accountTeamMem.Team_Member__c;
                    salesTeamMem.Opportunity__c = oneOpp.Id;
                    salesTeamMem.Opportunity_Access__c = accountTeamMem.Opportunity_Access__c;
                    salesTeamMem.Team_Role__c = accountTeamMem.Team_Role__c;
                    addSalesTeam.add(salesTeamMem);
                }
            }
            
            if(!ownerHasSharing)
            {
                salesTeamMem = new Sales_Team__c();
                salesTeamMem.User__c = oneOpp.CreatedById;
                salesTeamMem.Opportunity__c = oneOpp.Id;
                salesTeamMem.Opportunity_Access__c = 'Read/Write';
                salesTeamMem.Team_Role__c = 'Non-Forecasting Rep';
                addSalesTeam.add(salesTeamMem);
            }
            
        }
        // 1 dml
        if(addSalesTeam.size() > 0)
        {
            insert addSalesTeam;
        }
    }
    
    // Updates a Shareing Rule for an Opportunity when it is inserted.
    // Sets the Owner Manager for an Opportunity when inserted or updated.
    public static void CreateOpportunityShare(list<Opportunity> OpportunitiesToProcess, list<Opportunity> TriggerOld)
    {
        // the owner will be changed after the workflow 
        //   process and it will cause the trigger to fire one more time. 
        // this part will be called after the workflow 
        //   because the owner is changed and the trigger 
        //   will create a record in OpportunityShare
        
        string oppId = '';
        string ownerId = '';
        string OldOwnerId  = '';
        List<OpportunityShare> updatedOppShare = new List<OpportunityShare>();
        OpportunityShare oppShareRec;
        
        for(Integer i = 0; i < OpportunitiesToProcess.size(); i++)
        {
            Id OpportunityId = OpportunitiesToProcess[i].Id;
            OwnerId = OpportunitiesToProcess[i].OwnerId;
            OldOwnerId = TriggerOld[i].OwnerId;
            
            if (ownerId != OldOwnerId) 
            {
                OppShareRec = new OpportunityShare();
                OppShareRec.UserOrGroupId = OldOwnerId;
                //OppShareRec.RowCause = 'Team';
                OppShareRec.OpportunityId = OpportunityId;
                OppShareRec.OpportunityAccessLevel = 'Edit';    
                updatedOppShare.add(oppShareRec); 
            }
            
            // 1 dml
            if(updatedOppShare.size() > 0)
            {
                system.debug(updatedOppShare);
                insert updatedOppShare;
            }
        }
    }
    
    //2016-09-26 ragashalini.koka@cdk.com - updates the owner hierarchy fields on Opportunity - RQ-07879
    public static void updateOwnerHierarchy(List<Opportunity> oldList, List<Opportunity> newList, Boolean isInsert)
    {
        
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        
        CustomSettings__c settings = CustomSettings__c.getOrgDefaults();
        String DMGControllerValue = settings.DMG_Controller_Approver__c;
        String coreLegalControllerValue = settings.Core_Legal_Approver__c;
        String coreVPFinanace = settings.Core_VP_Finance_Approver__c;
        
        Set<String> userNameSet = new Set<String>();
        userNameSet.add(DMGControllerValue);
        userNameSet.add(coreLegalControllerValue);
        userNameSet.add(coreVPFinanace);
        userNameSet.remove(null);
        List<User> customSettingsUserList = [SELECT Id, Name, BigMachines__Login__c FROM User WHERE Name IN :userNameSet];
        Map<String,User> customSettingsUserMap = new Map<String,User>();
        for(User usr : customSettingsUserList) {
            customSettingsUserMap.put(usr.Name, usr);
        }
        
        DMGControllerValue = customSettingsUserMap.get(DMGControllerValue)!=null ? customSettingsUserMap.get(DMGControllerValue).BigMachines__Login__c : null;
        coreLegalControllerValue = customSettingsUserMap.get(coreLegalControllerValue)!=null ? customSettingsUserMap.get(coreLegalControllerValue).BigMachines__Login__c : null;
        coreVPFinanace = customSettingsUserMap.get(coreVPFinanace)!=null ? customSettingsUserMap.get(coreVPFinanace).BigMachines__Login__c : null;
        
        Set<String> bigMachineLoginSet = getUsersToExclude(settings);
        
        for(Integer i = 0;i < newList.size();i++) {
            Id opportunityOwnerId = newList[i].ADP_Opportunity_Owner__c;
            Id accountId = newList[i].AccountId;
            if(opportunityOwnerId != null && accountId != null) {
                if(isInsert || oldList[i].ADP_Opportunity_Owner__c != opportunityOwnerId) {
                    userIdSet.add(opportunityOwnerId);
                }
                accountIdSet.add(accountId);
            }
        }
        if(userIdSet.size() > 0 || accountIdSet.size() > 0) {
            Map<Id,User> userMap = new Map<Id,User>([
                SELECT Id, Profile.Name, Title, BigMachines__Login__c, Manager.BigMachines__Login__c,
                Manager.Manager.BigMachines__Login__c, Manager.Manager.Manager.BigMachines__Login__c 
                FROM User
                WHERE Id IN :userIdSet]);
            Map<Id,Account> accountMap = new Map<Id,Account>([
                SELECT 
                Id, Region__c, Designated_DSM__c, Designated_DSM__r.BigMachines__Login__c, Designated_DSM__r.Manager.BigMachines__Login__c, 
                Designated_DSM__r.Manager.Manager.BigMachines__Login__c, Designated_DSM__r.Manager.Manager.Manager.BigMachines__Login__c,
                Key_Rep__c, Key_Rep__r.BigMachines__Login__c, Key_Rep__r.Manager.BigMachines__Login__c, 
                Key_Rep__r.Manager.Manager.BigMachines__Login__c, Key_Rep__r.Manager.Manager.Manager.BigMachines__Login__c
                FROM Account 
                WHERE Id IN :accountIdSet
            ]);
            
            //Get the AVP_RGM_Link__c records based on region to populate CPQ_Core_Controller__c field
            Map<String,String> avpRegionToControllerMap  = new Map<String,String>();
            Map<String,String> accToRegionMap = new Map<String,String>();
            Set<String> accountRegionSet = new Set<String>();
            for(Id accId : accountMap.keySet()) {
                String accountRegion = accountMap.get(accId).Region__c;
                if(accountRegion != null) {
                    accountRegionSet.add(accountRegion);
                    accToRegionMap.put(accId, accountRegion);
                }
            }
            if(accountRegionSet.size() > 0) {
                List<AVP_RGM_Link__c> avpRecordList = [SELECT Id, Controller__r.BigMachines__Login__c, Region__c FROM AVP_RGM_Link__c WHERE Region__c IN :accountRegionSet];
                if(avpRecordList != null) {
                    for(AVP_RGM_Link__c avpRecord : avpRecordList) {
                        if(avpRecord.Region__c != null) {
                            avpRegionToControllerMap.put(avpRecord.Region__c, avpRecord.Controller__r.BigMachines__Login__c);
                        }
                    }
                } 
                
            }
            
            for(Integer i = 0;i < newList.size();i++) {
                Id opportunityOwnerId = newList[i].ADP_Opportunity_Owner__c;
                Id accountId = newList[i].AccountId;
                if(isInsert || oldList[i].ADP_Opportunity_Owner__c != opportunityOwnerId) {
                    if(opportunityOwnerId != null && accountId != null) {
                        User userRecord = userMap.get(opportunityOwnerId);
                        Account accountRecord = accountMap.get(accountId);
                        if(userRecord != null && accountId != null) {
                            if((userRecord.Title != null && userRecord.Title.containsIgnoreCase('DSM')) || userRecord.Profile.Name.startsWithIgnoreCase('Cobalt')) {
                                populateHierarchy(newList[i], userRecord, bigMachineLoginSet, 'DMG');
                                populateHierarchy(newList[i], accountRecord.Key_Rep__r, bigMachineLoginSet, 'Core');
                            }
                            else {
                                populateHierarchy(newList[i], userRecord, bigMachineLoginSet, 'Core');
                                
                            }
                            if(accountRecord.Designated_DSM__c != null && newList[i].CPQ_DMG_Rep__c == null) {
                                populateHierarchy(newList[i], accountRecord.Designated_DSM__r, bigMachineLoginSet, 'DMG');
                            }
                            populateHierarchy(newList[i], accountRecord.Key_Rep__r, bigMachineLoginSet, 'Baseline');
                            
                            //populates Digital Rep fields with Core Rep fields
                            if(newList[i].CPQ_DMG_rep__c == null && newList[i].CPQ_Core_Rep__c != null) {
                                
                                newList[i].CPQ_DMG_Rep__c = newList[i].CPQ_Core_Rep__c;
                                newList[i].CPQ_DMG_Mgr__c = newList[i].CPQ_Core_Mgr__c;
                                newList[i].CPQ_DMG_Mgr_Mgr__c = newList[i].CPQ_Core_Mgr_Mgr__c;
                                newList[i].CPQ_DMG_Mgr_Mgr_Mgr__c = newList[i].CPQ_Core_Mgr_Mgr_Mgr__c;
                            }
                        }
                    }
                    else {
                        populateHierarchy(newList[i], null, bigMachineLoginSet, 'DMG');
                        populateHierarchy(newList[i], null, bigMachineLoginSet, 'Core');
                        populateHierarchy(newList[i], null, bigMachineLoginSet, 'Baseline');
                        
                    }
                    
                }
                newList[i].CPQ_DMG_Controller__c = DMGControllerValue;
                newList[i].CPQ_Core_Legal__c = coreLegalControllerValue;
                newList[i].CPQ_Core_VP_Finance__c = coreVPFinanace;
                newList[i].CPQ_Core_Controller__c = avpRegionToControllerMap.get(accToRegionMap.get(accountId));
            }
        }
        
    }
    
    private static void populateHierarchy(Opportunity opp, User usr,Set<String> bigMachineLoginSet,String fieldKey) {
        Map<String,String> oppToUserPropertiesMap = new Map<String,String>();
        oppToUserPropertiesMap.put('CPQ_' + fieldKey +'_Rep__c','BigMachines__Login__c');
        oppToUserPropertiesMap.put('CPQ_' + fieldKey +'_Mgr__c','Manager.BigMachines__Login__c');
        oppToUserPropertiesMap.put('CPQ_' + fieldKey +'_Mgr_Mgr__c','Manager.Manager.BigMachines__Login__c');
        oppToUserPropertiesMap.put('CPQ_' + fieldKey +'_Mgr_Mgr_Mgr__c','Manager.Manager.Manager.BigMachines__Login__c');
        
        for(String key : oppToUserPropertiesMap.keySet()) {
            String userId = null;
            if(usr != null) {
                userId = getData(oppToUserPropertiesMap.get(key), usr);
                if(bigMachineLoginSet.contains(userId) && key.containsIgnoreCase('Mgr')) {
                    userId = null;
                }
            }
            opp.put(key, userId);
        }
        
    }
    
    private static String getData(String fieldName,SObject obj) {
        try {
            return String.valueOf(ALL_UtilitiesData.GetDataFromNestedFields(fieldName, obj));
        }
        catch(Exception exp) {
            return null;
        }
    }
    
    //2016-09-30 ragashalini.koka@cdk.com - inserts an Opportunity Location of Site Record type for the given Opportunities
    public static void addOpportunityLocations(List<Opportunity> newList) 
    {
       Set<Id> accIdSet = new Set<Id>();
        for(Opportunity oppRec : newList) {
            accIdSet.add(oppRec.AccountId);
        }
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id FROM Account WHERE PartyId__c != null AND Id IN :accIdSet]);
        createOpportunityLocations(newList, accMap);
    }
    
    public static void createOpportunityLocations(List<Opportunity> oppList, Map<Id,Account> accMap) {
        
        List<Opportunity_Location__c> opportunityLocationsList = new List<Opportunity_Location__c>();
        String siteRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c', 'Site');
         // 2017-04-12 ragashalini.koka@cdk.com - creates locations only if the Account has a party Id for RQ-09015
        for(Opportunity oppRec : oppList) {
            if(accMap.containsKey(oppRec.AccountId)) {
                Opportunity_Location__c opportunityLocationRecord = new Opportunity_Location__c();
                opportunityLocationRecord.Opportunity__c = oppRec.Id;
                opportunityLocationRecord.Site__c = oppRec.AccountId;
                opportunityLocationRecord.RecordTypeId = siteRecordTypeId;
                opportunityLocationsList.add(opportunityLocationRecord);
            }
        }
        
        insert opportunityLocationsList;
       
        
    }
    
    //returns the BigMachines__Login__c values of the users to be excluded.
    public static Set<String> getUsersToExclude(CustomSettings__c settings) {
        Set<String> bigMachineLoginSet = new Set<String>();
        try {
            Set<String> userNameSet = new Set<String>(settings.Users_To_Exclude_CPQ_Approval__c.split(','));
            if(userNameSet.size() > 0) {
                List<User> userList = [
                    SELECT Id, BigMachines__Login__c, Manager.BigMachines__Login__c, Manager.Manager.BigMachines__Login__c, Manager.Manager.Manager.BigMachines__Login__c 
                    FROM User
                    WHERE Name IN :userNameSet 
                ];
                
                for(User usr : userList) {
                    bigMachineLoginSet.add(usr.BigMachines__Login__c);
                    bigMachineLoginSet.add(usr.Manager.BigMachines__Login__c);
                    bigMachineLoginSet.add(usr.Manager.Manager.BigMachines__Login__c);
                    bigMachineLoginSet.add(usr.Manager.Manager.Manager.BigMachines__Login__c);
                }
                bigMachineLoginSet.remove(null);
            }
        }
        catch(Exception exp) {
            
        }
        return bigMachineLoginSet;
        
        
    }
    
    //2016-10-25 ragashalini.koka@cdk.com - sets the Ownership_Change_CMF__c on opportunity locations
    public static void handleOwnershipChanges(List<Opportunity> oldList, List<Opportunity> newList, Boolean isInsert)
    {
        Set<Id> opportunityIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        for(Integer i = 0;i < newList.size();i++) 
        {
            if(isInsert ||(newList[i].SLS_Buyer_Account__c != oldList[i].SLS_Buyer_Account__c)) 
            {
                opportunityIdSet.add(newList[i].Id);
                accountIdSet.add(newList[i].AccountId);
            }
        }
        if(opportunityIdSet.size() > 0 && accountIdSet.size() > 0) {
            List<Opportunity_Location__c> oppLocationList = [
                SELECT Id, Site__r.Dealer_Group_Name2__c, Opportunity__r.SLS_Buyer_Account__r.Dealer_Group_Name2__c, Opportunity__r.AccountId
                FROM Opportunity_Location__c
                WHERE Opportunity__c IN :opportunityIdSet
            ];
            
            //2016-11-17  ragashalini.koka@cdk.com - modified the query
            Map<Id,CMF_Info__c> CMFInfoMap = new Map<Id,CMF_Info__c>([
                SELECT Id, SLS_Baseline_CMF_Number__c, Ship_CMF__c, Account__c, CMF_Replaced__c 
                FROM CMF_Info__c 
                WHERE Status__c = 'A' AND CMF_Replaced__c != null AND 
                ((NOT SLS_Ownership_Change_Type__c LIKE '%Shared System%') OR SLS_Ownership_Change_Type__c = null)
                AND Account__c IN :accountIdSet
            ]);
            System.debug('CMF Info Map : ' + CMFInfoMap + accountIdSet);
            Map<Object,Set<Object>> accountToIdSetMap = CPQ_BigMachinesQuote_Handler.groupRecords(CMFInfoMap.values(), 'Account__c', 'Id');
            System.debug('account To Id Set Map : ' + accountToIdSetMap);
            for(Opportunity_Location__c oppLocation : oppLocationList) 
            {
                if(oppLocation.Site__r.Dealer_Group_Name2__c == oppLocation.Opportunity__r.SLS_Buyer_Account__r.Dealer_Group_Name2__c) 
                {
                    Id accId = oppLocation.Opportunity__r.AccountId;
                    oppLocation.Ownership_Change_CMF__c = getOwnershipChanges(accId, accountToIdSetMap, CMFInfoMap);
                }
                
            }
            
            update oppLocationList;
        }
    }
    public static void setDocusignCC(List<Opportunity> newList, Map<Id,Opportunity> oppMap)
    {
        Map<Id,Id> accountToOpportunityMap = new Map<Id,Id>();
        for(Opportunity opp: newList)
        {
            if(oppMap.get(opp.Id).SLS_Buyer_Account__c != opp.SLS_Buyer_Account__c)
            {
                accountToOpportunityMap.put(opp.AccountId,opp.Id);
            }
        }
        Map<Id,Id> topAccountsMap = AccountHierarchyTools.recursivelyFetchTopParentAccountIdList(new List<Id>(accountToOpportunityMap.keySet()));			
        
        for(Id accountId:topAccountsMap.keySet())		
        {			
            accountToOpportunityMap.put(topAccountsMap.get(accountId),accountToOpportunityMap.get(accountId));		
        }       		
        CPQ_OpportunityLocation_Handler.setAccountRequiredCCs(accountToOpportunityMap);
    }
    private static String getOwnershipChanges(Id accId, Map<Object,Set<Object>> accountToIdSetMap, Map<Id,CMF_Info__c> CMFInfoMap) 
    {
        if(accountToIdSetMap.containsKey(accId))
        {
            for(Object CMFId : accountToIdSetMap.get(accId))
            {
                CMF_Info__c CMFInfoRecord = CMFInfoMap.get(String.valueOf(CMFId));
                if(CMFInfoRecord.SLS_Baseline_CMF_Number__c == CMFInfoRecord.Ship_CMF__c)
                {
                    return CMFInfoRecord.CMF_Replaced__c;
                }
            }
        }
        return null;
        
    }
    
    
}