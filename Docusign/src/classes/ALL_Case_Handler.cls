/*----------------------------------------------
HISTORY:

07/13/15 - Hemanth Kesapragada - RQ-04941-Added logic to call Entitlements method when record type changes
07/28/15 - Venkata Shrivol     - Code Refactored for total Entitlements and RQ-05068 
2015-11-13 siva.pragada@cdk.com - new method getCasesCodeReferenceWise and improvements -still needs to be tested thoroughly
-------------------------------------------------*/

public class ALL_Case_Handler 
{  
    public static void ToggleController(List<Case> NewList, List<Case> OldList, Map<Id, Case> newMap, Map<Id, Case> oldMap)
    {
        boolean nonAsynchronous = (!system.isBatch() && !system.isFuture() && !system.isScheduled());
        // begin checking processing for each code block
        // map<CodeReference, list<Case>>
        map<string, list<Case>> FilteredTriggerNew = new map<string, list<Case>>(); 
        
        FilteredTriggerNew = ALL_Case_Handler.ToggleFilter(NewList);
        system.debug(FilteredTriggerNew);
        FilteredTriggerNew = ALL_Case_Handler.ProfileFilter(FilteredTriggerNew);
        system.debug(FilteredTriggerNew);
                
        // for debugging, FilteredTriggerNew2 is not used in the code
       /*map<string, list<string>> FilteredTriggerNew2 = new map<string, list<string>>();
        FilteredTriggerNew2 = ALL_Case_Handler.ToggleFilter_ForDebug(NewList);        
        system.debug(FilteredTriggerNew2);*/
        
        // process before insert and before update actions
        if(Trigger.isBefore) 
        {
            if(Trigger.isInsert || Trigger.isUpdate) 
            {
                // DSCB_CaseReferenceFields
                
                list<Case> ReferenceFieldCases = FilteredTriggerNew.get('DSCB_CaseReferenceFields');
                
                if( ReferenceFieldCases != null && !ReferenceFieldCases.isEmpty()) 
                {                     
                    DSCB_CaseReferenceFields.SetCaseReferenceFields(ReferenceFieldCases); 
                }
                
                // DS_CaseDefaultAccount
                
                CustomSettings__c settings = CustomSettings__c.getInstance();
                
                if(settings.CDK_Global_Account_Id__c != null)
                {     
                    list<Case> DefaultAccountCases = FilteredTriggerNew.get('DS_CaseDefaultAccount');
                    system.debug(DefaultAccountCases);
                    if( DefaultAccountCases != null && !DefaultAccountCases.isEmpty())
                    {                       
                        for(Case c : DefaultAccountCases)
                        {
                            c.AccountId = settings.CDK_Global_Account_Id__c;
                            system.debug( c.AccountId);
                        }
                    }
                }                
                
                // DSCB_CaseUserManager - not a separate trigger/class
                
                list<Case> UserManagerCases = FilteredTriggerNew.get('DSCB_CaseUserManager');
                
                if(UserManagerCases != null && !UserManagerCases.isEmpty())
                {                   
                    for(Case NewCase : UserManagerCases) 
                    {
                        Case OldCase = oldMap != null ? oldMap.get(NewCase.Id) : null;
                        if(OldCase == null) { OldCase = new Case(); }
                        
                        // 2014-10-14 from Christy Silveira - upon Owner change 
                        if(NewCase.OwnerId != OldCase.OwnerId)
                        {
                            String NewCaseOwnerId = String.valueOf(NewCase.OwnerId);
                            String OldCaseOwnerId = String.valueOf(OldCase.OwnerId);
                            
                            // 2014-10-14 CS - update owner lookup with new owner
                            //   if new owner is not a queue then current Owner
                            if(NewCaseOwnerId != null && !NewCaseOwnerId.startsWith('00G')) { 
                                NewCase.Owner_Lookup__c = NewCase.OwnerId; }
                            else { // 2014-10-14 CS - if new owner is queue then NULL 
                                NewCase.Owner_Lookup__c = null; }
                        }
                    } 
                }
                
                // SEO Case Assignment rule through the trigger based on Account Plan resource fields added 11/24/2014 SivaP
                
                list<Case> SeoAssignmentCases = FilteredTriggerNew.get('DSCB_CaseAssignment');
                if(SeoAssignmentCases != null && !SeoAssignmentCases.isEmpty()) 
                {                      
                    DSCB_CaseAssignment.CaseAssignmentRule(SeoAssignmentCases, OldMap);                    
                }               
            }
            
            if(Trigger.isInsert) 
            {
                // CB_UpdateContactAccount - pulled in, not a separate trigger/class
                
                // MK - 2012-08-16 - added global settings field for username
                // MK - 2013-08-14 - updated code to be more flexible and readable
                GlobalSettings__c gs = GlobalSettings__c.getInstance();
                String un = gs != null ? gs.Email_2_Case_User__c : null; 
                
                // only get a matching user if the Global Settings are set
                List<User> users = new List<User>();
                if(un != null) { users = [Select id from User where Username = :un]; }
                
                // u cannot be null because its properties are referenced later
                User u = users.isEmpty() ? new User() : users[0]; 
                
                // gather Email Addresses:
                //   if the Current User is the Email 2 Case User
                //   and an Email Address was supplied on the Case
                //     add the Email Address for processing
                Set<String> EmailAddresses = new Set<String>();
                
                list<Case> ContactAccountCases = FilteredTriggerNew.get('CB_UpdateContactAccount');    
                
                if(ContactAccountCases != null && !ContactAccountCases.isEmpty())
                {                   
                    for (Case CurrentCase : ContactAccountCases) 
                    {
                        if(UserInfo.getUserId() == u.Id && CurrentCase.SuppliedEmail != null) 
                        {
                            EmailAddresses.add(CurrentCase.SuppliedEmail);
                        }
                    }
                }
                
                List<Contact> MatchingContacts = new List<Contact>();
                if(!EmailAddresses.IsEmpty()) {
                    MatchingContacts = [SELECT Email FROM Contact WHERE Email IN :EmailAddresses]; 
                }
                                
                if(ContactAccountCases != null && ContactAccountCases.isEmpty())
                {
                    for (Case CurrentCase : ContactAccountCases) 
                    {
                        // check for multiple matches
                        Integer temp = 0;
                        for(Contact CurrentContact : MatchingContacts) {
                            if(CurrentContact.Email == CurrentCase.SuppliedEmail) { temp++; } 
                        }
                        
                        // if there is more than one match
                        //   set these fields to a blank value
                        if(temp > 1) 
                        {
                            CurrentCase.ContactId = null;
                            CurrentCase.AccountId = null;
                            CurrentCase.WebID__c = null; 
                            system.debug(CurrentCase.WebID__c);
                            system.debug(CurrentCase.ContactId);
                        }
                    }
                }
                // end CB_UpdateContactAccount
                
                // begin CB_EntitlementsToCaseAssignment_Handler
                
                // Added by Venkata 03/16/2015 for updating case with Entitlements from related WebId 
                list<Case> EntitlementToCases = FilteredTriggerNew.get('CB_EntitlementsToCaseAssignment_Handler');
                list<Case> casesToInsert = new list<Case>();
                
                //for debugging:
                //list<String> EntitlementToCases = FilteredTriggerNew.get('CB_EntitlementsToCaseAssignment_Handler');
                //system.debug('------EntitlementToCases- Size----'+EntitlementToCases.size());
                
                if(EntitlementToCases != null && !EntitlementToCases.isEmpty()) 
                {
                    
                    
                    for(Case c:EntitlementToCases)
                    {
                        if(c.WebID__c!=null)
                        {
                            casesToInsert.add(c);
                        }
                    }
                    if(!casesToInsert.isEmpty())
                    {
                        CB_EntitlementsToCaseAssignment_Handler.updateEntToCase(casesToInsert);    
                    }
                }
                // end CB_EntitlementsToCaseAssignment_Handler for insert
                
            } // end Trigger.isInsert
            
            if(Trigger.isUpdate)
            {
                // begin CB_MileStoneDatesOnCase_Handler
                
                // Case COmpletion Dates - Start
                list<Case> completionDateCasesBU = FilteredTriggerNew.get('CB_MileStoneDatesOnCase_Handler');
                //system.debug('-------'+completionDateCasesBU.size());
                if( completionDateCasesBU != null && !completionDateCasesBU.isEmpty()) 
                {                      
                    Map<id,String> newCaseMap = new Map<id,String>();   
                    Set<Id> csIds = new set<id>();
                    for(Case cs: completionDateCasesBU){                                          
                        Case oldCS = oldMap.get(cs.id);
                        if(cs.status.containsIgnoreCase('Closed')||(cs.status.containsIgnoreCase('Resolved') 
                            && !oldCS.status.containsIgnoreCase('Resolved') && !oldCS.status.containsIgnoreCase('Closed'))) {
                                csIds.add(cs.id);
                                newCaseMap.put(cs.id, cs.Status);   
                        }                                     
                    }  
                    system.debug('----newCaseMap--'+newCaseMap);
                    if(newCaseMap.size() > 0){
                        //CB_MileStoneCompletionDateonCase_Handler.updateCaseBU(newCaseMap.keySet(), newCaseMap);
                        CB_MileStoneDatesOnCase_Handler.updateCaseBU(newCaseMap.keySet(), newCaseMap);                        
                    }
                }
                // Case COmpletion Dates - End
                
                //Added by hemanth 2015-07-13 for updating case with Entitlements from related recordType
                Map<String,CB_CasePreviousRecordType__c> oldRecTypeMap = CB_CasePreviousRecordType__c.getAll();
                Map<String,CB_CaseRecordTypes__c> newRecTypeMap = CB_CaseRecordTypes__c.getAll();
                List<Case> updateCaseList = new List<Case>();
                set<Id> updateTargetDateTimeOfCaseIds = new set<Id>(); 
                for(Case caseObj : OldList)
                {
                   String previousRecordName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Case', caseObj.RecordTypeId);
                   String newRecordName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Case', newMap.get(caseObj.Id).RecordTypeId);
                    if(oldRecTypeMap.containsKey(previousRecordName) && newRecTypeMap.containsKey(newRecordName))
                    {
                        Case newCaseObj = newMap.get(caseObj.id);
                        updateCaseList.add(newCaseObj); 
                        updateTargetDateTimeOfCaseIds.add(newCaseObj.Id);
                    }
                }
                if(!updateCaseList.isEmpty())
                {
                    CB_EntitlementsToCaseAssignment_Handler.updateEntToCase(updateCaseList); 
                }
                if(!updateTargetDateTimeOfCaseIds.isEmpty() && ALL_CheckRecursive.runCodeBlockOnce('updateTargetDateTimeOfCaseIds'))
                { 
                    CB_MileStoneDatesOnCase_Handler.updateTargetDateTimeAI(updateTargetDateTimeOfCaseIds);
                }
                
                // Added by Venkata 06/04/2015 for updating case with Entitlements from related WebId 
                list<Case> EntitlementToCasesBU = FilteredTriggerNew.get('CB_EntitlementsToCaseAssignment_Handler');
                
                if( EntitlementToCasesBU != null && !EntitlementToCasesBU.isEmpty()) 
                {
                    Id oldWebId;
                    String oldStatus='';
                    String newStatus='';
                    list<Case> casesToUpdate = new list<Case>();
                    set<Id> targetDateTimeCaseIds = new set<Id>();
                    set<Id> webIdSet = new set<Id>();
                    set<Id> oldSet = new set<Id>();
                    for(Case cs:NewList)
                    {
                        webIdSet.add(cs.WebID__c);
                    }
                    for(Case cs:OldList)
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
                    for(Case c:NewList)
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
                        
                        if((c.WebID__c!=null && oldWebId==null)||
                           (oldStatus=='Inactive' 
                            && (newStatus=='Active' || newStatus=='New')
                            && c.WebID__c!=oldWebId))
                        {
                            casesToUpdate.add(c);
                            targetDateTimeCaseIds.add(c.Id);
                        }
                    }
                    if(!casesToUpdate.isEmpty())
                    {
                        CB_EntitlementsToCaseAssignment_Handler.updateEntToCase(casesToUpdate); 
                    }
                    if(!targetDateTimeCaseIds.isEmpty() && ALL_CheckRecursive.runCodeBlockOnce('targetDateTimeCaseIds'))
                    { 
                        CB_MileStoneDatesOnCase_Handler.updateTargetDateTimeAI(targetDateTimeCaseIds);
                    }
                }
               // end CB_MileStoneDatesOnCase_Handler, also CB_EntitlementsToCaseAssignment_Handler 
            
            } // end Trigger.isUpdate
            
        } // end Trigger.isBefore
        
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
        {
            
            if(Trigger.isUpdate)
            {
                // begin CB_MileStoneDatesOnCase_Handler
                // Case Entitlements COmpletion Date - Start
                list<Case> completionDateCasesAU = FilteredTriggerNew.get('CB_MileStoneDatesOnCase_Handler');
                if( completionDateCasesAU != null && !completionDateCasesAU.isEmpty()) 
                {
                    Map<id,String> oldCaseMap = new Map<id,String>();      
                    Set<Id> csIds = new set<id>(); 
                    Set<Id> targetCaseIds = new set<id>(); 
                    for(Case cs: oldList)
                    { 
                        Case newCS = newMap.get(cs.id);
                        if(cs.status.containsIgnoreCase('Closed')||(cs.status.containsIgnoreCase('Resolved') 
                            && !newCS.status.containsIgnoreCase('Resolved') && !newCS.status.containsIgnoreCase('Closed'))) 
                        {
                                csIds.add(cs.id);
                                oldCaseMap.put(cs.id, cs.Status); 
                        }
                        if(cs.EntitlementId != null )
                        {
                            Boolean addCase = false;
                            for(CB_CaseFields__c caseField : CB_CaseFields__c.getAll().values()){
                                String fieldName = caseField.APIName__c;
                                if(cs.get(fieldName) != newCs.get(fieldName)){
                                    addCase = true;
                                    break;
                                }
                            }
                            if(addCase){
                                targetCaseIds.add(cs.id);
                            }                        
                        }                   
                    }  
                    system.debug('----oldCaseMap--'+oldCaseMap);
                    system.debug('----targetCaseIds--'+targetCaseIds);
                    if((oldCaseMap.size() > 0 || targetCaseIds.size() > 0) && ALL_CheckRecursive.runCodeBlockOnce('updateCaseAU')){
                        //CB_MileStoneCompletionDateonCase_Handler.updateCaseAU(csIds, oldCaseMap, targetCaseIds);
                        if(nonAsynchronous) //need to add check this for all Future methods.
                        {
                            CB_MileStoneDatesOnCase_Handler.updateCaseAU(csIds, oldCaseMap, targetCaseIds);
                        }
                    }
                }
                // Case Entitlements COmpletion Date - End
                // end CB_MileStoneDatesOnCase_Handler       
            }    
            if(Trigger.isInsert)
            {
                // begin CB_CrtiveCseTallyUpdteWbIdAccPlan_Hndler, also CB_MileStoneDatesOnCase_Handler
                list<Case> ccTallyUpdateCases = FilteredTriggerNew.get('CB_CrtiveCseTallyUpdteWbIdAccPlan_Hndler');
                list<Case> targetDateTimecaseListAI = FilteredTriggerNew.get('CB_MileStoneDatesOnCase_Handler');
                //system.debug('-----'+targetDateTimecaseListAI);
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
                if(targetDateTimecaseListAI!=null && !targetDateTimecaseListAI.isEmpty())
                {
                    set<Id> targetCaseIds = new set<Id>();
                    for(Case cs:targetDateTimecaseListAI)
                    {
                        if(cs.EntitlementId != null)
                        {
                            Boolean addCase = false;
                            for(CB_CaseFields__c caseField : CB_CaseFields__c.getAll().values())
                            {
                                String fieldName = caseField.APIName__c;
                                if(cs.get(fieldName) != null)
                                {
                                    addCase = true;
                                    break;
                                }
                            }
                            if(addCase)
                            {
                                targetCaseIds.add(cs.id);
                            }
                        }    
                    }
                    if(targetCaseIds.size() > 0 && ALL_CheckRecursive.runCodeBlockOnce('updateTargetDateTimeAI')){
                        //CB_UpdateTargetDateMStoneToCase_Handler.updateTargetDateTimeAI(targetCaseIds);
                        CB_MileStoneDatesOnCase_Handler.updateTargetDateTimeAI(targetCaseIds);
                    }  
                }
                // end CB_CrtiveCseTallyUpdteWbIdAccPlan_Hndler, also CB_MileStoneDatesOnCase_Handler
            }
            
            // CaseTriggers - separate class, but not separate trigger
            
            map<Id, Case> FilteredTriggerNewMap = new map<Id, Case>();
            map<Id, Case> FilteredTriggerOldMap = new map<Id, Case>();
            
            list<Case> CaseTriggerCases = FilteredTriggerNew.get('caseTriggers');
            system.debug(CaseTriggerCases);
            
            if(CaseTriggerCases != null && !CaseTriggerCases.isEmpty())
            {
                for(Case c : CaseTriggerCases)
                {
                    Case NewMapCase = NewMap != null ? NewMap.get(c.Id) : null; 
                    if(NewMapCase != null) { FilteredTriggerNewMap.put(c.Id, NewMapCase); }
                    
                    Case OldMapCase = OldMap != null ? OldMap.get(c.Id) : null; 
                    if(OldMapCase != null) { FilteredTriggerOldMap.put(c.Id, OldMapCase); }
                }
            }
            
            system.debug(FilteredTriggerNewMap.isEmpty());
            if(!FilteredTriggerNewMap.isEmpty()) 
            { 
                caseTriggers.caseUpdates(FilteredTriggerNewMap, FilteredTriggerOldMap); 
            }
                        
            // DSCB_CaseAccountFieldUpdate - pulled in, not a separate trigger/class
            
            List<ID> CaseIDsToProcess = new List<ID>();
            
            list<Case> AccountFieldUpdateCases = FilteredTriggerNew.get('DSCB_CaseAccountFieldUpdate');
            
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
            
            // end DSCB_CaseAccountFieldUpdate
            
            // For updating the response date field value on contact object with the same field value on Case if record type is Tier 1
            // This is controlled from Trigger Toggle custom settings
            list<Case> ResponseDateCases = FilteredTriggerNew.get('DSCB_UpdatesThroughCaseObject');
            
            if(ResponseDateCases != null && !ResponseDateCases.isEmpty())
            {
                DSCB_UpdatesThroughCaseObject.UpdateMethod(ResponseDateCases);
            }
            
        } // end Trigger.isAfter   
           
    }
    
    //collects cases in a list recordtype wise and puts in a map
    public static map<string, list<Case>> RecordTypeToCases(List<Case> NewList) 
    {
        map<string, list<Case>> RecordTypeToCases = new map<string, list<Case>>();
        
        for(Case c: NewList)
        {
            string RecordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Case', c.RecordTypeId);
            list<Case> CasesRecordTypeWise = RecordTypeToCases.get(RecordTypeName);
            
            if(CasesRecordTypeWise == null)
            { 
                CasesRecordTypeWise = new list<Case>();
                CasesRecordTypeWise.add(c);
            }
            else
            {
                CasesRecordTypeWise.add(c);
            }
            
            RecordTypeToCases.put(RecordTypeName, CasesRecordTypeWise);
        }
        
        return RecordTypeToCases;
    }
    
    //collects trigger toggles of recordtype field null and non null values separately in two lists and puts them in a map 
    public static map<string, list<Trigger_Toggle__c>> getOrganizedTriggerToggles()
    {
        map<string, Trigger_Toggle__c> TriggerToggle = Trigger_Toggle__c.getAll();
        
        map<string, list<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise = new map<string, list<Trigger_Toggle__c>>();
        
        set<string> AllCodeReferences = new set<string>();
        
        for(Trigger_Toggle__c tt: TriggerToggle.values())
        {
            AllCodeReferences.add(tt.Code_Reference__c);
            
            if(tt.sObject__c == 'Case')
            {
                list<Trigger_Toggle__c> NullRecordTypeToggles = TriggerTogglesRecordTypeWise.get('TogglesWithNullRecordTypes');
                if(NullRecordTypeToggles == null){ NullRecordTypeToggles = new list<Trigger_Toggle__c>();}
                
                list<Trigger_Toggle__c> RecordTypeToggles = TriggerTogglesRecordTypeWise.get('TogglesWithRecordTypes');
                if(RecordTypeToggles == null){ RecordTypeToggles = new list<Trigger_Toggle__c>();}
                
                if(tt.RecordType_Name__c == null) 
                {
                    NullRecordTypeToggles.add(tt);                    
                }
                if(tt.RecordType_Name__c != null) { RecordTypeToggles.add(tt); }
                
                TriggerTogglesRecordTypeWise.put('TogglesWithNullRecordTypes', NullRecordTypeToggles);
                TriggerTogglesRecordTypeWise.put('TogglesWithRecordTypes', RecordTypeToggles);
            }
        }        
        return TriggerTogglesRecordTypeWise;
    }
    
    // loops through trigger toggles and decides and collects cases that are meant for each code reference block in a map
    public static map<string, list<case>> recordWiseCasesOrganizer(
        map<string, list<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise, map<string, list<case>> RecordTypeToCases)
    {
        map<string, list<case>> CasesToRecordName = new map<string, list<case>> ();
        
        list<Trigger_Toggle__c> NullTriggerToggleList = TriggerTogglesRecordTypeWise.get('TogglesWithNullRecordTypes');
        list<Trigger_Toggle__c> TriggerToggleList = TriggerTogglesRecordTypeWise.get('TogglesWithRecordTypes');
        
        if(NullTriggerToggleList != null && !NullTriggerToggleList.isEmpty())
        {
            for(Trigger_Toggle__c Toggle: NullTriggerToggleList)
            {           
                if(Toggle != null )
                {
                    string CodeReference = Toggle.Code_Reference__c;
                    
                    if(TriggerToggleList != null && !TriggerToggleList.isEmpty())
                    {
                        for(Trigger_Toggle__c tt:  TriggerToggleList)
                        {
                            if(Toggle.On__c)
                            {                        
                                if(tt.Code_Reference__c == CodeReference && !tt.On__c)
                                {
                                    list<case> CodeReferenceWiseCases = CasesToRecordName.get(CodeReference);
                                    
                                    for(string RecordTypeName: RecordTypeToCases.keySet())
                                    {                                
                                        if(CodeReferenceWiseCases == null)
                                        {
                                            CodeReferenceWiseCases = new list<case>();                                            
                                        }
                                        
                                        if(RecordTypeName != tt.RecordType_Name__c)
                                        { 
                                            list<case> RecordTypesAndCases = RecordTypeToCases.get(RecordTypeName);
                                            if(RecordTypesAndCases != null && !RecordTypesAndCases.isEmpty())
                                            {
                                                for(case c:RecordTypesAndCases){
                                                    CodeReferenceWiseCases.add(c);
                                                } 
                                            }
                                        }                                                        
                                    }                            
                                    CasesToRecordName.put(CodeReference, CodeReferenceWiseCases); 
                                }                        
                            }
                            
                            if(!Toggle.On__c)
                            {
                                if(tt.Code_Reference__c == CodeReference && tt.On__c)
                                {
                                    list<case> CodeReferenceWiseCases = CasesToRecordName.get(CodeReference);
                                    
                                    for(string RecordTypeName: RecordTypeToCases.keySet())
                                    {                        
                                        if(CodeReferenceWiseCases == null)
                                        {
                                            CodeReferenceWiseCases = new list<case>();                                            
                                        }
                                        
                                        if(RecordTypeName == tt.RecordType_Name__c)
                                        { 
                                            list<case> RecordTypesAndCases = RecordTypeToCases.get(RecordTypeName);
                                            if(RecordTypesAndCases != null && !RecordTypesAndCases.isEmpty())
                                            {
                                                for(case c:RecordTypesAndCases){
                                                    CodeReferenceWiseCases.add(c);
                                                }
                                            }
                                        }                                                              
                                    }                             
                                    CasesToRecordName.put(CodeReference, CodeReferenceWiseCases);
                                }                                           
                            }
                        }
                    }
                }
            }
        }
        system.debug(CasesToRecordName);
        return CasesToRecordName;
    }
    
    // 2015-11-13 siva.pragada@cdk.com - new method and improvements -still needs to be tested thoroughly
    public static map<string, list<Case>> getCasesCodeReferenceWise(List<Case> NewList)
    {
        map<string, list<Case>> RecordTypeToCases = ALL_UtilitiesDescribe.RecordTypeTosObjects(NewList);
        map<string, list<Case>> codeReferenceToCasesMap = new map<string, list<Case>>();
        list<Trigger_Toggle__c> TriggerToggles = Trigger_Toggle__c.getAll().values();
        
        for(Trigger_Toggle__c tt: TriggerToggles)
        {
            list<Case> codeReferenceCases = codeReferenceToCasesMap.get(tt.Code_Reference__c);
            if(codeReferenceCases == null){ codeReferenceCases = new list<Case>();}
            list<Case> recordTypeWiseCases = RecordTypeToCases.get(tt.RecordType_Name__c);
            
            if(recordTypeWiseCases != null && !recordTypeWiseCases.isEmpty())
            {
                codeReferenceCases.addAll(recordTypeWiseCases);
            }
            
            if(tt.RecordType_Name__c != null && tt.On__c)
            {  
                codeReferenceToCasesMap.put(tt.Code_Reference__c, codeReferenceCases);
            }
            
            if(tt.RecordType_Name__c != null && !tt.On__c)
            {
                if(RecordTypeToCases != null && !RecordTypeToCases.isEmpty())
                {
                    for(string recordType: RecordTypeToCases.keySet())
                    {  
                        if(tt.RecordType_Name__c != recordType)
                        { 
                            codeReferenceToCasesMap.put(tt.Code_Reference__c, codeReferenceCases);
                        }
                    }
                }
            }
        }
        
        return codeReferenceToCasesMap;
    }
    
    public static map<string, list<Case>> ToggleFilter(list<Case>NewList)
    {       
        
        map<string, list<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise = new map<string, list<Trigger_Toggle__c>>(
            ALL_Case_Handler.getOrganizedTriggerToggles()
        );
        
        
        map<string, list<case>> RecordTypeToCases = new map<string, list<case>>(
            ALL_Case_Handler.RecordTypeToCases(NewList)
        ); 
           
        
        return ALL_Case_Handler.recordWiseCasesOrganizer(TriggerTogglesRecordTypeWise, RecordTypeToCases);
    }
    
    public static map<string, list<Case>> ProfileFilter(map<string, list<Case>> FinalCasesMap)
    {       
        map<string, Trigger_Toggle_Profile__c> TpMap = Trigger_Toggle_Profile__c.getAll();
        
        for(Trigger_Toggle_Profile__c tp: TpMap.values())
        {
            if(tp.sObject__c == 'Case')
            {
                for(string CodeReference: FinalCasesMap.keySet())
                {
                    if(tp.get('Code_Reference__c') != null && 
                       tp.get('Code_Reference__c') == CodeReference && 
                       !tp.On__c && tp.Profile_Id__c == userInfo.getProfileId())
                    {                     
                         FinalCasesMap.get(CodeReference).Clear();                        
                    }
                    
                }
            }
        }        
        return FinalCasesMap;
    } 
    
    
    //For debugging purpose only
    /* public static map<string, list<string>> RecordTypeToCases_ForDebug(List<Case> NewList) 
    {
        map<string, list<string>> RecordTypeToCases = new map<string, list<string>>();
        
        for(Case c: NewList)
        {
            string RecordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Case', c.RecordTypeId);
            list<string> CasesRecordTypeWise = RecordTypeToCases.get(RecordTypeName);
            
            if(CasesRecordTypeWise == null)
            { 
                CasesRecordTypeWise = new list<string>();
                CasesRecordTypeWise.add(c.status);
            }
            else
            {
                CasesRecordTypeWise.add(c.status);
            }
            
            RecordTypeToCases.put(RecordTypeName, CasesRecordTypeWise);
        }
        
        return RecordTypeToCases;
    }
    
    public static map<string, list<string>> ToggleFilter_ForDebug(list<Case> NewList)
    {       
        
        map<string, list<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise = new map<string, list<Trigger_Toggle__c>>(
            ALL_Case_Handler.getOrganizedTriggerToggles()
        );
        
        
        map<string, list<string>> RecordTypeToCases = new map<string, list<string>>(
            ALL_Case_Handler.RecordTypeToCases_ForDebug(NewList)
        ); 
           
        
        return ALL_Case_Handler.recordWiseCasesOrganizer_ForDebug(TriggerTogglesRecordTypeWise, RecordTypeToCases);
    }
    
     public static map<string, list<string>> recordWiseCasesOrganizer_ForDebug(
        map<string, list<Trigger_Toggle__c>> TriggerTogglesRecordTypeWise, map<string, list<string>> RecordTypeToCases)
    {
        map<string, list<string>> CasesToRecordName = new map<string, list<string>> ();
        
        for(Trigger_Toggle__c Toggle: TriggerTogglesRecordTypeWise.get('TogglesWithNullRecordTypes'))
        {           
            if(Toggle != null )
            {
                string CodeReference = Toggle.Code_Reference__c;
                
                if(Toggle.On__c)
                {
                    for(Trigger_Toggle__c tt:  TriggerTogglesRecordTypeWise.get('TogglesWithRecordTypes'))
                    {
                        if(tt.Code_Reference__c == CodeReference && !tt.On__c)
                        {
                            list<string> CodeReferenceWiseCases = CasesToRecordName.get(CodeReference);
                            
                            for(string RecordTypeName: RecordTypeToCases.keySet())
                            {                                
                                if(CodeReferenceWiseCases == null)
                                {
                                    CodeReferenceWiseCases = new list<string>();
                                    
                                    if(RecordTypeName != tt.RecordType_Name__c)
                                    { 
                                        list<string> RecordTypesAndCases = RecordTypeToCases.get(RecordTypeName);
                                        if(RecordTypesAndCases != null && !RecordTypesAndCases.isEmpty())
                                        {
                                            for(string c:RecordTypesAndCases){
                                                CodeReferenceWiseCases.add(c);
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    if(RecordTypeName != tt.RecordType_Name__c)
                                    { 
                                        list<string> RecordTypesAndCases = RecordTypeToCases.get(RecordTypeName);
                                        if(RecordTypesAndCases != null && !RecordTypesAndCases.isEmpty())
                                        {
                                            for(string c:RecordTypesAndCases){
                                                CodeReferenceWiseCases.add(c);
                                            } 
                                        }
                                    } 
                                }                                                       
                            }                            
                            CasesToRecordName.put(CodeReference, CodeReferenceWiseCases); 
                        }
                    }
                }
                
                if(!Toggle.On__c)
                {
                    for(Trigger_Toggle__c tt:  TriggerTogglesRecordTypeWise.get('TogglesWithRecordTypes'))
                    {
                        if(tt.Code_Reference__c == CodeReference && tt.On__c)
                        {
                            list<string> CodeReferenceWiseCases = CasesToRecordName.get(CodeReference);
                            
                            for(string RecordTypeName: RecordTypeToCases.keySet())
                            {                        
                                if(CodeReferenceWiseCases == null)
                                {
                                    CodeReferenceWiseCases = new list<string>();
                                    
                                    if(RecordTypeName == tt.RecordType_Name__c)
                                    { 
                                        list<string> RecordTypesAndCases = RecordTypeToCases.get(RecordTypeName);
                                        if(RecordTypesAndCases != null && !RecordTypesAndCases.isEmpty())
                                        {
                                            for(string c:RecordTypesAndCases){
                                                CodeReferenceWiseCases.add(c);
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    if(RecordTypeName == tt.RecordType_Name__c)
                                    { 
                                        list<string> RecordTypesAndCases = RecordTypeToCases.get(RecordTypeName);
                                        if(RecordTypesAndCases != null && !RecordTypesAndCases.isEmpty())
                                        {
                                            for(string c:RecordTypesAndCases){
                                                CodeReferenceWiseCases.add(c);
                                            }
                                        }
                                    } 
                                }                      
                            }                            
                             
                            CasesToRecordName.put(CodeReference, CodeReferenceWiseCases);
                        }
                    }                     
                }
            }
        }        
        system.debug(CasesToRecordName);
        return CasesToRecordName;
    }*/
    

}