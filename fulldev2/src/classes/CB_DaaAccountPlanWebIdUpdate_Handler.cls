public class CB_DaaAccountPlanWebIdUpdate_Handler
{
    public static void daaAccountPlanHandler()
    {
        map<Id, Account_Plan__c> DaaAccountPlansMap = new map<Id, Account_Plan__c>();
        list<Account_Plan__c> newAccountPlans = (list<Account_Plan__c>)Trigger.New;
        
        for (Account_plan__c ap : newAccountPlans) 
        {
            // set Unique AP ID
            ap.Unique_AP_ID__c = string.valueof(ap.webid__C) + ap.recordtypeid;
            
            // Collect WebIds on the DAA Account Plans for request RQ-03704           
            string RecordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Account_Plan__c', ap.RecordTypeId);
            
            if(RecordTypeName == 'DAA Account Plan')
            {
                DaaAccountPlansMap.put(ap.Id, ap);
            } 
        }
        
        // this is for RQ-03704: updating WebId DA_Echelon_Level__c with AP(DAA account Plan)'s DA_Echelon_Level__c field
        CB_DaaAccountPlanWebIdUpdate_Handler.WebIdUpdateMethod(
            DaaAccountPlansMap, (list<Account_Plan__c>)Trigger.new, (map<ID, Account_Plan__c>)Trigger.oldMap);  
    }
    
    public static void WebIdUpdateMethod(map<Id, Account_Plan__c> newDaaAPRecordsMap, list<Account_Plan__c> newAPlist, 
                                         map<Id, Account_Plan__c> oldAPRecordsMap)
    {
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
        { 
            // Collect WebIds on the DAA Account Plans for request RQ-03704
            set<ID> DaaAccountPlanWebIdSet = new set<ID>();
            
            for(Account_Plan__c ap: newDaaAPRecordsMap.Values())
            {
                DaaAccountPlanWebIdSet.add(ap.WebID__c);
            }
            
            // query WebId records for RQ-03704
            map<Id, WebId__c> DaaAccountPlanWebIdMap;
            
            if(DaaAccountPlanWebIdSet != null && !DaaAccountPlanWebIdSet.isEmpty())
            {
                DaaAccountPlanWebIdMap = new map<Id, WebId__c>([
                    Select Id, Name, DA_Echelon_Level__c, Online_Marketing_Specialist__c, Digital_Advertising_Strategist__c
                    From WebId__c
                    Where ID IN : DaaAccountPlanWebIdSet
                ]);
            }
            
            if(DaaAccountPlanWebIdMap != null && !DaaAccountPlanWebIdMap.isEmpty())
            {
                // loop through new Account Plans to pick DAA Account Plans and corresponding WebId records from the Account Plans
                // and update the DA_Echelon_Level__c field on the WebIds.
                for(Account_Plan__c ap: newDaaAPRecordsMap.values())
                {   
                    WebId__c DaaAPWebID = DaaAccountPlanWebIdMap.get(ap.WebID__c);
                    
                    boolean BlankOut_WebId_DAEchelonLevel_Field = false;
                    if(ap.Account_Status__c == 'Cancelled' || ap.Account_Status__c == 'Inactive')
                    {
                        BlankOut_WebId_DAEchelonLevel_Field = true;
                    }
                    
                    // since DaaAccountPlanWebIdMap contains only WebId's that are related to DAA Account Plans We don't have to check for the 
                    // the recordtype name for the account plans in this loop. Even though checking would not cost a soql query, just a describe call
                    if(ap.DA_Echelon_Level__c != null && DaaAPWebID != null)
                    { 
                        DaaAPWebID.DA_Echelon_Level__c = ap.DA_Echelon_Level__c;                        
                    }
                    else
                    {
                        DaaAPWebID.DA_Echelon_Level__c = null;
                    }
                    
                    // below will blanckout the DA Echelon Level field from the WebId if the AP's Account Status is Cancelled or Inactive
                    if(BlankOut_WebId_DAEchelonLevel_Field)
                    {
                        DaaAPWebID.DA_Echelon_Level__c = null;
                    }
                    
                  /*  if(ap.Secondary_Owner__c != null)
                    {
                        DaaAPWebID.Online_Marketing_Specialist__c = ap.Secondary_Owner__c;
                        DaaAPWebID.Digital_Advertising_Strategist__c = ap.OwnerId;
                    }
                    else
                    {
                        DaaAPWebID.Online_Marketing_Specialist__c = ap.OwnerId;
                        DaaAPWebID.Digital_Advertising_Strategist__c = null;
                    }*/
                }
            }
            
            if(DaaAccountPlanWebIdMap != null && !DaaAccountPlanWebIdMap.isEmpty())
            {
                update DaaAccountPlanWebIdMap.values();
            }
            
            
            { // beginning of the code for RQ-04229 'Create a new Account Plan Trigger to fill email addresses' Added 3/18/2015 SivaP
                set<ID> WebIdIDset = new set<ID>();
                set<ID> AccountIDset = new set<ID>();
                For(Account_Plan__c ap: newAPlist)
                {
                    WebIdIDset.add(ap.webId__c);
                    AccountIDset.add(ap.Account__c);
                }
                map<ID, Account> AccountMapWithChildrenWebIds;
                
                if(WebIdIDset != null && !WebIdIDset.isEmpty())
                {
                    AccountMapWithChildrenWebIds = new map<ID, Account>([
                        Select Id, Name, Designated_DSM__r.Email, LMA_Regional_Director1__r.Name, LMA_Regional_Director1__r.isActive,
                               Digital_Services_CAM__c, Digital_Services_CAM__r.Email,
                               (Select Id, Name, Status__c, Account_Advocate__r.Email, SEO_Specialist__r.Email, 
                                       Reputation_Management_Specialist__r.Email, Online_Marketing_Specialist__r.Email, 
                                       Client_Account_Manager__r.Email, LMA_Strategist__c, LMA_Strategist__r.Email, 
                                       OwnerMktg_Specialist_lookup__r.Email, Social_Media_Specialist__r.Email,
                                       LMA_Analyst__r.Email, LMA_Analyst__r.Name, LMA_Analyst2__r.Email, LMA_Analyst2__r.Name,
                                       Account_Executive__r.Email, Account_Advocate__r.isActive, SEO_Specialist__r.isActive,
                                       Reputation_Management_Specialist__r.isActive, Online_Marketing_Specialist__r.isActive, 
                                       Client_Account_Manager__r.isActive, LMA_Strategist__r.isActive,
                                       OwnerMktg_Specialist_lookup__r.isActive, Social_Media_Specialist__r.isActive, 
                                       LMA_Analyst__r.isActive, LMA_Analyst2__r.isActive, Digital_Advertising_Strategist__c, 
                                       Digital_Advertising_Strategist__r.isActive, Digital_Advertising_Strategist__r.Email, 
                                       Online_Marketing_Specialist__c, 
                                       Account_Executive__r.isActive
                                From Sites__r),
                        
                               (Select Id, Team_Role__c, Team_Member__r.Email, Team_Member__r.isActive 
                                From AccountTeamAccounts__r
                                Where (Team_Role__c = 'Email Marketing Specialist' 
                                OR Team_Role__c = 'Social Media Specialist'))
                                
                        From Account
                        Where ID IN :AccountIDset
                    ]);
                }
                
                map<ID, WebId__c> WebIdMap;
                map<ID, WebId__c> OnstationWebIdMap;
                map<ID, WebId__c> SocialWebIDMap;
                map<ID, string> EmailMarketingSpecialistMap = new map<ID, string>(); // key is AccountId and value is Account Team Member email
                map<ID, string> SocialMediaSpecialistMap = new map<ID, string>(); // key is AccountId and value is Account Team Member email 
                
                if(AccountMapWithChildrenWebIds != null && !AccountMapWithChildrenWebIds.isEmpty())
                {
                    WebIdMap = new map<ID, WebId__c>();
                    OnstationWebIdMap = new map<ID, WebId__c>();
                    SocialWebIDMap = new map<ID, WebId__c>();
                    
                    for(string key: AccountMapWithChildrenWebIds.keySet()) 
                    {
                        Account CurrentAccount = AccountMapWithChildrenWebIds.get(key);
                        
                        if(CurrentAccount != null)
                        {
                            List<WebId__c> WebIdList = CurrentAccount.sites__r;
                            if(WebIdList != null && !WebIdList.isEmpty())
                            {
                                for(WebId__c w: WebIdList)
                                { 
                                    if(WebIdIDset.contains(w.Id))
                                    {
                                        WebIdMap.put(w.Id, w); // only collects WebIds that are on the current Account Plan
                                    }
                                    else if(w.Name.toLowerCase().Contains('onstation'))
                                    {
                                        OnstationWebIdMap.put(key, w); // key is accountId of the webid in the map
                                    }
                                    else if(w.Name.toLowerCase().Contains('social'))
                                    {
                                        SocialWebIDMap.put(key, w); // key is accountId of the webid in the map
                                    }                      
                                }
                            }
                            
                            List<Account_Team__c> AccountTeamList = CurrentAccount.AccountTeamAccounts__r;
                            
                            if(AccountTeamList != null && !AccountTeamList.isEmpty())
                            {
                                for(Account_Team__c atm: AccountTeamList)
                                {
                                    if(atm.Team_Role__c == 'Email Marketing Specialist')
                                    {
                                        EmailMarketingSpecialistMap.put(CurrentAccount.Id, atm.Team_Member__r.Email);
                                    }
                                    
                                    if(atm.Team_Role__c == 'Social Media Specialist')
                                    {
                                        SocialMediaSpecialistMap.put(CurrentAccount.Id, atm.Team_Member__r.Email);
                                    }  
                                }
                            }
                        }
                    }
                }
                
                for(Account_Plan__c ap: newAPlist)
                {
                    WebId__c currentWebID = WebIdMap.get(ap.WebId__c);
                    Account CurrentAccount = AccountMapWithChildrenWebIds.get(ap.Account__c);
                    WebId__c OnstationWebID = OnstationWebIdMap.get(ap.Account__c);
                    WebId__c SocialWebID = SocialWebIdMap.get(ap.Account__c);
                    
                    //this is for RQ-04668 (Ent. Sol.) Need trigger to populate field on Account Plan from Account
                    if(CurrentAccount != null && CurrentAccount.LMA_Regional_Director1__r.isActive)
                    {
                        ap.LMA_Regional_Director_Text__c = CurrentAccount.LMA_Regional_Director1__r.Name;
                    }
                    
                    if(currentWebID != null && currentWebID.Status__c == 'Active')
                    {
                        if(currentWebID.Account_Advocate__r.isActive)
                        { ap.Advocate_Email__c = currentWebID.Account_Advocate__r.Email; }
                        
                        if(currentWebID.SEO_Specialist__r.isActive)
                        { ap.SEO_Email__c = currentWebID.SEO_Specialist__r.Email; }
                        
                        if(currentWebID.Reputation_Management_Specialist__r.isActive)
                        { ap.RMS_Email__c = currentWebID.Reputation_Management_Specialist__r.Email; }
                        
                        if(currentWebID.Online_Marketing_Specialist__r.isActive)
                        { ap.OMS_Email__c = currentWebID.Online_Marketing_Specialist__r.Email; }
                        
                        if(currentWebID.Client_Account_Manager__r.isActive)
                        { ap.CAM_Email__c = currentWebID.Client_Account_Manager__r.Email; }
                        
                        if(currentWebID.LMA_Strategist__r.isActive)
                        { ap.LMA_Strategist_Email__c = currentWebID.LMA_Strategist__r.Email; } 
                        
                        if(currentWebID.Digital_Advertising_Strategist__r.isActive)
                        { ap.Digital_Advertising_Strategist_Email__c = currentWebID.Digital_Advertising_Strategist__r.Email; }
                        
                        if(currentWebID.LMA_Analyst__r.isActive)
                        { 
                            ap.LMA_Analyst_Email__c = currentWebID.LMA_Analyst__r.Email;
                            ap.LMA_Analyst__c = currentWebID.LMA_Analyst__r.Name;
                        }
                        
                        if(currentWebID.LMA_Analyst2__r.isActive)
                        {
                            ap.LMA_Analyst2_Email__c = currentWebID.LMA_Analyst2__r.Email;
                            ap.LMA_Analyst_2__c = currentWebID.LMA_Analyst2__r.Name;
                        }
                        
                        if(currentWebID.Account_Executive__r.isActive)
                        { ap.DSM_Email__c = currentWebID.Account_Executive__r.Email;}
                    }
                    
                    if(OnstationWebID != null && OnstationWebID.OwnerMktg_Specialist_lookup__r.Email != null)
                    {
                        ap.EMS_Email__c = OnstationWebID.OwnerMktg_Specialist_lookup__r.Email;
                    }
                    else
                    {
                        if(EmailMarketingSpecialistMap != null && EmailMarketingSpecialistMap.get(CurrentAccount.Id) != null)
                        {
                            ap.EMS_Email__c = EmailMarketingSpecialistMap.get(CurrentAccount.Id);
                        }
                    }
                    
                    if(SocialWebID != null && SocialWebID.Social_Media_Specialist__r.Email != null)
                    {
                        ap.SMS_Email__c = SocialWebID.Social_Media_Specialist__r.Email;
                    }
                    else
                    {
                        if(SocialMediaSpecialistMap != null && SocialMediaSpecialistMap.get(CurrentAccount.Id) != null)
                        {
                            ap.SMS_Email__c = SocialMediaSpecialistMap.get(CurrentAccount.Id);
                        }
                    }
                }               
            }// End of the code for RQ-04229 'Create a new Account Plan Trigger to fill email addresses' Added 3/18/2015 SivaP 
        }  
    }
        
    public static void APDeleted(map<ID, Account_Plan__c> oldAPRecordsMap)
    {
        
        set<ID> DAAaccountPlanWebIdSet = new set<ID>();
        
        for(Account_Plan__c ap: oldAPRecordsMap.values())
        {
            string RecordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Account_Plan__c', ap.RecordTypeId);
            
            if(RecordTypeName == 'DAA Account Plan')
            {
                DAAaccountPlanWebIdSet.add(ap.WebId__c);
            }
        }
        
        // query WebId records for RQ-03704
        map<Id, WebId__c> DAAaccountPlanWebIdMap = new map<Id, WebId__c>([
            Select Id, Name, DA_Echelon_Level__c, Online_Marketing_Specialist__c, Digital_Advertising_Strategist__c
            From WebId__c
            Where ID IN : DAAaccountPlanWebIdSet
        ]);
        
        if(DAAaccountPlanWebIdMap != null && !DAAaccountPlanWebIdMap.isEmpty())
        {
            for(WebId__c w: DAAaccountPlanWebIdMap.values())
            {
                w.DA_Echelon_Level__c = null;
            }
        }
        
        if(DAAaccountPlanWebIdMap != null && !DAAaccountPlanWebIdMap.isEmpty())
        {
            Update DAAaccountPlanWebIdMap.values();
        }       
    }
}