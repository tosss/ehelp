// 03-28-2016  -venkata.shrivol@cdk.com    -Added the code in this trigger for RQ-06546.
//2016-05-20 lalitha.adduru@cdk.com - RQ-06982
//2016-08-02 ragashalini.koka@cdk.com - RQ-07349 Added the delete trigger functionality while merging accounts
//2017-02-27 ragashalini.koka@cdk.com - RQ-08685 Added update functionality to make the CRs inactive if Account is marked as duplicate
trigger ALL_Account on Account (before insert, before update, after insert, after update,before delete, after delete) 
{
    // before insert or update
    // 2016-08-02 ragashalini.koka@cdk.com - RQ-07349 - added check so that it doesn't enter while deleting
    if (Trigger.isBefore && !Trigger.isDelete)
    { 
        // 2016-02-23 - added by lalitha.adduru@cdk.com - RQ-06139
        if(Trigger.isInsert && ALL_CheckRecursive.runCodeBlockOnce('[Account]_BeforeInsert'))
        {
            ALL_Account_Handler.propagateDataRights(Trigger.New, null);
            //2016-11-07 - lalitha.adduru@cdk.com add account team members from CDK DEfault Team whenever account is updated - RQ-08111
        }
        
        if(Trigger.isUpdate && ALL_CheckRecursive.runCodeBlockOnce('[Account]_BeforeUpdate'))
        {
            //2016-11-07 - lalitha.adduru@cdk.com add account team members from CDK DEfault Team whenever account is updated - RQ-08111
            Map<String, List<Account>> recordTypeToRecordList = new Map<String, List<Account>>();
            //system.debug('---->'+ALL_TriggerToggle_Handler.ToggleFilter(Trigger.New));
            recordTypeToRecordList=ALL_TriggerToggle_Handler.ToggleFilter(Trigger.New);
            
            ALL_Account_Handler.updateAccountTeamMembers(recordTypeToRecordList.get('CDK_Default_Team'), Trigger.OldMap);
            
            // 2016-02-21 - added by lalitha.adduru@cdk.com - RQ-06139            
            ALL_Account_Handler.propagateDataRights(Trigger.New, Trigger.OldMap);
        }
        
        // 2016-02-12 - added by lalitha.adduru@cdk.com to verify that BillingState NC and CA have 9D in their dataRightsOptOut Field - RQ-06139
        ALL_Account_Handler.verifyStateToDataRights(trigger.New);
        
        // DS_AccountVIP_Handler
        for(Account newAccount : Trigger.New)
        {
            newAccount.VIP_Reason_Primary_Text__c=String.valueOf(newAccount.VIP_Reason_Primary__c);
            newAccount.VIP_Reason_Secondary_Text__c=String.valueOf(newAccount.VIP_Reason_Secondary__c);  
            
            // DS_AccountDocusign_Handler
            if (newAccount.Signer_1_2_Signer__c!='Contact Specific Signer')
            {
                newAccount.Contact_Specific_Signer_1__c = null;
            }
            
            if (newAccount.Signer_2_2_Signer__c!='Contact Specific Signer')
            {
                newAccount.Contact_Specific_Signer_2__c = null;
            }
        }
    }
    
    // 27th Nov, 2014: Added by Anirudh for populating Account Advocate field on Account.
    // WebId records for an Account can only exist after a Account is already created
    // and Account Advocate field on Account can be populated when it is getting updated.
    if(Trigger.isUpdate)
    {
        // A list of WebId Records for the Updated Account is fetched.
        // Only those records are fetched which have valid Account Advocate field value, 
        //   i.e. Account Advocate field should not be Null.
        List<WebID__c> webIDList = [
            SELECT Account__c, Account_Advocate__c 
            FROM WebID__c 
            WHERE Account_Advocate__c != Null 
            AND Account__c IN :Trigger.New
        ];
        
        // Updated account records are iterated.
        for(Account accountRecord : Trigger.New)
        {
            // If Account Advocate field value is Null on Account record, 
            //   then only it should be populated.
            // Else, further processing should not be done.
            if(accountRecord.Account_Advocate__c == Null)
            {
                // WebId records list is iterated.
                for(WebID__c webIDRecord : webIDList)
                {
                    // If Account Id matches the Account field value on WebID Record,
                    // Account Advocate field on Account is populated with the value 
                    //   present in Account Advocate field value on WebID Record.
                    if(accountRecord.Id == webIDRecord.Account__c)
                    {
                        accountRecord.Account_Advocate__c = webIDRecord.Account_Advocate__c;
                        break;
                    }
                }
            }
        }
    }
    
    // Sanjay added line 89 for update of dealergroups on contact -- RQ-07181
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) // insert also
    {
        if(Trigger.isInsert)
        {
            //2016-11-17 - lalitha.adduru@cdk.com add account team members from CDK DEfault Team whenever account is inserted - RQ-08111
            Map<String, List<Account>> recordTypeToRecordList = ALL_TriggerToggle_Handler.ToggleFilter(Trigger.New);
            system.debug('CDK OEM/Brand records ----> '+recordTypeToRecordList.get('CDK_Default_Team'));
            //system.debug('************************* All Account after insert ************************');
            if(recordTypeToRecordList.get('CDK_Default_Team')!=null)
            {ALL_Account_Handler.populateAccountTeamMembers(recordTypeToRecordList.get('CDK_Default_Team'));}
        }
        if(ALL_CheckRecursive.runCodeBlockOnce('AccountHierarchy20150409') || Test.isRunningTest())
        {
            DS_AccountHierarchyFieldUpdates.AccountHierarchyProcessBeforeFuture(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);  
            //system.debug('$$ inside update');
            ALL_Account_Handler.updateContactDealerGroup(Trigger.new, Trigger.oldMap);
        }
    } 
    
    //Sync contact object
    if (Trigger.isAfter && Trigger.isUpdate)
    { 
        // updates and keeps the mailing address in cotacts in sync with the corresponding accounts billing address
        DS_SyncAccountAddress_Handler.ProcessBeforeFuture(Trigger.newMap, Trigger.oldMap);     
        
        // Updates deal state Account_Key_Rep_Email__c, Key_DOS_Email__c and etc, if same fields on DS opp. account are changed.    
        if(ALL_CheckRecursive.runCodeBlockOnce('ALL_DealState_Handler_AfterUpdate') || Test.isRunningTest())
        {
            DS_DealState_Handler.DealStateEmailUpdateFromAccount(Trigger.newMap, Trigger.oldMap); 
        }
        
        //03-28-2016  -venkata.shrivol@cdk.com    -Added the below code in this trigger for RQ-06546.
        map<Id, string> accountMap = new map<Id,string>();
        for(Account acc:Trigger.new)
        {
            Account accOld = Trigger.oldMap.get(acc.ID);
            if(acc.Region__c!=accOld.Region__c)
            {
                accountMap.put(acc.Id, acc.Region__c);
            }
        }
        if(!accountMap.isEmpty())
        {
            DS_UpdRegionOnDealStateFromAcc_Handler.updateRegionOnDealStates(accountMap);
        }
        ALL_Account_Handler.inactivateCROfDuplicateAccounts(Trigger.oldMap, Trigger.new);
    }    
    // 2016-08-02 ragashalini.koka@cdk.com - RQ-07349 - added code to maintain data integrity in CRs while merging accounts
    if(Trigger.isDelete) 
    {
        if(Trigger.isAfter && ALL_CheckRecursive.runCodeBlockOnce('AccountHandlerAfterDelete'))
        {
            //System.debug('triggered after delete');
            ALL_Account_Handler.handleContactRelationshipsOfDuplicateAccounts(Trigger.oldMap);
        }
    }
}