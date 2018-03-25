//2016-05-27 - siva.pragada@cdk.com - added logic for replacing WebID AA with Launch AA
public class DS_Launch_Handler 
{
    // below static maps are queries in before trigger and are available in after trigger as well
    public static Map<Id, Account> staticAccountsMap = new Map<Id, Account>();
    public static Map<Id, WebID__c> staticWebIDsMap = new Map<Id, WebID__c>();
    
    public static void processLaunch2CaseLogic()
    {
        Try{
            list<Launch__c> launchList = (list<Launch__c>)Trigger.new;
            //map<ID, Launch__c> oldLaunchMap = (map<ID, Launch__c>)Trigger.oldMap;
            list<ALL_Decision_Box_Settings__c> decisionList = ALL_UtilitiesLogic.getRelevantDecisionBoxSettings('Launch__c', 'Case');
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
                        //system.assertEquals(decisionList.size(),1);
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
            
            //system.debug(insertCasesList);
            //system.debug(ALL_UtilitiesLogic.evaluatedExpressionsMap);
            
            //for(string s: ALL_UtilitiesLogic.allIdentifierTobooleanMap.keySet())
            //{
            //system.debug(s + ' : ' + ALL_UtilitiesLogic.allIdentifierTobooleanMap.get(s));
            //}
            //system.debug(ALL_UtilitiesLogic.allIdentifierTobooleanMap);
            
            //for(string key: ALL_UtilitiesLogic.evaluatedExpressionsMap.keySet())
            //{
            //system.debug(key + ' : ' + ALL_UtilitiesLogic.evaluatedExpressionsMap.get(key));
            //}
            
            if(!insertCasesList.isEmpty())
            {  
                insert insertCasesList;
            }
        }
        Catch(Exception exp)
        {
            All_UtilitiesMiscellaneous.logException(exp);
        }
    }
    
    public static void CB_LaunchUpdateEmails()
    {
        Try{
            map<ID, Launch__c> launchMap = null;
            
            if(Trigger.isUpdate)
            {
                launchMap = new map<ID, Launch__c>([
                    Select ID, Name, (Select ID, ParentID, oldValue, newValue, Field From Histories Where Field = 'Status__c') 
                    From Launch__c
                    Where ID IN :Trigger.new
                ]);
            }
            ID A_La_Carte_RecordType = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Launch__c', 'A La Carte Launch');
            ID website_Launch = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Launch__c', 'Website Launch');
            
            list<WebID__c> webIDsListUpdate = new list<WebID__c>();
            
            Set<Id> AccountsToQuery = new Set<Id>();
            Set<Id> WebIDsToQuery = new Set<Id>();
            list<Launch__c> newList = (List<Launch__c>) Trigger.new;
            
            // loop through updated records
            for(Launch__c l : newList) 
            {    
                if(l.Account__c != null) { AccountsToQuery.add(l.Account__c); }
                if(l.WebID__c != null) { WebIDsToQuery.add(l.WebID__c); }
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
            
            if(!newList.IsEmpty()) 
            {
                for(Launch__c currentLaunch : newList)
                {
                    Account currentAccount = staticAccountsMap.get(currentLaunch.Account__c);
                    WebID__c currentWebID = staticWebIDsMap.get(currentLaunch.WebID__c);
                    object webIDAccountAdvocate;
                    object launchAccountAdvocate = currentLaunch.Account_Advocate__c;
                    
                    if(currentAccount != null)
                    {
                        currentLaunch.DSM_Email__c = currentAccount.Designated_DSM__r.Email; 
                        currentLaunch.CAM_Email__c = currentAccount.Digital_Services_CAM__r.Email;
                    }
                    
                    if(currentWebID != null)
                    {
                        currentLaunch.Advocate_Email__c = currentWebID.Account_Advocate__r.Email; 
                        currentLaunch.EMS_Email__c = currentWebID.OwnerMktg_Specialist_lookup__r.Email; 
                        currentLaunch.OMS_Email__c = currentWebID.Online_Marketing_Specialist__r.Email; 
                        currentLaunch.RMS_Email__c = currentWebID.Reputation_Management_Specialist__r.Email; 
                        currentLaunch.SEO_Email__c = currentWebID.SEO_Specialist__r.Email; 
                        currentLaunch.SMS_Email__c = currentWebID.Social_Media_Specialist__r.Email;
                        webIDAccountAdvocate = currentWebID.Account_Advocate__c;
                    }
                    
                    boolean statusClosedFirstTime = false;
                    
                    if(Trigger.isInsert && currentLaunch.Status__c != null && 
                       currentLaunch.Status__c.containsIgnoreCase('Closed'))
                    {
                        statusClosedFirstTime = true;
                    }
                    else if(Trigger.isUpdate && currentLaunch.Status__c != null && 
                            currentLaunch.Status__c.containsIgnoreCase('Closed'))
                    {
                        set<string> statusClosedSet = new set<string>();
                        list<Launch__History> launchHistories = launchMap.get(currentLaunch.ID).Histories;
                        if(!launchHistories.isEmpty())
                        {
                            for(Launch__History his: launchHistories)
                            {
                                statusClosedSet.add((string)his.newValue);
                                statusClosedSet.add((string)his.oldValue);
                            }
                            
                            if(!statusClosedSet.contains('Closed'))
                            {
                                statusClosedFirstTime = true;
                            }
                        }
                    }
                    
                    boolean conditionsMetForChangingAA = 
                        (currentLaunch.RecordTypeID == A_La_Carte_RecordType || currentLaunch.RecordTypeID == website_Launch) && 
                        ((currentLaunch.Product_Type__c != null && currentLaunch.Product_Type__c.containsIgnoreCase('ProCare')) || 
                         (currentLaunch.Add_Ons__c != null && currentLaunch.Add_Ons__c.containsIgnoreCase('ProCare'))) && 
                        currentWebID != null && launchAccountAdvocate != null && webIDAccountAdvocate == null;
                    
                    boolean conditionsMetForNullingSEOspecialist = (currentLaunch.RecordTypeID == A_La_Carte_RecordType || currentLaunch.RecordTypeID == website_Launch) &&
                        currentLaunch.Product_Type__c != null && (currentLaunch.Product_Type__c.containsIgnoreCase('Power SEO') || 
                                                                  currentLaunch.Product_Type__c.containsIgnoreCase('PowerSEO non-CDK') || 
                                                                  currentLaunch.Product_Type__c.containsIgnoreCase('ProCare') ||
                                                                  currentLaunch.Product_Type__c.containsIgnoreCase('SEO Essentials') ||
                                                                  currentLaunch.Product_Type__c.containsIgnoreCase('Performance') ||
                                                                  currentLaunch.Product_Type__c.containsIgnoreCase('PowerSEO non-CDK') ||
                                                                  currentLaunch.Product_Type__c.containsIgnoreCase('Audience Management Package') ||
                                                                  currentLaunch.Product_Type__c.containsIgnoreCase('VW Core') ||
                                                                  currentLaunch.Product_Type__c.containsIgnoreCase('VW Care'));
                        
                    
                    if(statusClosedFirstTime)
                    {
                        if(conditionsMetForChangingAA)
                        {
                            currentWebID.put('Account_Advocate__c', launchAccountAdvocate);
                            webIDsListUpdate.add(currentWebID);
                        }
                        
                        if(conditionsMetForNullingSEOspecialist)
                        {
                            currentLaunch.SEO_Specialist__c = null;
                        }
                    }
                    
                    if(currentWebID != null &&
                       ((currentLaunch.Product_Type__c != null && 
                         (
                             currentLaunch.Product_Type__c.containsIgnoreCase('Power SEO') || 
                             currentLaunch.Product_Type__c.containsIgnoreCase('PowerSEO non-CDK') ||
                             currentLaunch.Product_Type__c.containsIgnoreCase('SEO Essentials') ||
                             currentLaunch.Product_Type__c.containsIgnoreCase('ProCare') ||
                             currentLaunch.Product_Type__c.containsIgnoreCase('Audience Management Package') ||
                             currentLaunch.Product_Type__c.containsIgnoreCase('Audience Optimization') ||
                             currentLaunch.Product_Type__c.containsIgnoreCase('Base') ||
                             currentLaunch.Product_Type__c.containsIgnoreCase('Core/ProSite') ||
                             currentLaunch.Product_Type__c.containsIgnoreCase('Performance') ||
                             currentLaunch.Product_Type__c.containsIgnoreCase('PowerSEO non-CDK') ||
                             currentLaunch.Product_Type__c.containsIgnoreCase('VW Core')
                         )
                        ) ||
                        (currentLaunch.Add_Ons__c != null && 
                         (
                             currentLaunch.Add_Ons__c.containsIgnoreCase('Audience Optimization') ||
                             currentLaunch.Add_Ons__c.containsIgnoreCase('Power SEO') ||
                             currentLaunch.Add_Ons__c.containsIgnoreCase('ProCare') ||
                             currentLaunch.Add_Ons__c.containsIgnoreCase('SEO Essentials') ||
                             currentLaunch.Add_Ons__c.containsIgnoreCase('VW Care')
                         )
                        )) &&
                       currentLaunch.Status__c != null && 
                       currentLaunch.Status__c.containsIgnoreCase('Closed') &&
                       !currentLaunch.Send_SEO_Onboarding__c
                      )
                    {
                        currentWebID.put('SEO_Specialist__c', null);
                        webIDsListUpdate.add(currentWebID);
                    }
                }
            }
            
            if(!webIDsListUpdate.isEmpty())
            {
                ALL_UtilitiesData.SerializesObjectList(webIDsListUpdate, 'Update');
            }
        }
        Catch(Exception exp)
        {
            All_UtilitiesMiscellaneous.logException(exp);
        }
    }
}