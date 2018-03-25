//2016-01-27- anirudh.singh@cdk.com- Commented this class for Request RQ-06021, as the name is not as per standards.
//2016-01-27- anirudh.singh@cdk.com- A new handler class with the name DSCB_AccountReLink_Handler has been created.
/* ADP Dealer Services - Sales Automation
 * Programmer: Matt Keefe(matt_keefe@adp.com, 847.485.4849)
 * Project: Dealer Services and Cobalt Account Re-link
 * 
 * Short Description: This class contains the utility methods for the Account ReLink batch class and page.
 * 
 * Project Description: Occasionally, child records need to be moved from one Account to another.
 *   Accounts are matched after an Account ReLink record is saved, when the trigger executes, according to
 *   the Cobalt Account Number(source) and the Party ID(destination) - note: this is not the Party Number. 
 *   Once Accounts are matched, a nightly batch process(running as Admin - because specific workflow and 
 *   validation rules are ignored when the code is executed by the Admin User) processes the child records 
 *   of the source Account, moving them to the destination Account. Once all of the child records are moved, 
 *   data from specific fields(Cobalt Account number and related fields) on the source Account is moved to 
 *   the destination Account and deleted from the source Account.
 *   
 * Project Components:
 *   DSCB_AccountReLink.cls
 *   DSCB_AccountReLinkBatch.cls
 *   DSCB_AccountReLinkTest.cls
 *   DSCB_AccountReLink.trigger
 *   DSCB_AccountReLink.page
 *   jQuery.resource
 * 
 * Object Types

	 -01- ALL  ~ WebId Records
	 -02- RULE ~ Contact Records: External ID != null || CreatedDate > 2/18/2012
	 -03- ALL  ~ Launch Records
	 -04- ALL  ~ Site Config Records
	 -05- ALL  ~ Monthly Maintenance Records
	        
	 -06- RULE ~ Opportunities: if Record Type IN (Pipeline, BZ Migration)
	 -07- RULE ~ Leads: if Record Type IN (Digital Solutions Created, Digital Marketing Created)
	 -08- ALL  ~ Cases (Name=Subject)
	 -09- RULE ~ Events: if Record Type IN (Digital Solutions Event)
	 -10- RULE ~ Tasks: if Record Type IN 
	             (AA Tasks, AA/OMS Tasks, Dealer Services, EMS Tasks, Finance Tasks, 
	                 IFS Tasks, OMS Tasks, RMS Tasks, SEO Tasks, Service Tasks, Social Consultant Task, Social Media Task)
	             || (CreatedBy.Name starts with CB or Cobalt)
	 -11- RULE ~ Attachments: if Cobalt Consolidation ID != null || (CreatedBy.Name starts with CB or Cobalt && CreatedDate > 2/18/2012)
	 -12- RULE ~ Notes: if Cobalt Consolidation ID != null || (CreatedBy.Name starts with CB or Cobalt && CreatedDate > 2/18/2012)
	 -13- RULE ~ Campaign Account Members: if Campaign owned by Camela Thompson
	 -14- ALL  ~ Business Sites
	 -15- ALL  ~ Service Contracts
	 -16- ALL  ~ WIP
	 -17- ALL  ~ Installed Bases
	 -??- ALL  ~ Installed Base Components
	 -18- ALL  ~ Contact Report Assignments
	 -19- ALL  ~ Email Collections
	 -20- RULE ~ Account Fields: specified fields
 
 * Execute batch test code:

    List<Account_ReLink__c> arls = [Select Id, Name, Cobalt_Account__c, Party_Account__c From Account_ReLink__c];
    DSCB_AccountReLinkBatch arl = new DSCB_AccountReLinkBatch();
    arl.ex(arls);

 * Test Replacement Account:

	List<sObject> l = DSCB_AccountReLink.QueryAndUpdate(
		new Set<Id>{'a1AV00000007qBgMAI'},
		new Map<Id,Id>{'a1AV00000007qBgMAI'=>'00540000000zU2K'},
		'Monthly_Maintenance__c', 
		DSCB_AccountReLink.GetSobjectFieldList('Monthly_Maintenance__c'), 
		'Account__c',
		'0014000000Jw2uV');
	system.debug(l);

 */

//2015-12-03- anirudh.singh@cdk.com- Modified the API Version from 25.0 to 34.0. Corrected the indetation.

public class DSCB_AccountReLink
{
    /*
    // custom settings and variables
    
    public static List<AccountReLinkObject__c> rlObjects = AccountReLinkObject__c.getall().values();
    
    public class Result
    {
        public Boolean Success;
        public String Message;
        public String ProcessingLog;
        
        public Map<String,sObject> ObjectMap = new Map<String,sObject>();
        
        public Result()
        {
            Success=false;
            Message='';
        }
    }
    
    public class SourceAccount
    {
        public Account sAccount;
        public Map<String,List<sObject>> sChildObjects;
    }
    
    // constructor
    
    public DSCB_AccountReLink()
    {
        if(rlObjects == null)
        {
            rlObjects = new List<AccountReLinkObject__c>();
        }
    }
    
    // Visualforce actions
    
    //
    //  Submit single ReLink 
    //
    @RemoteAction
    public static Id SubmitReLink(ID ReLinkID)
    {
        DSCB_AccountReLinkBatch Batch = new DSCB_AccountReLinkBatch();
        Batch.conditions += ' And Id = \''+ReLinkId+'\' ';
        Id BatchId = Database.executeBatch(Batch,1);
        
        return BatchId; //return '707Q0000003IMv4'; // hard coded Id for testing in Training
    }
    
    //
    //  Check Single ReLink Status 
    //
    @RemoteAction
    public static List<AsyncApexJob> CheckReLinkStatus(ID BatchId)
    {
        return [SELECT Id, Status, ExtendedStatus, TotalJobItems, JobItemsProcessed, NumberOfErrors, 
                CompletedDate, ApexClassId, MethodName, CreatedDate FROM AsyncApexJob WHERE Id=:BatchId 
                Order By CreatedDate DESC];
    }
    
    // methods
    
    //
    //  Process ReLinks into ReLink Detail Records
    //
    public static Result ProcessRelinks(List<Account_ReLink__c> relinks)
    {
        //system.debug(relinks);
        
        Result arlResult = new Result();
        arlResult.ProcessingLog = '';
        if(rlObjects == null)
        {
            rlObjects = new List<AccountReLinkObject__c>();
        }
        
        List<AccountReLinkObject__c> ObjectsToProcess = new List<AccountReLinkObject__c>();
        
        for(AccountReLinkObject__c o : rlObjects)
        {
            if(o.Account_Relationship_Name__c != null)
            {
                ObjectsToProcess.add(o);
            }
        }
        
        system.debug(ObjectsToProcess);
        
        List<Account_ReLink_Detail__c> DetailsToInsert = new List<Account_ReLink_Detail__c>();
        List<Account_ReLink_Detail__c> DetailsToUpdate = new List<Account_ReLink_Detail__c>();
        Map<Id,Account_ReLink_Detail__c> ExistingDetails = new Map<Id,Account_ReLink_Detail__c>();
        
        Set<Id> ReLinkIds = new Set<Id>();
        Map<Id,Id> SourceAccountIds = new Map<Id,Id>(); // ReLink Ids by Cobalt Account Ids
        Map<Id,Id> DestinationAccountIds = new Map<Id,Id>(); // ReLink Ids by Party Account Ids
        Map<Id,DateTime> ReLinkCreatedDates = new Map<Id,DateTime>(); // ReLink CreatedDates by ReLink Ids
        
        for(Account_ReLink__c rl : relinks)
        {
            ReLinkIds.add(rl.Id);
            
            if(rl.Cobalt_Account__c != null) {
                SourceAccountIds.put(rl.Cobalt_Account__c,rl.Id); 
                ReLinkCreatedDates.put(rl.Id,rl.CreatedDate);
            }
            
            if(rl.Party_Account__c != null) {DestinationAccountIds.put(rl.Party_Account__c,rl.Id);}
        }
        
        List<Account_ReLink_Detail__c> ds = [
            Select Id, Name, Object_Id__c, Account_ReLink__c 
            From Account_ReLink_Detail__c 
            Where Account_ReLink__c IN :ReLinkIds];
        
        for(Account_ReLink_Detail__c d : ds) {ExistingDetails.put(d.Object_Id__c,d);}
        
        system.debug(SourceAccountIds);
        system.debug(DestinationAccountIds);
        
        List<SourceAccount> SourceAccounts = DSCB_AccountReLink.QuerySourceAccounts(SourceAccountIds.keyset());
        List<Account> DestinationAccounts = DSCB_AccountReLink.QueryDestinationAccounts(DestinationAccountIds.keyset());
        
        for(SourceAccount a : SourceAccounts)
        {
            Id SourceReLinkID = SourceAccountIds.get(a.sAccount.Id); // get the ReLink Id for the current source Account
            
            List<sObject> CurrentObjects;
            
            // un-necessary due to removal of Days Since ReLink Created
            //DateTime rlCreatedDate = ReLinkCreatedDates.get(SourceReLinkID);
            //Integer DaysSinceReLinkCreated = rlCreatedDate != null ? rlCreatedDate.Date().daysBetween(Date.Today()) : 0;
            //DaysSinceReLinkCreated++; // need to add one because this is used in multiplication 
            
            for(AccountReLinkObject__c o : ObjectsToProcess)
            {
                String n = o.Object_API_Name__c;
                
                CurrentObjects = null;
                CurrentObjects = a.sChildObjects.get(n); // get all child objects for the Account by type (Api Name)
                
                if(CurrentObjects != null)
                {
                    if(!CurrentObjects.IsEmpty())
                    {
                        Integer c = 0;
                        
                        for(sObject s : CurrentObjects)
                        {
                            String sType = String.valueOf(s.getsObjectType());
                            
                            system.debug(LOGGINGLEVEL.WARN,c);
                            system.debug(LOGGINGLEVEL.WARN,sType);
                            
                            Id OwnerId = null;
                            sObject Owner = null;
                            Boolean OwnerIsActive = null;
                            String OwnerName = null;
                            
                            Account_ReLink_Detail__c ExistingDetail = ExistingDetails.get(s.Id);
                            Boolean PreExisting = true;
                            
                            // if an existing detail record with this sObject Id was found, 
                            //   check to see if the ReLink Id matches
                            if(ExistingDetail != null) {
                                // if it does not match, mark it as not pre-existing
                                if(ExistingDetail.Account_ReLink__c != SourceReLinkID) {
                                    PreExisting = false;
                                }
                                // if no detail record was found, mark it as not pre-existing
                            } else {PreExisting = false;}
                            
                            //system.debug(ExistingDetail);
                            //system.debug(SourceReLinkID);
                            //system.debug(PreExisting);
                            
                            try {OwnerId = (ID)s.get('OwnerId');} catch (Exception e) {}
                            
                            if(OwnerId != null) {
                                try {
                                    Owner = s.getSObject('Owner'); 
                                    OwnerIsActive = Boolean.valueOf(Owner.get('IsActive'));
                                    OwnerName = String.valueOf(Owner.get('Name'));}
                                catch (Exception e) {system.debug(e);}
                            }
                            
                            if(!PreExisting)
                            {
                                system.debug('Not PreExisting...');
                                
                                //system.debug(LOGGINGLEVEL.WARN, c);
                                //system.debug(LOGGINGLEVEL.WARN, o.Limit_Per_Day__c);
                                //system.debug(LOGGINGLEVEL.WARN, DaysSinceReLinkCreated);
                                //system.debug(LOGGINGLEVEL.WARN, 
                                //	'Total Objects for this Type to process: ' 
                                //		+ ((o.Limit_Per_Day__c==null?0:o.Limit_Per_Day__c)*DaysSinceReLinkCreated));
                                
                                // DaysSinceReLinkCreated was multiplied by Limit Per Day, but because success records
                                // are not counted, it was un-necessary. Without it, regardless of the number of success records,
                                // only the Limit Per Day number of records would be added on that nightly batch.
                                //if(o.Limit_Per_Day__c == null || o.Limit_Per_Day__c == 0 || c < (o.Limit_Per_Day__c)) //*DaysSinceReLinkCreated
                                //{
                                DetailsToInsert.add(new Account_ReLink_Detail__c(
                                    Object_ID__c = s.Id
                                    ,Object_Type__c = String.valueOf(s.getSObjectType())
                                    ,Owner__c = (OwnerId != null ? OwnerId : null)
                                    ,Owner_Name__c = (OwnerName != null ? OwnerName : null)
                                    ,Owner_Status__c = (OwnerIsActive != null ? 
                                                        (OwnerIsActive ? 'Active' : 'Inactive') : '')
                                    ,Detail_Status__c = 'Pending'
                                    ,Account_ReLink__c = SourceAccountIds.get(a.sAccount.Id)
                                ));
                                
                                //c++; // yay c++! Increment the counter to check how many objects have been processed
                                //}
                            }
                            else
                            {
                                if(ExistingDetail != null) 
                                {
                                    if(ExistingDetail.Object_ID__c == s.Id)
                                    {
                                        ExistingDetail.Object_Type__c = String.valueOf(s.getSObjectType());
                                        ExistingDetail.Owner__c = (OwnerId != null ? OwnerId : null);
                                        ExistingDetail.Owner_Status__c = (OwnerIsActive != null ? 
                                                                          (OwnerIsActive ? 'Active' : 'Inactive') : '');
                                        ExistingDetail.Owner_Name__c = (OwnerName != null ? OwnerName : null);
                                        ExistingDetail.Detail_Status__c = 'Pending';
                                        ExistingDetail.Detail_Message__c = null;
                                        DetailsToUpdate.add(ExistingDetail);
                                    } // end if object id equals s id
                                } // end if existing detail not null
                            } // end else (pre-existing)
                        } // end for current objects
                    } // end if current objects empty
                } // end if current objects null
            } // end for object names
        } // end for accounts
        
        try 
        {
            system.debug('                                                                                   Details to Insert');
            system.debug(DetailsToInsert);
            insert DetailsToInsert;
            
            system.debug('                                                                                   Details to Update');
            system.debug(DetailsToInsert);
            update DetailsToUpdate;
            
        } catch (Exception ex) {system.debug(ex.getMessage());}
        
        return arlResult;
    }
    
    public static List<SourceAccount> QuerySourceAccounts(Set<Id> AccountIds)
    {
        system.debug(AccountIds);
        
        // prevent null exception by creating a placeholder list if the Account ReLink settings do not exist
        if(rlObjects == null) {rlObjects = new List<AccountReLinkObject__c>();}
        
        // convert set to string for query
        String AccountIdQueryString = '(';
        for(Id i : AccountIds) {AccountIdQueryString += '\'' + String.valueOf(i) + '\',';}
        if (AccountIdQueryString.endsWith(',')){AccountIdQueryString = AccountIdQueryString.substring(0,AccountIdQueryString.lastIndexOf(','));}
        AccountIdQueryString += ')';
        
        // For querying in the Schema Explorer or Force.com Explorer, use //(.*)$ regex, replace with blank
        String AccountQuery = ''
            + 'Select Id, Name '; 
        
        AccountQuery += ''  
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
            + (AccountIds != null ? 'Where Id IN ' + AccountIdQueryString + ' ' : '')
            + '';
        
        Map<Id,Account> Accounts = new Map<Id,Account>((List<Account>)database.query(AccountQuery)); // Accounts by Id
        Map<Id,Map<String,List<sObject>>> AccountChildren = new Map<Id,Map<String,List<sObject>>>(); // Account Id, children (List<sObject>) by type (string)
        
        // loop through all ReLink object settings
        for(AccountReLinkObject__c o : rlObjects)
        {
            // if ReLink object setting is valid
            if(o.Account_Relationship_Name__c != null && o.Object_API_Name__c != null && o.Action__c != null)
            {
                if(o.Fields__c == null) {o.Fields__c = DSCB_AccountReLink.GetSobjectFieldList(o.Object_API_Name__c);}
                
                // temporary variable in case the object is an Attachment and the field list needs modifying
                String Fields = o.Fields__c; // if the current object is not an Attachment, all of the fields will be passed
                
                // if the object is Attachment, do not include the body field (this causes problems in cloning)
                if(o.Object_API_Name__c == 'Attachment' && o.Fields__c.toLowerCase().contains('body')) {
                    Fields = o.Fields__c.replaceAll('[\\, ]*[bB]+[oO]+[dD]+[yY]+','');}
                
                // put together query
                String AccountChildQuery = '' 
                    + 'Select ' + Fields + ' '
                    + 'From ' + o.Object_API_Name__c + ' ' 
                    + (o.Conditions_1__c != null ? o.Conditions_1__c + ' ' : '')
                    + (o.Conditions_2__c != null ? o.Conditions_2__c + ' ' : '')
                    + '';
                
                // if the query already contains a where clause, add an And clause, if not, add a Where clause
                // to get only the records for the Accounts provided
                AccountChildQuery += (o.Conditions_1__c != null || AccountChildQuery.toLowerCase().contains(' Where') ? 
                                      ' And ' : ' Where ') + o.Account_Field__c + ' IN ' + AccountIdQueryString;
                
                system.debug(AccountChildQuery);
                
                List<sObject> ChildObjects = database.query(AccountChildQuery);
                
                for(sObject s : ChildObjects)
                {
                    // get the Account Id from the child object
                    Id AccountFieldId = null; 
                    try {AccountFieldId = (Id)s.get(o.Account_Field__c);}
                    catch(Exception ex) {}
                    
                    // if the children type map is not initialized, initialize it
                    if(AccountChildren.get(AccountFieldId) == null) {
                        AccountChildren.put(AccountFieldId, new Map<String,List<sObject>>());}
                    
                    // if the list of child objects is not initialized, initialize it
                    if(AccountChildren.get(AccountFieldId).get(o.Object_API_Name__c) == null) {
                        AccountChildren.get(AccountFieldId).put(o.Object_API_Name__c,new List<sObject>());}
                    
                    AccountChildren.get(AccountFieldId).get(o.Object_API_Name__c).add(s);
                }
            }
        }
        
        for(Id i : AccountIds)
        {
            Map<String,List<sObject>> ChildrenByType = AccountChildren.get(i);
            for(AccountReLinkObject__c o : rlObjects) {
                system.debug(ChildrenByType);
                if(ChildrenByType != null) {
                    if(ChildrenByType.get(o.Object_API_Name__c) == null) {
                        ChildrenByType.put(o.Object_API_Name__c, new List<sObject>());}
                }
            }
        }
        
        // create a new SourceAccount
        List<SourceAccount> SourceAccounts = new List<SourceAccount>();
        
        // for each Account Id (i) in the Account children map
        for(Id i : AccountChildren.keyset())
        {
            SourceAccount s = new SourceAccount();
            
            // set the SourceAccount Account to the queried Account
            s.sAccount = Accounts.get(i); 
            s.sChildObjects = new Map<String,List<sObject>>();
            
            //system.debug(s);
            
            Map<String,List<sObject>> ChildObjects = AccountChildren.get(i);
            
            // Map of Children by type (API Name) Map<String,List<sObject>>
            if(ChildObjects != null)
            {
                //system.debug(ChildObjects);
                s.sChildObjects = ChildObjects;
            }
            
            //for(String ObjectType : s.sChildObjects.keyset()) {
            //	system.debug(ObjectType+': '+s.sChildObjects.get(ObjectType));}
            
            SourceAccounts.add(s);
        }
        
        return SourceAccounts;
    }
    
    public static List<Account> QueryDestinationAccounts(Set<Id> AccountIds)
    {
        String AccountIdQueryString = '(';
        for(Id i : AccountIds) {AccountIdQueryString += '\'' + String.valueOf(i) + '\',';}
        if (AccountIdQueryString.endsWith(',')){AccountIdQueryString = AccountIdQueryString.substring(0,AccountIdQueryString.lastIndexOf(','));}
        AccountIdQueryString += ')';
        
        String AccountQuery = ''
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
            + (AccountIds != null ? 'Where Id IN ' + AccountIdQueryString + ' ' : '')
            + '';
        
        system.debug(AccountQuery);
        return database.query(AccountQuery);
    }
    
    //
    // Set Account Id and Update
    //
    public static List<sObject> UpdateAccountIds(List<sObject> objects, Map<Id,User> ReplacementOwnerUsers, String AccountField, ID NewAccountId)
    {
        if(objects == null) {return new List<sObject>();}
        if(objects.isEmpty()) {return new List<sObject>();}
        
        system.debug('-- Update -- '+objects[0].getSObjectType()+' --');
        
        List<sObject> ValidSObjects = new List<sObject>();
        
        for(sObject s : objects)
        {
            Boolean IsValid = false;
            
            system.debug('before: '+s);
            
            // check and update Account field
            String af = null; 
            try {af = (String)s.get(AccountField);} catch (Exception e1) {system.debug(e1);}
            if(af != null) {s.put(AccountField,NewAccountId);}
            
            // check Owner
            Id OwnerId = null;
            sObject Owner = null;
            
            if(ReplacementOwnerUsers.get(s.Id) != null) {
                Owner = ReplacementOwnerUsers.get(s.Id); // get the replacement
                if(Owner.get('IsActive') != false || Owner.get('IsActive') == null) {OwnerId = Owner.Id; s.put('OwnerId',Owner.Id);}
            }
            else {
                try {OwnerId = (ID)s.get('OwnerId');} catch (Exception e2) {system.debug(e2);}
                try {Owner = s.getSObject('Owner');} catch (Exception e3) {system.debug(e3);}
            }
            
            if(OwnerId == null) {IsValid = true;} // if Owner field was not found
            else // if Owner field was found
            {
                if(Owner == null) {IsValid = true;} // if there is no Owner, valid
                else
                {
                    // if there is an Owner, add to valid list if Owner is active
                    if(Owner.get('IsActive') != false || Owner.get('IsActive') == null) {IsValid = true;}
                }
            }
            
            system.debug('after ('+ (IsValid?'valid':'invalid') +'): '+s);
            
            if(IsValid) {ValidSObjects.add(s);}
        }
        
        return ValidSObjects;
    }
    
    //
    // Clone and Delete
    //
    public static Map<Id,sObject> Clone(List<sObject> objects, Map<Id,User> ReplacementOwnerUsers, String AccountField, ID NewAccountId)
    {
        if(objects == null) {return new Map<Id,sObject>();}
        if(objects.isEmpty()) {return new Map<Id,sObject>();}
        
        system.debug('-- Insert -- '+objects[0].getSObjectType()+' --');
        
        Map<Id,sObject> NewObjects = new Map<Id,sObject>(); // Map of the original Id and the new Object
        
        for(sObject s : objects)
        {
            Id OriginalId = s.Id;
            Boolean IsValid = false;
            
            system.debug('before: '+s);
            
            // clone: PreserveID? false, IsDeepClone? true, PreserveTimestamps? true, PreserveAutoNumber? true
            sObject n = s.clone(false,true,true,true); 
            
            // add a prefix to the Description if the sObject is an Attachment
            if(n.getSObjectType() == Attachment.sObjectType) 
            {
                system.debug('Attachment');
                
                try 
                {
                    String Description = (String)n.get('Description');
                    String XferDescription = 'XFER' + (Description != null ? ': ' + Description : '');
                    n.put('Description', XferDescription); system.debug(XferDescription); 
                } 
                catch(Exception ex) {system.debug(ex);}
            }
            
            // add a prefix to the Title if the sObject is a Note
            if(n.getSObjectType() == Note.sObjectType) 
            {
                try {n.put('Title','XFER: ' + n.get('Title'));} 
                catch(Exception ex) {system.debug(ex);}
            }
            
            // put the new Account Id
            String af = null;
            try {af = (String)n.get(AccountField);} catch(Exception ex) {}
            if(af != null) {n.put(AccountField,NewAccountId);}
            
            // check Owner
            Id OwnerId = null;
            sObject Owner = null;
            
            // set replacement owner if necessary
            if(ReplacementOwnerUsers.get(s.Id) != null) {
                Owner = ReplacementOwnerUsers.get(s.Id); // get the replacement
                if(Owner.get('IsActive') != false || Owner.get('IsActive') == null) {OwnerId = Owner.Id; n.put('OwnerId',Owner.Id);}
            }
            else {
                try {OwnerId = (ID)n.get('OwnerId');} catch (Exception e2) {system.debug(e2);}
                try {Owner = n.getSObject('Owner');} catch (Exception e3) {system.debug(e3);}
            }
            
            if(OwnerId == null) {IsValid = true;} // if Owner field was not found
            else // if Owner field was found
            {
                // if the Owner could not be retrieved
                if(Owner == null) {IsValid = true;} // if there is no Owner, valid
                else // if the Owner could be retrieved 
                {
                    // check the Owner status
                    // if there is an Owner, add to valid list if Owner is active
                    if(Owner.get('IsActive') != false || Owner.get('IsActive') == null) {IsValid = true;}
                }
            }
            
            system.debug('after ('+ (IsValid?'valid':'invalid') +'): '+s);
            
            if(IsValid) {NewObjects.put(OriginalId,n);}
        }
        
        system.debug(NewObjects);
        return NewObjects;
    }
    
    //
    // Query and Update
    //
    public static List<sObject> QueryAndUpdate(Set<Id> ObjectIds, Map<Id,Id> ReplacementOwners, String ObjectType, String Fields, String AccountField, ID NewAccountId)
    {
        if(ObjectIds == null) {return null;}
        if(ObjectIds.isEmpty()) {return null;}
        if(ObjectType == null) {return null;}
        
        List<sObject> QueriedObjects
            = Database.query('Select '+Fields+' From '+ObjectType+' Where Id IN :ObjectIds ');
        
        Map<Id,User> ReplacementOwnerUsers = new Map<Id,User>();
        Map<Id,User> Users = new Map<Id,User>([Select Id, IsActive From User Where Id IN :ReplacementOwners.values()]);
        for(Id i : ReplacementOwners.keyset()) {
            system.debug(i+': '+Users.get(ReplacementOwners.get(i)));
            ReplacementOwnerUsers.put( 
                // original object id, queried User record
                // get the user by Id from the ReplacementOwners map
                i, Users.get(ReplacementOwners.get(i)) 
            );
        }
        
        return UpdateAccountIds(QueriedObjects, ReplacementOwnerUsers, AccountField, NewAccountId);
    }
    
    //
    // Query and Clone
    //
    public static Map<Id,sObject> QueryAndClone(Set<Id> ObjectIds, Map<Id,Id> ReplacementOwners, String ObjectType, String Fields, String AccountField, ID NewAccountId)
    {
        if(ObjectIds == null) {return null;}
        if(ObjectIds.isEmpty()) {return null;}
        if(ObjectType == null) {return null;}
        
        if(ObjectType == 'Launch__c') {Fields += ',OwnerId,RecordType.Name ';}
        
        List<sObject> QueriedObjects
            = Database.query('Select '+Fields+' From '+ObjectType+' Where Id IN :ObjectIds ');
        
        Map<Id,User> ReplacementOwnerUsers = new Map<Id,User>();
        Map<Id,User> Users = new Map<Id,User>([Select Id, IsActive From User Where Id IN :ReplacementOwners.values()]);
        for(Id i : ReplacementOwners.keyset()) {
            system.debug(i+': '+Users.get(ReplacementOwners.get(i)));
            ReplacementOwnerUsers.put( 
                // original object id, queried User record
                // get the user by Id from the ReplacementOwners map
                i, Users.get(ReplacementOwners.get(i)) 
            ); 
        }
        
        return Clone(QueriedObjects, ReplacementOwnerUsers, AccountField, NewAccountId);
    }
    
    //
    // Return a comma separated field list for a specific object
    //
    public static String GetSobjectFieldList(String ObjectName)
    {
        String Fields = '';
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        List<string> FieldList = new list<string>();
        
        if (fMap != null)
        {
            // loop through all fields (f)
            for (Schema.SObjectField f : fMap.values())
            {
                Schema.DescribeFieldResult fd = f.getDescribe(); // describe each field (fd)
                
                // field can be set on create by the current User
                if (fd.isCreateable()) {FieldList.add(fd.getName());}
            }
        }
        
        if(!FieldList.isEmpty())
        {
            for(string s : FieldList){Fields += s + ',';}
            if(Fields.endsWith(','))
            {
                Fields = Fields.substring(0,Fields.lastIndexOf(','));
            }
        }
        
        return Fields;
    }*/
}