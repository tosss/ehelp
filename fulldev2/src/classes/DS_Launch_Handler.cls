public class DS_Launch_Handler 
{
    // below static maps are queries in before trigger and are available in after trigger as well
    public static Map<Id, Account> staticAccountsMap = new Map<Id, Account>();
    public static Map<Id, WebID__c> staticWebIDsMap = new Map<Id, WebID__c>();
    
    public static void processLaunch2CaseLogic()
    {
        list<Launch__c> launchList = (list<Launch__c>)Trigger.new;
        //map<ID, Launch__c> oldLaunchMap = (map<ID, Launch__c>)Trigger.oldMap;
        list<ALL_Decision_Box_Settings__c> decisionList = ALL_Decision_Box_Settings__c.getAll().Values();
        GlobalSettings__c gs = GlobalSettings__c.getInstance();
        list<case> insertCasesList = new list<Case>();
        map<ID, Launch__c> helperLaunchMap = new map<ID, Launch__c>(launchList.deepClone(true, true, true));
       
        
        for(Launch__c newLaunch: launchList)
        {  
            WebID__c currentWebID = newLaunch.WebID__c != null ? staticWebIDsMap.get(newLaunch.WebID__c): null;
            Launch__c helperLaunch = helperLaunchMap.get(newLaunch.ID);
            helperLaunch.putSobject('WebID__r', currentWebID);
            
            if(!decisionList.isEmpty() && gs.Launch_Onboarding_Switch__c)
            {
                for(ALL_Decision_Box_Settings__c dbs: decisionList)
                {
                    //Launch__c oldLaunch = oldLaunchMap != null ? oldLaunchMap.get(newLaunch.ID) : null;
                    boolean fieldsValuesChanged = ALL_UtilitiesLogic.evaluatedExpressionsMap.get(dbs.Condition_Check__c);
                    
                    system.debug(dbs.Condition_Check__c);
                    system.debug(fieldsValuesChanged);
                    
                    if(fieldsValuesChanged == null)
                    {                
                        fieldsValuesChanged = ALL_UtilitiesLogic.getcompositeExpressionsEvaluatedValue(
                            dbs.Condition_Check__c, helperLaunch);
                    }
                    
                    system.debug(dbs.Condition_Check__c);
                    system.debug(fieldsValuesChanged);
                    
                    if(fieldsValuesChanged != null && fieldsValuesChanged)
                    {
                        sObject newObject = ALL_UtilitiesLogic.createRecords(
                            dbs.Value_Assignment__c, dbs.Assignment_sObject__c, helperLaunch);
                        
                        Case newCase = (Case)newObject;                    
                        insertCasesList.add(newCase);
                    }
                    
                    //below makes sure the expression is not evaluated one more time consuming the browser limited time.
                    ALL_UtilitiesLogic.evaluatedExpressionsMap.put(dbs.Condition_Check__c, fieldsValuesChanged);
                }
            }
        }
        
        /*system.debug(insertCasesList);
        system.debug(ALL_UtilitiesLogic.evaluatedExpressionsMap);
        
        for(string s: ALL_UtilitiesLogic.allIdentifierTobooleanMap.keySet())
        {
             system.debug(s + ' : ' + ALL_UtilitiesLogic.allIdentifierTobooleanMap.get(s));
        }
        system.debug(ALL_UtilitiesLogic.allIdentifierTobooleanMap);
        
        for(string key: ALL_UtilitiesLogic.evaluatedExpressionsMap.keySet())
        {
            system.debug(key + ' : ' + ALL_UtilitiesLogic.evaluatedExpressionsMap.get(key));
        }*/
        
        if(!insertCasesList.isEmpty())
        {
            try
            {
                insert insertCasesList;
            }
            Catch(Exception e)
            {
                launchList[0].addError(e.getMessage());
            }
        }
        
    }
    
    public static void CB_LaunchUpdateEmails()
    {
        List<Launch__c> LaunchesToUpdate = new List<Launch__c>();
        list<WebID__c> webIDsListUpdate = new list<WebID__c>();
        
        Set<Id> AccountsToQuery = new Set<Id>();
        Set<Id> WebIDsToQuery = new Set<Id>();
        list<Launch__c> newList = (List<Launch__c>) Trigger.new;
        
        // loop through updated records
        for(Launch__c l : newList) 
        {
            //if(l.CreatedDate <= DateTime.now())
            //{
                LaunchesToUpdate.add(l);
                if(l.Account__c != null) { AccountsToQuery.add(l.Account__c); }
                if(l.WebID__c != null) { WebIDsToQuery.add(l.WebID__c); }
            //}
        }
        
        system.debug(AccountsToQuery);
        
        // query the Account fields for the collected Launch Accounts
        
        if(!AccountsToQuery.IsEmpty()) 
        {
            staticAccountsMap = new Map<Id, Account>([
                Select Id, Designated_DSM__r.Email, Digital_Services_CAM__r.Email 
                From Account 
                Where Id IN :AccountsToQuery
            ]); 
        }
        
        // query the WebID fields for the collected Launch WebIDs
       
        if(!WebIDsToQuery.IsEmpty()) 
        {
            staticWebIDsMap = new Map<Id, WebID__c>([
                Select Id, Name, Status__c, Account_Advocate__c, Account_Advocate__r.Email, OwnerMktg_Specialist_lookup__r.Email,
                       Online_Marketing_Specialist__r.Email, Reputation_Management_Specialist__r.Email, 
                       SEO_Specialist__r.Email, Social_Media_Specialist__r.Email 
                From WebID__c 
                Where Id IN :WebIDsToQuery
            ]); 
        }
        
        if(!LaunchesToUpdate.IsEmpty()) 
        {
            for(Launch__c l : LaunchesToUpdate)
            {
                Account a = staticAccountsMap.get(l.Account__c);
                WebID__c w = staticWebIDsMap.get(l.WebID__c);
                object webIDAccountAdvocate;
                object launchAccountAdvocate = l.Account_Advocate__c;
                
                if(a != null)
                {
                    l.DSM_Email__c = a.Designated_DSM__r.Email; 
                    l.CAM_Email__c = a.Digital_Services_CAM__r.Email; 
                    //l.GAM_Email__c = a.Digital_Services_GAM__r.Email; 
                }
                
                if(w != null)
                {
                    l.Advocate_Email__c = w.Account_Advocate__r.Email; 
                    l.EMS_Email__c = w.OwnerMktg_Specialist_lookup__r.Email; 
                    l.OMS_Email__c = w.Online_Marketing_Specialist__r.Email; 
                    l.RMS_Email__c = w.Reputation_Management_Specialist__r.Email; 
                    l.SEO_Email__c = w.SEO_Specialist__r.Email; 
                    l.SMS_Email__c = w.Social_Media_Specialist__r.Email;
                    webIDAccountAdvocate = w.Account_Advocate__c;
                }
                
                if(w != null && launchAccountAdvocate != null && webIDAccountAdvocate != launchAccountAdvocate)
                {
                    w.put('Account_Advocate__c', launchAccountAdvocate);
                    webIDsListUpdate.add(w);
                }
                
                if(w != null &&
                    ((l.Product_Type__c != null && 
                         (
                          l.Product_Type__c.containsIgnoreCase('Power SEO') || 
                          l.Product_Type__c.containsIgnoreCase('PowerSEO non-CDK') ||
                          l.Product_Type__c.containsIgnoreCase('SEO Essentials') ||
                          l.Product_Type__c.containsIgnoreCase('ProCare') ||
                          l.Product_Type__c.containsIgnoreCase('Audience Management Package') ||
                          l.Product_Type__c.containsIgnoreCase('Audience Optimization') ||
                          l.Product_Type__c.containsIgnoreCase('Base') ||
                          l.Product_Type__c.containsIgnoreCase('Core/ProSite') ||
                          l.Product_Type__c.containsIgnoreCase('Performance') ||
                          l.Product_Type__c.containsIgnoreCase('PowerSEO non-CDK') ||
                          l.Product_Type__c.containsIgnoreCase('VW Core')
                         )
                    ) ||
                    (l.Add_Ons__c != null && 
                         (
                          l.Add_Ons__c.containsIgnoreCase('Audience Optimization') ||
                          l.Add_Ons__c.containsIgnoreCase('Power SEO') ||
                          l.Add_Ons__c.containsIgnoreCase('ProCare') ||
                          l.Add_Ons__c.containsIgnoreCase('SEO Essentials') ||
                          l.Add_Ons__c.containsIgnoreCase('VW Care')
                         )
                    )) &&
                   l.Status__c != null && 
                   l.Status__c.containsIgnoreCase('Closed') &&
                   !l.Send_SEO_Onboarding__c
                )
                {
                    w.put('SEO_Specialist__c', null);
                    webIDsListUpdate.add(w);
                }
            }
        }
        
        if(!webIDsListUpdate.isEmpty())
        {
            ALL_UtilitiesData.SerializesObjectList(webIDsListUpdate, 'Update');
        }
    }
}