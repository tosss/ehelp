//2016-09-22  -vishal.bandari@cdk.com - RQ-07834 : created Class with name SLS_OpportunityLocation_Handler from SLSSlong
//2016-09-22  -vishal.bandari@cdk.com - RQ-07834 : commented out logic for Discovery_Site_Workbook__c as it is not configured in Salesforce
//2016-09-30  -ragashalini.koka@cdk.com-RQ-07925 : added logic to set Brands__c and OEMs on insertion of records
//2016-12-08  -vishal.bandari@cdk.com - RQ-08092 : CPQ - CDK Docusign CCs Object and its population
public class CPQ_OpportunityLocation_Handler 
{
    public static List<Id> recordsTobeDeleted;
    static
    {
        if(recordsTobeDeleted == null)
        {
            recordsTobeDeleted = new List<Id>();
        }
    }
    public static void beforeInsert(list<Opportunity_Location__c> newRecords)
    {
        String BuildingRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c', 'Building');
        Set<Id> requiredAccountIds = new Set<Id>();
        Set<Id> requiredOpportunityIds = new Set<Id>();
        //2016-09-30 ragashalini.koka@cdk.com -added variable to store the opportunity Ids of all Opportunity Locations
        Set<Id> opportunityIdSet = new Set<Id>();
        for(Opportunity_Location__c oppLocationObj : newRecords)
        {
            if(oppLocationObj.RecordTypeId == BuildingRecordTypeId)
            {
                requiredAccountIds.add(oppLocationObj.Site__c);
                requiredOpportunityIds.add(oppLocationObj.Opportunity__c);
            }
            opportunityIdSet.add(oppLocationObj.Opportunity__c);
        }
        if(requiredAccountIds.size() > 0 && requiredOpportunityIds.size() > 0)
        {
            List<Opportunity_Location__c> requiredSites = [
                SELECT ID, Site__c, Opportunity__c
                FROM Opportunity_Location__c 
                WHERE RecordType.Name = 'Site' 
                AND Site__c IN: requiredAccountIds 
                AND Opportunity__c IN:requiredOpportunityIds
            ];
            
            Map<String,Opportunity_Location__c> accOppToOppLocMap = new Map<String,Opportunity_Location__c>();
            
            for(Opportunity_Location__c oppLocSiteObj : requiredSites)
            {
                accOppToOppLocMap.put(oppLocSiteObj.Site__c +''+ oppLocSiteObj.Opportunity__c,oppLocSiteObj);
            }
            
            for(Opportunity_Location__c oppLocationObj : newRecords)
            {
                if(oppLocationObj.RecordTypeId == BuildingRecordTypeId)
                {
                    Opportunity_Location__c oppLocSiteObj = accOppToOppLocMap.get(oppLocationObj.Site__c +''+ oppLocationObj.Opportunity__c);
                    if(oppLocSiteObj == null )
                    {
                        oppLocationObj.addError('No Opportunity Location Site Found with Matching Site and Opportunity Details, Please create Opportunity Location Site first.');
                    }
                    else
                    {
                        oppLocationObj.Building_Site__c = oppLocSiteObj.Id;
                    }
                }
            }
        }
        
        //sets Brands__c and OEMs  on Opportunity_Locations
        if(opportunityIdSet.size() > 0) {
            Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>([SELECT Id, Account.Make__c, Account.OEM__c FROM Opportunity WHERE Id IN :opportunityIdSet]);
            if(opportunityMap != null) {
                for(Opportunity_Location__c oppLocationRec : newRecords) {
                    String opportunityId = oppLocationRec.Opportunity__c;
                    if(opportunityMap.containsKey(opportunityId)) {
                        String accountMake = opportunityMap.get(opportunityId).Account.Make__c;
                        String accountOEM = opportunityMap.get(opportunityId).Account.OEM__c;
                        if(accountMake != null) {
                            oppLocationRec.Brands__c = accountMake.left(1000);
                        }
                        if(accountOEM != null) {
                            oppLocationRec.OEMs__c = accountOEM.left(1000);
                        }
                    }
                }
            }
        }
        
    }
    public static void beforeDelete(List<Opportunity_Location__c> oldList)
    {
        for(Opportunity_Location__c siteObj: [Select Id FROM Opportunity_Location__c WHERE Building_Site__c IN: oldList AND Building_Site__r.RecordType.Name = 'Site'])
        {
           recordsTobeDeleted.add(siteObj.Id);
        }
    }
    public static void afterDelete(List<Opportunity_Location__c> oldList)
    {
        if(recordsTobeDeleted != null)
        {
            delete [Select Id FROM Opportunity_Location__c WHERE Id IN: recordsTobeDeleted];    
        }
    }
    public static void afterInsert(list<Opportunity_Location__c> newRecords)
    {
        list<Discovery_Site_Workbook__c> wkbksToInsert = new list<Discovery_Site_Workbook__c>();
        
        list<Opportunity_Location__c> buildingsToInsert = new list<Opportunity_Location__c>();
        
        string buildingRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c', 'Building');
       
        string siteRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c','Site');
        
        List<Id> opportunityIds = new List<Id>();
        
        for(Opportunity_Location__c siteRec:newRecords)
        {
            if(siteRec.RecordTypeId == siteRecordTypeId)
            {
                Discovery_Site_Workbook__c dsw = new Discovery_Site_Workbook__c();
                dsw.Opportunity_Location__c = siteRec.Id;
                dsw.Account__c = siteRec.Site__c;
                wkbksToInsert.add(dsw);
                
                Opportunity_Location__c buildingRec = new Opportunity_Location__c();
                buildingRec.RecordTypeId = buildingRecordTypeId;
                buildingRec.Building_Site__c = siteRec.Id;
                buildingRec.Building_Types__c = 'Other';
                buildingRec.Building_Name__c = 'Site Main Building';
                buildingRec.Opportunity__c = siteRec.Opportunity__c;
                buildingRec.Site__c = siteRec.Site__c;
                buildingsToInsert.add(buildingRec);
            } 
            opportunityIds.add(siteRec.Opportunity__c);
        }
        
        //2016-12-08  -vishal.bandari@cdk.com - RQ-08092 : CPQ - CDK Docusign CCs Object and its population
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>([SELECT Id         
                                                                      FROM Opportunity      
                                                                      WHERE ID IN :opportunityIds       
                                                                      AND  ( RecordType.Name = '1 - Baseline Multi-channel Opportunity'         
                                                                             OR RecordType.Name = '5 - Inside Sales Opportunity'        
                                                                             OR RecordType.Name = '3 - Network Solutions Opportunity')  
                                                                      ORDER BY LastModifiedDate
                                                                     ]);        
        
        Map<Id, Id> accountToOpportunityMap = new Map<Id,Id>();
        for(Opportunity_Location__c oppLocRecord:newRecords)        
        {       
            if(opportunityMap.containsKey(oppLocRecord.Opportunity__c))     
            {       
                accountToOpportunityMap.put(oppLocRecord.Site__c,oppLocRecord.Opportunity__c);
            }       
        }       
        Map<Id,Id> topAccountsMap = AccountHierarchyTools.recursivelyFetchTopParentAccountIdList(new List<Id>(accountToOpportunityMap.keySet()));           
                
         for(Id accountId:topAccountsMap.keySet())      
         {          
             accountToOpportunityMap.put(topAccountsMap.get(accountId),accountToOpportunityMap.get(accountId));     
         }              
         setAccountRequiredCCs(accountToOpportunityMap);
       
        CPQ_OpportunitySplit_Helper.newSplitInsert(newRecords);
        insert wkbksToInsert;
        
        insert buildingsToInsert;
    }
    
    //2016-12-08  -vishal.bandari@cdk.com - RQ-08092 : CPQ - CDK Docusign CCs Object and its population
     public static void setAccountRequiredCCs(Map<Id, Id> accountToOpportunityMap)      
    {       
        List<Contact_Relationship__c> contactRelationShipList = [       
            SELECT Contact__r.Email,  DS_SLS_Required_CC__c, Contact__r.LastName, Contact__r.FirstName, Account__c      
            FROM Contact_Relationship__c        
            WHERE Account__c IN: accountToOpportunityMap.keySet()       
            AND Status__c = 'Active'        
            AND DS_SLS_Required_CC__c = True        
        ];  
        Set<String> emails = new Set<String>();
        for(Contact_Relationship__c crObject : contactRelationShipList)     
        {
            emails.add(crObject.Contact__r.Email);
        }
        Map<Id,Set<String>> existingMails = new Map<Id,Set<String>>();
        List<CDK_Docusign_CCs__c> exisitngCCDocusign = [Select Email__c,Opportunity__c FROM CDK_Docusign_CCs__c WHERE Email__c IN: emails];
        for(CDK_Docusign_CCs__c  CDKDocusignCCsObject : exisitngCCDocusign)
        {
            if(!existingMails.containsKey(CDKDocusignCCsObject.Opportunity__c))
            {
                existingMails.put(CDKDocusignCCsObject.Opportunity__c,new Set<String>()); 
            }
            Set<String> emailIds = existingMails.get(CDKDocusignCCsObject.Opportunity__c);   
            emailIds.add(CDKDocusignCCsObject.Email__c);
            existingMails.put(CDKDocusignCCsObject.Opportunity__c,emailIds);
        }
        Map<String, CDK_Docusign_CCs__c> CDKDocusignCCsMap = new Map<String, CDK_Docusign_CCs__c>();        
        for(Contact_Relationship__c crObject : contactRelationShipList)     
        {   
            if(!(existingMails.containsKey(accountToOpportunityMap.get(crObject.Account__c)) 
                 && existingMails.get(accountToOpportunityMap.get(crObject.Account__c)).contains(crObject.Contact__r.Email)) 
                    && !CDKDocusignCCsMap.containsKey(crObject.Contact__r.Email))
            {
                CDK_Docusign_CCs__c CDKDocusignCCsObject = new CDK_Docusign_CCs__c();       
                CDKDocusignCCsObject.Contact__c = crObject.Contact__c; 
                CDKDocusignCCsObject.First_Name__c = crObject.Contact__r.FirstName;
                CDKDocusignCCsObject.Last_Name__c = crObject.Contact__r.LastName;
                CDKDocusignCCsObject.Email__c = crObject.Contact__r.Email;
                CDKDocusignCCsObject.Opportunity__c = accountToOpportunityMap.get(crObject.Account__c);
                CDKDocusignCCsObject.Required_CC_Contact__c = true;     
                CDKDocusignCCsMap.put(CDKDocusignCCsObject.Email__c,CDKDocusignCCsObject);   
            }
        }       
        Database.SaveResult[] srList = Database.insert(CDKDocusignCCsMap.values(), false);
    }
}