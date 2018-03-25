/*----------------------------------------------
HISTORY:

07-13-15 - Hemanth Kesapragada - RQ-04941-Added logic to call Entitlements method when record type changes
07-28-15 - Venkata Shrivol     - Code Refactored for total Entitlements and RQ-05068 
11-2015  - siva.pragada@cdk.com - refactored code and moved out code to separate handler classes.
12-08-2015 - siva.pragada@cdk.com - used ALL_TriggerToggle_Handler.cls for trigger logic replacing and deleting ToggleFilter method.
2-17-2016 -  siva.pragada@cdk.com - added static maps to reference in entitlements time trigger
2016-05-12 - lalitha.adduru@cdk.com - assign contact relationship field when account or contact lookup is updated - RQ-06982
12-20-2016 - siva.pragada@cdk.com - made changes to create static new and old trigger maps to make available in entitlement time triggers.
2017-02-09 lalitha.adduru@cdk.com Use Trigger Toggle to populate email field on Case Termination Record Type only - RQ-08446

-------------------------------------------------*/
//2017-Sep-30  vishal.bandari@cdk.com - Added Code to Sync JIRA Methods 

public class ALL_Case_Handler 
{   
    public static map<ID, Case> staticCaseMap;
    public static map<ID, MileStoneType> staticMileStonesMap;
    public static map<ID, Case> staticNewMap; // set this after trigger to have ID in the map
    public static map<ID, Case> staticOldMap; 
    public static boolean isInsert = Trigger.isInsert;
    public static boolean isUpdate = Trigger.isUpdate;
    public static String runFutureOnce = '';
    public static void ToggleController(List<Case> NewList, List<Case> OldList, Map<Id, Case> newMap, Map<Id, Case> oldMap)
    {
        try
        {
            boolean notFutureOrBatch = !system.isFuture() && !system.isBatch() && !system.isScheduled();
            
            // begin checking processing for each code block
            // map<CodeReference, list<Case>>
            map<string, list<Case>> FilteredTriggerNew = new map<string, list<Case>>(); 
            
            FilteredTriggerNew = ALL_TriggerToggle_Handler.ToggleFilter(NewList);
            //system.debug(FilteredTriggerNew);
            FilteredTriggerNew = ALL_Case_Handler.ProfileFilter(FilteredTriggerNew);
            //system.debug(FilteredTriggerNew);
            
            // process before insert and before update actions
            if(Trigger.isBefore) 
            {
                boolean recursiveCheckBefore = All_CheckRecursive.runCodeBlockOnce('runOnce_04202017@Case');
                
                if(Trigger.isInsert || Trigger.isUpdate) 
                {
                    if(Test.isRunningTest() || recursiveCheckBefore)
                    {
                        system.debug('insert or update a case');
                        //2017-02-09 lalitha.adduru@cdk.com Use Trigger Toggle to populate email field on- 
                        //Case Termination Record Type only - RQ-08446
                        list<Case> TerminationTypeCases = FilteredTriggerNew.get('UpdateCaseTerminationEmail');
                        system.debug('TerminationTypeCases --- >'+TerminationTypeCases);
                        if(TerminationTypeCases != null && !TerminationTypeCases.isEmpty())
                        {
                            caseTriggers.updateCaseTerminationEmail(TerminationTypeCases, OldMap);
                        }
                        list<Case> partnerContactCases = FilteredTriggerNew.get('DSCB_UpdatesThroughCaseObject');                        
                        //system.debug(partnerContactCases);
                        if(partnerContactCases != null && !partnerContactCases.isEmpty())
                        {
                            DSCB_UpdatesThroughCaseObject.retrieveValuesFromLookUpsToCase(partnerContactCases);
                        }
                        // DSCB_CaseReferenceFields
                        list<Case> ReferenceFieldCases = FilteredTriggerNew.get('DSCB_CaseReferenceFields');
                        
                        if( ReferenceFieldCases != null && !ReferenceFieldCases.isEmpty())  
                        {
                            DSCB_CaseReferenceFields.SetCaseReferenceFields(ReferenceFieldCases); 
                        }
                        
                        // DS_CaseDefaultAccount
                        list<Case> DefaultAccountCases = FilteredTriggerNew.get('DS_CaseDefaultAccount');
                        
                        if( DefaultAccountCases != null && !DefaultAccountCases.isEmpty())
                        {
                            DSCB_CaseReferenceFields.CaseDefaultAccount(DefaultAccountCases);
                        }  
                        
                        //DSCB_CaseUserManager
                        list<Case> UserManagerCases = FilteredTriggerNew.get('DSCB_CaseUserManager');
                        
                        if(UserManagerCases != null && !UserManagerCases.isEmpty())
                        {
                            DSCB_CaseReferenceFields.CaseUserManager(UserManagerCases, oldMap);
                        }
                        
                        // SEO Case Assignment rule through the trigger based on Account Plan resource fields added 11/24/2014 SivaP
                        list<Case> SeoAssignmentCases = FilteredTriggerNew.get('DSCB_CaseAssignment');
                        
                        if(SeoAssignmentCases != null && !SeoAssignmentCases.isEmpty()) 
                        {                      
                            DSCB_CaseAssignment.CaseAssignmentRule(SeoAssignmentCases, OldMap);
                        } 
                        
                        if(Trigger.isInsert)
                        {
                            system.debug('************** oldMap*****'+oldMap);
                            
                            // 2016-06-27 matt.keefe@cdk.com 
                            Map<String, String> contactToCRMap = new Map<String, String>();
                            contactToCRMap.put('ContactId','Contact_Name_Relationship__c');
                            ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, OldMap,'AccountId', null, contactToCRMap);
                            
                            // begin CB_EntitlementsToCaseAssignment_Handler
                            // Added by Venkata 03/16/2015 for updating case with Entitlements from related WebId 
                            list<Case> EntitlementToCases = FilteredTriggerNew.get('CB_EntitlementsToCaseAssignment_Handler');
                            
                            if(EntitlementToCases != null && !EntitlementToCases.isEmpty())
                            {
                                CB_EntitlementsToCaseAssignment_Handler.webIdNullCheck(EntitlementToCases, oldMap);
                            }
                            
                            // moved it inside isInsert condition- business change
                            // 4/20/2016 - siva.pragada@cdk.com
                            list<Case> concatenateCases = FilteredTriggerNew.get('DSCB_CaseConcatenate_Handler');
                            
                            if(concatenateCases != null && !concatenateCases.isEmpty()) 
                            {
                                DSCB_CaseConcatenate_Handler.ConcatenateTheFieldValues(concatenateCases);
                            }
                        }
                        
                        if(Trigger.isUpdate)
                        {
                            
                            //  list<Case> contactRelationshipCases = FilteredTriggerNew.get('ALL_ContactRelationship_Helper');
                            //  if(contactRelationshipCases != null && !contactRelationshipCases.isEmpty())
                            //  {
                            //2016-05-17 lalitha.adduru@cdk.com - RQ-06982
                            //2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
                            system.debug('********* after update starts here ');
                            Map<String, String> contactToCRMap = new Map<String, String>();
                            contactToCRMap.put('ContactId','Contact_Name_Relationship__c');
                            ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.new, OldMap,'AccountId', null, contactToCRMap);
                            
                            // begin CB_MileStoneDatesOnCase_Handler
                            // Case Completion Dates - Start
                            list<Case> completionDateCasesBU = FilteredTriggerNew.get('CB_MileStoneDatesOnCase_Handler');
                            
                            if( completionDateCasesBU != null && !completionDateCasesBU.isEmpty()) 
                            {                      
                                CB_MileStoneDatesOnCase_Handler.updateCases(completionDateCasesBU, oldMap);
                            } 
                            // Case Completion Dates - End
                            // end CB_MileStoneDatesOnCase_Handler
                            
                            list<Case> creativeAndTechSupportCases = FilteredTriggerNew.get('CB_EntitlementsToCaseAssignment_Handler');
                            
                            if(creativeAndTechSupportCases != null && !creativeAndTechSupportCases.isEmpty())
                            {
                                CB_Entitlements_Handler.routeEntitlementCallsToHandlers(creativeAndTechSupportCases, oldMap);
                            }
                            
                            // Added by Venkata 06/04/2015 for updating case with Entitlements from related WebId 
                            list<Case> EntitlementToCasesBU = FilteredTriggerNew.get('CB_EntitlementsToCaseAssignment_Handler');
                            
                            if(EntitlementToCasesBU != null && !EntitlementToCasesBU.isEmpty())
                            {
                                CB_Entitlements_Handler.entitlementsToCasesBU(EntitlementToCasesBU, oldMap);
                            }
                        } // end Trigger.isUpdate
                        
                        //2017-12-06 - siva.pragad@cdk.com - added for RQ-09398  
                        list<Case> ContactRelPhone = FilteredTriggerNew.get('CB_AllCaseRecordTypes_Handler');                        
                        if(ContactRelPhone != null && !ContactRelPhone.isEmpty()) 
                        {                      
                            CB_AllCaseRecordTypes_Handler.updateCasePhone(ContactRelPhone, OldMap);
                        }
                    }
                }
                
            } // end Trigger.isBefore
            
            if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
            {
                boolean recursiveCheckAfter = All_CheckRecursive.runCodeBlockOnce('recursiveCheckAfter');
                
                if(recursiveCheckAfter)
                {
                    staticNewMap = (map<ID, Case>)Trigger.newMap; // set this after insert to have ID in the map
                    staticOldMap = (map<ID, Case>)Trigger.oldMap;
                    
                    if(Trigger.isUpdate)
                    {
                        // begin CB_MileStoneDatesOnCase_Handler
                        // Case Entitlements COmpletion Date - Start
                        list<Case> completionDateCasesAU = FilteredTriggerNew.get('CB_MileStoneDatesOnCase_Handler');
                        
                        if(completionDateCasesAU != null && !completionDateCasesAU.isEmpty())
                        {
                            CB_Entitlements_Handler.completionDateCasesAU(completionDateCasesAU, oldMap);
                        }
                        
                        //2016-11-02 - siva.Pragada@cdk.com for retention record automation
                        List<Case> cancellationCases = FilteredTriggerNew.get('CB_createRetentionRecords');
                        
                        if(cancellationCases != null && !cancellationCases.isEmpty())
                        {
                            CB_Entitlements_Handler.CB_createRetentionRecords(CancellationCases);
                        }
                    } 
                    
                    if(Trigger.isInsert)
                    {
                        // begin CB_CrtiveCseTallyUpdteWbIdAccPlan_Hndler, also CB_MileStoneDatesOnCase_Handler
                        list<Case> ccTallyUpdateCases = FilteredTriggerNew.get('CB_CrtiveCseTallyUpdteWbIdAccPlan_Hndler');
                        
                        if(ccTallyUpdateCases != null && !ccTallyUpdateCases.isEmpty())
                        {
                            CB_Entitlements_Handler.ccTallyUpdateCases(ccTallyUpdateCases);
                        }
                        
                        list<Case> targetDateTimecaseListAI = FilteredTriggerNew.get('CB_MileStoneDatesOnCase_Handler');
                        
                        if(targetDateTimecaseListAI != null && !targetDateTimecaseListAI.isEmpty())
                        {
                            CB_Entitlements_Handler.targetDateTimecaseListAI(targetDateTimecaseListAI);
                        }
                        
                        //2016-11-02 - siva.Pragada@cdk.com for retention record automation
                        List<Case> cancellationCases = FilteredTriggerNew.get('CB_createRetentionRecords');
                        
                        if(cancellationCases != null && !cancellationCases.isEmpty())
                        {
                            CB_Entitlements_Handler.CB_createRetentionRecords(CancellationCases);
                        }
                    }
                }
                
                // CaseTriggers - separate class, but not separate trigger
                list<Case> CaseTriggerCases = FilteredTriggerNew.get('caseTriggers');
                
                if(CaseTriggerCases != null && !CaseTriggerCases.isEmpty() && ALL_CheckRecursive.runCodeBlockGivenTimes('CaseTeamMember', 3))
                { 
                    caseTriggers.CaseTriggerCases(CaseTriggerCases, NewMap, oldMap);
                } 
                
                // DSCB_CaseAccountFieldUpdate - pulled in, not a separate trigger/class            
                list<Case> AccountFieldUpdateCases = FilteredTriggerNew.get('DSCB_CaseAccountFieldUpdate');
                
                if(AccountFieldUpdateCases != null && !AccountFieldUpdateCases.isEmpty())
                {
                    CB_Entitlements_Handler.AccountFieldUpdateCases(AccountFieldUpdateCases);
                }
                // end DSCB_CaseAccountFieldUpdate
                
                // For updating the response date field value on contact object with the same field value on Case if record type is Tier 1
                // This is controlled from Trigger Toggle custom settings
                list<Case> ResponseDateCases = FilteredTriggerNew.get('DSCB_UpdatesThroughCaseObject');
                
                //2016-07-28 - siva.pragada@cdk.com - added All_checkRecursive to allow trigger through 2 times 
                if(ResponseDateCases != null && !ResponseDateCases.isEmpty() && 
                   ALL_CheckRecursive.runCodeBlockGivenTimes('DSCB_UpdatesThroughCaseObject20160728', 3))
                {
                    DSCB_UpdatesThroughCaseObject.UpdateMethod(ResponseDateCases, oldMap);
                }
                
                staticCaseMap = new map<ID, Case>([
                    Select Id, Priority, Status, EntitlementId, Entitlement.BusinessHoursId, SlaStartDate, Product_Category__c,
                    Problem_Code__c, Target_Date_Time_SLA__c, X911_Escalation__c, DA_Echelon_Level__c, Target_Date_Time__c, isStopped,
                    recordType.Name, OwnerId, Owner.Name,
                    Entitlement.BusinessHours.TimeZoneSidKey, Entitlement.BusinessHours.MondayStartTime, 
                    Entitlement.BusinessHours.MondayEndTime, Entitlement.BusinessHours.TuesdayStartTime, 
                    Entitlement.BusinessHours.TuesdayEndTime, Entitlement.BusinessHours.WednesdayStartTime, 
                    Entitlement.BusinessHours.WednesdayEndTime, Entitlement.BusinessHours.ThursdayStartTime, 
                    Entitlement.BusinessHours.ThursdayEndTime, Entitlement.BusinessHours.FridayStartTime, 
                    Entitlement.BusinessHours.FridayEndTime, Entitlement.BusinessHours.SaturdayStartTime, 
                    Entitlement.BusinessHours.SaturdayEndTime, Entitlement.BusinessHours.SundayStartTime, 
                    Entitlement.BusinessHours.SundayEndTime, CreatedDate, MilestoneStatus,
                    (Select ID, MileStoneTypeId From CaseMileStones),
                    (Select ID, CaseId, oldValue, newValue, Field, CreatedDate From Histories Where Field = 'isStopped')
                    From Case
                    Where ID IN :newMap.keySet()
                ]);
                //system.assertEquals(staticCaseMap, new map<ID, Case>());
                staticMileStonesMap = new map<ID, MileStoneType>([
                    Select ID, Name 
                    From MileStoneType
                    Limit 100
                ]);
                
                
            } // end Trigger.isAfter
        }
        catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
        }
    }
    
    //2017-Sep-30  vishal.bandari@cdk.com - Added Method to Sync JIRA Methods 
    
    public static void createJIRAIssue(List<Case> newCaseList)
    {
        Id serviceConnectRecordTypeId = All_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Service Connect');
        for(Case newCaseObj: newCaseList)
        {
            if(newCaseObj.RecordTypeId == serviceConnectRecordTypeId)
            {
                createJIRAFuture(JSON.serialize(newCaseObj));
            }
        }
    }
    
    //2017-Sep-30  vishal.bandari@cdk.com - Added Method to Sync JIRA Methods 
    public static void updateJIRAIssue(List<Case> newCaseList, Map<id,Case> oldCaseMap)
    {
        Id serviceConnectRecordTypeId = All_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Service Connect');
        for(Case newCaseObj: newCaseList)
        {
            if(newCaseObj.RecordTypeId == serviceConnectRecordTypeId)
            {
                updateJIRAFuture(JSON.serialize(newCaseObj),JSON.serialize(oldCaseMap.get(newCaseObj.Id)));
            }
        }
    }
    
    
    //2017-Sep-30  vishal.bandari@cdk.com - Added Method to Sync JIRA Methods 
    @future(callout=true)
    public static void createJIRAFuture(String newCaseObj)
    {
        Case caseObj = (Case)Json.deserialize(newCaseObj, Case.class);
        Http h = new Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://JIRA_Instance_URL/rest/api/2/issue/');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        String fieldsString = '';
        List<Case_to_Jira__c> ctj = Case_to_Jira__c.getAll().values();
        for(Case_to_Jira__c ctjObj : ctj)
        {
            if(ctjObj.IsSFAccessible__c && ctjObj.JiraName__c.toLowerCase() !='status')
            {
                fieldsString+='"'+ctjObj.JiraName__c.toLowerCase()+'":"'+caseObj.get(ctjObj.CaseName__c)+'",';
            }
        }
        fieldsString = fieldsString.removeEnd(',');
        req.setBody('{"fields": {   "project":   {       "key": "SFI"   } ,   "issuetype": {      "name": "Story"   }, '+fieldsString+' }}');
        req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(BLob.valueOf('username:password')) );
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        if(res.getStatusCode()>=200 &&  res.getStatusCode()<205)
        {
            caseObj.JiraIssue__c = res.getBody().substringBetween('"key":"','","');
            //To Avoid Recurrence and infinte looping
            runFutureOnce = 'Jira Create';
            update caseObj;
        }
    }
    
    
    //2017-Sep-30  vishal.bandari@cdk.com - Added Method to Sync JIRA Methods     
    @future(callout=true)
    public static void updateJIRAFuture(String newCaseObj,String oldCaseObj)
    {
        Case caseObj = (Case)Json.deserialize(newCaseObj, Case.class);
        Case oldCase = (Case)Json.deserialize(oldCaseObj, Case.class);
        Http h = new Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://JIRA_Instance_URL/rest/api/2/issue/'+caseObj.JiraIssue__c);
        req.setMethod('PUT');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(BLob.valueOf('username:password')) );
        String updateFields = '{"update":{';
        String fields = '{"fields":';
        Boolean StatusChanged = false;
        List<Case_to_Jira__c> ctj = Case_to_Jira__c.getAll().values();
        for(Case_to_Jira__c ctjObj : ctj)
        {
            if(ctjObj.IsSFAccessible__c  && oldCase.get(ctjObj.CaseName__c) != caseObj.get(ctjObj.CaseName__c))
            {
                if(ctjObj.JiraName__c.toLowerCase() == 'status')
                {
                    StatusChanged =true;
                }
                else if(!ctjObj.JiraName__c.toLowerCase().startswith('customfield_'))
                {
                    updateFields+='"'+ctjObj.JiraName__c.toLowerCase()
                        +'":[{"'+ctjObj.Action__c.toLowerCase()+'":"'+caseObj.get(ctjObj.CaseName__c)+'"}],';
                }
                else
                {
                    fields+=
                        '{"'+ctjObj.Action__c.toLowerCase()+'":"'+caseObj.get(ctjObj.CaseName__c)+'"},';
                }
            }
        }
        
        //if Update has standard fields
        if(updateFields != '{"update":{')
        {
            updateFields = updateFields.removeEnd(',');
            updateFields+= '}}';
            req.setBody(updateFields);
            
            // Send the request, and return a response
            HttpResponse res = h.send(req);
        }
        //if Update has custom fields
        if(fields != '{"fields":')
        {
            fields = fields.removeEnd(',');
            fields+= '}';
            req.setBody(fields);
            
            // Send the request, and return a response
            HttpResponse res = h.send(req);
        }
        //if Update is Change in Status
        if(StatusChanged)
        {
            Map<String,String> statusMap = new Map<String,String>();
            statusMap.put('Open','11');
            statusMap.put('Waiting','31');
            statusMap.put('Reopened','11');
            statusMap.put('Resolved','61');
            statusMap.put('Returned','21');
            statusMap.put('QA','51');
            req.setMethod('POST');
            req.setEndpoint('JIRA_Instance_URL/rest/api/2/issue/'+caseObj.JiraIssue__c+'/transitions?expand=transitions.fields');
            req.setBody('{"transition": { "id": "'+statusMap.get(caseObj.Status)+'"}}');
            HttpResponse res = h.send(req);
        }
    }
    
    
    public static map<string, list<Case>> ProfileFilter(map<string, list<Case>> FinalCasesMap)
    {
        
        map<string, Trigger_Toggle_Profile__c> TpMap = Trigger_Toggle_Profile__c.getAll();
        
        for(Trigger_Toggle_Profile__c tp: TpMap.values())
        {
            if(tp.sObject__c == 'Case')
            {
                if(FinalCasesMap != null)
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
        }
        
        return FinalCasesMap;
    } 
}