//2016-01-22- anirudh.singh@cdk.com- Created this handler class for the Trigger DSCB_AccountReLink, as the earlier class was not following name standard.
//2016-01-22- anirudh.singh@cdk.com- Also, corrected the variable naming standards, indentation, implemented Result class as it was present but not implemented earlier.
//2016-02-24- anirudh.singh@cdk.com- Modified the method populateAccReLinkDetailRecords to comment the Trigger.OldMap logic, as Trigger.OldMap is Null for after insert.
public class DSCB_AccountReLink_Handler
{
    //2016-02-18- anirudh.singh@cdk.com- Made this variable private from public as it is not accessed outside this class.
    //This variable is used to hold the Account ReLink Object Custom Setting Records List.
    private static List<AccountReLinkObject__c> accReLinkObjects=AccountReLinkObject__c.getall().values();
    
    //This is the constructor of this class.
    public DSCB_AccountReLink_Handler()
    {
        system.debug('Start DSCB_AccountReLink_Handler---->');
        if(accReLinkObjects==Null)
        {
            accReLinkObjects=new List<AccountReLinkObject__c>();
        }
        system.debug('End DSCB_AccountReLink_Handler---->');
    }
    
    //2016-02-25- anirudh.singh@cdk.com- Added this method.
    //This method is invoked from the Trigger for before insert.
    public static void processAccountReLinksBeforeInsert(List<Account_ReLink__c> accReLinkNewList)
    {
        system.debug('Start processAccountReLinksBeforeInsert---->');
        populateFieldsFromAccount(accReLinkNewList);
        system.debug('End processAccountReLinksBeforeInsert---->');
    }
    
    //This method is invoked from processAccountReLinksBeforeInsert method.
    private static void populateFieldsFromAccount(List<Account_ReLink__c> accReLinkNewList)
    {
        system.debug('Start populateFieldsFromAccount---->');
        Map<String, Account_ReLink__c> partyIdAndAccReLinkMap=new Map<String, Account_ReLink__c>();
        Map<String, Account_ReLink__c> cobaltIdAndAccReLinkMap=new Map<String, Account_ReLink__c>();
        
        //2016-01-28- anirudh.singh@cdk.com- Added the IF Block.
        if(accReLinkNewList!=Null && accReLinkNewList.size()>0)
        {
            for(Account_ReLink__c accReLink: accReLinkNewList)
            {
                //If Relink Date is NOT blank, do NOT process
                if(accReLink.Relink_Date__c==Null)
                {
                    if(accReLink.Party_ID__c==Null)
                    { 
                        accReLink.Party_ID__c.addError('Party ID must not be Null.'); 
                    }
                    else
                    {
                        partyIdAndAccReLinkMap.put(accReLink.Party_ID__c, accReLink); 
                    }
                    
                    if(accReLink.Cobalt_Account_Number__c==Null)
                    { 
                        accReLink.Cobalt_Account_Number__c.addError('Cobalt Account Number must not be Null.'); 
                    }
                    else
                    {
                        cobaltIdAndAccReLinkMap.put(accReLink.Cobalt_Account_Number__c, accReLink); 
                    }
                }
            }
            
            Map<String, Account> partyIdAndAccountMap=new Map<String, Account>();
            List<String> partyAccIdsToQuery=new List<String>();
            partyAccIdsToQuery.addAll(partyIdAndAccReLinkMap.keyset());
            
            List<Account> partyAccounts=[
                Select Id, Name, PartyID__c, Account_Number__c, 
                BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone 
                From Account 
                Where PartyID__c IN :partyAccIdsToQuery
            ];
            
            for(Account acc: partyAccounts)
            {
                partyIdAndAccountMap.put(acc.PartyID__c, acc);
            }
            
            for(Account_ReLink__c accReLink: partyIdAndAccReLinkMap.values())
            {
                Account acc=partyIdAndAccountMap.get(accReLink.Party_ID__c);
                
                if(acc==Null)
                { 
                    accReLink.Party_ID__c.addError('Party ID is invalid.'); 
                }
                //else if(acc.Id==accReLink.Cobalt_Account__c) {
                //  accReLink.Party_ID__c.addError('Party Account('+acc.Name+') and Cobalt Account must not match.'); 
                //}
                else
                {
                    accReLink.Party_Account__c=acc.Id;
                    accReLink.Party_Account_Phone__c=acc.Phone;
                    accReLink.Party_Account_Street__c=acc.BillingStreet;
                    accReLink.Party_Account_City__c=acc.BillingCity;
                    accReLink.Party_Account_State__c=acc.BillingState;
                    accReLink.Party_Account_Zip_Code__c=acc.BillingPostalCode;
                    accReLink.Party_Account_Country__c=acc.BillingCountry;
                }
            }
            
            Map<String, Account> acctsByCobaltAcctNumbersMap=new Map<String, Account>();
            
            List<String> cobaltAccIdsToQuery=new List<String>();
            cobaltAccIdsToQuery.addAll(cobaltIdAndAccReLinkMap.keyset());
            
            List<Account> cobaltAccounts=[
                Select Id, Name, PartyID__c, Account_Number__c, 
                BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone 
                From Account 
                Where Account_Number__c IN :cobaltAccIdsToQuery
            ];
            
            for(Account acc: cobaltAccounts)
            {
                acctsByCobaltAcctNumbersMap.put(acc.Account_Number__c, acc);
            }
            
            for(Account_ReLink__c accReLink: cobaltIdAndAccReLinkMap.values())
            {
                Account acc=acctsByCobaltAcctNumbersMap.get(accReLink.Cobalt_Account_Number__c);
                
                if(acc==Null)
                { 
                    accReLink.Cobalt_Account_Number__c.addError('Cobalt Account Number is invalid.'); 
                }
                //else if(acc.Id==accReLink.Party_Account__c) {
                //  accReLink.Cobalt_Account_Number__c.addError('Cobalt Account('+acc.Name+') and Party Account must not match.'); 
                //}
                else
                {
                    accReLink.Cobalt_Account__c=acc.Id;
                    accReLink.Cobalt_Account_Phone__c=acc.Phone;
                    accReLink.Cobalt_Account_Street__c=acc.BillingStreet;
                    accReLink.Cobalt_Account_City__c=acc.BillingCity;
                    accReLink.Cobalt_Account_State__c=acc.BillingState;
                    accReLink.Cobalt_Account_Zip_Code__c=acc.BillingPostalCode;
                    accReLink.Cobalt_Account_Country__c=acc.BillingCountry;
                }
            }
        }
        system.debug('End populateFieldsFromAccount---->');
    }
    
    //This method is invoked from the Trigger for after insert.
    public static void processAccountReLinksAfterInsert(List<Account_ReLink__c> accReLinkNewList)
    {
        system.debug('Start processAccountReLinksAfterInsert---->');
        populateAccReLinkDetailRecords(accReLinkNewList);
        system.debug('End processAccountReLinksAfterInsert---->');
    }
    
    //2016-02-24- anirudh.singh@cdk.com- Also, modified the method to comment the Trigger.OldMap logic, as Trigger.OldMap is Null for after insert.
    //2016-02-24- anirudh.singh@cdk.com- Also, changed the method parameters removed Map<Id, Account_ReLink__c> accReLinkOldMap.
    //This method is invoked from processAccountReLinksBeforeInsert method.
    private static void populateAccReLinkDetailRecords(List<Account_ReLink__c> accReLinkNewList)
    {
        system.debug('Start populateAccReLinkDetailRecords---->');
        
        //Delete all previous ReLink details(case: when Accounts change on the ReLink)
        //2016-01-29- anirudh.singh@cdk.com- Commented this variable as it is not being used anywhere.
        //Set<Id> ReLinkIdsToDeleteDetails=new Set<Id>();
        List<Account_ReLink__c> accReLinkList=new List<Account_ReLink__c>();
        
        //2016-01-28- anirudh.singh@cdk.com- Added the IF Block.
        if(accReLinkNewList!=Null && accReLinkNewList.size()>0)
        {
            for(Account_ReLink__c accReLink: accReLinkNewList)
            {
                //2016-02-24- anirudh.singh@cdk.com- Commented the below code as Trigger.OldMap is not applicable for after insert scenario.
                //Account_ReLink__c oldAccReLink;
                //if(accReLinkOldMap!=Null)
                //{
                //	if(accReLinkOldMap.get(accReLink.Id)!=Null)
                //	{
                //		oldAccReLink=accReLinkOldMap.get(accReLink.Id);
                //	}
                //}
                //else
                //{
                //	oldAccReLink=new Account_ReLink__c();
                //}
                
                if(accReLink.Account_Updated__c=='False' || accReLink.Account_Updated__c==Null)
                {
                    //2016-02-24- anirudh.singh@cdk.com- Commented the below line as Trigger.OldMap is not applicable for after insert scenario.
                    //if(accReLink.Cobalt_Account__c!=oldAccReLink.Cobalt_Account__c || accReLink.Party_Account__c!=oldAccReLink.Party_Account__c)
                    if(accReLink.Cobalt_Account__c!=Null || accReLink.Party_Account__c!=Null)
                    {
                        // the below code is never true if this Trigger only executes on Insert
                        //if(accReLinkOldMap!= Null) {
                        //    if(accReLink.Cobalt_Account__c!=oldAccReLink.Cobalt_Account__c) { ReLinkIdsToDeleteDetails.add(accReLink.Id); } }
                        
                        if(accReLink.Cobalt_Account__c!=Null && accReLink.Party_Account__c!=Null)
                        {
                            accReLinkList.add(accReLink);
                        }
                    }
                }
            }
            
            // the below code is never true if this Trigger only executes on Insert
            //if(!ReLinkIdsToDeleteDetails.IsEmpty()) {
            //    delete [Select Id, Name From Account_ReLink_Detail__c Where Account_ReLink__c IN :ReLinkIdsToDeleteDetails]; }
            
            // process relinks into ReLink Detail records
            if(!accReLinkList.IsEmpty())
            {
                processRelinks(accReLinkList);
            }
        }
        system.debug('End populateAccReLinkDetailRecords---->');
    }
    
    //This method is invoked from the Batch Class. It processes ReLinks into ReLink Detail Records.
    public static Result processRelinks(List<Account_ReLink__c> relinks)
    {
        system.debug('Start processRelinks---->');
        
        Result accReLinkResult=new Result();
        accReLinkResult.processingLog='';
        
        if(accReLinkObjects==Null)
        {
            accReLinkObjects=new List<AccountReLinkObject__c>();
        }
        
        List<AccountReLinkObject__c> accReLinkObjectList=new List<AccountReLinkObject__c>();
        
        for(AccountReLinkObject__c accReLinkObject: accReLinkObjects)
        {
            if(accReLinkObject.Account_Relationship_Name__c!=Null)
            {
                accReLinkObjectList.add(accReLinkObject);
            }
        }
        
        List<Account_ReLink_Detail__c> accReLinkDetailsToInsert=new List<Account_ReLink_Detail__c>();
        List<Account_ReLink_Detail__c> accReLinkDetailsToUpdate=new List<Account_ReLink_Detail__c>();
        Map<Id, Account_ReLink_Detail__c> existingAccReLinkDetailMap=new Map<Id, Account_ReLink_Detail__c>();
        
        Set<Id> accReLinkIds=new Set<Id>();
        
        //ReLink Ids by Cobalt Account Ids.
        Map<Id, Id> sourceAccountIds=new Map<Id, Id>();
        
        //2016-01-28- anirudh.singh@cdk.com- Commented the below line as the destinationAccountIds Map has not been used anywhere.
        //ReLink Ids by Party Account Ids.
        //Map<Id, Id> destinationAccountIds=new Map<Id, Id>();
        
        //ReLink CreatedDates by ReLink Ids.
        Map<Id, DateTime> accReLinkCreatedDateMap=new Map<Id, DateTime>();
        
        for(Account_ReLink__c accReLink: relinks)
        {
            accReLinkIds.add(accReLink.Id);
            
            if(accReLink.Cobalt_Account__c != Null)
            {
                sourceAccountIds.put(accReLink.Cobalt_Account__c, accReLink.Id); 
                accReLinkCreatedDateMap.put(accReLink.Id, accReLink.CreatedDate);
            }
            
            //2016-01-28- anirudh.singh@cdk.com- Commented the below line as the destinationAccountIds Map has not been used anywhere.
            //if(accReLink.Party_Account__c != Null)
            //{
            //    destinationAccountIds.put(accReLink.Party_Account__c, accReLink.Id);
            //}
        }
        
        List<Account_ReLink_Detail__c> accReLinkDetailList=[
            Select Id, Name, Object_Id__c, Account_ReLink__c 
            From Account_ReLink_Detail__c 
            Where Account_ReLink__c IN :accReLinkIds
        ];
        
        for(Account_ReLink_Detail__c accReLinkDetail: accReLinkDetailList)
        {
            existingAccReLinkDetailMap.put(accReLinkDetail.Object_Id__c, accReLinkDetail);
        }
        
        List<SourceAccount> sourceAccountsList=querySourceAccounts(sourceAccountIds.keyset());
        //2016-01-28- anirudh.singh@cdk.com- Commented the below line as the list DestinationAccounts has not been used anywhere.
        //List<Account> DestinationAccounts=QueryDestinationAccounts(destinationAccountIds.keyset());
        
        for(SourceAccount sourceAccRef: sourceAccountsList)
        {
            //Get the ReLink Id for the current source Account.
            Id sourceReLinkID=sourceAccountIds.get(sourceAccRef.sAccount.Id); 
            
            List<sObject> currentObjectList;
            
            //un-necessary due to removal of Days Since ReLink Created
            //DateTime rlCreatedDate=accReLinkCreatedDateMap.get(sourceReLinkID);
            //Integer DaysSinceReLinkCreated=rlCreatedDate != Null ? rlCreatedDate.Date().daysBetween(Date.Today()) : 0;
            //DaysSinceReLinkCreated++; // need to add one because this is used in multiplication 
            
            for(AccountReLinkObject__c accReLinkObject: accReLinkObjectList)
            {
                String objAPIName=accReLinkObject.Object_API_Name__c;
                
                //Get all child objects for the Account by type (Api Name).
                currentObjectList=Null;
                currentObjectList=sourceAccRef.sChildObjects.get(objAPIName);
                
                if(currentObjectList!=Null && !currentObjectList.IsEmpty())
                {
                    Integer counter=0;
                    
                    for(sObject sObjectRef: currentObjectList)
                    {
                        String sObjectType=String.valueOf(sObjectRef.getsObjectType());
                        
                        system.debug(LOGGINGLEVEL.WARN, counter);
                        system.debug(LOGGINGLEVEL.WARN, sObjectType);
                        
                        Id ownerId=Null;
                        sObject owner=Null;
                        Boolean ownerIsActive=Null;
                        String ownerName=Null;
                        
                        Account_ReLink_Detail__c accReLinkDetailExisting=existingAccReLinkDetailMap.get(sObjectRef.Id);
                        Boolean preExisting=true;
                        
                        // if an existing detail record with this sObject Id was found, 
                        //   check to see if the ReLink Id matches
                        if(accReLinkDetailExisting != Null)
                        {
                            // if it does not match, mark it as not pre-existing
                            if(accReLinkDetailExisting.Account_ReLink__c != SourceReLinkID)
                            {
                                preExisting=false;
                            }
                            // if no detail record was found, mark it as not pre-existing
                        }
                        else
                        {
                            preExisting=false;
                        }
                        
                        try
                        {
                            ownerId=(ID)sObjectRef.get('OwnerId');
                        }
                        catch (Exception e) {}
                        
                        if(ownerId != Null)
                        {
                            try
                            {
                                Owner=sObjectRef.getSObject('Owner'); 
                                ownerIsActive=Boolean.valueOf(Owner.get('IsActive'));
                                ownerName=String.valueOf(Owner.get('Name'));
                            }
                            catch (Exception e) {system.debug(e);}
                        }
                        
                        if(!preExisting)
                        {
                            system.debug('Not preExisting...');
                            
                            //system.debug(LOGGINGLEVEL.WARN, counter);
                            //system.debug(LOGGINGLEVEL.WARN, accReLinkObject.Limit_Per_Day__c);
                            //system.debug(LOGGINGLEVEL.WARN, DaysSinceReLinkCreated);
                            //system.debug(LOGGINGLEVEL.WARN, 
                            //  'Total Objects for this Type to process: ' 
                            //    + ((accReLinkObject.Limit_Per_Day__c==Null?0:accReLinkObject.Limit_Per_Day__c)*DaysSinceReLinkCreated));
                            
                            // DaysSinceReLinkCreated was multiplied by Limit Per Day, but because success records
                            // are not counted, it was un-necessary. Without it, regardless of the number of success records,
                            // only the Limit Per Day number of records would be added on that nightly batch.
                            //if(accReLinkObject.Limit_Per_Day__c==Null || accReLinkObject.Limit_Per_Day__c==0 || counter < (accReLinkObject.Limit_Per_Day__c)) //*DaysSinceReLinkCreated
                            //{
                            accReLinkDetailsToInsert.add(new Account_ReLink_Detail__c(
                                Object_ID__c=sObjectRef.Id
                                ,Object_Type__c=String.valueOf(sObjectRef.getSObjectType())
                                ,Owner__c=(ownerId != Null ? ownerId : Null)
                                ,Owner_Name__c=(ownerName != Null ? ownerName : Null)
                                ,Owner_Status__c=(ownerIsActive != Null ? 
                                                  (ownerIsActive ? 'Active' : 'Inactive') : '')
                                ,Detail_Status__c='Pending'
                                ,Account_ReLink__c=sourceAccountIds.get(sourceAccRef.sAccount.Id)
                            ));
                            
                            //c++; // yay c++! Increment the counter to check how many objects have been processed
                            //}
                        }
                        else
                        {
                            if(accReLinkDetailExisting != Null) 
                            {
                                if(accReLinkDetailExisting.Object_ID__c==sObjectRef.Id)
                                {
                                    accReLinkDetailExisting.Object_Type__c=String.valueOf(sObjectRef.getSObjectType());
                                    accReLinkDetailExisting.Owner__c=(ownerId != Null ? ownerId : Null);
                                    accReLinkDetailExisting.Owner_Status__c=(ownerIsActive != Null ? 
                                                                             (ownerIsActive ? 'Active' : 'Inactive') : '');
                                    accReLinkDetailExisting.Owner_Name__c=(ownerName != Null ? ownerName : Null);
                                    accReLinkDetailExisting.Detail_Status__c='Pending';
                                    accReLinkDetailExisting.Detail_Message__c=Null;
                                    accReLinkDetailsToUpdate.add(accReLinkDetailExisting);
                                } // end if object id equals s id
                            } // end if existing detail not Null
                        } // end else (pre-existing)
                    } // end for current objects
                } // end if current objects empty
            } // end for object names
        } // end for accounts
        
        try 
        {
            system.debug('Details to Insert---->'+accReLinkDetailsToInsert);
            //2016-02-19- anirudh.singh@cdk.com- Commented the below line.
            //insert accReLinkDetailsToInsert;
            
            //2016-02-19- anirudh.singh@cdk.com- Added the below line.
            if(accReLinkDetailsToInsert.size()>0)
            {
                List<Database.SaveResult> insertResults=Database.insert(accReLinkDetailsToInsert, false);
                
                logErrors('Insert', accReLinkResult, insertResults);
            }
            
            system.debug('Details to Update---->'+accReLinkDetailsToUpdate);
            //2016-02-19- anirudh.singh@cdk.com- Commented the below line.
            //update accReLinkDetailsToUpdate;
            
            //2016-02-19- anirudh.singh@cdk.com- Added the below line.
            if(accReLinkDetailsToUpdate.size()>0)
            {
                List<Database.SaveResult> updateResults=Database.update(accReLinkDetailsToUpdate, false);
                
                logErrors('Update', accReLinkResult, updateResults);
            }
        }
        catch (Exception ex) {system.debug(ex.getMessage());}
        
        system.debug('End processRelinks---->');
        return accReLinkResult;
    }
    
    //2016-02-19- anirudh.singh@cdk.com- Added this method to log the errors.
    private static void logErrors(String scenario, Result accReLinkResult, List<Database.SaveResult> saveResults)
    {
        system.debug('Start logErrors---->');
        
        Integer countSuccesses=0;
        
        for(Integer i=0; i<saveResults.size(); i++)
        {
            if(saveResults[i].isSuccess())
            {
                countSuccesses++;
            }
            else
            {
                for(Database.Error err: saveResults[i].getErrors())
                {
                    if(accReLinkResult.processingLog=='')
                    {
                        accReLinkResult.processingLog=err.getMessage();
                    }
                    else if(accReLinkResult.processingLog!='' && !accReLinkResult.processingLog.contains(err.getMessage()))
                    {
                        accReLinkResult.processingLog+=', '+err.getMessage();
                    }
                }
            }
        }
        
        if(countSuccesses==saveResults.size())
        {
            accReLinkResult.message+=accReLinkResult.message=='' ? (scenario+' Successful') : (', '+scenario+' Successful');
        }
        else
        {
            accReLinkResult.message+=accReLinkResult.message=='' ? (scenario+' of '+(saveResults.size()-countSuccesses)+'records failed') : (', '+scenario+' of '+(saveResults.size()-countSuccesses)+'records failed');
        }
        
        system.debug('End logErrors---->');
    }
    
    //2016-02-18- anirudh.singh@cdk.com- Made this method private from public as it is not accessed outside this class.
    //This method is invoked from processRelinks method.
    private static List<SourceAccount> querySourceAccounts(Set<Id> accountIds)
    {
        system.debug('Start querySourceAccounts---->');
        
        //Prevent Null exception by creating a placeholder list if the Account ReLink settings do not exist.
        if(accReLinkObjects==Null)
        {
            accReLinkObjects=new List<AccountReLinkObject__c>();
        }
        
        // convert set to string for query
        String accountIdQueryString='(';
        for(Id ref: accountIds)
        {
            accountIdQueryString += '\'' + String.valueOf(ref) + '\',';
        }
        if (accountIdQueryString.endsWith(','))
        {
            accountIdQueryString=accountIdQueryString.substring(0, accountIdQueryString.lastIndexOf(','));
        }
        accountIdQueryString += ')';
        
        // For querying in the Schema Explorer or Force.com Explorer, use //(.*)$ regex, replace with blank
        String accountQuery=''
            + 'Select Id, Name '; 
        
        accountQuery += ''  
            + ',Account_Number__c ' // Digital Solutions Account Number
            + ',Decision_Making_Model__c ' // Decision Making Model
            + ',MDA__c ' // MDA 
            + ',Dealership_Health__c ' // Dealership Help 
            + ',Core_Utility__c ' // Core Utility
            + ',Operational_Efficiency__c ' // Operational Efficiency
            + ',Financial_Performance__c ' // Financial Performance
            + ',COF_Summary__c ' // COF Summary
            + ',Cobalt_Strategy__c ' // Cobalt Strategy
            + ',Do_Not_Sell__c ' // In Digital Solutions Collections
            + ',Status__c ' // Status
            + ',Critical_Note__c ' // Critical Note
            + ',OEM__c ' // OEM
            + ',Make__c ' // Make
            + ',Org_Key__c ' // Org Key
            + ',Nitra_Date__c ' // Nitra Date
            + ',LDP__c ' // LDP 
            + ',VIP__c ' // VIP 
            + ',CBLTAccountName__c ' // Digital Solutions Account Name
            + ',CBLTShipStreet__c ' // Digital Solutions Shipping Street
            + ',CBLTShipCity__c ' // Digital Solutions Shipping City
            + ',CBLTState__c ' // Digital Solutions Shipping State
            + ',CBLTZip__c ' // Digital Solutions Shipping Zip
            + ',CBLTShipCountry__c ' // Digital Solutions Shipping Country
            + ',CBLTBillStreet__c ' // Digital Solutions Shipping Street
            + ',CBLTBillCity__c ' // Digital Solutions Shipping City
            + ',CBLTBillState__c ' // Digital Solutions Shipping State
            + ',CBLTBillZip__c ' // Digital Solutions Shipping Zip
            + ',CBLTBillCountry__c ' // Digital Solutions Shipping Country
            + ',CBLTPhone__c ' // Digital Solutions Phone
            + ',CBLTFax__c ' // Digital Solutions Fax
            + ',Collector__c ' // Collector
            + ',Designated_DSM__c ' // Designated DSM
            + 'From Account ' 
            + (accountIds != Null ? 'Where Id IN ' + accountIdQueryString + ' ' : '')
            + '';
        
        system.debug('accountQuery---->'+accountQuery);
        
        List<Account> accountList=new List<Account>();
        accountList=Database.query(accountQuery);
        
        //Accounts by Id.
        Map<Id, Account> accountsMap=new Map<Id, Account>(accountList);
        
        //Account Id, children (List<sObject>) by type (string).
        Map<Id, Map<String, List<sObject>>> accountChildrenMap=new Map<Id, Map<String, List<sObject>>>();
        
        // loop through all ReLink object settings
        for(AccountReLinkObject__c accReLinkObject: accReLinkObjects)
        {
            // if ReLink object setting is valid
            if(accReLinkObject.Account_Relationship_Name__c != Null && accReLinkObject.Object_API_Name__c != Null && accReLinkObject.Action__c != Null)
            {
                if(accReLinkObject.Fields__c==Null)
                {
                    accReLinkObject.Fields__c=getSobjectFieldList(accReLinkObject.Object_API_Name__c);
                    system.debug('accReLinkObject.Fields__c 1---->'+accReLinkObject.Fields__c);
                }
                system.debug('accReLinkObject.Fields__c----> 2'+accReLinkObject.Fields__c);
                
                // temporary variable in case the object is an Attachment and the field list needs modifying
                // if the current object is not an Attachment, all of the fields will be passed
                String fields=accReLinkObject.Fields__c;
                // if the object is Attachment, do not include the body field (this causes problems in cloning)
                if(accReLinkObject.Object_API_Name__c=='Attachment' && accReLinkObject.Fields__c.toLowerCase().contains('body'))
                {
                    fields=accReLinkObject.Fields__c.replaceAll('[\\, ]*[bB]+[oO]+[dD]+[yY]+','');
                }
                
                // put together query
                String accountChildQuery='' 
                    + 'Select ' + fields + ' '
                    + 'From ' + accReLinkObject.Object_API_Name__c + ' ' 
                    + (accReLinkObject.Conditions_1__c != Null ? accReLinkObject.Conditions_1__c + ' ' : '')
                    + (accReLinkObject.Conditions_2__c != Null ? accReLinkObject.Conditions_2__c + ' ' : '')
                    + '';
                
                // if the query already contains a where clause, add an And clause, if not, add a Where clause
                // to get only the records for the Accounts provided
                accountChildQuery += (accReLinkObject.Conditions_1__c != Null || accountChildQuery.toLowerCase().contains(' Where') ? 
                                      ' And ' : ' Where ') + accReLinkObject.Account_Field__c + ' IN ' + accountIdQueryString;
                
                List<sObject> childObjectsList=database.query(accountChildQuery);
                
                for(sObject ref: childObjectsList)
                {
                    // get the Account Id from the child object
                    Id accountFieldId=Null; 
                    try
                    {
                        accountFieldId=(Id)ref.get(accReLinkObject.Account_Field__c);
                    }
                    catch(Exception ex) {}
                    
                    // if the children type map is not initialized, initialize it
                    if(accountChildrenMap.get(accountFieldId)==Null)
                    {
                        accountChildrenMap.put(accountFieldId, new Map<String, List<sObject>>());
                    }
                    
                    // if the list of child objects is not initialized, initialize it
                    if(accountChildrenMap.get(accountFieldId).get(accReLinkObject.Object_API_Name__c)==Null)
                    {
                        accountChildrenMap.get(accountFieldId).put(accReLinkObject.Object_API_Name__c, new List<sObject>());
                    }
                    
                    accountChildrenMap.get(accountFieldId).get(accReLinkObject.Object_API_Name__c).add(ref);
                }
            }
        }
        
        for(Id accId: accountIds)
        {
            Map<String, List<sObject>> childrenByTypeMap=accountChildrenMap.get(accId);
            
            for(AccountReLinkObject__c accReLinkObject: accReLinkObjects)
            {
                if(childrenByTypeMap != Null)
                {
                    if(childrenByTypeMap.get(accReLinkObject.Object_API_Name__c)==Null)
                    {
                        childrenByTypeMap.put(accReLinkObject.Object_API_Name__c, new List<sObject>());
                    }
                }
            }
        }
        
        // create a new SourceAccount
        List<SourceAccount> sourceAccountsList=new List<SourceAccount>();
        
        // for each Account Id (i) in the Account children map
        for(Id accId : accountChildrenMap.keyset())
        {
            SourceAccount sourceAcc=new SourceAccount();
            
            // set the SourceAccount Account to the queried Account
            sourceAcc.sAccount=accountsMap.get(accId); 
            sourceAcc.sChildObjects=new Map<String, List<sObject>>();
            
            //system.debug(s);
            
            Map<String, List<sObject>> childObjectsMap=accountChildrenMap.get(accId);
            
            // Map of Children by type (API Name) Map<String, List<sObject>>
            if(childObjectsMap != Null)
            {
                //system.debug(childObjectsMap);
                sourceAcc.sChildObjects=childObjectsMap;
            }
            
            //for(String ObjectType : sourceAcc.sChildObjects.keyset()) {
            //  system.debug(ObjectType+': '+sourceAcc.sChildObjects.get(ObjectType));}
            
            sourceAccountsList.add(sourceAcc);
        }
        
        system.debug('End querySourceAccounts---->');
        return sourceAccountsList;
    }
    
    //2016-02-18- anirudh.singh@cdk.com- Made this method private from public as it is not accessed outside this class.
    //This method returns a comma separated field list for a specific object.
    //This method is invoked from querySourceAccounts method.
    private static String getSobjectFieldList(String objectName)
    {
        system.debug('Start getSobjectFieldList---->');
        String fields='';
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fieldMap=Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().fields.getMap();
        List<string> fieldList=new list<string>();
        
        if (fieldMap != Null)
        {
            // loop through all fields (f)
            for (Schema.SObjectField field: fieldMap.values())
            {
                // describe each field (fd).
                Schema.DescribeFieldResult fieldResult=field.getDescribe();
                
                // field can be set on create by the current User
                if (fieldResult.isCreateable())
                {
                    fieldList.add(fieldResult.getName());
                }
            }
        }
        
        if(!fieldList.isEmpty())
        {
            for(String field: fieldList)
            {
                fields += field + ',';
            }
            
            if(fields.endsWith(','))
            {
                fields=fields.substring(0, fields.lastIndexOf(','));
            }
        }
        
        system.debug('End getSobjectFieldList---->'+fields);
        return fields;
    }
    
    //This method is invoked from Batch Class.
    public static List<sObject> queryAndUpdate(Set<Id> objectIds, Map<Id, Id> replacementOwnersMap, String objectType, String fields, String accountField, ID newAccountId)
    {
        system.debug('Start queryAndUpdate---->');
        if(objectIds==Null)
        {
            return Null;
        }
        
        if(objectIds.isEmpty())
        {
            return Null;
        }
        
        if(objectType==Null)
        {
            return Null;
        }
        
        List<sObject> queriedObjects=Database.query('Select '+fields+' From '+objectType+' Where Id IN :objectIds ');
        
        Map<Id, User> replacementOwnerUsersMap=new Map<Id, User>();
        Map<Id, User> usersMap=new Map<Id, User>([Select Id, IsActive From User Where Id IN :replacementOwnersMap.values()]);
        
        for(Id idRef: replacementOwnersMap.keyset())
        {
            replacementOwnerUsersMap.put( 
                // original object id, queried User record
                // get the user by Id from the replacementOwnersMap map
                idRef, usersMap.get(replacementOwnersMap.get(idRef)) 
            );
        }
        
        system.debug('End queryAndUpdate---->');
        return updateAccountIds(queriedObjects, replacementOwnerUsersMap, accountField, newAccountId);
    }
    
    //2016-02-18- anirudh.singh@cdk.com- Made this method private from public as it is not accessed outside this class.
    //This method is invoked from queryAndUpdate method.
    private static List<sObject> updateAccountIds(List<sObject> objects, Map<Id, User> replacementOwnerUsersMap, String accountField, ID newAccountId)
    {
        system.debug('Start updateAccountIds---->');
        if(objects==Null)
        {
            return new List<sObject>();
        }
        
        if(objects.isEmpty())
        {
            return new List<sObject>();
        }
        
        List<sObject> validSObjectsList=new List<sObject>();
        
        for(sObject sObj: objects)
        {
            Boolean isValid=false;
            
            // check and update Account field
            String accField=Null; 
            try
            {
                accField=(String)sObj.get(accountField);
            }
            catch (Exception e1) {system.debug(e1);}
            
            if(accField != Null)
            {
                sObj.put(accountField, newAccountId);
            }
            
            // check Owner
            Id ownerId=Null;
            sObject owner=Null;
            
            if(replacementOwnerUsersMap.get(sObj.Id) != Null)
            {
                // get the replacement.
                owner=replacementOwnerUsersMap.get(sObj.Id);
                
                if(owner.get('IsActive') != false || owner.get('IsActive')==Null)
                {
                    ownerId=owner.Id;
                    sObj.put('OwnerId', owner.Id);
                }
            }
            else
            {
                try
                {
                    ownerId=(ID)sObj.get('OwnerId');
                }
                catch (Exception e2) {system.debug(e2);}
                
                try
                {
                    owner=sObj.getSObject('Owner');
                }
                catch (Exception e3) {system.debug(e3);}
            }
            
            // if Owner field was not found
            if(ownerId==Null)
            {
                isValid=true;
            }
            else // if Owner field was found
            {
                // if there is no Owner, valid
                if(owner==Null)
                {
                    isValid=true;
                }
                else
                {
                    // if there is an Owner, add to valid list if Owner is active
                    if(owner.get('IsActive') != false || owner.get('IsActive')==Null)
                    {
                        isValid=true;
                    }
                }
            }
            
            if(isValid)
            {
                validSObjectsList.add(sObj);
            }
        }
        
        system.debug('End updateAccountIds---->');
        return validSObjectsList;
    }
    
    //This method is invoked from the Batch Class.
    public static Map<Id, sObject> queryAndClone(Set<Id> objectIds, Map<Id, Id> replacementOwnersMap, String objectType, String fields, String accountField, ID newAccountId)
    {
        system.debug('Start queryAndClone---->');
        if(objectIds==Null)
        {
            return Null;
        }
        
        if(objectIds.isEmpty())
        {
            return Null;
        }
        
        if(objectType==Null)
        {
            return Null;
        }
        
        if(objectType=='Launch__c')
        {
            fields += ',OwnerId,RecordType.Name ';
        }
        
        List<sObject> queriedObjects= Database.query('Select '+fields+' From '+objectType+' Where Id IN :objectIds ');
        
        Map<Id, User> replacementOwnerUsersMap=new Map<Id, User>();
        Map<Id, User> usersMap=new Map<Id, User>([Select Id, IsActive From User Where Id IN :replacementOwnersMap.values()]);
        
        for(Id idRef : replacementOwnersMap.keyset())
        {
            replacementOwnerUsersMap.put( 
                // original object id, queried User record
                // get the user by Id from the replacementOwnersMap map
                idRef, usersMap.get(replacementOwnersMap.get(idRef)) 
            ); 
        }
        
        system.debug('End queryAndClone---->');
        return clone(queriedObjects, replacementOwnerUsersMap, accountField, newAccountId);
    }
    
    //2016-02-18- anirudh.singh@cdk.com- Made this method private from public as it is not accessed outside this class.
    //This method is invoked from queryAndClone method.
    private static Map<Id, sObject> clone(List<sObject> objects, Map<Id, User> replacementOwnerUsersMap, String accountField, ID newAccountId)
    {
        system.debug('Start clone---->');
        if(objects==Null)
        {
            return new Map<Id,sObject>();
        }
        
        if(objects.isEmpty())
        {
            return new Map<Id,sObject>();
        }
        
        //Map of the original Id and the new Object.
        Map<Id, sObject> newObjects=new Map<Id, sObject>();
        
        for(sObject sObj: objects)
        {
            Id originalId=sObj.Id;
            Boolean isValid=false;
            
            // clone: PreserveID? false, IsDeepClone? true, PreserveTimestamps? true, PreserveAutoNumber? true
            sObject sObjClone=sObj.clone(false, true, true, true); 
            
            // add a prefix to the Description if the sObject is an Attachment
            if(sObjClone.getSObjectType()==Attachment.sObjectType) 
            {
                try 
                {
                    String description=(String)sObjClone.get('Description');
                    String xferDescription='XFER' + (description != Null ? ': ' + description : '');
                    sObjClone.put('Description', xferDescription);
                    system.debug(xferDescription); 
                } 
                catch(Exception ex) {system.debug(ex);}
            }
            
            // add a prefix to the Title if the sObject is a Note
            if(sObjClone.getSObjectType()==Note.sObjectType) 
            {
                try
                {
                    sObjClone.put('Title','XFER: ' + sObjClone.get('Title'));
                } 
                catch(Exception ex) {system.debug(ex);}
            }
            
            // put the new Account Id
            String accField=Null;
            try
            {
                accField=(String)sObjClone.get(accountField);
            }
            catch(Exception ex) {}
            
            if(accField != Null)
            {
                sObjClone.put(accountField, newAccountId);
            }
            
            // check Owner
            Id ownerId=Null;
            sObject owner=Null;
            
            // set replacement owner if necessary
            if(replacementOwnerUsersMap.get(sObj.Id) != Null)
            {
                owner=replacementOwnerUsersMap.get(sObj.Id); // get the replacement
                if(owner.get('IsActive') != false || owner.get('IsActive')==Null)
                {
                    ownerId=owner.Id;
                    sObjClone.put('OwnerId', owner.Id);
                }
            }
            else
            {
                try
                {
                    ownerId=(ID)sObjClone.get('OwnerId');
                }
                catch (Exception e2) {system.debug(e2);}
                
                try
                {
                    owner=sObjClone.getSObject('Owner');
                }
                catch (Exception e3) {system.debug(e3);}
            }
            
            // if Owner field was not found
            if(ownerId==Null)
            {
                isValid=true;
            }
            else // if Owner field was found
            {
                // if the Owner could not be retrieved
                // if there is no Owner, valid
                if(owner==Null)
                {
                    isValid=true;
                } 
                else // if the Owner could be retrieved 
                {
                    // check the Owner status
                    // if there is an Owner, add to valid list if Owner is active
                    if(owner.get('IsActive') != false || owner.get('IsActive')==Null)
                    {
                        isValid=true;
                    }
                }
            }
            
            if(isValid)
            {
                newObjects.put(originalId, sObjClone);
            }
        }
        
        system.debug('End clone---->');
        return newObjects;
    }
    
    //This method is invoked from Visualforce Page to Submit ReLink.
    @RemoteAction
    public static Id submitReLink(Id reLinkId)
    {
        system.debug('Start submitReLink---->');
        DSCB_AccountReLink_Batch batch=new DSCB_AccountReLink_Batch();
        batch.conditions += ' And Id=\''+reLinkId+'\' ';
        Id batchId=Database.executeBatch(batch, 1);
        
        system.debug('End submitReLink---->');
        //return '707Q0000003IMv4'; // hard coded Id for testing in Training.
        return batchId;
    }
    
    //This method is invoked from Visualforce Page to Check Single ReLink Status.
    @RemoteAction
    public static List<AsyncApexJob> checkReLinkStatus(ID batchId)
    {
        system.debug('checkReLinkStatus---->');
        return [
            SELECT Id, Status, ExtendedStatus, TotalJobItems, JobItemsProcessed, NumberOfErrors, 
            CompletedDate, ApexClassId, MethodName, CreatedDate 
            FROM AsyncApexJob 
            WHERE Id=:batchId 
            Order By CreatedDate DESC
        ];
    }
    
    public class Result
    {
        //2016-02-23- anirudh.singh@cdk.com- Commented the below variable as it was not used anywhere.
        //public Boolean success;
        public String message;
        public String processingLog;
        
        public Map<String, sObject> ObjectMap=new Map<String, sObject>();
        
        public Result()
        {
            //2016-02-23- anirudh.singh@cdk.com- Commented the below variable as it was not used anywhere.
            //success=false;
            message='';
        }
    }
    
    public class SourceAccount
    {
        public Account sAccount;
        public Map<String, List<sObject>> sChildObjects;
    }
    
    //2016-01-28- anirudh.singh@cdk.com- Commented this method as it was not being used anywhere.
    /*public static List<Account> QueryDestinationAccounts(Set<Id> AccountIds)
    {
        system.debug('Start QueryDestinationAccounts---->');
        String accountIdQueryString='(';
        for(Id i : AccountIds) {accountIdQueryString += '\'' + String.valueOf(i) + '\',';}
        if (accountIdQueryString.endsWith(',')){accountIdQueryString=accountIdQueryString.substring(0, accountIdQueryString.lastIndexOf(','));}
        accountIdQueryString += ')';
        
        String AccountQuery=''
            + 'Select Id, Name ' 
            + ',Account_Number__c ' // Digital Solutions Account Number
            + ',Decision_Making_Model__c ' // Decision Making Model
            + ',MDA__c ' // MDA 
            + ',Dealership_Health__c ' // Dealership Help 
            + ',Core_Utility__c ' // Core Utility
            + ',Operational_Efficiency__c ' // Operational Efficiency
            + ',Financial_Performance__c ' // Financial Performance
            + ',COF_Summary__c ' // COF Summary
            + ',Cobalt_Strategy__c ' // Cobalt Strategy
            + ',Do_Not_Sell__c ' // In Digital Solutions Collections
            + ',Status__c ' // Status
            + ',Critical_Note__c ' // Critical Note
            + ',OEM__c ' // OEM
            + ',Make__c ' // Make
            + ',Org_Key__c ' // Org Key
            + ',Nitra_Date__c ' // Nitra Date
            + ',LDP__c ' // LDP 
            + ',VIP__c ' // VIP 
            + ',CBLTAccountName__c ' // Digital Solutions Account Name
            + ',CBLTShipStreet__c ' // Digital Solutions Shipping Street
            + ',CBLTShipCity__c ' // Digital Solutions Shipping City
            + ',CBLTState__c ' // Digital Solutions Shipping State
            + ',CBLTZip__c ' // Digital Solutions Shipping Zip
            + ',CBLTShipCountry__c ' // Digital Solutions Shipping Country
            + ',CBLTBillStreet__c ' // Digital Solutions Shipping Street
            + ',CBLTBillCity__c ' // Digital Solutions Shipping City
            + ',CBLTBillState__c ' // Digital Solutions Shipping State
            + ',CBLTBillZip__c ' // Digital Solutions Shipping Zip
            + ',CBLTBillCountry__c ' // Digital Solutions Shipping Country
            + ',CBLTPhone__c ' // Digital Solutions Phone
            + ',CBLTFax__c ' // Digital Solutions Fax
            + ',Collector__c ' // Collector
            + ',Designated_DSM__c ' // Designated DSM
            + 'From Account ' 
            + (AccountIds != Null ? 'Where Id IN ' + accountIdQueryString + ' ' : '')
            + '';
        
        system.debug(AccountQuery);
        return database.query(AccountQuery);
    }*/
}