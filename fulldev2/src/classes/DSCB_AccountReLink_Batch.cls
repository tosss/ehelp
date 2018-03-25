//2016-01-27- anirudh.singh@cdk.com- Created this class for the replacing the class DSCB_AccountReLinkBatch for Request RQ-06021.
//2016-01-27- anirudh.singh@cdk.com- Changed the method and variable names which were not following standards.
global class DSCB_AccountReLink_Batch implements Database.Batchable<Sobject>, Database.Stateful
{
    //2016-02-18- anirudh.singh@cdk.com- Made this variable private from public as it is not accessed outside this class.
    private static List<AccountReLinkObject__c> accReLinkObjectList=AccountReLinkObject__c.getall().values();
    
    //2016-02-18- anirudh.singh@cdk.com- Made this variable private from public as it is not accessed outside this class.
    private static Integer reLinksProcessed=0;
    
    //2016-02-18- anirudh.singh@cdk.com- Made this variable private from global as it is not accessed outside this class.
    //2015-10-20- anirudh.singh@cdk.com- Added the below variable.
    // used in error logging and finish e-mail
    private static final String currentClassName='DSCB_AccountReLink_Batch';
    
    //2016-02-18- anirudh.singh@cdk.com- Made this variable private from public as it is not accessed outside this class.
    //2015-11-02- anirudh.singh@cdk.com- Added the below parameter.
    private ALL_UtilitiesBatch.Logger log;
    
    //2016-02-18- anirudh.singh@cdk.com- Made this variable private from public as it is not accessed outside this class.
    private String queryString=''
        + 'Select Id, Name, CreatedDate, Cobalt_Account_Number__c, Party_ID__c '
        + ',Party_Account__c, Party_Account__r.Account_Number__c ' 
        + ',Cobalt_Account__c '
        + ',Cobalt_Account__r.Account_Number__c ' // Digital Solutions Account Number
        + ',Cobalt_Account__r.Decision_Making_Model__c ' // Decision Making Model
        + ',Cobalt_Account__r.MDA__c ' // MDA 
        + ',Cobalt_Account__r.Dealership_Health__c ' // Dealership Help 
        + ',Cobalt_Account__r.Core_Utility__c ' // Core Utility
        + ',Cobalt_Account__r.Operational_Efficiency__c ' // Operational Efficiency
        + ',Cobalt_Account__r.Financial_Performance__c ' // Financial Performance
        + ',Cobalt_Account__r.COF_Summary__c ' // COF Summary
        + ',Cobalt_Account__r.Cobalt_Strategy__c ' // Cobalt Strategy
        + ',Cobalt_Account__r.Do_Not_Sell__c ' // In Digital Solutions Collections
        + ',Cobalt_Account__r.Status__c ' // Status
        + ',Cobalt_Account__r.Critical_Note__c ' // Critical Note
        + ',Cobalt_Account__r.OEM__c ' // OEM
        + ',Cobalt_Account__r.Make__c ' // Make
        + ',Cobalt_Account__r.Org_Key__c ' // Org Key
        + ',Cobalt_Account__r.Nitra_Date__c ' // Nitra Date
        + ',Cobalt_Account__r.LDP__c ' // LDP 
        + ',Cobalt_Account__r.VIP__c ' // VIP 
        + ',Cobalt_Account__r.CBLTAccountName__c ' // Digital Solutions Account Name
        + ',Cobalt_Account__r.CBLTShipStreet__c ' // Digital Solutions Shipping Street
        + ',Cobalt_Account__r.CBLTShipCity__c ' // Digital Solutions Shipping City
        + ',Cobalt_Account__r.CBLTState__c ' // Digital Solutions Shipping State
        + ',Cobalt_Account__r.CBLTZip__c ' // Digital Solutions Shipping Zip
        + ',Cobalt_Account__r.CBLTShipCountry__c ' // Digital Solutions Shipping Country
        + ',Cobalt_Account__r.CBLTBillStreet__c ' // Digital Solutions Shipping Street
        + ',Cobalt_Account__r.CBLTBillCity__c ' // Digital Solutions Shipping City
        + ',Cobalt_Account__r.CBLTBillState__c ' // Digital Solutions Shipping State
        + ',Cobalt_Account__r.CBLTBillZip__c ' // Digital Solutions Shipping Zip
        + ',Cobalt_Account__r.CBLTBillCountry__c ' // Digital Solutions Shipping Country
        + ',Cobalt_Account__r.CBLTPhone__c ' // Digital Solutions Phone
        + ',Cobalt_Account__r.CBLTFax__c ' // Digital Solutions Fax
        + ',Cobalt_Account__r.Collector__c ' // Collector
        + ',Cobalt_Account__r.Designated_DSM__c ' // Designated DSM
        + ',(Select Id, Name, Detail_Status__c, Detail_Message__c, Object_ID__c, Object_Type__c, Object_Link__c, '
        + 'Owner__c, Owner_Status__c, Replacement_Owner__c From Account_ReLink_Details__r Where Detail_Status__c != \'Success\') '
        + 'From Account_ReLink__c '
        ;
    
    //This is used in the handler class also.
    public String conditions='Where Relink_Date__c=Null ';
    
    //2016-02-19- anirudh.singh@cdk.com- Added the below parameter.
    private DSCB_AccountReLink_Handler.Result accReLinkResult;
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug('Start start---->');
        return Database.getQueryLocator(processStart());
    }
    
    //2016-02-18- anirudh.singh@cdk.com- Made this variable private from global as it is not accessed outside this class.
    private String processStart() 
    {
        system.debug('Start processStart---->');
        return queryString+conditions;
    }
    
    global void execute(Database.BatchableContext BC, List<Account_ReLink__c> relinks)
    {
        system.debug('Start execute---->');
        processExecute(relinks);
        system.debug('End execute---->');
    }
    
    //2016-02-18- anirudh.singh@cdk.com- Made this variable private from global as it is not accessed outside this class.
    private void processExecute(List<Account_ReLink__c> relinks)
    {
        system.debug('Start processExecute---->'+accReLinkObjectList);
        
        //Bypass triggers.
        GlobalSettings.BypassCaseTriggersTrigger=true;
        GlobalSettings.BypassMMRechargeCloneRecordTrigger=true;
        
        //Initialize a new map of re-link objects (custom Apex objects).
        Map<String, ReLinkObject> reLinkObjectMap=new Map<String, ReLinkObject>();
        
        for(AccountReLinkObject__c accReLinkObjectRec: accReLinkObjectList)
        {
            // if the custom setting is valid
            //&& o.Active__c == true) // added 2012-08-22 MK
            if(accReLinkObjectRec.Account_Relationship_Name__c != Null && accReLinkObjectRec.Object_API_Name__c != Null 
               && accReLinkObjectRec.Action__c != Null)
            {
                // add the setting to the map of re-link objects
                reLinkObjectMap.put(accReLinkObjectRec.Object_API_Name__c, new ReLinkObject(accReLinkObjectRec));
            }
        }
        
        // call process relinks into detail records
        // this is used to make sure there have been no additional child records
        // added to the Account since the ReLink record was created
        accReLinkResult=DSCB_AccountReLink_Handler.processRelinks(relinks);
        // once process relinks is complete, the relink and relink details
        // need to be queried/refreshed to get the (potential) new records
        
        // only process for the relinks supplied
        //String q=st();
        //if(q.toLowerCase().contains('where')) { q += ' And '; }
        //else { q += ' Where '; }
        
        // format the ids
        //String ReLinkIds='(';
        //for(Account_ReLink__c rl : relinks) { ReLinkIds += '\'' + String.valueOf(rl.Id) + '\','; }
        //if (ReLinkIds.endsWith(',')){ReLinkIds=ReLinkIds.substring(0,ReLinkIds.lastIndexOf(','));}
        //ReLinkIds += ')';
        
        //q += ' Id IN ' + ReLinkIds;
        
        //system.debug(q);
        
        // requery relinks and detail records to make sure all fields are included in the data
        //List<Account_ReLink__c> RefreshedReLinks=Database.query(q);
        
        // changed query 2012-08-22 MK
        // this is due to a salesforce bug that does not return all of the records when a subquery is performed
        Map<Id, List<Account_ReLink_Detail__c>> refreshedAccReLinkDetailMap=new Map<Id, List<Account_ReLink_Detail__c>>();
        
        List<Account_ReLink_Detail__c> refreshedAccReLinkDetailList=[
            Select Id, Name, Detail_Status__c, Detail_Message__c, Object_ID__c, 
            Object_Type__c, Object_Link__c, Owner__c, Owner_Status__c, 
            Replacement_Owner__c, Account_ReLink__c 
            From Account_ReLink_Detail__c 
            Where Detail_Status__c != 'Success'
            And Account_ReLink__c IN :relinks
        ];
        
        for(Account_ReLink_Detail__c accReLinkDetailRec: refreshedAccReLinkDetailList) 
        { 
            List<Account_ReLink_Detail__c> accReLinkDetailList=refreshedAccReLinkDetailMap.get(accReLinkDetailRec.Account_ReLink__c);
            
            if(accReLinkDetailList == Null)
            {
                accReLinkDetailList=new List<Account_ReLink_Detail__c>();
            }
            accReLinkDetailList.add(accReLinkDetailRec); 
            
            refreshedAccReLinkDetailMap.put(accReLinkDetailRec.Account_ReLink__c, accReLinkDetailList); 
        }
        
        for(Account_ReLink__c accReLinkRec : relinks)
        {
            system.debug(LoggingLevel.WARN, '--- ReLink ---');
            system.debug('accReLinkRec---->'+accReLinkRec);
            
            // returns a list of Account ReLink Details where status != success
            // if this list contains 0 records, or all records in this list are set to Success 
            // after processing, the ReLink is complete, and the ReLink Date can be set
            List<Account_ReLink_Detail__c> reLinkDetailsList=refreshedAccReLinkDetailMap.get(accReLinkRec.Id);
            
            // not needed because details are stored on ReLink object and ReLink Details object
            //Boolean UpdateAccountFields=true;
            
            List<Account_ReLink_Detail__c> reLinkDetailsToUpdateList=new List<Account_ReLink_Detail__c>();
            
            // Limiter.
            Map<String, Integer> typeCountMap=new Map<String, Integer>();
            
            if(reLinkDetailsList != Null)
            {
                for(Account_ReLink_Detail__c accReLinkDetailRef : reLinkDetailsList)
                {
                    ReLinkObject reLinkObjectRecord=reLinkObjectMap.get(accReLinkDetailRef.Object_Type__c); 
                    
                    // increment the number of records processed, for this type 
                    if(typeCountMap.get(accReLinkDetailRef.Object_Type__c) == Null)
                    {
                        typeCountMap.put(accReLinkDetailRef.Object_Type__c, 1);
                    }
                    else
                    {
                        typeCountMap.put(accReLinkDetailRef.Object_Type__c, typeCountMap.get(accReLinkDetailRef.Object_Type__c)+1);
                    }
                    
                    // if there is a ReLinkObject and the number of records added (to process) for that object is less than the Limit Per Day
                    if(reLinkObjectRecord != Null && (reLinkObjectRecord.settings.Limit_Per_Day__c == Null || reLinkObjectRecord.settings.Limit_Per_Day__c == 0 
                                                      || typeCountMap.get(accReLinkDetailRef.Object_Type__c) <= reLinkObjectRecord.settings.Limit_Per_Day__c))
                    {
                        reLinkObjectRecord.accReLinkDetailList.put(accReLinkDetailRef.Object_Id__c, accReLinkDetailRef);
                        reLinkObjectRecord.recordIds.add(accReLinkDetailRef.Object_Id__c);
                        
                        if(accReLinkDetailRef.Replacement_Owner__c != Null)
                        {
                            Id validReplacementOwnerId=Null;
                            
                            try
                            {
                                validReplacementOwnerId=accReLinkDetailRef.Replacement_Owner__c;
                            }
                            catch(Exception ex)
                            {
                                system.debug(ex);
                            }
                            
                            if(validReplacementOwnerId != Null)
                            {
                                reLinkObjectRecord.ReplacementOwnersByRecordId.put(accReLinkDetailRef.Object_Id__c, accReLinkDetailRef.Replacement_Owner__c);
                            }
                        }
                    }
                }
            }
            
            system.debug('reLinkObjectMap---->'+reLinkObjectMap);
            
            // sort the ReLink Objects by their order setting
            List<ReLinkObject> sortedReLinkObjectsList=reLinkObjectMap.values();
            Boolean swapped=true;
            Integer j=0;
            
            while(swapped) 
            {
                swapped=false;
                j++;
                
                for(Integer i=0; i<sortedReLinkObjectsList.size()-j; i++) 
                {
                    if(sortedReLinkObjectsList[i].settings.Order__c>sortedReLinkObjectsList[i+1].settings.Order__c) 
                    {
                        ReLinkObject temp=sortedReLinkObjectsList[i];
                        sortedReLinkObjectsList[i]=sortedReLinkObjectsList[i+1];
                        sortedReLinkObjectsList[i+1]=temp;
                        swapped=true;
                    }
                } 
            }
            
            for(ReLinkObject reLinkObjectRecord: sortedReLinkObjectsList)
            {
                system.debug(LoggingLevel.WARN,'---->Update/Clone loop for ' + reLinkObjectRecord.settings.Object_API_Name__c + ' Detail Records---->' + reLinkObjectRecord.accReLinkDetailList);
                
                if(!reLinkObjectRecord.accReLinkDetailList.isEmpty())// && reLinkObjectRecord.settings.Object_API_Name__c == 'Note')
                {
                    List<Database.SaveResult> updateResults;
                    List<Database.DeleteResult> deleteResults;
                    List<Database.SaveResult> insertResults;
                    
                    if(reLinkObjectRecord.settings.Action__c.toLowerCase() == 'update')
                    {
                        system.debug(LoggingLevel.WARN,'---->Calling queryAndUpdate');
                        
                        reLinkObjectRecord.sObjectsToUpdateList=DSCB_AccountReLink_Handler.queryAndUpdate(
                            reLinkObjectRecord.recordIds, reLinkObjectRecord.ReplacementOwnersByRecordId, reLinkObjectRecord.settings.Object_API_Name__c, 
                            reLinkObjectRecord.settings.Fields__c, reLinkObjectRecord.settings.Account_Field__c, accReLinkRec.Party_Account__c
                        );
                        
                        system.debug(LoggingLevel.WARN,'---->Update---->'+reLinkObjectRecord.sObjectsToUpdateList);
                        
                        if(!reLinkObjectRecord.sObjectsToUpdateList.IsEmpty())
                        {
                            // -- UPDATE
                            Integer updateSuccesses=0, updateErrors=0;
                            //System.SavePoint UpdateSavePoint=Database.setSavepoint();
                            
                            try
                            {
                                for(sObject sObj: reLinkObjectRecord.sObjectsToUpdateList)
                                {
                                    system.debug(LoggingLevel.WARN,'---->'+sObj);
                                }
                                updateResults=Database.update(reLinkObjectRecord.sObjectsToUpdateList, false);
                            } 
                            catch(Exception ex)
                            {
                                system.debug(LoggingLevel.WARN,'---->'+ex);
                            }
                            
                            for(Integer i=0; i<updateResults.size(); i++)
                            {
                                Database.SaveResult updateRes=updateResults[i];
                                Account_ReLink_Detail__c accReLinkDetailRecord=reLinkObjectRecord.accReLinkDetailList.get(reLinkObjectRecord.sObjectsToUpdateList[i].Id);
                                
                                if(updateRes.getErrors().size() > 0)
                                {
                                    system.debug(LoggingLevel.WARN,'---->'+updateRes);
                                }
                                else
                                {
                                    system.debug(LoggingLevel.WARN,'---->'+updateRes);
                                }
                                
                                system.debug(LoggingLevel.WARN,'---->'+accReLinkDetailRecord); 
                                
                                if(updateRes.isSuccess())
                                {
                                    updateSuccesses += 1;
                                    if(accReLinkDetailRecord != Null)
                                    {
                                        accReLinkDetailRecord.Detail_Message__c='';
                                        accReLinkDetailRecord.Owner_Status__c='';
                                        accReLinkDetailRecord.Detail_Status__c='Success';
                                    }
                                }
                                else
                                {
                                    updateErrors += 1;
                                    if(accReLinkDetailRecord != Null)
                                    {
                                        accReLinkDetailRecord.Detail_Status__c='Error';
                                        accReLinkDetailRecord.Detail_Message__c='';
                                        
                                        for(Database.Error error : updateRes.getErrors())
                                        {
                                            accReLinkDetailRecord.Detail_Message__c += error.getMessage();
                                        }
                                    }
                                }
                            }
                        }
                        //if(updateErrors > 0) { Database.rollback(UpdateSavePoint); }
                    }
                    
                    if(reLinkObjectRecord.settings.Action__c.toLowerCase() == 'clone')
                    {
                        system.debug(LoggingLevel.WARN,'---->Calling QueryAndClone');
                        
                        reLinkObjectRecord.sObjectsToCloneMap=DSCB_AccountReLink_Handler.QueryAndClone(
                            reLinkObjectRecord.recordIds, reLinkObjectRecord.ReplacementOwnersByRecordId, reLinkObjectRecord.settings.Object_API_Name__c, 
                            reLinkObjectRecord.settings.Fields__c, reLinkObjectRecord.settings.Account_Field__c, accReLinkRec.Party_Account__c
                        );
                        
                        system.debug('Clone---->'+reLinkObjectRecord.sObjectsToCloneMap);
                        
                        if(reLinkObjectRecord.sObjectsToCloneMap != Null && !reLinkObjectRecord.sObjectsToCloneMap.IsEmpty())
                        {
                            // -- CLONE
                            // setup clone variables
                            Integer cloneSuccesses=0, cloneErrors=0;
                            System.SavePoint cloneSavePoint=Database.setSavepoint();
                            
                            Map<Id, sObject> clonedSObjectsByOriginalIdsMap=new Map<Id, sObject>();
                            
                            // setup delete variables
                            List<Id> originalIdsList=new List<Id>();
                            
                            // gather all of the original Ids
                            for(Id originalId: reLinkObjectRecord.sObjectsToCloneMap.keyset())
                            {
                                clonedSObjectsByOriginalIdsMap.put(originalId, reLinkObjectRecord.sObjectsToCloneMap.get(originalId));
                                originalIdsList.add(originalId);
                            }
                            
                            // -- DELETE
                            // try to delete the original Ids
                            try
                            {
                                system.debug(LoggingLevel.WARN,'---->'+originalIdsList);
                                deleteResults=Database.delete(originalIdsList, false); // must be false to get all errors
                            } 
                            catch(Exception ex)
                            {
                                system.debug(LoggingLevel.WARN,'---->'+ex);
                            }
                            
                            // a new list of deleted Ids (records that were successfully deleted)
                            List<Id> deletedOriginalIdsList=new List<Id>();
                            
                            // loop through the delete results
                            system.debug(LoggingLevel.WARN,'---->Delete Results');
                            
                            for(Integer i=0; i<originalIdsList.size(); i++) 
                            {
                                Database.DeleteResult deleteRes=deleteResults[i];
                                Account_ReLink_Detail__c accReLinkDetailRec=reLinkObjectRecord.accReLinkDetailList.get(originalIdsList[i]);
                                
                                if(deleteRes.getErrors().size() > 0)
                                {
                                    system.debug(LoggingLevel.WARN,'---->'+deleteRes);
                                }
                                else
                                {
                                    system.debug(LoggingLevel.WARN,'---->'+deleteRes);
                                }
                                
                                system.debug(LoggingLevel.WARN,'---->'+accReLinkDetailRec); 
                                
                                // if the delete was successful
                                if(deleteRes.isSuccess())
                                {
                                    deletedOriginalIdsList.add(originalIdsList[i]);
                                }
                                // else, the delete was not successful
                                else
                                {
                                    cloneErrors += 1; // add one to clone errors
                                    if(accReLinkDetailRec != Null)
                                    {
                                        accReLinkDetailRec.Detail_Status__c='Error';
                                        accReLinkDetailRec.Detail_Message__c='';
                                        for(Database.Error error : deleteRes.getErrors())
                                        {
                                            accReLinkDetailRec.Detail_Message__c += error.getMessage();
                                        }
                                    }
                                }
                            }
                            
                            // -- END DELETE
                            
                            // -- INSERT 
                            //    (only the records that were deleted)
                            
                            List<sObject> sObjectsToInsertList=new List<sObject>();
                            List<Id> originalIdsToInsertList=new List<Id>();
                            
                            // a list of valid Ids should the first insert dml statement fail.
                            List<Id> validOriginalIdsToInsertList=new List<Id>();
                            
                            // for all of the successfully deleted records
                            for(Id originalId : deletedOriginalIdsList)
                            {
                                // add the record to the end of the insert list
                                //   because of the way the add method for lists works (values are added to the end of the list), 
                                //   the values will always match
                                sObject sObj=clonedSObjectsByOriginalIdsMap.get(originalId);
                                if(sObj != Null)
                                {
                                    sObjectsToInsertList.add(sObj);
                                    originalIdsToInsertList.add(originalId);
                                }
                                
                                // because of this condition DeletedOriginalIds[i] may not match sObjectsToInsertList[i]
                            }
                            
                            // try to insert the cloned records
                            try
                            {
                                system.debug(LoggingLevel.WARN,'---->'+sObjectsToInsertList);
                                insertResults=Database.insert(sObjectsToInsertList, false); // must be false to get all errors
                            }
                            catch(Exception ex)
                            {
                                system.debug(LoggingLevel.WARN,'---->'+ex);
                            }
                            
                            // at this point sObjectsToInsertList, insertResults, and originalIdsToInsertList are all in the same order
                            // sObjectsToInsertList[i] (sObject) has insertResults[i] (SaveResult) for originalIdsToInsertList[i] (Id)
                            
                            system.debug(LoggingLevel.WARN,'---->Insert Results');
                            
                            for(Integer i=0; i<sObjectsToInsertList.size(); i++)
                            {
                                system.debug(originalIdsToInsertList[i]+' '+insertResults[i]+' '+sObjectsToInsertList[i]);
                                
                                Database.SaveResult insertRes=insertResults[i];
                                Account_ReLink_Detail__c accReLinkDetailRecord=reLinkObjectRecord.accReLinkDetailList.get(originalIdsToInsertList[i]);
                                
                                if(insertRes.getErrors().size()>0)
                                {
                                    system.debug(LoggingLevel.WARN,'---->'+insertRes);
                                }
                                else
                                {
                                    system.debug(LoggingLevel.WARN,'---->'+insertRes);
                                }
                                
                                system.debug(LoggingLevel.WARN,'---->'+accReLinkDetailRecord); 
                                
                                if(insertRes.isSuccess())
                                {
                                    cloneSuccesses += 1;
                                    validOriginalIdsToInsertList.add(originalIdsToInsertList[i]);
                                    
                                    if(accReLinkDetailRecord != Null)
                                    {
                                        accReLinkDetailRecord.Detail_Message__c='';
                                        accReLinkDetailRecord.Owner_Status__c='';
                                        accReLinkDetailRecord.Detail_Status__c='Success';
                                    }
                                }
                                else
                                {
                                    cloneErrors += 1;
                                    if(accReLinkDetailRecord != Null)
                                    {
                                        accReLinkDetailRecord.Detail_Status__c='Error';
                                        accReLinkDetailRecord.Detail_Message__c='';
                                        
                                        for(Database.Error error : insertRes.getErrors())
                                        {
                                            accReLinkDetailRecord.Detail_Message__c += error.getMessage();
                                        }
                                    }
                                }
                            }
                            
                            // -- END INSERT
                            
                            // if errors occurred in cloning, rollback the database and if some were valid, partial process them
                            if(cloneErrors > 0) 
                            { 
                                system.debug(LoggingLevel.WARN,'---->'+CloneErrors);
                                
                                // roll back to the database save point
                                Database.rollback(cloneSavePoint); 
                                
                                if(validOriginalIdsToInsertList.size()>0)
                                {
                                    system.debug(LoggingLevel.WARN,'---->Partial Processing');
                                    system.debug(LoggingLevel.WARN,'---->ValidIdsToInsert---->'+validOriginalIdsToInsertList);
                                    
                                    Set<Id> validOriginalIdsToInsertSet=new Set<Id>();
                                    validOriginalIdsToInsertSet.addAll(validOriginalIdsToInsertList);
                                    
                                    // put together a list of valid sObjects to clone from the valid Ids to insert
                                    Map<Id, sObject> validsObjectsToCloneMap=DSCB_AccountReLink_Handler.QueryAndClone(
                                        validOriginalIdsToInsertSet, reLinkObjectRecord.ReplacementOwnersByRecordId, reLinkObjectRecord.settings.Object_API_Name__c, 
                                        reLinkObjectRecord.settings.Fields__c, reLinkObjectRecord.settings.Account_Field__c, accReLinkRec.Party_Account__c
                                    );
                                    
                                    // define a list because database.delete does not accept sets
                                    List<Id> originalIdsToDeleteList=new List<Id>(); 
                                    originalIdsToDeleteList.addAll(validsObjectsToCloneMap.keyset());
                                    
                                    // process the Valid IDs
                                    for(Id recId : originalIdsToDeleteList)
                                    {
                                        system.debug('recId---->'+recId);
                                        database.delete(recId);
                                    }
                                    
                                    //Database.delete(originalIdsToDeleteList);
                                    for(sObject sObj: validsObjectsToCloneMap.values())
                                    {
                                        system.debug('sObj---->'+sObj);
                                        insert sObj;
                                    }
                                    //Database.insert(validsObjectsToCloneMap.values());
                                }
                            }
                        }
                    }
                    
                    // store all the ReLinkDetail record modifications 
                    //   (containing successes/errors) for updating after the database rollback
                    // this applies to both updates and clones and is therefore outside of the if statements for each
                    for(Account_ReLink_Detail__c accReLinkDetailRef: reLinkObjectRecord.accReLinkDetailList.values()) 
                    {
                        //if(rld.Detail_Status__c != 'Success') { UpdateAccountFields=false; }
                        reLinkDetailsToUpdateList.add(accReLinkDetailRef); 
                    }
                    
                    update reLinkDetailsToUpdateList;
                }
            } // end for sorted ReLink Objects
            
            system.debug('accReLinkRec.Party_Account__r.Account_Number__c---->'+accReLinkRec.Party_Account__r.Account_Number__c);
            
            if(accReLinkRec.Cobalt_Account_Number__c != accReLinkRec.Party_Account__r.Account_Number__c)
            {
                try
                {
                    List<Account> accountsToUpdateList=new List<Account>();
                    
                    Account cobaltAcc=new Account(Id=accReLinkRec.Cobalt_Account__c);
                    cobaltAcc.Decision_Making_Model__c=Null; 
                    cobaltAcc.MDA__c=Null; 
                    cobaltAcc.Dealership_Health__c=Null; 
                    cobaltAcc.Core_Utility__c=Null; 
                    cobaltAcc.Operational_Efficiency__c=Null; 
                    cobaltAcc.Financial_Performance__c=Null; 
                    cobaltAcc.COF_Summary__c=Null; 
                    cobaltAcc.Cobalt_Strategy__c=Null; 
                    cobaltAcc.Do_Not_Sell__c=false; // boolean, cannot be set to Null
                    cobaltAcc.Status__c=Null; 
                    cobaltAcc.Critical_Note__c=Null; 
                    cobaltAcc.OEM__c=Null; 
                    cobaltAcc.Make__c=Null; 
                    cobaltAcc.Org_Key__c=Null; 
                    cobaltAcc.Nitra_Date__c=Null; 
                    cobaltAcc.LDP__c=false; // boolean, cannot be set to Null
                    cobaltAcc.VIP__c=false; // boolean, cannot be set to Null 
                    cobaltAcc.CBLTAccountName__c=Null; 
                    cobaltAcc.CBLTShipStreet__c=Null; 
                    cobaltAcc.CBLTShipCity__c=Null; 
                    cobaltAcc.CBLTState__c=Null; 
                    cobaltAcc.CBLTZip__c=Null; 
                    cobaltAcc.CBLTShipCountry__c=Null; 
                    cobaltAcc.CBLTBillStreet__c=Null; 
                    cobaltAcc.CBLTBillCity__c=Null; 
                    cobaltAcc.CBLTBillState__c=Null; 
                    cobaltAcc.CBLTBillZip__c=Null; 
                    cobaltAcc.CBLTBillCountry__c=Null; 
                    cobaltAcc.CBLTPhone__c=Null; 
                    cobaltAcc.CBLTFax__c=Null; 
                    cobaltAcc.Collector__c=Null; 
                    cobaltAcc.Designated_DSM__c=Null;
                    accountsToUpdateList.add(cobaltAcc);
                    
                    Account partyAcc=new Account(Id=accReLinkRec.Party_Account__c);
                    partyAcc.Decision_Making_Model__c=accReLinkRec.Cobalt_Account__r.Decision_Making_Model__c; 
                    partyAcc.MDA__c=accReLinkRec.Cobalt_Account__r.MDA__c; 
                    partyAcc.Dealership_Health__c=accReLinkRec.Cobalt_Account__r.Dealership_Health__c; 
                    partyAcc.Core_Utility__c=accReLinkRec.Cobalt_Account__r.Core_Utility__c; 
                    partyAcc.Operational_Efficiency__c=accReLinkRec.Cobalt_Account__r.Operational_Efficiency__c; 
                    partyAcc.Financial_Performance__c=accReLinkRec.Cobalt_Account__r.Financial_Performance__c; 
                    partyAcc.COF_Summary__c=accReLinkRec.Cobalt_Account__r.COF_Summary__c; 
                    partyAcc.Cobalt_Strategy__c=accReLinkRec.Cobalt_Account__r.Cobalt_Strategy__c; 
                    partyAcc.Do_Not_Sell__c=accReLinkRec.Cobalt_Account__r.Do_Not_Sell__c; 
                    partyAcc.Status__c=accReLinkRec.Cobalt_Account__r.Status__c; 
                    partyAcc.Critical_Note__c=accReLinkRec.Cobalt_Account__r.Critical_Note__c; 
                    partyAcc.OEM__c=accReLinkRec.Cobalt_Account__r.OEM__c; 
                    partyAcc.Make__c=accReLinkRec.Cobalt_Account__r.Make__c; 
                    partyAcc.Org_Key__c=accReLinkRec.Cobalt_Account__r.Org_Key__c; 
                    partyAcc.Nitra_Date__c=accReLinkRec.Cobalt_Account__r.Nitra_Date__c; 
                    partyAcc.LDP__c=accReLinkRec.Cobalt_Account__r.LDP__c; 
                    partyAcc.VIP__c=accReLinkRec.Cobalt_Account__r.VIP__c; 
                    partyAcc.CBLTAccountName__c=accReLinkRec.Cobalt_Account__r.CBLTAccountName__c; 
                    partyAcc.CBLTShipStreet__c=accReLinkRec.Cobalt_Account__r.CBLTShipStreet__c; 
                    partyAcc.CBLTShipCity__c=accReLinkRec.Cobalt_Account__r.CBLTShipCity__c; 
                    partyAcc.CBLTState__c=accReLinkRec.Cobalt_Account__r.CBLTState__c; 
                    partyAcc.CBLTZip__c=accReLinkRec.Cobalt_Account__r.CBLTZip__c; 
                    partyAcc.CBLTShipCountry__c=accReLinkRec.Cobalt_Account__r.CBLTShipCountry__c; 
                    partyAcc.CBLTBillStreet__c=accReLinkRec.Cobalt_Account__r.CBLTBillStreet__c; 
                    partyAcc.CBLTBillCity__c=accReLinkRec.Cobalt_Account__r.CBLTBillCity__c; 
                    partyAcc.CBLTBillState__c=accReLinkRec.Cobalt_Account__r.CBLTBillState__c; 
                    partyAcc.CBLTBillZip__c=accReLinkRec.Cobalt_Account__r.CBLTBillZip__c; 
                    partyAcc.CBLTBillCountry__c=accReLinkRec.Cobalt_Account__r.CBLTBillCountry__c; 
                    partyAcc.CBLTPhone__c=accReLinkRec.Cobalt_Account__r.CBLTPhone__c; 
                    partyAcc.CBLTFax__c=accReLinkRec.Cobalt_Account__r.CBLTFax__c; 
                    partyAcc.Collector__c=accReLinkRec.Cobalt_Account__r.Collector__c; 
                    partyAcc.Designated_DSM__c=accReLinkRec.Cobalt_Account__r.Designated_DSM__c;
                    accountsToUpdateList.add(partyAcc);
                    
                    update accountsToUpdateList;
                    
                    // if the field update was successful, update the Account Numbers
                    Account updateCobaltAcc=new Account(Id=accReLinkRec.Cobalt_Account__c);
                    updateCobaltAcc.Account_Number__c=Null; 
                    update updateCobaltAcc;
                    
                    Account updatePartyAcc=new Account(Id=accReLinkRec.Party_Account__c);
                    updatePartyAcc.Account_Number__c=accReLinkRec.Cobalt_Account__r.Account_Number__c; 
                    update updatePartyAcc;
                } 
                catch(Exception ex)
                {
                    accReLinkRec.Status_Message__c='Account field update failed. Error Message: '+ex.getMessage();
                }
            }
            
            // if no relink details were returned (the query returns details that were not successful)
            if(reLinkDetailsList == Null)
            {
                accReLinkRec.Relink_Date__c=DateTime.now();
                reLinksProcessed++;
            }
            else
            {
                // if no relink details were returned (the query returns details that were not successful)
                if(reLinkDetailsList.size() == 0)
                {
                    accReLinkRec.Relink_Date__c=DateTime.now();
                    reLinksProcessed++;
                }
                else
                {
                    // a variable for counting the non-success detail records
                    Integer nonSuccess=0; 
                    
                    for(Account_ReLink_Detail__c accReLinkDetailRec : reLinkDetailsList)
                    {
                        if(accReLinkDetailRec.Detail_Status__c != 'Success')
                        {
                            nonSuccess++;
                        }
                    }
                    
                    // there are no non-success statuses (no errors or pendings)
                    if(nonSuccess == 0)
                    {
                        accReLinkRec.Relink_Date__c=DateTime.now();
                        reLinksProcessed++;
                    }
                }
            }
            
            //rl.Relink_Date__c=DateTime.now();
            system.debug(LoggingLevel.WARN, accReLinkRec);
            update accReLinkRec;
            system.debug(LoggingLevel.WARN, accReLinkRec);
        } // end for refreshed ReLinks
        
        // turn on triggers
        GlobalSettings.BypassCaseTriggersTrigger=false;
        GlobalSettings.BypassMMRechargeCloneRecordTrigger=false;
        system.debug('End processExecute---->');
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('Start finish---->');
        processFinish(BC);
        system.debug('End finish---->');
    }
    
    //2016-02-18- anirudh.singh@cdk.com- Made this variable private from global as it is not accessed outside this class.
    private void processFinish(Database.BatchableContext BC)
    {
        system.debug('Start processFinish---->');
        //2015-10-23- anirudh.singh@cdk.com- Added the below code.
        if(BC!=Null && reLinksProcessed>0)
        {
            log=new ALL_UtilitiesBatch.Logger();
            log.batchId=BC.getJobId();
            log.title='DSCB_AccountReLink_Batch Batch Job Summary';
            log.description='Re-Linking Account related objects from a Cobalt Account Number Account to a Party ID Account ';
            //2016-02-19- anirudh.singh@cdk.com- Changed the log.message from Complete to accReLinkResult.
            log.message=accReLinkResult.message;
            log.processingLog=accReLinkResult.processingLog;
            
            ALL_UtilitiesBatch.finish(currentClassName, log);
        }
        system.debug('End processFinish---->');
    }
    
    public class ReLinkObject
    {
        public AccountReLinkObject__c settings;
        
        public Map<Id, Account_ReLink_Detail__c> accReLinkDetailList;
        public Set<Id> recordIds;
        public List<sObject> sObjectsToUpdateList;
        public Map<Id, sObject> sObjectsToCloneMap;
        
        // record id and owner id
        public Map<Id, Id> ReplacementOwnersByRecordId=new Map<Id, Id>();
        
        public ReLinkObject(AccountReLinkObject__c accReLinkObj) 
        { 
            accReLinkDetailList=new Map<Id, Account_ReLink_Detail__c>();
            recordIds=new Set<Id>(); 
            settings=accReLinkObj;
        }
    }
}