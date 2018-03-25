public class DS_UpdateKeyRep_Handler 
{
    public static void updateKeyRep()
    {
        list<Account> newAccountsList = (list<Account>)Trigger.new;
        list<Account> oldAccountsList = (list<Account>)Trigger.old;
        map<ID, Account> newAccountMap = (map<ID, Account>)Trigger.newMap;
        map<ID, Account> oldAccountMap = (map<ID, Account>)Trigger.oldMap;
        
        
        if(Trigger.IsBefore)
        {
            Map<string, list<Trigger_Toggle__c>> TriggerTogglesByCodeReference 
                = new map<string, list<Trigger_Toggle__c>>();
            Map<String,Trigger_Toggle__c> ttByRecordName = new Map<String,Trigger_Toggle__c>();
            
            Map<String, Trigger_Toggle__c> TriggerToggle = Trigger_Toggle__c.getAll();
            if(TriggerToggle != null)
            {
                // for each toggle setting
                for(Trigger_Toggle__c tt : TriggerToggle.values())
                {
                    if(tt.sObject__c == 'Account')
                    {
                        // add the toggle setting to a map of lists indexed by code reference
                        list<Trigger_Toggle__c> TriggerToggles = TriggerTogglesByCodeReference.get(tt.Code_Reference__c);
                        if(TriggerToggles == null)
                        { 
                            TriggerToggles = new list<Trigger_Toggle__c>();
                        }
                        TriggerToggles.add(tt);
                        TriggerTogglesByCodeReference.put(tt.Code_Reference__c, TriggerToggles);
                        
                    }
                }
                
                List<Trigger_Toggle__c> TriggerToggles = TriggerTogglesByCodeReference.get('DS_UpdateKeyRep');
                if(TriggerToggles!=null)
                {
                    for(Trigger_Toggle__c triggerToggleObj : TriggerToggles)
                    {
                        if(triggerToggleObj.RecordType_Name__c!=null)
                        {
                            ttByRecordName.put(triggerToggleObj.RecordType_Name__c,triggerToggleObj); 
                        }                
                    }
                }
            }
            CustomSettings__c cs = CustomSettings__c.getInstance();
            Id NonDealershipKeyRepID = cs != null ? cs.Nondealership_Key_Rep_ID__c : null;
            
            Set<Id> userIds = new Set<Id>();
            Set<Id> siteTypeIds = new Set<Id>();
            
            for(Account acc : newAccountsList)
            { 
                //sanjay.ghanathey@cdk.com 02-Dec-2014 Do not process for record type CB Digital Advertising        
                Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account.getRecordTypeInfosById();
                String recordTypeName = rtMap.get(acc.RecordTypeId).getName();
                Trigger_Toggle__c tTObject = ttByRecordName.get(recordTypeName);
                if(tTObject == null || !tTObject.On__c)
                {
                    System.debug('$$ Not CB Dig Adv - Update Key Rep - Trig New- '+recordTypeName);
                    userIds.add(acc.OwnerId); 
                    userIds.add(acc.Key_Rep__c); 
                    siteTypeIds.add(acc.Site_Type__c); 
                }
            }
            
            if(oldAccountsList != null) {
                for(Account acc : oldAccountsList) 
                {
                    //sanjay.ghanathey@cdk.com 02-Dec-2014 Do not process for record type CB Digital Advertising
                    Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account.getRecordTypeInfosById();
                    String recordTypeName = rtMap.get(acc.RecordTypeId).getName();
                    Trigger_Toggle__c tTObject = ttByRecordName.get(recordTypeName);
                    if(tTObject == null || !tTObject.On__c)
                    {
                        System.debug('$$ Not CB Dig Adv - Update Key Rep - Trig Old- '+recordTypeName);
                        siteTypeIds.add(acc.Site_Type__c);
                    }
                }
            }
            
            if(NonDealershipKeyRepID != null) { userIds.add(NonDealershipKeyRepID); }
            
            // prepare Users map
            Map<ID, User> usersMap = new Map<ID, User>([
                SELECT Id, Name, Region__c, Non_Interactive_User__c, Sales_Automation_User__c, 
                ManagerId, Manager.Name, Manager.Region__c, Manager.Non_Interactive_User__c, Manager.Sales_Automation_User__c 
                FROM User 
                WHERE ID IN :userIds
            ]);
            
            // prepare Site Types map
            Map<Id, Site_Type__c> siteTypesMap = new Map<Id, Site_Type__c>([
                SELECT Id, Name, Non_Sales_Type__c 
                FROM Site_Type__c
                WHERE ID IN :siteTypeIds
            ]);
            
            if((Trigger.isUpdate && trigger.isBefore) || (trigger.isInsert && trigger.isBefore))
            {
                for(integer i=0; i<newAccountsList.size(); i++)
                {
                    // set variables
                    Account currentAccount = newAccountsList[i]; 
                    //sanjay.ghanathey@cdk.com 02-Dec-2014 Do not process for record type CB Digital Advertising
                    Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account.getRecordTypeInfosById();
                    String recordTypeName = rtMap.get(currentAccount.RecordTypeId).getName();
                    Trigger_Toggle__c tTObject = ttByRecordName.get(recordTypeName);
                    if(tTObject == null || !tTObject.On__c)
                    {
                        System.debug('$$ Not CB Dig Adv - Update Key Rep - Update/Before/Insert- '+recordTypeName);
                        Site_Type__c currentSiteType = siteTypesMap.get(currentAccount.Site_Type__c);
                        Account oldAccount = oldAccountsList != null ? oldAccountsList[i] : new Account();
                        Site_Type__c oldSiteType = siteTypesMap.get(oldAccount.Site_Type__c);
                        
                        String TriggerType = (Trigger.isBefore ? 'BEFORE' : 'AFTER') + ' ' 
                            + (Trigger.isInsert ? 'INSERT' : '') + (Trigger.isUpdate ? 'UPDATE' : '');
                        
                        system.debug(TriggerType);
                        
                        // -- START -- Key Rep and Owner modifications
                        
                        // 2013-08-29 MK - This is done in Realignment (check with Irfan before un-commenting)
                        // if the Site Type is set to Out-of-Business or Duplicate, 
                        //   update the Key_Rep__c according to Custom Settings
                        //if(currentSiteType != null && currentSiteType.Name.toLowerCase() == 'out-of-business') { 
                        //	if(cs != null) { currentAccount.Key_Rep__c = cs.Out_of_business_Key_Rep_ID__c; } }
                        //if(currentSiteType != null && currentSiteType.Name.toLowerCase() == 'duplicate') { 
                        //	if(cs != null) { currentAccount.Key_Rep__c = cs.Duplicate_Key_Rep_ID__c; } }
                        
                        // if OwnerId or Key_Rep__c has changed (whether manually or by the current Site Type) 
                        //   update either the Key_Rep__c or the OwnerId respectively 
                        if(oldAccount.Key_Rep__c != currentAccount.Key_Rep__c) { 
                            if(currentAccount.Key_Rep__c != null) { currentAccount.OwnerId = currentAccount.Key_Rep__c; } }
                        if(oldAccount.OwnerId != currentAccount.OwnerId) { 
                            if(currentAccount.OwnerId != null) { currentAccount.Key_Rep__c = currentAccount.OwnerId; } }
                        
                        // if this is an Insert action
                        //   check the Site Type and set the Key Rep 
                        if(trigger.isInsert && trigger.isBefore) 
                        {
                            // set the Owner and Key Rep on Account to Custom Setting value
                            if(currentSiteType != null && currentSiteType.Non_Sales_Type__c == true && cs != null && cs.Nondealership_Key_Rep_ID__c != null)
                            {
                                currentAccount.Key_Rep__c = cs.Nondealership_Key_Rep_ID__c; 
                                currentAccount.OwnerId = cs.Nondealership_Key_Rep_ID__c; 
                            }
                            // otherwise set the Key Rep to the OwnerId
                            else { currentAccount.Key_Rep__c = currentAccount.OwnerId; }
                        }
                        
                        // -- END -- Key Rep and Owner modifications
                        
                        // -- START -- Out-of-business Prior Site Type Modifications
                        
                        system.debug(currentSiteType);
                        String currentSiteTypeName = currentSiteType != null ? currentSiteType.Name.toLowerCase() : '';
                        
                        system.debug(oldSiteType);
                        String oldSiteTypeName = oldSiteType != null ? oldSiteType.Name.toLowerCase() : '';
                        
                        if(currentAccount.Site_Type__c != oldAccount.Site_Type__c) 
                        {
                            // Khan : RQ-04052 change criteria to look at new checkboxes for duplicate & OOB
                            ////if(currentSiteType != null && (currentSiteTypeName == 'out-of-business' || currentSiteTypeName == 'duplicate')) {
                            //  if(oldSiteType != null && (oldSiteTypeName != 'out-of-business' && oldSiteTypeName != 'duplicate')) {
                            
                            if(currentSiteType != null && (currentAccount.Out_of_Business__c == true || currentAccount.Duplicate__c == true)) {
                                if(oldSiteType != null && (oldAccount.Out_of_Business__c != true && oldAccount.Duplicate__c != true)) {
                                    currentAccount.Prior_to_OOB_Site_Type__c = oldSiteType.Name; 
                                }
                            }
                            else {
                                currentAccount.Prior_to_OOB_Site_Type__c = null; 
                            }
                        }
                        
                        // -- END -- Out-of-business Prior Site Type Modifications
                        
                        // -- START -- Region Modifications
                        
                        // get the current Owner User
                        User currentOwner = null;
                        if(currentAccount != null && currentAccount.OwnerId != null) { currentOwner = usersMap.get(currentAccount.OwnerId); }
                        
                        
                        
                        
                        if(oldAccount.OwnerId != currentAccount.OwnerId )
                        {
                            // set the Region__c conditionally
                            if(currentOwner != null)
                            {
                                // if the current Owner is NOT a Non-interactive User and is NOT a Sales Automation User
                                // or if the Region has no value 
                                if((currentOwner.Non_Interactive_User__c == false && currentOwner.Sales_Automation_User__c == false)|| (currentAccount.Region__c == null)) {
                                    // if(currentOwner.Name.toLowerCase() != 'unassigned key-rep') // not needed b/c Non-Interactive User
                                    currentAccount.Region__c = currentOwner != null ? currentOwner.Region__c : currentAccount.Region__c; 
                                }
                            }
                        }
                        
                        //Vishal Bandari added code to retain the value of Region if the account is OOB or Duplicate on 13/05/2015
                        if(((currentAccount.Out_of_Business__c) || (currentAccount.Duplicate__c)) && (oldAccount.Region__c!= currentAccount.Region__c) )
                        {
                            currentAccount.Region__c = oldAccount.Region__c;
                        }
                        // -- END -- Region Modifications
                        
                        // -- START -- Key DOS Modifications
                        
                        // if OwnerId or Key_Rep__c has changed (whether manually or by the current Site Type)
                        if(oldAccount.OwnerId != currentAccount.OwnerId || oldAccount.Key_Rep__c != currentAccount.Key_Rep__c)
                        {
                            // if the Owner exists
                            if(usersMap != null && currentOwner != null && currentOwner.ManagerId != null)
                            {
                                // update the Key_DOS__c to the current Owner Manager Id
                                currentAccount.Key_DOS__c = currentOwner.ManagerId;
                            }
                            // if the Owner does not exist, 
                            //   set the Key DOS to a blank value
                            else { currentAccount.Key_DOS__c = null; } // this should theoretically never happen
                        }
                        
                        // -- END -- Key DOS Modifications
                    }
                }
            }
        }
    }
}