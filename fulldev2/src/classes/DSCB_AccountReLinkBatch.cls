//2015-09-22- anirudh.singh@cdk.com- To upgrade the API Version FROM 25.0 to 34.0.
//2015-10-20- anirudh.singh@cdk.com- Modified the finish method to use the generic Finish method on ALL_UtilitiesBatch.
//2016-01-27- anirudh.singh@cdk.com- Commented this class for Request RQ-06021, as the name is not as per standards.
//2016-01-27- anirudh.singh@cdk.com- A new handler class with the name DSCB_AccountReLink_Batch has been created.
/*
// execute batch 
DSCB_AccountReLinkBatch b=new DSCB_AccountReLinkBatch();
b.conditions='Where Relink_Date__c=null AND ID=\'a1YM0000000CpRU\' '; // optional
ID BatchId=Database.executeBatch(b,1);

// execute single
List<Account_ReLink__c> relinks=
[Select Id, Name, Cobalt_Account__c, Cobalt_Account_Number__c, 
Party_Account__c, Party_Account__r.Account_Number__c, CreatedDate 
From Account_ReLink__c Where Id='a1YM0000000D95B'];
system.debug(relinks);
DSCB_AccountReLinkBatch batch=new DSCB_AccountReLinkBatch();
batch.ex(relinks);
*/

//global class DSCB_AccountReLinkBatch implements Database.Batchable<Sobject>, Database.Stateful
global class DSCB_AccountReLinkBatch
{
    /*public static List<AccountReLinkObject__c> rlObjects=AccountReLinkObject__c.getall().values();
    
    public static Integer ReLinksProcessed=0;
    
    //2015-10-20- anirudh.singh@cdk.com- Added the below variable.
    // used in error logging and finish e-mail
    global static final String currentClassName='DSCB_AccountReLinkBatch';
    
    //2015-11-02- anirudh.singh@cdk.com- Added the below parameter.
    public ALL_UtilitiesBatch.Logger log;
    
    public String query=''
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
    
    public String conditions='Where Relink_Date__c=null ';
    
    public class ReLinkObject
    {
        public AccountReLinkObject__c Settings;
        
        public Map<Id,Account_ReLink_Detail__c> DetailRecords;
        public Set<Id> RecordIds;
        
        public List<sObject> sObjectsToUpdate;
        public Map<Id,sObject> sObjectsToClone;
        
        // record id and owner id
        public Map<Id,Id> ReplacementOwnersByRecordId=new Map<Id,Id>();
        
        public ReLinkObject(AccountReLinkObject__c o) 
        { 
            DetailRecords=new Map<Id,Account_ReLink_Detail__c>();
            RecordIds=new Set<Id>(); 
            Settings=o;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(st());
    }
    
    global void execute(Database.BatchableContext BC, List<Account_ReLink__c> relinks)
    {
        ex(relinks);
    }
    
    global String st() 
    {
        return query+conditions;
    }
    
    global void ex(List<Account_ReLink__c> relinks)
    {
        // bypass triggers
        GlobalSettings.BypassCaseTriggersTrigger=true;
        GlobalSettings.BypassMMRechargeCloneRecordTrigger=true;
        
        // initialize a new map of re-link objects (custom Apex objects)
        Map<String,ReLinkObject> ReLinkObjects=new Map<String,ReLinkObject>();
        
        system.debug(rlObjects);
        
        // for each relink object (custom setting)
        for(AccountReLinkObject__c o : rlObjects)
        {
            // if the custom setting is valid
            if(o.Account_Relationship_Name__c != null 
               && o.Object_API_Name__c != null 
               && o.Action__c != null) 
                //&& o.Active__c == true) // added 2012-08-22 MK
            {
                // add the setting to the map of re-link objects
                ReLinkObjects.put(o.Object_API_Name__c,new ReLinkObject(o)); system.debug(o);
            }
        }
        
        // call process relinks into detail records
        // this is used to make sure there have been no additional child records
        // added to the Account since the ReLink record was created
        DSCB_AccountReLink.ProcessRelinks(relinks);
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
        Map<Id,List<Account_ReLink_Detail__c>> RefreshedReLinkDetails=new Map<Id,List<Account_ReLink_Detail__c>>();
        List<Account_ReLink_Detail__c> RefreshedReLinkDetailList=[
            Select Id, Name, 
            Detail_Status__c, Detail_Message__c, Object_ID__c, Object_Type__c, Object_Link__c, Owner__c, Owner_Status__c, 
            Replacement_Owner__c, Account_ReLink__c From Account_ReLink_Detail__c Where Detail_Status__c != 'Success'
            And Account_ReLink__c IN :relinks
        ];
        
        for(Account_ReLink_Detail__c rld : RefreshedReLinkDetailList) 
        { 
            List<Account_ReLink_Detail__c> arld=RefreshedReLinkDetails.get(rld.Account_ReLink__c);
            if(arld == null)
            {
                arld=new List<Account_ReLink_Detail__c>();
            }
            arld.add(rld); 
            
            RefreshedReLinkDetails.put(rld.Account_ReLink__c, arld); 
        }
        
        // for each relink
        for(Account_ReLink__c rl : relinks)
        {
            system.debug(LoggingLevel.WARN,'--- ReLink ---');
            system.debug(rl);
            
            // returns a list of Account ReLink Details where status != success
            // if this list contains 0 records, or all records in this list are set to Success 
            // after processing, the ReLink is complete, and the ReLink Date can be set
            List<Account_ReLink_Detail__c> ReLinkDetails=RefreshedReLinkDetails.get(rl.Id);
            
            // not needed because details are stored on ReLink object and ReLink Details object
            //Boolean UpdateAccountFields=true;
            
            List<Account_ReLink_Detail__c> ReLinkDetailsToUpdate=new List<Account_ReLink_Detail__c>();
            
            Map<String,Integer> TypeCount=new Map<String,Integer>(); // Limiter
            
            if(ReLinkDetails != null)
            {
                for(Account_ReLink_Detail__c rld : ReLinkDetails)
                {
                    ReLinkObject o=ReLinkObjects.get(rld.Object_Type__c); 
                    
                    // increment the number of records processed, for this type 
                    if(TypeCount.get(rld.Object_Type__c) == null)
                    {
                        TypeCount.put(rld.Object_Type__c, 1);
                    }
                    else
                    {
                        TypeCount.put(rld.Object_Type__c, TypeCount.get(rld.Object_Type__c)+1);
                    }
                    
                    // if there is a ReLinkObject and the number of records added (to process) for that object is less than the Limit Per Day
                    if(o != null && (
                        o.Settings.Limit_Per_Day__c == null || o.Settings.Limit_Per_Day__c == 0 || 
                        TypeCount.get(rld.Object_Type__c) <= o.Settings.Limit_Per_Day__c))
                    {
                        o.DetailRecords.put(rld.Object_Id__c,rld);
                        o.RecordIds.add(rld.Object_Id__c);
                        
                        if(rld.Replacement_Owner__c != null)
                        {
                            Id ValidReplacementOwnerId=null;
                            try
                            {
                                ValidReplacementOwnerId=rld.Replacement_Owner__c;
                            }
                            catch(Exception ex)
                            {
                                system.debug(ex);
                            }
                            
                            if(ValidReplacementOwnerId != null)
                            {
                                o.ReplacementOwnersByRecordId.put(rld.Object_Id__c,rld.Replacement_Owner__c);
                            }
                        }
                    }
                }
            }
            
            system.debug(ReLinkObjects);
            
            // sort the ReLink Objects by their order setting
            List<ReLinkObject> SortReLinkObjects=ReLinkObjects.values();
            Boolean swapped=true;
            Integer j=0;
            
            while(swapped) 
            {
                swapped=false;
                j++;
                
                for(Integer i=0; i < SortReLinkObjects.size() - j; i++) 
                {
                    if (SortReLinkObjects[i].Settings.Order__c > SortReLinkObjects[i+1].Settings.Order__c) 
                    {
                        ReLinkObject temp=SortReLinkObjects[i];
                        SortReLinkObjects[i]=SortReLinkObjects[i+1];
                        SortReLinkObjects[i+1]=temp;
                        swapped=true;
                    }
                } 
            }
            // end sort
            
            for(ReLinkObject o : SortReLinkObjects)
            {
                system.debug(LoggingLevel.WARN,'  Update/Clone loop for ' + o.Settings.Object_API_Name__c + ' Detail Records: ' + o.DetailRecords);
                
                if(!o.DetailRecords.isEmpty())// && o.Settings.Object_API_Name__c == 'Note')
                {
                    //system.debug(LoggingLevel.WARN,'    Object API Name: '+o.Settings.Object_API_Name__c);
                    //for(Account_ReLink_Detail__c d : o.DetailRecords.values()) {system.debug(LoggingLevel.WARN,'      Detail: '+d);}
                    //system.debug(LoggingLevel.WARN,'      RecordIds: '+o.RecordIds);
                    
                    List<Database.SaveResult> UpdateResults;
                    List<Database.DeleteResult> DeleteResults;
                    List<Database.SaveResult> InsertResults;
                    
                    if(o.Settings.Action__c.toLowerCase() == 'update')
                    {
                        system.debug(LoggingLevel.WARN,'    Calling QueryAndUpdate ');
                        
                        o.sObjectsToUpdate=
                            DSCB_AccountReLink.QueryAndUpdate(
                                o.RecordIds, o.ReplacementOwnersByRecordId, o.Settings.Object_API_Name__c, 
                                o.Settings.Fields__c, o.Settings.Account_Field__c, rl.Party_Account__c);
                        
                        system.debug(LoggingLevel.WARN,'    Update: '+o.sObjectsToUpdate);
                        
                        if(!o.sObjectsToUpdate.IsEmpty())
                        {
                            // -- UPDATE
                            
                            Integer UpdateSuccesses=0, UpdateErrors=0;
                            //System.SavePoint UpdateSavePoint=Database.setSavepoint();
                            
                            try
                            {
                                for(sObject s : o.sObjectsToUpdate)
                                {
                                    system.debug(LoggingLevel.WARN,'      '+s);
                                }
                                UpdateResults=Database.update(o.sObjectsToUpdate, false);
                            } 
                            catch(Exception ex)
                            {
                                system.debug(LoggingLevel.WARN,'      '+ex);
                            }
                            
                            for(Integer i=0; i < UpdateResults.size(); i++)
                            {
                                Database.SaveResult ur=UpdateResults[i];
                                Account_ReLink_Detail__c rld=o.DetailRecords.get(o.sObjectsToUpdate[i].Id);
                                
                                if(ur.getErrors().size() > 0)
                                {
                                    system.debug(LoggingLevel.WARN,' ****** '+ur);
                                }
                                else
                                {
                                    system.debug(LoggingLevel.WARN,'        '+ur);
                                }
                                
                                system.debug(LoggingLevel.WARN,'          '+rld); 
                                
                                if(ur.isSuccess())
                                {
                                    UpdateSuccesses += 1;
                                    if(rld != null)
                                    {
                                        rld.Detail_Message__c='';
                                        rld.Owner_Status__c='';
                                        rld.Detail_Status__c='Success';
                                    }
                                }
                                else
                                {
                                    UpdateErrors += 1;
                                    if(rld != null)
                                    {
                                        rld.Detail_Status__c='Error';
                                        rld.Detail_Message__c='';
                                        for(Database.Error dbe : ur.getErrors())
                                        {
                                            rld.Detail_Message__c += dbe.getMessage();
                                        }
                                    }
                                }
                            }
                            
                            // -- END UPDATE
                        }
                        
                        //if(UpdateErrors > 0) { Database.rollback(UpdateSavePoint); }
                    }
                    
                    if(o.Settings.Action__c.toLowerCase() == 'clone')
                    {
                        system.debug(LoggingLevel.WARN,'    Calling QueryAndClone ');
                        
                        o.sObjectsToClone=
                            DSCB_AccountReLink.QueryAndClone(
                                o.RecordIds, o.ReplacementOwnersByRecordId, o.Settings.Object_API_Name__c, 
                                o.Settings.Fields__c, o.Settings.Account_Field__c, rl.Party_Account__c);
                        
                        system.debug('    Clone: '+o.sObjectsToClone);
                        
                        if(o.sObjectsToClone != null)
                        {
                            if(!o.sObjectsToClone.IsEmpty())
                            {
                                // -- CLONE
                                
                                // setup clone variables
                                Integer CloneSuccesses=0, CloneErrors=0;
                                System.SavePoint CloneSavePoint=Database.setSavepoint();
                                
                                Map<Id,sObject> ClonedSObjectsByOriginalIds=new Map<Id,sObject>();
                                
                                // setup delete variables
                                List<Id> OriginalIds=new List<Id>();
                                
                                // gather all of the original Ids
                                for(Id OriginalId : o.sObjectsToClone.keyset())
                                {
                                    ClonedSObjectsByOriginalIds.put(OriginalId,o.sObjectsToClone.get(OriginalId));
                                    OriginalIds.add(OriginalId);
                                }
                                
                                // -- DELETE
                                
                                // try to delete the original Ids
                                try
                                {
                                    system.debug(LoggingLevel.WARN,'      '+OriginalIds);
                                    DeleteResults=Database.delete(OriginalIds, false); // must be false to get all errors
                                } 
                                catch(Exception ex)
                                {
                                    system.debug(LoggingLevel.WARN,'      '+ex);
                                }
                                
                                // a new list of deleted Ids (records that were successfully deleted)
                                List<Id> DeletedOriginalIds=new List<Id>();
                                
                                // loop through the delete results
                                system.debug(LoggingLevel.WARN,'      Delete Results  ');
                                for(Integer i=0; i < OriginalIds.size(); i++) 
                                {
                                    Database.DeleteResult dr=DeleteResults[i];
                                    Account_ReLink_Detail__c rld=o.DetailRecords.get(OriginalIds[i]);
                                    
                                    if(dr.getErrors().size() > 0)
                                    {
                                        system.debug(LoggingLevel.WARN,' ****** '+dr);
                                    }
                                    else
                                    {
                                        system.debug(LoggingLevel.WARN,'        '+dr);
                                    }
                                    
                                    system.debug(LoggingLevel.WARN,'          '+rld); 
                                    
                                    // if the delete was successful
                                    if(dr.isSuccess())
                                    {
                                        DeletedOriginalIds.add(OriginalIds[i]);
                                    }
                                    // else, the delete was not successful
                                    else
                                    {
                                        CloneErrors += 1; // add one to clone errors
                                        if(rld != null)
                                        {
                                            rld.Detail_Status__c='Error';
                                            rld.Detail_Message__c='';
                                            for(Database.Error dbe : dr.getErrors())
                                            {
                                                rld.Detail_Message__c += dbe.getMessage();
                                            }
                                        }
                                    }
                                }
                                
                                // -- END DELETE
                                
                                // -- INSERT 
                                //    (only the records that were deleted)
                                
                                List<sObject> sObjectsToInsert=new List<sObject>();
                                List<Id> OriginalIdsToInsert=new List<Id>();
                                
                                List<Id> ValidOriginalIdsToInsert=new List<Id>(); // a list of valid Ids should the first insert dml statement fail 
                                
                                // for all of the successfully deleted records
                                for(Id OriginalId : DeletedOriginalIds)
                                {
                                    // add the record to the end of the insert list
                                    //   because of the way the add method for lists works (values are added to the end of the list), 
                                    //   the values will always match
                                    sObject s=ClonedSObjectsByOriginalIds.get(OriginalId);
                                    if(s != null)
                                    {
                                        sObjectsToInsert.add(s);
                                        OriginalIdsToInsert.add(OriginalId);
                                    }
                                    
                                    // because of this condition DeletedOriginalIds[i] may not match sObjectsToInsert[i]
                                }
                                
                                // try to insert the cloned records
                                try
                                {
                                    system.debug(LoggingLevel.WARN,'      '+sObjectsToInsert);
                                    InsertResults=Database.insert(sObjectsToInsert, false); // must be false to get all errors
                                }
                                catch(Exception ex)
                                {
                                    system.debug(LoggingLevel.WARN,'      '+ex);
                                }
                                
                                // at this point sObjectsToInsert, InsertResults, and OriginalIdsToInsert are all in the same order
                                // sObjectsToInsert[i] (sObject) has InsertResults[i] (SaveResult) for OriginalIdsToInsert[i] (Id)
                                
                                system.debug(LoggingLevel.WARN,'      Insert Results  ');
                                for(Integer i=0; i < sObjectsToInsert.size(); i++)
                                {
                                    system.debug(OriginalIdsToInsert[i]+' '+InsertResults[i]+' '+sObjectsToInsert[i]);
                                    
                                    Database.SaveResult ir=InsertResults[i];
                                    Account_ReLink_Detail__c rld=o.DetailRecords.get(OriginalIdsToInsert[i]);
                                    
                                    if(ir.getErrors().size() > 0)
                                    {
                                        system.debug(LoggingLevel.WARN,' ****** '+ir);
                                    }
                                    else
                                    {
                                        system.debug(LoggingLevel.WARN,'        '+ir);
                                    }
                                    
                                    system.debug(LoggingLevel.WARN,'          '+rld); 
                                    
                                    if(ir.isSuccess())
                                    {
                                        //system.debug('INSERT RESULT IS SUCCESS: '+ir);
                                        CloneSuccesses += 1;
                                        ValidOriginalIdsToInsert.add(OriginalIdsToInsert[i]);
                                        
                                        if(rld != null)
                                        {
                                            rld.Detail_Message__c='';
                                            rld.Owner_Status__c='';
                                            rld.Detail_Status__c='Success';
                                        }
                                    }
                                    else
                                    {
                                        //system.debug('INSERT RESULT NOT SUCCESS: '+ir);
                                        CloneErrors += 1;
                                        if(rld != null)
                                        {
                                            rld.Detail_Status__c='Error';
                                            rld.Detail_Message__c='';
                                            for(Database.Error dbe : ir.getErrors())
                                            {
                                                rld.Detail_Message__c += dbe.getMessage();
                                            }
                                        }
                                    }
                                }
                                
                                // -- END INSERT
                                
                                // if errors occurred in cloning, rollback the database and if some were valid, partial process them
                                if(CloneErrors > 0) 
                                { 
                                    system.debug(LoggingLevel.WARN,' **** Cloning Errors: '+CloneErrors);
                                    
                                    // roll back to the database save point
                                    Database.rollback(CloneSavePoint); 
                                    
                                    if(ValidOriginalIdsToInsert.size() > 0)
                                    {
                                        system.debug(LoggingLevel.WARN,' ++++ Partial Processing ');
                                        system.debug(LoggingLevel.WARN,'      ValidIdsToInsert: '+ValidOriginalIdsToInsert);
                                        
                                        Set<Id> ValidOriginalIdsToInsertSet=new Set<Id>();
                                        ValidOriginalIdsToInsertSet.addAll(ValidOriginalIdsToInsert);
                                        
                                        // put together a list of valid sObjects to clone from the valid Ids to insert
                                        Map<Id,sObject> ValidsObjectsToClone=
                                            DSCB_AccountReLink.QueryAndClone(
                                                ValidOriginalIdsToInsertSet, o.ReplacementOwnersByRecordId, o.Settings.Object_API_Name__c, 
                                                o.Settings.Fields__c, o.Settings.Account_Field__c, rl.Party_Account__c);
                                        
                                        // define a list because database.delete does not accept sets
                                        List<Id> OriginalIdsToDelete=new List<Id>(); 
                                        OriginalIdsToDelete.addAll(ValidsObjectsToClone.keyset());
                                        
                                        // process the Valid IDs
                                        for(Id i : OriginalIdsToDelete)
                                        {
                                            system.debug(i);
                                            database.delete(i);
                                        }
                                        //Database.delete(OriginalIdsToDelete);
                                        for(sObject s : ValidsObjectsToClone.values())
                                        {
                                            system.debug(s);
                                            insert s;
                                        }
                                        //Database.insert(ValidsObjectsToClone.values());
                                    }
                                }
                            } // end if !o.sObjectsToClone.IsEmpty()
                        } // end if o.sObjectsToClone not equal null
                    }
                    
                    // store all the ReLinkDetail record modifications 
                    //   (containing successes/errors) for updating after the database rollback
                    // this applies to both updates and clones and is therefore outside of the if statements for each
                    for(Account_ReLink_Detail__c rld : o.DetailRecords.values()) 
                    {
                        //if(rld.Detail_Status__c != 'Success') { UpdateAccountFields=false; }
                        ReLinkDetailsToUpdate.add(rld); 
                    }
                    
                    update ReLinkDetailsToUpdate;
                }
            } // end for sorted ReLink Objects
            
            system.debug(rl.Party_Account__r.Account_Number__c);
            
            if(rl.Cobalt_Account_Number__c != rl.Party_Account__r.Account_Number__c)
            {
                try
                {
                    List<Account> AccountsToUpdate=new List<Account>();
                    
                    Account c=new Account(Id=rl.Cobalt_Account__c);
                    c.Decision_Making_Model__c=null; 
                    c.MDA__c=null; 
                    c.Dealership_Health__c=null; 
                    c.Core_Utility__c=null; 
                    c.Operational_Efficiency__c=null; 
                    c.Financial_Performance__c=null; 
                    c.COF_Summary__c=null; 
                    c.Cobalt_Strategy__c=null; 
                    c.Do_Not_Sell__c=false; // boolean, cannot be set to null
                    c.Status__c=null; 
                    c.Critical_Note__c=null; 
                    c.OEM__c=null; 
                    c.Make__c=null; 
                    c.Org_Key__c=null; 
                    c.Nitra_Date__c=null; 
                    c.LDP__c=false; // boolean, cannot be set to null
                    c.VIP__c=false; // boolean, cannot be set to null 
                    c.CBLTAccountName__c=null; 
                    c.CBLTShipStreet__c=null; 
                    c.CBLTShipCity__c=null; 
                    c.CBLTState__c=null; 
                    c.CBLTZip__c=null; 
                    c.CBLTShipCountry__c=null; 
                    c.CBLTBillStreet__c=null; 
                    c.CBLTBillCity__c=null; 
                    c.CBLTBillState__c=null; 
                    c.CBLTBillZip__c=null; 
                    c.CBLTBillCountry__c=null; 
                    c.CBLTPhone__c=null; 
                    c.CBLTFax__c=null; 
                    c.Collector__c=null; 
                    c.Designated_DSM__c=null;
                    AccountsToUpdate.add(c);
                    
                    Account p=new Account(Id=rl.Party_Account__c);
                    p.Decision_Making_Model__c=rl.Cobalt_Account__r.Decision_Making_Model__c; 
                    p.MDA__c=rl.Cobalt_Account__r.MDA__c; 
                    p.Dealership_Health__c=rl.Cobalt_Account__r.Dealership_Health__c; 
                    p.Core_Utility__c=rl.Cobalt_Account__r.Core_Utility__c; 
                    p.Operational_Efficiency__c=rl.Cobalt_Account__r.Operational_Efficiency__c; 
                    p.Financial_Performance__c=rl.Cobalt_Account__r.Financial_Performance__c; 
                    p.COF_Summary__c=rl.Cobalt_Account__r.COF_Summary__c; 
                    p.Cobalt_Strategy__c=rl.Cobalt_Account__r.Cobalt_Strategy__c; 
                    p.Do_Not_Sell__c=rl.Cobalt_Account__r.Do_Not_Sell__c; 
                    p.Status__c=rl.Cobalt_Account__r.Status__c; 
                    p.Critical_Note__c=rl.Cobalt_Account__r.Critical_Note__c; 
                    p.OEM__c=rl.Cobalt_Account__r.OEM__c; 
                    p.Make__c=rl.Cobalt_Account__r.Make__c; 
                    p.Org_Key__c=rl.Cobalt_Account__r.Org_Key__c; 
                    p.Nitra_Date__c=rl.Cobalt_Account__r.Nitra_Date__c; 
                    p.LDP__c=rl.Cobalt_Account__r.LDP__c; 
                    p.VIP__c=rl.Cobalt_Account__r.VIP__c; 
                    p.CBLTAccountName__c=rl.Cobalt_Account__r.CBLTAccountName__c; 
                    p.CBLTShipStreet__c=rl.Cobalt_Account__r.CBLTShipStreet__c; 
                    p.CBLTShipCity__c=rl.Cobalt_Account__r.CBLTShipCity__c; 
                    p.CBLTState__c=rl.Cobalt_Account__r.CBLTState__c; 
                    p.CBLTZip__c=rl.Cobalt_Account__r.CBLTZip__c; 
                    p.CBLTShipCountry__c=rl.Cobalt_Account__r.CBLTShipCountry__c; 
                    p.CBLTBillStreet__c=rl.Cobalt_Account__r.CBLTBillStreet__c; 
                    p.CBLTBillCity__c=rl.Cobalt_Account__r.CBLTBillCity__c; 
                    p.CBLTBillState__c=rl.Cobalt_Account__r.CBLTBillState__c; 
                    p.CBLTBillZip__c=rl.Cobalt_Account__r.CBLTBillZip__c; 
                    p.CBLTBillCountry__c=rl.Cobalt_Account__r.CBLTBillCountry__c; 
                    p.CBLTPhone__c=rl.Cobalt_Account__r.CBLTPhone__c; 
                    p.CBLTFax__c=rl.Cobalt_Account__r.CBLTFax__c; 
                    p.Collector__c=rl.Cobalt_Account__r.Collector__c; 
                    p.Designated_DSM__c=rl.Cobalt_Account__r.Designated_DSM__c;
                    AccountsToUpdate.add(p);
                    
                    update AccountsToUpdate;
                    
                    // if the field update was successful, update the Account Numbers
                    Account c2=new Account(Id=rl.Cobalt_Account__c);
                    c2.Account_Number__c=null; 
                    update c2;
                    
                    Account p2=new Account(Id=rl.Party_Account__c);
                    p2.Account_Number__c=rl.Cobalt_Account__r.Account_Number__c; 
                    update p2;
                } 
                catch(Exception ex)
                {
                    rl.Status_Message__c='Account field update failed. Error Message: '+ex.getMessage();
                }
            }
            
            // if no relink details were returned (the query returns details that were not successful)
            if(ReLinkDetails == null)
            {
                rl.Relink_Date__c=DateTime.now();
                ReLinksProcessed++;
            }
            else
            {
                // if no relink details were returned (the query returns details that were not successful)
                if(ReLinkDetails.size() == 0)
                {
                    rl.Relink_Date__c=DateTime.now();
                    ReLinksProcessed++;
                }
                else
                {
                    Integer NonSuccess=0; // a variable for counting the non-success detail records
                    
                    for(Account_ReLink_Detail__c endRld : ReLinkDetails)
                    {
                        if(endRld.Detail_Status__c != 'Success')
                        {
                            NonSuccess++;
                        }
                    }
                    
                    // there are no non-success statuses (no errors or pendings)
                    if(NonSuccess == 0)
                    {
                        rl.Relink_Date__c=DateTime.now();
                        ReLinksProcessed++;
                    }
                }
            }
            
            //rl.Relink_Date__c=DateTime.now();
            system.debug(LoggingLevel.WARN,rl);
            update rl;
            system.debug(LoggingLevel.WARN,rl);
        } // end for refreshed ReLinks
        
        // turn on triggers
        GlobalSettings.BypassCaseTriggersTrigger=false;
        GlobalSettings.BypassMMRechargeCloneRecordTrigger=false;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        fn(BC);
    }
    
    global void fn(Database.BatchableContext BC)
    {
        //2015-10-23- anirudh.singh@cdk.com- Added the below code.
        if(BC!=Null && ReLinksProcessed>0)
        {
            log=new ALL_UtilitiesBatch.Logger();
            log.batchId=BC.getJobId();
            log.title='DSCB_AccountReLinkBatch Batch Job Summary';
            log.description='Re-Linking Account related objects from a Cobalt Account Number Account to a Party ID Account ';
            log.message='Complete';
            
            ALL_UtilitiesBatch.finish(currentClassName, log);
        }
    }*/
}