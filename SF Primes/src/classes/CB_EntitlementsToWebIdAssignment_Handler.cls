/*
--2/20/15 - Venkata Shrivol Created 

******Status of Entitlments****** 
Active=if (system date>=StartDate && system date<=EndDate)
Expired=if(system date>= EndDate)
Inactive if(system date<= StartDate)
******Status of Entitlments******
*/
//2016-02-22- anirudh.singh@cdk.com- Modified this class to correct the indentation and naming standards.
public with sharing class CB_EntitlementsToWebIdAssignment_Handler 
{
    //To Pass the Id of WebId object which are 'Active' on Insert.
    public static void createEntitlementOnInsert(Map<Id, WebId__c> webIdNewMap)
    {
        system.debug('Start createEntitlementOnInsert---->');
        
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
        
        system.debug('End createEntitlementOnInsert---->');
    }
    
    //To Pass the Id's of WebId object which are either updating their OEM's or 'Inactive'.
    public static void createEntitlementOnUpdate(Map<Id, WebId__c> webIdOldMap, Map<Id, WebId__c> webIdNewMap)
    {
        system.debug('Start createEntitlementOnUpdate---->');
        
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
            
            if((webIdStatusChanged || webIdOEMChanged) && ((webIdStatusActive || webIdStatusNew) && oldWebIdStatusInActiveOrNull))
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
        
        system.debug('End createEntitlementOnUpdate---->');
    }
    
    @future
    public static void createEntitlements(Set<Id> webIds, Boolean isUpdate)
    {
        system.debug('Start createEntitlements---->');
        
        Map<Id, WebId__c> mainWebIdMap=new Map<Id, WebId__c>([Select Id, Name, OEM__c, Account__c from WebId__c where Id in :webIds]);
        
        //List to add/update Entitlements.
        List<Entitlement> entitlementList=new List<Entitlement>();
        String entitlementProcessName='';
        Set<String> duplicateEntitlementProcesses=new Set<String>();
        
        //SlaProcess - Entitlement Process.
        Map<String, SlaProcess> slaProcessMap=new Map<String, SlaProcess>();
        
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
        
        Map<Id, List<Entitlement>> webIdAndEntitlementListMap=new Map<Id, List<Entitlement>>();
        
        for(Entitlement ent: [Select Id, Name, StartDate, EndDate, WebId__c from Entitlement where WebId__c in :WebIds])
        {
            List<Entitlement> entitlmentsForWebIdList=webIdAndEntitlementListMap.containsKey(ent.WebId__c) ? webIdAndEntitlementListMap.get(ent.WebId__c):  new List<Entitlement>();
            entitlmentsForWebIdList.add(ent);
            
            webIdAndEntitlementListMap.put(ent.WebId__c, entitlmentsForWebIdList);
        }
        system.debug('webIdAndEntitlementListMap---->'+webIdAndEntitlementListMap);
        
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
            
            system.debug('entitlementProcessName---->'+entitlementProcessName);
            
            //Exisiting Entitlements - Start; Not useful as of now, have to check with Cami
            //Only for Update - Start ;
            List<Entitlement> entitlmentsForWebIdList=webIdAndEntitlementListMap.containsKey(webId.Id) ? webIdAndEntitlementListMap.get(webId.Id): new List<Entitlement>();
            
            if(entitlmentsForWebIdList.size() > 0)
            {
                for(Entitlement entitlementRecord: entitlmentsForWebIdList)
                {
                    if(entitlementRecord.Name!=entitlementProcessName && entitlementRecord.Name!='Creative Support')
                    {
                        entitlementRecord.endDate=date.Today();
                        entitlementList.add(entitlementRecord);
                    }
                }
            }
            //Only for Update - End
            //Exisiting Entitlements - End
            
            //For Creation of TechSupport Ent
            Entitlement techSupportEntitlement=createEnt(entitlementProcessName, webId, slaProcessMap, 'Technical Support');
            entitlementList.add(techSupportEntitlement);
            
            //For Creation of CreativeSupport Ent		
            Entitlement creativeSuppEntitlement=createEnt('Creative Support', webId, slaProcessMap, 'Creative Support');
            entitlementList.add(creativeSuppEntitlement);
        }
        //Entitlement Creation - End.
        
        system.debug('entitlementList---->'+entitlementList);
        
        try
        {
            Database.UpsertResult[] resultList=Database.upsert(entitlementList, false);
            system.debug('resultList---->'+resultList);
        }
        catch(Exception ex)
        {
            system.debug('Exception---->'+ex);
        }
        
        if(isUpdate)
        {
            //For Updating the cases if the WebId is turned to active again
            CB_EntitlementsToCaseAssignment_Handler.updateEntToCaseOnWebIdUpdate(webIds);
        }
        
        system.debug('End createEntitlements---->');
    }
    
    private static Entitlement createEnt(String entitlementProcessName, WebId__c webId, Map<String, SlaProcess> slaProcessMap, String supportType)
    {
        system.debug('Start createEnt---->');
        
        Entitlement oemSupportEnt=new Entitlement();
        SlaProcess currentSlaProcess=slaProcessMap.get(entitlementProcessName);
        system.debug('currentSlaProcess---->'+currentSlaProcess);
        
        if(currentSlaProcess!=Null)
        {
            oemSupportEnt.name=entitlementProcessName;
            oemSupportEnt.AccountId=webId.Account__c;
            oemSupportEnt.BusinessHoursId=currentSlaProcess.BusinessHoursId;
            oemSupportEnt.SlaProcessId=currentSlaProcess.Id;
            oemSupportEnt.WebId__c=webId.Id;
            oemSupportEnt.Type=supportType;
            oemSupportEnt.StartDate=Date.Today();
        }
        
        system.debug('End createEnt---->');
        return oemSupportEnt;
    }
    
    private static void closeEntitlements(Map<Id, WebId__c> mainWebIdMap) 
    {
        system.debug('Start closeEntitlements---->');
        
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
        system.debug('entitlementList---->'+entitlementList);
        
        try
        {
            Database.SaveResult[] resultList=Database.update(entitlementList, false);
            system.debug(resultList);
        }
        catch(Exception ex)
        {
            system.debug('Exception---->'+ex);
        }
        
        system.debug('End closeEntitlements---->');
    }
}