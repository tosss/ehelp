public class ALL_BrandRelationship_Handler 
{
    public static void invokeMainMethod()
    {
        List<BrandRelationship__c> newList = Trigger.new != null ? (List<BrandRelationship__c>)Trigger.new : new list<BrandRelationship__c>();
        Map<ID, BrandRelationship__c> oldMap = Trigger.oldMap != null ? (Map<ID, BrandRelationship__c>)Trigger.oldMap : new Map<ID, BrandRelationship__c>();
        
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            ALL_BrandRelationship_Handler.insertProcessUpdates(newList, oldMap);
        }
        
        if(Trigger.isDelete)
        {
            ALL_BrandRelationship_Handler.deleteProcessUpdates(newList);
        }
        
    }
    
    private static void insertProcessUpdates(List<BrandRelationship__c> newList, Map<ID, BrandRelationship__c> oldMap)
    {
        boolean updateDealerships = false;
        map<String, Account> accountsByMigrationID = DS_ManufacturersAtDealership_Handler.getAccountsByMigrationID();
        Map<ID, Account> dealershipAccountsMap;
        Set<String> dealershipAccIDs = new Set<String>();
        
        if(!newList.isEmpty())
        {
            for(BrandRelationship__c brl: newList)
            {
                dealershipAccIDs.add(brl.Dealership__c);
                dealershipAccIDs.add(brl.GM_BAC_Dealer__c);
            }
        }
        
        if(!dealershipAccIDs.isEmpty())
        {
            dealershipAccountsMap = new Map<ID, Account>([
                Select ID, Name, Make__c, OEM__c, BAC_List__c
                From Account
                Where ID IN :dealershipAccIDs
            ]);
        }
        
        if(!newList.isEmpty())
        {
            for(BrandRelationship__c brl: newList)
            {
                if(brl.Active__c == true)
                {
                    
                    BrandRelationship__c oldBrl = oldMap.get(brl.ID);
                    
                    if(oldBrl != null)
                    {
                        oldBrl.recalculateFormulas();
                    }
                    
                    brl.recalculateFormulas();
                    
                    String brandRelationID = brl.Migration_ID__c;
                    
                    if(brandRelationID != null)
                    {
                        String brandRelMigrationID = brandRelationID.substringBefore('@');
                        
                        if(brandRelMigrationID != null)
                        {
                            Account brandAccount = accountsByMigrationID.get(brandRelMigrationID);
                            Account dealershipAccount = dealershipAccountsMap.get(brl.dealership__c);
                            
                            String make = (String)dealershipAccount.Make__c;
                            String OEM = (String)dealershipAccount.OEM__c;
                            String BAClist = (String)dealershipAccount.BAC_List__c;
                            
                            if(make != null)
                            {
                                Set<String> makeSet = new Set<String>(make.Split(';'));
                                
                                if(makeSet != null)
                                {
                                    makeSet.add(brandAccount.Name);
                                    String makeValue = '';
                                    
                                    for(String s: makeSet)
                                    {
                                        if(s != null && s != 'null')
                                        {
                                            s = s.normalizeSpace();
                                            makeValue = makeValue + s + ';';
                                        }                                    
                                    }
                                    
                                    dealershipAccount.Make__c = makeValue;
                                }
                            }
                            else
                            {
                                if(brandAccount.Name != null)
                                {
                                    dealershipAccount.Make__c = brandAccount.Name;
                                }
                            }
                            
                            if(OEM != null)
                            {
                                Set<String> OEMset = new Set<String>(OEM.split(';'));
                                
                                if(OEMset != null)
                                {
                                    OEMset.add(brandAccount.Brand_OEM__r.Name);
                                    String OEMvalue = '';
                                    
                                    for(String s: OEMset)
                                    {
                                        if(s != null && s != 'null')
                                        {
                                            s = s.normalizeSpace();
                                            OEMvalue = OEMvalue + s + ';';
                                        }
                                        
                                    }
                                    
                                    dealershipAccount.OEM__c = OEMvalue;
                                }
                            }
                            else
                            {
                                if(brandAccount.Brand_OEM__r.Name != null)
                                {
                                    dealershipAccount.OEM__c = brandAccount.Brand_OEM__r.Name;
                                }
                            }
                            
                            if(BAClist != null)
                            {
                                Set<String> BacListSet = new Set<String>(BAClist.Split(';'));
                                boolean ChangedBAC = (oldBrl != null && brl.GM_BAC_Dealer__c != oldBrl.GM_BAC_Dealer__c);
                                //system.assertEquals(brl.GM_BAC_Dealer__c, '83737373');
                                if(BacListSet != null)
                                {
                                    if(ChangedBAC)
                                    { 
                                        BacListSet.remove(oldBrl.GM_BAC_Dealer__c);
                                        BacListSet.add(brl.GM_BAC_Dealer__c);
                                    }
                                    else
                                    {
                                        if(!BacListSet.contains(brl.GM_BAC_Dealer__c))
                                        {
                                            BacListSet.add(brl.GM_BAC_Dealer__c);
                                        }
                                    }
                                    
                                    String BacValue = '';
                                    
                                    for(String s: BacListSet)
                                    {
                                        if(s != null && s != 'null')
                                        {
                                            s = s.normalizeSpace();
                                            BacValue = BacValue + s + ';';
                                        }                                    
                                    }
                                    
                                    dealershipAccount.BAC_List__c = BacValue;
                                }
                            }
                            else
                            {
                                if(brl.GM_BAC_Dealer__c != null)
                                {
                                    dealershipAccount.BAC_List__c = brl.GM_BAC_Dealer__c;
                                }
                            }
                            
                            updateDealerships = true;
                            
                            dealershipAccountsMap.put(dealershipAccount.ID, dealershipAccount);
                        }                    
                    }
                    
                }
            }
        }
        
        if(updateDealerships)
        {
            Update dealershipAccountsMap.values();
        }
    }
    
    private static void deleteProcessUpdates(List<BrandRelationship__c> newList)
    {
        Set<ID> dealershipAccIDs = new Set<ID>();
        Map<ID, Account> dealershipAccountsMap;
        
        if(!newList.isEmpty())
        {
            for(BrandRelationship__c brl: newList)
            {
                dealershipAccIDs.add(brl.Dealership__c);
            }
        }
        
        if(!dealershipAccIDs.isEmpty())
        {
            dealershipAccountsMap = new Map<ID, Account>([
                Select ID, Name, Make__c
                From Account
                Where ID IN :dealershipAccIDs
            ]);
        }
        
        if(dealershipAccountsMap != null && !dealershipAccountsMap.isEmpty())
        {
            for(Account acc: dealershipAccountsMap.values())
            {
                acc.Make__c = null;
                dealershipAccountsMap.put(acc.ID, acc);
            }
        }
        
        if(dealershipAccountsMap != null && !dealershipAccountsMap.isEmpty())
        {
           Update dealershipAccountsMap.values(); 
        }
    }
}