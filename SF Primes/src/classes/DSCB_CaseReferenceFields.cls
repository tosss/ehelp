public class DSCB_CaseReferenceFields
{
    public static void SetCaseReferenceFields(list<Case> NewCaseList)
    {
        list<String> WebIds = New list<String>();
        list<String> AccountIds = new list<String>();
        set<ID> AccountPlanIDs = new set<ID>();
        
        for(Case c: NewCaseList) 
        {
            WebIds.add(c.WebID__c);
            AccountIds.add(c.AccountId);
            AccountIds.add(c.Destination_Account__c);
            AccountPlanIDs.add(c.Account_Plan__c);
        }
        
        system.debug(AccountPlanIDs);
        
        map<Id, WebID__c> WebIdMap = new map<Id, WebID__c>([
            select Id, BAC_Dealer_Code__c, Webnum__c, Online_Marketing_Specialist__r.FirstName, Online_Marketing_Specialist__r.lastName,
                Online_Marketing_Specialist__r.Extension, Primary__c, Account_Advocate__r.FirstName, Account_Advocate__r.LastName,
                Account_Advocate__r.Extension, AA_Echelon_Level__c, DA_Echelon_Level__c 
            From WebID__c 
            where Id IN :WebIds
        ]);
        
        // query account plans that are related to these trigger.new cases
        map<ID, Account_Plan__c> AccountPlanMap = new map<ID, Account_Plan__c>([
            select ID, Name, DA_Echelon_Level__c
            From Account_Plan__c
            Where ID IN :AccountPlanIDs
        ]);
        
        system.debug(AccountPlanMap);
        
        map<Id, Account> AccountIdMap = new map<Id, Account>([
            Select Id, name, Account_Number__c, Org_Key__c, CBLTZip__c //, Dealer_Group_Name2__c
            From Account 
            where Id IN :AccountIds
        ]);
        
        for(Case c : NewCaseList)
        {
            if(WebIdMap != null && !WebIdMap.IsEmpty() && WebIdMap.containskey(c.webid__c))
            {
                WebID__c w = WebIdMap.get(c.WebID__c);
                Account_Plan__c ap = AccountPlanMap.get(c.Account_Plan__c);
                system.debug(ap);
                
                if(w != null){ c.BAC_Dealer_Code__c = w.BAC_Dealer_Code__c;}
                if(w != null){ c.AA_Echelon_Level__c = w.AA_Echelon_Level__c;}                
                if(w != null){ c.DA_Echelon_Level__c = w.DA_Echelon_Level__c;} // getting this value from WebId instead of account plan changed to this after
                                                                               // the request RQ-03704
                
                if(w.Account_Advocate__r != null)
                {
                    if(w.Account_Advocate__r.Extension !=null) 
                    {
                        c.Account_Advocate__c 
                            = w.Account_Advocate__r.FirstName + ' ' 
                                + w.Account_Advocate__r.lastName 
                                + ' - Ext: ' + w.Account_Advocate__r.Extension;
                    }
                    else 
                    {
                        c.Account_Advocate__c 
                            = w.Account_Advocate__r.FirstName + ' ' 
                                + w.Account_Advocate__r.LastName;
                    }
                }
                else 
                {
                    c.Account_Advocate__c = '';
                }
               
                if(w.Online_Marketing_Specialist__r != null)
                {
                    if(w.Online_Marketing_Specialist__r.Extension != null) 
                    {
                        c.Online_Marketing_Specialist__c 
                            = w.Online_Marketing_Specialist__r.FirstName + ' ' 
                                + w.Online_Marketing_Specialist__r.lastName 
                                + ' - Ext: ' + w.Online_Marketing_Specialist__r.Extension;
                    }
                    else 
                    {
                        c.Online_Marketing_Specialist__c 
                            = w.Online_Marketing_Specialist__r.FirstName + ' ' 
                                + w.Online_Marketing_Specialist__r.lastName;
                    }
                }
                else 
                {
                    c.Online_Marketing_Specialist__c = '';
                }
                
                //if(w.Primary__c == True) {
                //    c.Primary_Site_Status__c = 'Primary';
                //}
                //else {
                //    c.Primary_Site_Status__c = 'Secondary';
                //}
                
                c.WebNum__c = w.Webnum__c;
            }
            
            if(AccountIdMap != null && !AccountIdMap.IsEmpty() 
            && AccountIdMap.containsKey(c.AccountId))
            {
                Account a = AccountIdMap.get(c.AccountId);
                
                c.Account_Number__c = a.Account_Number__c;
                //c.Dealer_Group_Name__c = a.Dealer_Group_Name2__c;
                c.Zip_Code__c = a.CBLTZip__c;
            }
            
            if(AccountIdMap != null && !AccountIdMap.IsEmpty() 
            && AccountIdMap.containsKey(c.Destination_Account__c))
            {
                Account a = AccountIdMap.get(c.Destination_Account__c);
                
                c.Destination_Oracle_Customer__c = a.Account_Number__c;
                c.Destination_Org_Key__c = a.Org_Key__c;   
            }
        }
    }
    
    public static void CaseDefaultAccount(list<Case> DefaultAccountCases)
    {
        // DS_CaseDefaultAccount        
        CustomSettings__c settings = CustomSettings__c.getInstance();
        
        if(settings.CDK_Global_Account_Id__c != null)
        {  
            if(DefaultAccountCases != null && !DefaultAccountCases.isEmpty())
            {                       
                for(Case c : DefaultAccountCases)
                {
                    c.AccountId = settings.CDK_Global_Account_Id__c;
                }
            }
        }                
    }
    
    public static void CaseUserManager(list<Case> UserManagerCases, Map<Id, Case> oldMap)
    {
        if(UserManagerCases != null && !UserManagerCases.isEmpty())
        {                   
            for(Case NewCase : UserManagerCases) 
            {
                Case OldCase = oldMap != null ? oldMap.get(NewCase.Id) : null;
                if(OldCase == null) { OldCase = new Case(); }
                
                // 2014-10-14 from Christy Silveira - upon Owner change 
                if(NewCase.OwnerId != OldCase.OwnerId)
                {
                    String NewCaseOwnerId = String.valueOf(NewCase.OwnerId);
                    String OldCaseOwnerId = String.valueOf(OldCase.OwnerId);
                    
                    // 2014-10-14 CS - update owner lookup with new owner
                    //   if new owner is not a queue then current Owner
                    if(NewCaseOwnerId != null && !NewCaseOwnerId.startsWith('00G')) { 
                        NewCase.Owner_Lookup__c = NewCase.OwnerId; }
                    else { // 2014-10-14 CS - if new owner is queue then NULL 
                        NewCase.Owner_Lookup__c = null; }
                }
            } 
        }
        
    }
    
    public static void UpdateContactAccount(map<string, list<Case>> FilteredTriggerNew)
    {
        // CB_UpdateContactAccount - pulled in, not a separate trigger/class
        
        // MK - 2012-08-16 - added global settings field for username
        // MK - 2013-08-14 - updated code to be more flexible and readable
        GlobalSettings__c gs = GlobalSettings__c.getInstance();
        String un = gs != null ? gs.Email_2_Case_User__c : null; 
        
        // only get a matching user if the Global Settings are set
        List<User> users = new List<User>();
        if(un != null) { users = [Select id from User where Username = :un]; }
        
        // u cannot be null because its properties are referenced later
        User u = users.isEmpty() ? new User() : users[0]; 
        
        // gather Email Addresses:
        //   if the Current User is the Email 2 Case User
        //   and an Email Address was supplied on the Case
        //     add the Email Address for processing
        Set<String> EmailAddresses = new Set<String>();
        
        list<Case> ContactAccountCases = FilteredTriggerNew.get('CB_UpdateContactAccount');    
        
        if(ContactAccountCases != null && !ContactAccountCases.isEmpty())
        {                   
            for (Case CurrentCase : ContactAccountCases) 
            {
                if(UserInfo.getUserId() == u.Id && CurrentCase.SuppliedEmail != null) 
                {
                    EmailAddresses.add(CurrentCase.SuppliedEmail);
                }
            }
        }
        
        List<Contact> MatchingContacts = new List<Contact>();
        if(!EmailAddresses.IsEmpty()) {
            MatchingContacts = [SELECT Email FROM Contact WHERE Email IN :EmailAddresses]; 
        }
        
        if(ContactAccountCases != null && ContactAccountCases.isEmpty())
        {
            for (Case CurrentCase : ContactAccountCases) 
            {
                // check for multiple matches
                Integer temp = 0;
                for(Contact CurrentContact : MatchingContacts) {
                    if(CurrentContact.Email == CurrentCase.SuppliedEmail) { temp++; } 
                }
                
                // if there is more than one match
                //   set these fields to a blank value
                if(temp > 1) 
                {
                    CurrentCase.ContactId = null;
                    CurrentCase.AccountId = null;
                    CurrentCase.WebID__c = null; 
                    system.debug(CurrentCase.WebID__c);
                    system.debug(CurrentCase.ContactId);
                }
            }
        }
        // end CB_UpdateContactAccount
        
    }
}