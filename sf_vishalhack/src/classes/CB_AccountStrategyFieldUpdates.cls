public class CB_AccountStrategyFieldUpdates 
{
    Public static void UpdatesMethod(list<Account_Strategy__c> newList)
    {
        set<ID> WebIDset = new Set<ID>();
        
        for(Account_Strategy__c accStrategy: newList)
        {
            WebIDset.add(accStrategy.WebId__c);
        }
        
        map<ID, WebId__c> WebIdMap;
        
        if(WebIDset != null && !WebIDset.isEmpty())
        {
            WebIdMap = new map<ID, WebId__c>([
                Select Id, Name, LMA_Analyst2__r.Email, LMA_Analyst2__r.isActive, SEO_Specialist__r.Email, SEO_Specialist__r.isActive,
                       Social_Media_Specialist__r.Email, Social_Media_Specialist__r.isActive, Reputation_Management_Specialist__r.Email, 
                       Reputation_Management_Specialist__r.isActive, Online_Marketing_Specialist__r.Email, Online_Marketing_Specialist__r.isActive,
                       OwnerMktg_Specialist_lookup__r.Email, OwnerMktg_Specialist_lookup__r.isActive, Client_Account_Manager__r.Email,
                       Client_Account_Manager__r.isActive, LMA_Strategist__r.Email, LMA_Strategist__r.isActive, 
                       Account_Advocate__r.isActive, Account_Advocate__r.Email, Social_Media_Specialist__c,
                
                       (Select Id, Name, RecordTypeId, RecordType.Name
                        From Account_Plans__r)
                
                From WebId__c 
                Where Id IN: WebIDset
            ]);
        }        
        
        for(Account_Strategy__c astr: newlist)
        {
            WebId__c w = WebIdMap.get(astr.WebId__c);           
            
            if(w != null)
            {
                if(w.Account_Advocate__r.isActive)
                { astr.Account_Advocate_Email__c = w.Account_Advocate__r.Email;}
                
                if(w.SEO_Specialist__r.isActive) 
                { astr.SEO_Specialist_Email__c = w.SEO_Specialist__r.Email; }
                
                if(w.Social_Media_Specialist__r.isActive) 
                { astr.Social_Media_Rep_Email__c = w.Social_Media_Specialist__r.Email; }
                
                if(w.Social_Media_Specialist__r.isActive) 
                { astr.social_media_specialist__c = w.Social_Media_Specialist__c; }
                
                if(w.Reputation_Management_Specialist__r.isActive) 
                { astr.Reputation_Management_Specialist_Email__c = w.Reputation_Management_Specialist__r.Email; }
                
                if(w.Online_Marketing_Specialist__r.isActive) 
                { astr.Digital_Advertising_Analyst_Email__c  = w.Online_Marketing_Specialist__r.Email; }
                
                if(w.OwnerMktg_Specialist_lookup__r.isActive) 
                { astr.Email_Marketing_Specialist_Email__c = w.OwnerMktg_Specialist_lookup__r.Email; }
                
                if(w.Client_Account_Manager__r.isActive) 
                { astr.Marketing_Strategist_Email__c = w.Client_Account_Manager__r.Email; }
                
                if(w.LMA_Strategist__r.isActive) 
                { astr.LMA_Strategist_Email__c = w.LMA_Strategist__r.Email; }
                
                list<Account_Plan__c> AccountPlans = w.Account_Plans__r;
                
                if(AccountPlans != null && !AccountPlans.isEmpty())
                {
                    for(Account_Plan__c ap: AccountPlans)
                    {
                        string RecordTypeName = ap.Recordtype.Name;
                        
                        if(RecordTypeName != null && !String.isEmpty(RecordTypeName))
                        {
                            if(RecordTypeName == 'AA Account Plan'){ astr.AA_Account_Plan_Link__c = ap.Id; }
                            
                            if(RecordTypeName == 'SEO Account Plan'){ astr.SEO_Account_Plan_Link__c = ap.Id; }
                            
                            if(RecordTypeName == 'SMS Account Plan'){ astr.SMS_Account_Plan_Link__c = ap.Id; }
                            
                            if(RecordTypeName == 'RMS Account Plan'){ astr.RMS_Account_Plan_Link__c  = ap.Id; }
                            
                            if(RecordTypeName == 'DAA Account Plan'){ astr.DAA_Account_Plan_Link__c = ap.Id; }
                            
                            if(RecordTypeName == 'EMS Account Plan'){ astr.EMS_Account_Plan_Link__c = ap.Id; }
                        }
                    }
                }
            }
        }        
    }
}