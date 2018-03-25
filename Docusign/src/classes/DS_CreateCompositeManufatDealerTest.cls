@isTest
public class DS_CreateCompositeManufatDealerTest {
    public static testmethod void testCompositeExtIdUpdateTrigger()
    {
        Account a = new Account(Name='testAccount');
        insert a;
        
        Manufacturer__c m = new Manufacturer__c();
        insert m;
        
        Manufacturer_At_Dealership__c md = new MAnufacturer_At_Dealership__c(Account__c = a.id, Manufacturer__c = m.id);
        insert md;
        
        Manufacturer__c m2 = new Manufacturer__c();
        insert m2;
        
        md.Manufacturer__c = m2.id;
        update md;
    }
}