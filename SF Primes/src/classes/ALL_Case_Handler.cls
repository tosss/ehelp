/*----------------------------------------------
HISTORY:

07-13-15 - Hemanth Kesapragada - RQ-04941-Added logic to call Entitlements method when record type changes
07-28-15 - Venkata Shrivol     - Code Refactored for total Entitlements and RQ-05068 
11-2015  - siva.pragada@cdk.com - refactored code and moved out code to separate handler classes.
12-08-2015 - siva.pragada@cdk.com - used ALL_TriggerToggle_Handler.cls for trigger logic replacing and deleting ToggleFilter method.
2-17-2016 -  siva.pragada@cdk.com - added static maps to reference in entitlements time trigger
-------------------------------------------------*/
public class ALL_Case_Handler 
{  
    public static map<ID, Case> staticCaseMap;
    public static map<ID, MileStoneType> staticMileStonesMap;
    
    public static void ToggleController(List<Case> NewList, List<Case> OldList, Map<Id, Case> newMap, Map<Id, Case> oldMap)
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
            boolean recursiveCheckBefore = All_CheckRecursive.runCodeBlockOnce('AllowOnlyOnce');
            if(Trigger.isInsert || Trigger.isUpdate) 
            {
                if(recursiveCheckBefore)
                {
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
                        // begin CB_EntitlementsToCaseAssignment_Handler                
                        // Added by Venkata 03/16/2015 for updating case with Entitlements from related WebId 
                        list<Case> EntitlementToCases = FilteredTriggerNew.get('CB_EntitlementsToCaseAssignment_Handler');
                        
                        if(EntitlementToCases != null && !EntitlementToCases.isEmpty())
                        {
                            CB_EntitlementsToCaseAssignment_Handler.webIdNullCheck(EntitlementToCases, oldMap);
                        }
                    }
                    
                    if(Trigger.isUpdate)
                    {
                        // begin CB_MileStoneDatesOnCase_Handler
                        
                        // Case COmpletion Dates - Start
                        list<Case> completionDateCasesBU = FilteredTriggerNew.get('CB_MileStoneDatesOnCase_Handler');
                        
                        if( completionDateCasesBU != null && !completionDateCasesBU.isEmpty()) 
                        {                      
                            CB_MileStoneDatesOnCase_Handler.updateCases(completionDateCasesBU, oldMap);
                        } // Case COmpletion Dates - End
                        
                        
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
                }
            }
            
        } // end Trigger.isBefore
        
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
        {
            boolean recursiveCheckAfter = All_CheckRecursive.runCodeBlockOnce('recursiveCheckAfter');
            
            if(recursiveCheckAfter)
            {
                if(Trigger.isUpdate)
                {
                    // begin CB_MileStoneDatesOnCase_Handler
                    // Case Entitlements COmpletion Date - Start
                    list<Case> completionDateCasesAU = FilteredTriggerNew.get('CB_MileStoneDatesOnCase_Handler');
                    
                    if(completionDateCasesAU != null && !completionDateCasesAU.isEmpty())
                    {
                        CB_Entitlements_Handler.completionDateCasesAU(completionDateCasesAU, oldMap);
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
            
            if(ResponseDateCases != null && !ResponseDateCases.isEmpty() && recursiveCheckAfter)
            {
                DSCB_UpdatesThroughCaseObject.UpdateMethod(ResponseDateCases);
            }
            
            
            staticCaseMap = new map<ID, Case>([
                Select Id, Priority, Status, EntitlementId, Entitlement.BusinessHoursId, SlaStartDate, Product_Category__c,
                       Problem_Code__c, Target_Date_Time_SLA__c, X911_Escalation__c, DA_Echelon_Level__c,
                       Entitlement.BusinessHours.TimeZoneSidKey, Entitlement.BusinessHours.MondayStartTime, 
                       Entitlement.BusinessHours.MondayEndTime, Entitlement.BusinessHours.TuesdayStartTime, 
                       Entitlement.BusinessHours.TuesdayEndTime, Entitlement.BusinessHours.WednesdayStartTime, 
                       Entitlement.BusinessHours.WednesdayEndTime, Entitlement.BusinessHours.ThursdayStartTime, 
                       Entitlement.BusinessHours.ThursdayEndTime, Entitlement.BusinessHours.FridayStartTime, 
                       Entitlement.BusinessHours.FridayEndTime, Entitlement.BusinessHours.SaturdayStartTime, 
                       Entitlement.BusinessHours.SaturdayEndTime, Entitlement.BusinessHours.SundayStartTime, 
                       Entitlement.BusinessHours.SundayEndTime 
                From Case
                Where ID IN :newMap.keySet()
            ]);
            
            staticMileStonesMap = new map<ID, MileStoneType>([
                Select ID, Name 
                From MileStoneType
                Limit 100
            ]);
            
            
        } // end Trigger.isAfter
        
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
}