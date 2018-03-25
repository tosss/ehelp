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
}