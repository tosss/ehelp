trigger ALL_Account on Account (before insert, before update, after insert, after update) 
{
    if (Trigger.isBefore)
    {
        for(Account newAccount: Trigger.New)
        {
            // DS_AccountVIP_Handler
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
    } 
    
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) // insert also
    {
        if(ALL_CheckRecursive.runCodeBlockOnce('AccountHierarchy20150409') || Test.isRunningTest())
        {
            DS_AccountHierarchyFieldUpdates.AccountHierarchyProcessBeforeFuture(Trigger.new, Trigger.oldMap);            
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
    }    
}