public class DSCB_CaseAssignment 
{
    //  Case Assignment rule through the trigger based on Account Plan resource fields added 11/24/2014 SivaP
    public static void CaseAssignmentRule(list<case> newCaseRecords, map<Id, Case>AllOldCasesMap)
    {
        boolean AllowForSettingSecondaryOwner = false;
        
        if(Trigger.isInsert)
        {
            AllowForSettingSecondaryOwner = true;
        }
        
        // get all the webIds that are in the CasesToAssign
        set<ID> WebIds = new set<ID>();
        list<case> newSEOCases = new list<case>();
        
        for(case c: newCaseRecords)
        { 
            system.debug(c.RecordType.Name);
            system.debug(c.CaseNumber);
            
            string RecordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('case', c.RecordTypeId);
            if(RecordTypeName.toLowerCase() == 'inquiry - seo')
            {
                newSEOCases.add(c);
                WebIds.add(c.WebID__c);
                
                system.debug(newSEOCases);
                system.debug(WebIds);
            }            
        }

        // query all the account plans that are related to the WebIds but with filters
        map<ID, Account_Plan__c> UniqueAccountPlan;
        if(WebIds != null && !WebIds.isEmpty())
        {
            UniqueAccountPlan = new map<ID, Account_Plan__c>([
                select Id, Name, RecordType.DeveloperName, Account_Status__c, Owner.Name, Secondary_Owner__r.Name, Additional_Resource__r.Name,
                WebId__c, RecordType.Name
                From Account_Plan__c
                Where (RecordType.Name = 'SEO Account Plan'
                       OR RecordType.Name = 'PowerSEO Account Plan')
                AND (Account_Status__c = 'Active' OR Account_Status__c = 'Onboarding') 
                AND WebId__c IN :WebIds
            ]);
        }
        
        //system.debug(UniqueAccountPlan.values());
        //system.debug(UniqueAccountPlan.values().size());
               
        if(newSEOCases != null && !newSEOCases.isEmpty())
        {        
            for(case c: newSEOCases)
            {
                Case OldVersionOfCurrentCase;
                
                if(Trigger.isUpdate && AllOldCasesMap.keySet() != null && !AllOldCasesMap.keySet().isEmpty()) 
                { 
                    OldVersionOfCurrentCase = AllOldCasesMap.get(c.Id);
                    
                    if(OldVersionOfCurrentCase != null)
                    {
                        if(!(OldVersionOfCurrentCase.Product_Category__c == 'Performance' && 
                             OldVersionOfCurrentCase.Priority == '1-ONE Business Day'))
                        {
                            AllowForSettingSecondaryOwner = true;
                        }
                    }
                }              
                
                              
                if(UniqueAccountPlan.values() != null && !UniqueAccountPlan.values().isEmpty())
                {
                    for(Account_Plan__c ap: UniqueAccountPlan.values())
                    {
                        if(c.WebID__c == ap.WebID__c)
                        {
                            system.debug(c.ownerId == ap.OwnerId);
                            system.debug(c.ownerId == ap.Secondary_Owner__c);
                            system.debug(c.ownerId == ap.Additional_Resource__c);
                            system.debug(c.Product_Category__c ==  'Performance' && c.Priority == '1-ONE Business Day');
                            system.debug(AllowForSettingSecondaryOwner);
                            
                            if((c.ownerId == ap.OwnerId || c.ownerId == ap.Secondary_Owner__c || c.ownerId == ap.Additional_Resource__c) &&
                              !Trigger.isUpdate)
                            {
                                system.debug('here1');
                                c.ownerId = userInfo.getUserId(); break;                       
                            }  
                            else if(c.Product_Category__c ==  'Performance' && 
                                    c.Priority == '1-ONE Business Day' && 
                                    ap.Secondary_Owner__c != null &&
                                    AllowForSettingSecondaryOwner)
                            {                         
                                system.debug('here2');
                                c.OwnerId = ap.Secondary_Owner__c; break;                                
                            }
                            else 
                            {                    
                                if(!Trigger.isUpdate)
                                {
                                    system.debug('here3');
                                    c.OwnerId = ap.OwnerId; break;       
                                } 
                            }
                        }     
                    }
                }
            } 
        }   
    }  
}