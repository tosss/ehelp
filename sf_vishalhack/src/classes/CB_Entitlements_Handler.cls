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
    
    public static void CB_createRetentionRecords(List<Case> CancellationCases)
    {
        GlobalSettings__c gs = GlobalSettings__c.getInstance();
        
        if(gs.Retention_Switch__c)
        {
            list<ALL_Decision_Box_Settings__c> decisionList = ALL_UtilitiesLogic.getRelevantDecisionBoxSettings('Case', 'CB_Retention__c');
            List<CB_Retention__c> retentionList = new List<CB_Retention__c>();
            //map<ID, Case> helperLaunchMap = new map<ID, Case>(CancellationCases.deepClone(true, true, true));
            for(Case newCase: CancellationCases)
            {
                if(!decisionList.isEmpty())
                {
                    for(ALL_Decision_Box_Settings__c dbs: decisionList)
                    {
                        boolean fieldsValuesChanged = ALL_UtilitiesLogic.evaluatedExpressionsMap.get(dbs.Condition_Check__c);
                        
                        if(fieldsValuesChanged == null)
                        {                
                            fieldsValuesChanged = ALL_UtilitiesLogic.getcompositeExpressionsEvaluatedValue(
                                dbs.Condition_Check__c, newCase);
                        }
                        system.debug(fieldsValuesChanged);
                        if(fieldsValuesChanged != null && fieldsValuesChanged)
                        {
                            sObject newObject = ALL_UtilitiesLogic.createRecords(
                                dbs.Value_Assignment__c, dbs.Assignment_sObject__c, newCase);
                           
                            system.debug(newObject);
                            
                            CB_Retention__c newRetention = (CB_Retention__c)newObject; 
                            
                            system.debug(newRetention);
                            retentionList.add(newRetention);
                        }
                        
                        //below makes sure the expression is not evaluated one more time consuming the browser limited time.
                        ALL_UtilitiesLogic.evaluatedExpressionsMap.put(dbs.Condition_Check__c, fieldsValuesChanged);
                    }
                }
            }
            
            if(!retentionList.isEmpty())
            {
                Try
                {
                    insert retentionList;
                }
                catch(Exception exp)
                {
                    Trigger.new[0].addError(exp.getMessage());
                }
                
            }
        }
    }
    
    Private Class webIdEntitlementMaps
    {
        Map<String, Set<String>> webIDToEntNames;
        Map<String, Set<Entitlement>> webIDToEntitlements;
        
        Public webIdEntitlementMaps()
        {
            webIDToEntNames = new Map<String, Set<String>>();
            webIDToEntitlements = new Map<String, Set<Entitlement>>();
        }
    }
    
    public static void createEntitlements(list<sObject> newRecords, map<ID, sObject> oldMap)
    {
        Schema.SObjectType sObjectToken = newRecords.getSObjectType();
        String sObjectType = sObjectToken.getDescribe().getName();
        boolean isWebIdRecord = (sObjectType.equalsIgnoreCase('WebId__c'));
        boolean isInstalledBase = sObjectType.equalsIgnoreCase('Installed_Base__c');
        boolean isInstalledBaseItem = sObjectType.equalsIgnoreCase('Installed_Base_Item__c');
        map<ID, WebId__c> allWebIds;
        map<String, list<WebId__c>> webIdsOfInterest = new map<String, list<WebId__c>>();
        map<ID, Installed_Base_Item__c> installBaseItems;
        Set<Id> allWebIDSet = new Set<ID>();
            
        if(isWebIdRecord == true)
        {
            list<WebID__c> webIds = (list<WebId__c>)newRecords;
            allWebIds = new map<ID, WebId__c>(webIds);
        }
        else
        {
            if(isInstalledBase)
            {
                list<Installed_Base__c> installBases = (list<Installed_Base__c>)newRecords;
                Set<ID> webIdSet = new Set<ID>();
                
                for(Installed_Base__c obj: installBases)
                {
                    if(obj.webId__c != null)
                    {
                        webIdSet.add(obj.webId__c);
                    }
                }
                
                if(!webIdSet.isEmpty())
                {
                    allWebIds = new map<Id, WebID__c>([
                        Select Id, OEM__c, Status__c, Account__c 
                        From WebId__c 
                        Where ID IN :webIdSet
                    ]);
                }
            }
            
            if(isInstalledBaseItem)
            {
                list<Installed_Base_Item__c> installBaseItems2 =  (list<Installed_Base_Item__c>)newRecords;
                installBaseItems = new map<ID, Installed_Base_Item__c>([
                    Select Id, Product_Status__c, Product_Code__c, Installed_Base__c, Installed_Base__r.WebID__c,
                    Installed_Base__r.WebID__r.Status__c, Installed_Base__r.WebID__r.OEM__c, Installed_Base__r.WebID__r.Account__c
                    From Installed_Base_Item__c
                    Where ID IN :installBaseItems2 
                ]);
                
                if(installBaseItems != null)
                {
                    allWebIds = new map<ID, WebId__c>();
                    
                    for(Installed_Base_Item__c ibi: installBaseItems.values())
                    {
                        webId__c webID = ibi.Installed_Base__r.WebId__r;
                        allWebIds.put(webId.ID, webId);
                    }
                }
            }
        }
        
        // all webIdsare collected into allWebIds at this point.
        // below is the code for checking conditions and picking only webIds of interest
        Map<String, ALL_CreateEntitlements__c> allSettingsMap = ALL_CreateEntitlements__c.getAll();
        list<ALL_CreateEntitlements__c> allSettings = allSettingsMap.values();
        list<ALL_CreateEntitlements__c> relevantSettings = new list<ALL_CreateEntitlements__c>();
        map<String, list<webID__c>> settingsNameToWebIDs = new map<String, list<webID__c>>();
        Map<String, Map<String, List<webID__c>>> twinMap = new Map<String, Map<String, List<webID__c>>>();
        
                    
        for(ALL_CreateEntitlements__c eachSetting: allSettings)
        {
            if(sObjectType == eachSetting.sObject__c)
            {
                relevantSettings.add(eachSetting);
            } 
        }
        
        for(sObject obj: newRecords)
        {
            for(ALL_CreateEntitlements__c eachSetting : relevantSettings)
            {
                boolean conditionTrue = ALL_UtilitiesLogic.getcompositeExpressionsEvaluatedValue(
                    eachSetting.Condition_Check__c, obj);
                
                if(conditionTrue)
                {
                    ID objectID = isWebIdRecord == true ? obj.ID : 
                    (isInstalledBase == true ? (ID)obj.get('webId__c') : installBaseItems.get(obj.ID).Installed_Base__r.WebID__c);
                        
                    webId__c currentWebId = allWebIds.get(objectID); allWebIDSet.add(currentWebId.ID);
                    list<webId__c> records = settingsNameToWebIDs.get(eachSetting.Name);
                    if(records == null){ records = new list<webId__c>();}
                    records.add(currentWebId);
                    settingsNameToWebIDs.put(eachSetting.Name, records);
                }
            }
        }
         
        map<String, SlaProcess> slaProcessMap =  CB_Entitlements_Handler.getSlaProcesses();
        webIdEntitlementMaps newWebIdEntls = CB_Entitlements_Handler.getAllEntilementNames(allWebIDSet); 
        twinMap = CB_Entitlements_Handler.assignEntitlements(settingsNameToWebIDs, newWebIdEntls.webIDToEntNames, allSettingsMap);
        //finally create entitlements
        map<String, list<webID__c>> createEntlToWebID = twinMap.get('Create');
        map<String, list<webID__c>> closeEntlToWebID = twinMap.get('Close');
            
        if(createEntlToWebID != null)
        {
            CB_Entitlements_Handler.createEntitlements(slaProcessMap, createEntlToWebID);
        }
        if(closeEntlToWebID != null && newWebIdEntls.webIDToEntitlements != null)
        {
            CB_Entitlements_Handler.closeEntitlements(closeEntlToWebID, newWebIdEntls.webIDToEntitlements);
        }
        //system.assertEquals(settingsNameToWebIDs, new map<String, list<webID__c>>());
    }
    
    Public Static void closeEntitlements(map<String, list<webID__c>> closeEntlToWebID, Map<String, Set<Entitlement>> webIDToEntitlements)
    {
        List<Entitlement> closeEntitlements = new List<Entitlement>();
        
        for(String entitlementName: closeEntlToWebID.keySet())
        {
            list<webID__c> webIdList = closeEntlToWebID.get(entitlementName);
            
            if(webIdList != null)
            {
                for(webId__c webID: webIdList)
                {
                    Set<Entitlement> entlToClose = webIDToEntitlements.get(webID.ID);
                    
                    if(entlToClose != null)
                    {
                        for(Entitlement entl: entlToClose)
                        {
                            if(entl.Name == entitlementName)
                            {
                                entl.EndDate = Date.today();
                                closeEntitlements.add(entl);
                            }
                        }
                    }
                }
            }
        }
        
        if(!closeEntitlements.isEmpty())
        {
            Update closeEntitlements;
        }
    }
    
    Public Static void createEntitlements(map<String, SlaProcess> slaProcessMap, map<String, list<webID__c>> createEntlToWebID)
    {
        List<Entitlement> entitlementList = new List<Entitlement>();
        
        for(String slaName: createEntlToWebID.keySet())
        {
            list<webID__c> currentRecords = createEntlToWebID.get(slaName);
            SlaProcess currentSlaProcess = slaProcessMap.get(slaName);
            
            if(currentRecords != null)
            {
                for(webID__c webID: currentRecords)
                {
                    Entitlement newEntitlement = 
                        CB_EntitlementsToWebIdAssignment_Handler.createEnt(slaName, webID, slaProcessMap, 'Technical Support');
                    if(newEntitlement != null){  entitlementList.add(newEntitlement); }
                }
            }
        }
        
        if(!entitlementList.isEmpty())
        {
            insert entitlementList;
        }
    }
    //Map<String, Map<String, List<webID__c>>> twinMap = new Map<String, Map<String, List<webID__c>>>();
    Public Static Map<String, Map<String, List<webID__c>>> assignEntitlements(
        map<String, list<webID__c>> settingsNameToWebIDs, 
        Map<String, Set<String>> webIDToEntNames, Map<String, ALL_CreateEntitlements__c> allSettingsMap)
    {
        Map<String, Map<String, List<webID__c>>> twinMap = new Map<String, Map<String, List<webID__c>>>();
        map<String, list<webID__c>> createEntlToWebID = new map<String, list<webID__c>>();
        map<String, list<webID__c>> closeEntlToWebID = new map<String, list<webID__c>>();
        
        for(String settingName: settingsNameToWebIDs.keySet())
        {
            List<webID__c> currentList = settingsNameToWebIDs.get(settingName);
            ALL_CreateEntitlements__c setting = allSettingsMap.get(settingName);
            String slaName = setting.Entitlement_Value__c;
            
            for(webID__c webIdRecord: currentList)
            {
                String webId = webIdRecord.ID;
                Set<String> slaNamesSet = webIDToEntNames.get(webId); system.debug(slaNamesSet);  system.debug(slaName);
                boolean webIdContainsSla = slaNamesSet == null ? false : slaNamesSet.contains(slaName);
                
                if(webIdContainsSla == false && setting.Do_This__c == 'Create')
                {
                    list<webID__c> tempList = createEntlToWebID.get(slaName);
                    if(tempList == null){ tempList = new list<webID__c>();}
                    tempList.add(webIdRecord);
                    createEntlToWebID.put(slaName, tempList);
                    twinMap.put('Create', createEntlToWebID);
                }
                if(webIdContainsSla == true && setting.Do_This__c == 'Close')
                {
                    list<webID__c> tempList = closeEntlToWebID.get(slaName);
                    if(tempList == null){ tempList = new list<webID__c>();}
                    tempList.add(webIdRecord);
                    closeEntlToWebID.put(slaName, tempList);
                    twinMap.put('Close', closeEntlToWebID);
                }
            }
        }
        
        return twinMap;
    }
    
    Public Static map<String, SlaProcess> getSlaProcesses()
    {
        map<String, SlaProcess> slaProcessMap = new map<String, SlaProcess>();
        String slaProcessQuery='Select Id, BusinessHoursId, Name, isActive from SlaProcess where isActive=true ';
        
        for(SlaProcess slaProcess: Database.Query(slaProcessQuery))
        {
            slaProcessMap.put(slaProcess.Name, slaProcess);
        }
        
        return slaProcessMap;
    }
    
    Public Static webIdEntitlementMaps getAllEntilementNames(Set<Id> allWebIDSet)
    {
        webIdEntitlementMaps newWebIdEntls = new webIdEntitlementMaps();
        
        for(Entitlement ent: [Select Id, Name, StartDate, EndDate, WebId__c 
                              From Entitlement 
                              Where WebId__c IN :allWebIDSet 
                              AND Status = 'Active' AND EndDate = null
                             ])
        {
            Set<String> entitlementNames = 
            newWebIdEntls.webIDToEntNames.containsKey(ent.WebId__c) ? newWebIdEntls.webIDToEntNames.get(ent.WebId__c):  new Set<String>();
            entitlementNames.add(ent.Name);
            
            newWebIdEntls.webIDToEntNames.put(ent.WebId__c, entitlementNames);
            
            Set<Entitlement> entitlements = 
            newWebIdEntls.webIDToEntitlements.containsKey(ent.WebId__c) ? newWebIdEntls.webIDToEntitlements.get(ent.WebId__c):  new Set<Entitlement>();
            entitlements.add(ent);
            
            newWebIdEntls.webIDToEntitlements.put(ent.WebId__c, entitlements);
        }
        
        return newWebIdEntls;
    }
}