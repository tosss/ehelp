global with sharing class CB_UpdateExistingWebIdsToEntilmnts_Batch implements Database.Batchable<sObject> {
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string query = 'SELECT ID, OEM__c, Account__c from WebID__c where Status__c=\'New\' or Status__c=\'Active\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<WebID__c> scope)
    {
        try
        {
            list<Entitlement> entsToInsert = new list<Entitlement>();
            string eProcessName = '';
            set<String> removeDuplicateEprocessSet = new set<String>();
            map<String, SlaProcess> slaProcessMap = new map<String,SlaProcess>(); // SlaProcess - Entitlement Process
            
            string slaProcQuery = 'Select id, BusinessHoursId, Name, isActive from SlaProcess where isActive = true ';
            list<SlaProcess_Settings__c> customSettings = SlaProcess_Settings__c.getAll().values(); //Custom settings for the entitlement processes name
            
            if(customSettings!=null && !customSettings.isEmpty())
            {
                for(SlaProcess_Settings__c slaSet :customSettings)
                {
                    removeDuplicateEprocessSet.add(slaSet.EntitlementProcessName__c);
                } 
            }
            
            if(removeDuplicateEprocessSet!=null && !removeDuplicateEprocessSet.isEmpty())
            {
                slaProcQuery += 'and ('; 
                
                for(String s :removeDuplicateEprocessSet)
                {
                    
                    slaProcQuery += 'Name =\''+ s +'\' or ';
                }
                
                slaProcQuery = slaProcQuery.RemoveEnd(' or ');
                slaProcQuery += ')'; 
            }
            
            slaProcQuery += ' limit 20';
            system.debug('-----------Database Query------'+slaProcQuery);
            
            //for(SlaProcess slaProc : [Select id, BusinessHoursId, Name, isActive from SlaProcess where isActive = true and IsVersionDefault = true and
            // (Name = 'GM OEM Tech Support' or Name = 'Holden Tech Support' or Name = 'US Canada OEM Tech Support' 
            //or Name = 'Creative Support') limit 20])

            for(SlaProcess slaProc: Database.Query(slaProcQuery))
            {
                slaProcessMap.put(slaProc.Name, slaProc);
            }
            
            for(WebID__c webId: scope)
            {
                if(webId.OEM__c!=null && webId.OEM__c!='')
                {
                    if(SlaProcess_Settings__c.getInstance(webId.OEM__c).EntitlementProcessName__c!=null)
                    {
                        eProcessName = SlaProcess_Settings__c.getInstance(webId.OEM__c).EntitlementProcessName__c;
                    }
                    if(eProcessName!=null && eProcessName!='')
                    {
                        //Technical Support
                        //Entitlement techSupportRecord = createEntitlement(eProcessName,webId,slaProcessMap,'Technical Support');
                        //entsToInsert.add(techSupportRecord);
                        //Creative Support
                        Entitlement creativeSupportRecord = createEntitlement('Creative Support',webId,slaProcessMap,'Creative Support');
                        entsToInsert.add(creativeSupportRecord);
                    }
                    
                }
                
            }
            
            insert entsToInsert;
        }
        catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
        }
        
    }
    
    public static Entitlement createEntitlement(string oemType, WebID__c webId, Map<string,SlaProcess> slaProcessMap, string supportType)
    {
        Entitlement oemSupportEnt = new Entitlement();
        
        try{
            SlaProcess curOem = slaProcessMap.get(oemType);
            system.debug('----curOem----'+curOem);
            if(curOem != null)
            {
                oemSupportEnt.name = oemType;
                oemSupportEnt.AccountId = webId.Account__c;
                oemSupportEnt.BusinessHoursId = curOem.BusinessHoursId;
                oemSupportEnt.SlaProcessId = curOem.Id;
                oemSupportEnt.WebID__c = webId.Id;
                oemSupportEnt.Type = supportType;
                oemSupportEnt.StartDate = Date.Today();
            }
        }
        Catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
        }
        return oemSupportEnt;
    }
    global void finish(Database.BatchableContext BC)
    {
        try
        {
            Id JobId = null;
            if(BC != null) { JobId = BC.getJobId(); }
            
            AsyncApexJob BatchJob = null;
            List<AsyncApexJob> BatchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedDate 
                                            FROM AsyncApexJob WHERE Id = :JobId LIMIT 1];
            
            ALL_UtilitiesMiscellaneous.Job j = null;
            if(!BatchJobs.IsEmpty()) { j = new ALL_UtilitiesMiscellaneous.Job(BatchJobs[0]); } 
            else { j = new ALL_UtilitiesMiscellaneous.Job(); }
            
            ALL_UtilitiesMiscellaneous.SendBatchCompleteMessage(j, 'WebIdEntAssignBatch', 'Finished ', 'Batch Complete');
        }
        Catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
        }
    }
    
    

}