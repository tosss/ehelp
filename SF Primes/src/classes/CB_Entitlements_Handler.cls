public class CB_Entitlements_Handler 
{
    public static void routeEntitlementCallsToHandlers(list<Case> creativeAndTechSupportCases, map<ID, Case> oldMap)
    {
        //Added by hemanth 2015-07-13 for updating case with Entitlements from related recordType
        Map<String,CB_CasePreviousRecordType__c> oldRecTypeMap = CB_CasePreviousRecordType__c.getAll();
        Map<String,CB_CaseRecordTypes__c> newRecTypeMap = CB_CaseRecordTypes__c.getAll();
        List<Case> updateCaseList = new List<Case>();
        set<Id> updateTargetDateTimeOfCaseIds = new set<Id>();
        
        if(creativeAndTechSupportCases != null && !creativeAndTechSupportCases.isEmpty())
        {
            for(Case caseObj : creativeAndTechSupportCases)
            {
                String newRecordName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Case', caseObj.RecordTypeId);
                String previousRecordName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Case', oldMap.get(caseObj.Id).RecordTypeId);
                if(oldRecTypeMap.containsKey(previousRecordName) && newRecTypeMap.containsKey(newRecordName))
                { 
                    updateCaseList.add(caseObj);
                    if(newRecordName != 'Inquiry - Creative')
                    {
                        updateTargetDateTimeOfCaseIds.add(caseObj.Id); 
                    }  
                }
            }
        }
        if(!updateCaseList.isEmpty())
        {
            CB_EntitlementsToCaseAssignment_Handler.updateEntToCase(updateCaseList, oldMap); 
        }
        if(!updateTargetDateTimeOfCaseIds.isEmpty())
        { 
            CB_MileStoneDatesOnCase_Handler.updateTargetDateTimeAI(updateTargetDateTimeOfCaseIds);
        }
    }
    
    public static void entitlementsToCasesBU(list<Case> EntitlementToCasesBU, map<ID, Case> oldMap)
    {
        boolean notFutureOrBatch = !system.isFuture() && !system.isBatch() && !system.isScheduled();
        
        if( EntitlementToCasesBU != null && !EntitlementToCasesBU.isEmpty()) 
        {
            Id oldWebId;
            String oldStatus='';
            String newStatus='';
            list<Case> casesToUpdate = new list<Case>();
            set<Id> targetDateTimeCaseIds = new set<Id>();
            set<Id> webIdSet = new set<Id>();
            set<Id> oldSet = new set<Id>();
            boolean statusChangedSoSetSlaStartTime = false;
            
            for(Case cs:EntitlementToCasesBU)
            {
                webIdSet.add(cs.WebID__c);
            }
            for(Case cs:oldMap.values())
            {
                oldSet.add(cs.WebID__c);
            }
            
            map<Id, WebID__c> allWebIDMap = new map<Id, WebID__c>([
                select Id, Status__c from WebID__c where Id IN: webIdSet or Id IN: oldSet
            ]);
            
            map<Id, WebID__c> newWebIDMap = new map<Id, WebID__c>();
            map<Id, WebID__c> oldWebIDMap = new map<Id, WebID__c>();
            
            for(Id WebIDId : allWebIDMap.keySet()) 
            {
                WebID__c currentWebID = allWebIDMap.get(WebIDId);
                if(webIdSet.contains(WebIDId)) { newWebIDMap.put(WebIDId, currentWebID); }
                if(oldSet.contains(WebIDId)) { oldWebIDMap.put(WebIDId, currentWebID); }
            }
            for(Case c:EntitlementToCasesBU)
            {
                oldWebId = oldMap.get(c.Id).WebId__c;
                if(oldWebId!=null){
                    oldStatus = oldWebIDMap.get(oldWebId).Status__c;
                }
                if(c.WebID__c!=null)
                {
                    newStatus = newWebIDMap.get(c.WebID__c).Status__c;
                }
                system.debug('---------oldStatus----------'+oldStatus);
                system.debug('---------newStatus----------'+newStatus);
                
                if(c.status != null)
                {
                    if((c.Status.containsIgnoreCase('Fix') && !oldMap.get(c.ID).Status.containsIgnoreCase('Fix')) || 
                       (c.Status.containsIgnoreCase('Changes') && !oldMap.get(c.ID).Status.containsIgnoreCase('Changes')) || 
                       (c.Status.containsIgnoreCase('Minor Edit') && !oldMap.get(c.ID).Status.containsIgnoreCase('Minor Edit')) ||
                       (c.Status.containsIgnoreCase('Design') && !oldMap.get(c.ID).Status.containsIgnoreCase('Design')) ||
                       (c.Status.containsIgnoreCase('Open') && !oldMap.get(c.ID).Status.containsIgnoreCase('Open')) ||
                       (c.Status.containsIgnoreCase('911') && !oldMap.get(c.ID).Status.containsIgnoreCase('911')) ||
                       (c.Status.containsIgnoreCase('Dealer Review') && !oldMap.get(c.ID).Status.containsIgnoreCase('Dealer Review')) ||
                       (c.Status.containsIgnoreCase('Blocked') && !oldMap.get(c.ID).Status.containsIgnoreCase('Blocked')) ||
                       (c.Status.containsIgnoreCase('On Hold') && !oldMap.get(c.ID).Status.containsIgnoreCase('On Hold')))
                    {
                        statusChangedSoSetSlaStartTime = true;
                    }
                }
                
                if(((c.WebID__c!=null && oldWebId==null)||
                    (oldStatus=='Inactive' && (newStatus=='Active' || newStatus=='New') && c.WebID__c!=oldWebId)) ||
                   statusChangedSoSetSlaStartTime)
                {
                    casesToUpdate.add(c); 
                    if(c.RecordTypeId != ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case','Inquiry - Creative'))
                    {
                        targetDateTimeCaseIds.add(c.Id);  
                    }
                    
                }
                
            }
            if(!casesToUpdate.isEmpty())
            {
                CB_EntitlementsToCaseAssignment_Handler.updateEntToCase(casesToUpdate, oldMap); 
            }
            
            if(!targetDateTimeCaseIds.isEmpty() && notFutureOrBatch)
            { 
                CB_MileStoneDatesOnCase_Handler.updateTargetDateTimeAI(targetDateTimeCaseIds);
            }
        }
    }
    
    public static void completionDateCasesAU(list<Case> completionDateCasesAU, map<ID, Case> oldMap)
    {
        boolean notFutureOrBatch = !system.isFuture() && !system.isBatch() && !system.isScheduled();
        
        if( completionDateCasesAU != null && !completionDateCasesAU.isEmpty()) 
        {    
            Set<Id> csIds = new set<id>(); 
            Set<Id> targetCaseIds = new set<id>(); 
            
            for(Case newCase: completionDateCasesAU)
            { 
                Case oldCase = oldMap.get(newCase.ID);
                
                if(oldCase.status.containsIgnoreCase('Closed')||
                   (oldCase.status.containsIgnoreCase('Resolved') && 
                    !newCase.status.containsIgnoreCase('Resolved') && 
                    !newCase.status.containsIgnoreCase('Closed'))) 
                {
                    csIds.add(oldCase.id); 
                }
                
                if(oldCase.EntitlementId != null )
                {
                    Boolean addCase = false;
                    
                    for(CB_CaseFields__c caseField : CB_CaseFields__c.getAll().values())
                    {
                        String fieldName = caseField.APIName__c;
                        
                        if(oldCase.get(fieldName) != newCase.get(fieldName))
                        {                                    
                            addCase = true;
                            break;
                        }
                    }
                    
                    if(addCase && (oldCase.RecordTypeId!= ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Inquiry - Creative')))
                    {
                        targetCaseIds.add(oldCase.id);
                    }                        
                }                   
            }  
            
            system.debug('----targetCaseIds--'+targetCaseIds);
            if((csIds.size() > 0 || targetCaseIds.size() > 0) && notFutureOrBatch)
            {                        
                CB_MileStoneDatesOnCase_Handler.updateCaseAU(csIds, targetCaseIds); 
            }
        }
    }
    
    public static void ccTallyUpdateCases(list<Case> ccTallyUpdateCases)
    {
        if(ccTallyUpdateCases!=null && !ccTallyUpdateCases.isEmpty())
        {
            Set<Id> caseIds = new Set<Id>(); 
            
            for(Case cs: ccTallyUpdateCases)
            {
                if(cs.Status == 'Open')
                {
                    caseIds.add(cs.Id);
                } 
            }
            system.debug('-------caseIds-----'+caseIds);
            
            if(!caseIds.isEmpty())
            {
                CB_CrtiveCseTallyUpdteWbIdAccPlan_Hndler.creativeCaseTallyUpdate(caseIds); 
            }
        }
    }
    
    public static void targetDateTimecaseListAI(list<Case> targetDateTimecaseListAI)
    {
        if(targetDateTimecaseListAI!=null && !targetDateTimecaseListAI.isEmpty())
        {
            set<Id> targetCaseIds = new set<Id>();
            
            for(Case cs:targetDateTimecaseListAI)
            {
                if(cs.EntitlementId != null)
                {
                    Boolean addCase = false;
                    boolean notInquiryCreativeCase = 
                        (cs.RecordTypeId != ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Inquiry - Creative'))? true: false;
                    
                    for(CB_CaseFields__c caseField : CB_CaseFields__c.getAll().values())
                    {
                        String fieldName = caseField.APIName__c;
                        if(cs.get(fieldName) != null)
                        {
                            addCase = true;
                            break;
                        }
                    }
                    if(addCase && notInquiryCreativeCase)
                    {
                        targetCaseIds.add(cs.id);
                    }
                }    
            }
            
            if(targetCaseIds.size() > 0)
            {
                CB_MileStoneDatesOnCase_Handler.updateTargetDateTimeAI(targetCaseIds);
            }  
        }
    }
    
    public static void AccountFieldUpdateCases(list<Case> AccountFieldUpdateCases)
    {
        List<ID> CaseIDsToProcess = new List<ID>();            
        if(AccountFieldUpdateCases != null && !AccountFieldUpdateCases.isEmpty())
        {
            for(Case c : AccountFieldUpdateCases)
            {
                if((c.Type == 'Customer Buy/Sell' || c.Type == 'GM Complete Buy/Sell')
                   && (c.Assumption_Approved__c == 'Yes' || c.Assumption_Approved__c == 'No'))
                {
                    CaseIDsToProcess.add(c.Id);
                }
            }
        }
        
        List<Case> CasesToProcess = [
            Select Id, RecordType.Name, AccountId, Account.BuySell_Date__c, Seller__c, Seller__r.Name, End_Billing_Date__c 
            From Case 
            Where ID in :CaseIDsToProcess
        ];
        
        Map<Id,Account> AccountsToUpdate = new Map<Id,Account>();
        
        if(CasesToProcess != null && !CasesToProcess.isEmpty())
        {
            for(Case c : CasesToProcess)
            {
                if (c.RecordType.Name == 'IFS - Contract Admin')
                {
                    if(c.AccountId != null)
                    {
                        Account a = new Account(Id=c.AccountId);
                        a.Seller_Account_Name__c = c.Seller__r.Name;
                        a.BuySell_Date__c = c.End_Billing_Date__c;
                        a.Buy_Sell__c = True;
                        
                        if(AccountsToUpdate.keyset().contains(c.AccountId))
                        {
                            if(c.End_Billing_Date__c > c.Account.BuySell_Date__c)
                            {
                                // replace the Account that is Existing in the map
                                AccountsToUpdate.put(c.AccountId, a);
                            }
                        }
                        else
                        {
                            // add the Account to the map
                            AccountsToUpdate.put(c.AccountId, a);
                        }
                    }
                }
            }
        }
        
        if(!AccountsToUpdate.IsEmpty()) { update AccountsToUpdate.values(); } 
    }
}