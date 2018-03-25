//2016-04-20- fsalwen@salesforce.com- Updated to add in handling for syncing up the BrandRelationship records

public class ALL_BusinessSites_Handler 
{
    public static void fieldsettingMethod(map<ID, Business_Site__c> oldMap, list<Business_Site__c> newList)
    {
        map<string, string> ProductCodeToFranchise = new map<string, string>{ 'Chevrolet' => 'SC-14.437.01', 'Buick' => 'SC-14.488.00', 'Cadillac' => 'SC-14.527.00'};         
        set<string> accountNumberSet = new set<string>();
        set<ID> accountIDs = new set<ID>();
        map<ID, list<Service_Contract__c>> accountToServiceContracts = new map<ID, list<Service_Contract__c>>();
        list<CB_LMA_Relationship__c> toBeInsertedLMArelationships = new list<CB_LMA_Relationship__c>();
           
        if(Trigger.isDelete){ newList = oldMap.Values();}
        
        if(newList != null && !newList.isEmpty())
        {
            for(Business_Site__c bs: newList)
            {
                if(bs.LMA_Account__c != null)
                {
                    accountIDs.add(bs.LMA_Account__c);
                } 
                
                if(bs.Account__c != null)
                {
                    accountIDs.add(bs.Account__c);
                }
                
                if(bs.Account_Number__c != null)
                {                
                    accountNumberSet.add(bs.Account_Number__c);
                }
                
                if(oldMap != null)
                {
                    string accountNumber = oldMap.get(bs.ID).Account_Number__c;
                    
                    if(oldMap != null && !oldMap.isEmpty() && accountNumber != null)
                    {
                        accountNumberSet.add(accountNumber);
                    }
                }
            }
        }
        
        map<ID, Account> accountMap;
        map<ID, string> siteTypeMap = ALL_BusinessSites_Handler.getSiteTypeMap(new list<ID>(accountIDs));
        
        if(accountNumberSet != null && !accountNumberSet.isEmpty())
        {
            accountMap = new map<ID, Account>([
                Select ID, Name, Account_Number__c, Site_Type__r.Name
                //(Select Id, Name, Product_Code__c From Service_Contract__r)
                From Account
                Where ((Account_Number__c IN :accountNumberSet)
                       OR (ID IN :accountIDs)) 
                AND Account_Number__c != null
                AND isDeleted = false
            ]);
        }
        
        List<Service_Contract__c> ServiceContractList = [SELECT ID, Name, Product_Code__c, Account__c 
                                                         FROM Service_Contract__c
                                                         WHERE (Account__r.Account_Number__c IN : accountNumberSet OR Account__c IN :accountIDs)
                                                         AND Account__r.Account_Number__c != null
                                                         AND Account__r.isDeleted = false ];
        
        if(ServiceContractList != null && !ServiceContractList.isEmpty())
        {
            for(Service_Contract__c sc: ServiceContractList)
            {
                List<Service_Contract__c> ServiceContracts = accountToServiceContracts.get(sc.Account__c);
                
                if(ServiceContracts == null){ ServiceContracts = new List<Service_Contract__c>(); }
                ServiceContracts.add(sc);
                accountToServiceContracts.put(sc.Account__c, ServiceContracts);                
            }
        }
        
        map<string, Account> numberToAccount = new map<string, Account>(); 
        
        system.debug(accountMap);
        
        if(accountMap != null && !accountMap.isEmpty())
        {
            for(Account a: accountMap.values())
            {
                //accountToServiceContracts.put(a.ID, a.getSobjects('Service_Contract__r'));
                
                if(a.Account_Number__c != null)
                {
                    numberToAccount.put(a.Account_Number__c, a);
                }
            } 
        }
        
        system.debug(numberToAccount);
        
        if(Trigger.isInsert && Trigger.isBefore)
        {        
            for(Business_Site__c bs: newList)
            {
                if(bs.Account_Number__c != null)
                {
                    Account lmaAccount = numberToAccount.get(bs.Account_Number__c);
                    ID dealerAccountID = bs.Account__c != null?bs.Account__c:null;
                    
                    list<Service_Contract__c> serviceContracts;
                    if(dealerAccountID != null)
                    {
                        serviceContracts = accountToServiceContracts.get(dealerAccountID);
                    }
                    
                    CB_LMA_Relationship__c newCBLMArelation = new CB_LMA_Relationship__c();
                    
                    if(bs.Account__c != null)
                    {
                        newCBLMArelation.Dealer_Account__c = (siteTypeMap.get(bs.Account__c) != 'Local Marketing')?bs.Account__c:null;
                    }
                    newCBLMArelation.LMA_Account__c = (lmaAccount != null && lmaAccount.Site_Type__r.Name.equalsIgnoreCase('Local Marketing'))?lmaAccount.ID : null;
                    newCBLMArelation.Status__c = 'Inactive';
                    
                    
                    bs.LMA_Account__c = lmaAccount.ID;
                    
                    if(serviceContracts != null && !serviceContracts.isEmpty())
                    {
                        for(Service_Contract__c cs: serviceContracts)
                        {
                            if(bs.Franchise__c != null && cs.Product_Code__c == ProductCodeToFranchise.get(bs.Franchise__c))
                            {
                                newCBLMArelation.Status__c = 'Active'; break;
                            }
                        } 
                    }                        
                    toBeInsertedLMArelationships.add(newCBLMArelation);
                    
                }
            }
            
            if(toBeInsertedLMArelationships != null && !toBeInsertedLMArelationships.isEmpty())
            {
                insert toBeInsertedLMArelationships;
            }
        }
         
        if(Trigger.isUpdate && Trigger.isBefore)
        { 
            set<ID> BusinessAccounts = new set<ID>();
            for(Business_Site__c bs: newList)
            {  
                if(bs.LMA_Account__c != null)
                {
                    BusinessAccounts.add(bs.LMA_Account__c);
                }
                
                if(bs.Account__c != null)
                {
                    BusinessAccounts.add(bs.Account__c);
                }                
            }
            
            map<ID, CB_LMA_Relationship__c> LMArelationsMap;
            
            LMArelationsMap = new map<ID, CB_LMA_Relationship__c>([
                Select ID, Name, LMA_Account__c, Dealer_Account__c, Dealer_Account__r.Name
                From CB_LMA_Relationship__c
                Where LMA_Account__c IN :BusinessAccounts
            ]);
            
            map<ID, CB_LMA_Relationship__c> toBeDeletedRelations = new map<ID, CB_LMA_Relationship__c>();
            map<ID, CB_LMA_Relationship__c> toBeUpdatedRelations = new map<ID, CB_LMA_Relationship__c>();
            
            
            if(LMArelationsMap != null && !LMArelationsMap.isEmpty())
            {
                for(CB_LMA_Relationship__c LMArelation: LMArelationsMap.values())
                {
                    for(Business_Site__c bs: newList)
                    {
                        if(bs.Account_Number__c == null || 
                           (bs.Status__c != null && bs.Status__c.startsWithIgnoreCase('i') && bs.Account_Number__c != null))
                        {
                            bs.LMA_Account__c = null;
                            
                            if(bs.Account_Number__c != null)
                            {
                                Account lmaAccount = numberToAccount.get(oldMap.get(bs.ID).Account_Number__c);
                                
                                if(lmaAccount != null && 
                                   LMArelation.LMA_Account__c == lmaAccount.ID && bs.Status__c != null)
                                {
                                    toBeDeletedRelations.put(LMArelation.ID, LMArelation);
                                }
                            }
                        }
                        
                        //system.debug(bs.Status__c != null && bs.Status__c.startsWithIgnoreCase('a')); 
                        //system.debug(bs.Account_Number__c != null);
                        //system.debug(lmaRelation.LMA_Account__c == numberToAccount.get(bs.Account_Number__c).ID);
                        
                        if(bs.Status__c != null && bs.Status__c.startsWithIgnoreCase('a') && 
                           bs.Account_Number__c != null && numberToAccount.get(bs.Account_Number__c) != null &&
                           lmaRelation.LMA_Account__c == numberToAccount.get(bs.Account_Number__c).ID)
                        {
                            list<Service_Contract__c> serviceContracts;
                            Account lmaAccount;
                            ID dealerAccountID;
                            
                            if(LMArelation.LMA_Account__c != null)
                            {
                                lmaAccount = numberToAccount.get(LMArelation.LMA_Account__c);
                            }
                            
                            dealerAccountID = LMArelation.Dealer_Account__c != null ? LMArelation.Dealer_Account__c : null;
                            
                            if(dealerAccountID != null)
                            {
                                serviceContracts = accountToServiceContracts.get(dealerAccountID);
                            } 
                            
                            //system.debug(LMArelation.Dealer_Account__r.Name); system.debug(ServiceContracts.size());
                            
                            if(serviceContracts != null && !serviceContracts.isEmpty())
                            {
                                for(Service_Contract__c cs: serviceContracts)
                                {
                                    if(bs.Franchise__c != null && cs.Product_Code__c == ProductCodeToFranchise.get(bs.Franchise__c))
                                    {
                                        LMArelation.Status__c = 'Active'; toBeUpdatedRelations.put(LMArelation.ID, LMArelation); break;
                                    }
                                    else
                                    {
                                        LMArelation.Status__c = 'INACTIVE'; toBeUpdatedRelations.put(LMArelation.ID, LMArelation);
                                    }
                                } 
                            }                            
                        }
                    }
                }
            }
            
            if(toBeUpdatedRelations != null && !toBeUpdatedRelations.isEmpty())
            {
                Update toBeUpdatedRelations.values();
            }
            
            if(toBeDeletedRelations != null && !toBeDeletedRelations.isEmpty())
            {
                Delete toBeDeletedRelations.values(); 
            }            
        }
        
        if(Trigger.isDelete)
        {
            list<Business_site__c> oldList = oldMap.values();           
            set<ID> BusinessAccounts = new set<ID>();
            for(Business_Site__c bs: oldMap.values())
            {                
                if(bs.LMA_Account__c != null)
                {                    
                    BusinessAccounts.add(bs.LMA_Account__c);
                } 
                if(bs.Account__c != null)
                {
                    BusinessAccounts.add(bs.Account__c);
                }
            }
            
            map<ID, CB_LMA_Relationship__c> LMArelationsMap = new map<ID, CB_LMA_Relationship__c>([
                Select ID, Name, LMA_Account__c
                From CB_LMA_Relationship__c
                Where LMA_Account__c IN :BusinessAccounts
            ]);
            
            system.debug(LMArelationsMap);
            
            list<CB_LMA_Relationship__c> toBeDeletedRelations = new List<CB_LMA_Relationship__c>();
            if(LMArelationsMap != null && !LMArelationsMap.isEmpty())
            {
                for(CB_LMA_Relationship__c LMArelation: LMArelationsMap.values())
                {
                    for(Business_Site__c bs: oldMap.values())
                    {
                        Account a = numberToAccount.get(bs.Account_Number__c);
                        if(a != null && 
                           LMArelation.LMA_Account__c == a.ID)
                        {
                            toBeDeletedRelations.add(LMArelation);
                        }
                    }
                }
            }
            
            if(toBeDeletedRelations != null && !toBeDeletedRelations.isEmpty())
            {
                Delete toBeDeletedRelations; 
            } 
        }
    }
    
    public static map<ID, string> getSiteTypeMap(list<ID> accountIDsList)
    {
        map<ID, string> siteTypeIDtoName = new map<ID, string>();
        map<ID, Account> accountMap;
        
        if(!accountIDsList.isEmpty())
        {
           accountMap = new map<ID, Account>([
                Select ID, Name, Site_Type__r.Name 
                From Account
                Where ID IN :accountIDsList
            ]);
        }
        
        if(accountMap != null && !accountMap.isEmpty())
        {
            for(Account acc: accountMap.values())
            {
                siteTypeIDtoName.put(acc.ID, acc.Site_Type__r.Name);
            }
        }
        
        return siteTypeIDtoName;
    }
}