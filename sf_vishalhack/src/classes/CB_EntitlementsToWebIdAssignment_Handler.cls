/*
--2/20/15 - Venkata Shrivol Created 

******Status of Entitlments****** 
Active=if (system date>=StartDate && system date<=EndDate)
Expired=if(system date>= EndDate)
Inactive if(system date<= StartDate)
******Status of Entitlments******
*/
//2016-02-22- anirudh.singh@cdk.com- Modified this class to correct the indentation and naming standards.
//2016-08-02 - siva.pragad@cdk.com - added tryCatch and Exception logging
//2017-05-24 - siva.pragada@cdk.com - entitlements duplicates fix
public with sharing class CB_EntitlementsToWebIdAssignment_Handler 
{
    //To Pass the Id of WebId object which are 'Active' on Insert.
    public static void createEntitlementOnInsert(Map<Id, WebId__c> webIdNewMap)
    {
        try{            
            Map<Id, WebId__c> activeOrNewWebIdsMap=new Map<Id, WebId__c>();
            
            for(Id webId: webIdNewMap.keySet())
            {
                if(webIdNewMap.get(webId).Status__c=='Active' || webIdNewMap.get(webId).Status__c=='New')
                {
                    activeOrNewWebIdsMap.put(webId, webIdNewMap.get(webId));
                }
            }
            
            if(!activeOrNewWebIdsMap.isEmpty())
            {
                //To create Entitlements on Insert of WebId.
                createEntitlements(activeOrNewWebIdsMap.keySet(), false);
            }
        }
        Catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
        }
    }
    
    //To Pass the Id's of WebId object which are either updating their OEM's or 'Inactive'.
    public static void createEntitlementOnUpdate(Map<Id, WebId__c> webIdOldMap, Map<Id, WebId__c> webIdNewMap)
    {
        try{
            Map<Id, WebId__c> entitlementsToCreateWebIdsMap=new Map<Id, WebId__c>();
            Map<Id, WebId__c> entitlementsToCloseWebIdsMap=new Map<Id, WebId__c>();
            
            for(Id webId: webIdNewMap.keySet())
            {  
                Boolean webIdStatusChanged, webIdOEMChanged, webIdStatusActive, webIdStatusNew, 
                    oldWebIdStatusInActiveOrNull, webIdStatusInActive, webIdAccountChanged;
                
                webIdStatusChanged=(webIdOldMap.get(webId).Status__c!=webIdNewMap.get(webId).Status__c);
                webIdOEMChanged=(webIdOldMap.get(webId).OEM__c!=webIdNewMap.get(webId).OEM__c);
                webIdStatusActive=(webIdNewMap.get(webId).Status__c=='Active');
                webIdStatusNew=(webIdNewMap.get(webId).Status__c=='New');
                oldWebIdStatusInActiveOrNull=(webIdOldMap.get(webId).Status__c=='Inactive') || (webIdOldMap.get(webId).Status__c==Null);
                webIdStatusInActive=(webIdNewMap.get(webId).Status__c=='Inactive');
                webIdAccountChanged=(webIdOldMap.get(webId).Account__c!=webIdNewMap.get(webId).Account__c);
                
                if((webIdStatusChanged || webIdOEMChanged) && ((webIdStatusActive || webIdStatusNew)/* && oldWebIdStatusInActiveOrNull*/))
                {
                    entitlementsToCreateWebIdsMap.put(webId, webIdNewMap.get(webId));
                }
                else if((webIdStatusChanged || webIdOEMChanged) && webIdStatusInActive)
                {
                    entitlementsToCloseWebIdsMap.put(webId, webIdNewMap.get(webId));
                }
            }
            
            if(!entitlementsToCreateWebIdsMap.isEmpty())
            {
                //Create Entitlments on Update of WebId.
                createEntitlements(entitlementsToCreateWebIdsMap.keySet(), true);
            }
            
            if(!entitlementsToCloseWebIdsMap.isEmpty())
            {
                //Close Entitlements on Update of WebId.
                closeEntitlements(entitlementsToCloseWebIdsMap);
            }
        }
        Catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
        }
    }
    
    @future
    public static void createEntitlements(Set<Id> webIds, Boolean isUpdate)
    {
        //try{
            Map<Id, WebId__c> mainWebIdMap = new Map<Id, WebId__c>([
                Select Id, Name, OEM__c, Account__c 
                from WebId__c 
                where Id in :webIds
            ]);
        
            //List to add/update Entitlements.
            List<Entitlement> entitlementList=new List<Entitlement>();
            String entitlementProcessName='';
            Set<String> duplicateEntitlementProcesses=new Set<String>();
            
            //SlaProcess - Entitlement Process.
            Map<String, SlaProcess> slaProcessMap = new Map<String, SlaProcess>();
            
            //Entitlement Process Map - Start.
            String slaProcessQuery='Select Id, BusinessHoursId, Name, isActive from SlaProcess where isActive=true ';
            
            //Custom Settings for the entitlement processes name.
            List<SlaProcess_Settings__c> entitlementProcessSettingsList=SlaProcess_Settings__c.getAll().values();
            
            if(entitlementProcessSettingsList!=Null && !entitlementProcessSettingsList.isEmpty())
            {
                for(SlaProcess_Settings__c entitlementProcessSettings: entitlementProcessSettingsList)
                {
                    duplicateEntitlementProcesses.add(entitlementProcessSettings.EntitlementProcessName__c);
                } 
            }
            
            if(duplicateEntitlementProcesses!=Null && !duplicateEntitlementProcesses.isEmpty())
            {
                slaProcessQuery += 'and ('; 
                
                for(String str: duplicateEntitlementProcesses)
                {
                    
                    slaProcessQuery += 'Name =\''+ str +'\' or ';
                }
                
                slaProcessQuery=slaProcessQuery.RemoveEnd(' or ');
                slaProcessQuery += ')'; 
            }
            slaProcessQuery += ' limit 20';
            
            system.debug('slaProcessQuery---->'+slaProcessQuery);
            
            //for(SlaProcess slaProc: [Select Id, BusinessHoursId, Name, isActive from SlaProcess where isActive=true and IsVersionDefault=true and
            //(Name='GM OEM Tech Support' or Name='Holden Tech Support' or Name='US Canada OEM Tech Support' 
            //or Name='Creative Support') limit 20])
            for(SlaProcess slaProcess: Database.Query(slaProcessQuery))
            {
                slaProcessMap.put(slaProcess.Name, slaProcess);
            }
            
            system.debug('mainWebIdMap---->'+mainWebIdMap);
            system.debug('slaProcessMap---->'+slaProcessMap);
            //Entitlement Process Map - End.
            
            Map<Id, List<Entitlement>> webIdAndEntitlementListMap = new Map<Id, List<Entitlement>>();
            
            for(Entitlement ent: [SELECT Id, Name, StartDate, EndDate, WebId__c 
                                  FROM Entitlement 
                                  WHERE EndDate = null
                                  AND Status = 'Active'
                                  AND WebId__c in :WebIds])
            {
                List<Entitlement> entitlmentsForWebIdList = webIdAndEntitlementListMap.containsKey(ent.WebId__c) ? webIdAndEntitlementListMap.get(ent.WebId__c):  new List<Entitlement>();
                entitlmentsForWebIdList.add(ent);
                
                webIdAndEntitlementListMap.put(ent.WebId__c, entitlmentsForWebIdList);
            }
            //Entitlement Creation - Start.
            for(WebId__c webId: mainWebIdMap.values())
            {
                entitlementProcessName='';
                
                if(webId.OEM__c!=Null)
                {
                    if(SlaProcess_Settings__c.getInstance(webId.OEM__c)!=Null)
                    {
                        if(SlaProcess_Settings__c.getInstance(webId.OEM__c).EntitlementProcessName__c!=Null)
                        {
                            entitlementProcessName=SlaProcess_Settings__c.getInstance(webId.OEM__c).EntitlementProcessName__c;
                        }
                    }
                }
                
                //Exisiting Entitlements - Start; Not useful as of now, have to check with Cami
                //Only for Update - Start ;
                List<Entitlement> entitlmentsForWebIdList = webIdAndEntitlementListMap.containsKey(webId.Id) ? webIdAndEntitlementListMap.get(webId.Id): new List<Entitlement>();
                
                Boolean createCreative = false;
                Boolean createTechnical = false;
                
                Set<String> creativeSet = new Set<String>();
                Set<String> technicalSet = new Set<String>();
                
                if(entitlmentsForWebIdList.size() > 0)
                {
                    for(Entitlement entitlementRecord: entitlmentsForWebIdList)
                    {
                        if(entitlementRecord.Name != entitlementProcessName && 
                           entitlementRecord.Name != 'Creative Support')
                        {
                            entitlementRecord.endDate=date.Today();
                            entitlementList.add(entitlementRecord);
                        }
                        
                        if(entitlementRecord.Name == 'Creative Support')
                        {
                            creativeSet.add(entitlementRecord.Name);
                        }
                        else
                        {
                            technicalSet.add(entitlementRecord.Name);
                        }
                    }
                }
                
                if(creativeSet.isEmpty())
                {
                    createCreative = true;
                }
                
                if(!technicalSet.contains(entitlementProcessName))
                {
                    createTechnical = true;
                }
                
                //Only for Update - End
                //Exisiting Entitlements - End
                
                //For Creation of TechSupport Ent
                if(createTechnical)
                {
                    Entitlement techSupportEntitlement = createEnt(entitlementProcessName, webId, slaProcessMap, 'Technical Support');
                    if(techSupportEntitlement != null){ entitlementList.add(techSupportEntitlement); }
                }
                
                //For Creation of CreativeSupport Ent
                if(createCreative)
                {		
                    Entitlement creativeSuppEntitlement = createEnt('Creative Support', webId, slaProcessMap, 'Creative Support');
                    if(creativeSuppEntitlement != null){ entitlementList.add(creativeSuppEntitlement); }
                }
            }
        
            upsert entitlementList;
            
            if(isUpdate)
            {
                //For Updating the cases if the WebId is turned to active again
                CB_EntitlementsToCaseAssignment_Handler.updateEntToCaseOnWebIdUpdate(webIds);
            }
        //}
        //Catch(Exception exp)
        //{
            //ALL_UtilitiesMiscellaneous.logException(exp);
        //}
    }
    
    public static Entitlement createEnt(String entitlementProcessName, WebId__c webId, Map<String, SlaProcess> slaProcessMap, String supportType)
    {
        Entitlement newEnt;
        try{
            SlaProcess currentSlaProcess=slaProcessMap.get(entitlementProcessName);
            //system.debug('currentSlaProcess---->'+currentSlaProcess);
            
            if(currentSlaProcess!=Null)
            {
                newEnt = new Entitlement();
                newEnt.name=entitlementProcessName;
                newEnt.AccountId=webId.Account__c;
                newEnt.BusinessHoursId=currentSlaProcess.BusinessHoursId;
                newEnt.SlaProcessId=currentSlaProcess.Id;
                newEnt.WebId__c=webId.Id;
                newEnt.Type=supportType;
                newEnt.StartDate=Date.Today();
            }
        }
        Catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
        }
        
        return newEnt;
    }
    
    private static void closeEntitlements(Map<Id, WebId__c> mainWebIdMap) 
    {
        try{
            //webIdAndEntitlementListMap
            List<Entitlement> entitlementList=new List<Entitlement>();
            Map<Id, List<Entitlement>> webIdAndEntitlementListMap=new Map<Id, List<Entitlement>>();
            List<Entitlement> entitlmentsForWebIdList=new List<Entitlement>();
            
            for(Entitlement entitlement: [Select Id, Name, StartDate, EndDate, WebId__c from Entitlement where WebId__c in :mainWebIdMap.keySet()])
            {
                entitlmentsForWebIdList=webIdAndEntitlementListMap.containsKey(entitlement.WebId__c) ? webIdAndEntitlementListMap.get(entitlement.WebId__c):  new List<Entitlement>();
                entitlmentsForWebIdList.add(entitlement);
                webIdAndEntitlementListMap.put(entitlement.WebId__c, entitlmentsForWebIdList);
            }
            
            system.debug('webIdAndEntitlementListMap---->'+webIdAndEntitlementListMap);
            
            for(WebId__c webId: mainWebIdMap.values())
            {
                //Only for Update - Start
                //entitlmentsForWebIdList=webIdAndEntitlementListMap.containsKey(webId.Id) ? webIdAndEntitlementListMap.get(webId.Id): new List<Entitlement>();
                if(webIdAndEntitlementListMap.containsKey(webId.Id))
                {
                    entitlmentsForWebIdList=webIdAndEntitlementListMap.get(webId.Id);
                }
                system.debug('entitlmentsForWebIdList---->'+entitlmentsForWebIdList);
                
                if(entitlmentsForWebIdList.size()>0)
                {
                    for(Entitlement entitlement: entitlmentsForWebIdList)
                    {
                        if(entitlement.endDate==Null)
                        {
                            entitlement.endDate=date.Today();
                            entitlementList.add(entitlement);
                        }
                    }
                }
                //Only for Update - End
            }
            update entitlementList;          
        }
        Catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
        }
    }
}