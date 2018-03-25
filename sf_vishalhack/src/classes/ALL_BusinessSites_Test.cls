@isTest
public class ALL_BusinessSites_Test 
{
    public static testMethod void unitTest()
    {
        Site_Type__c st = DS_TestObjects.NewSiteType();
        st.Name = 'Local Marketing';
        st.Active__c = true;
        
        Site_Type__c st2 = DS_TestObjects.NewSiteType();
        st2.Name = 'Auto';
        st2.Active__c = true;
        
        insert new list<Site_Type__c>{ st, st2 };
        
        Account acc = DS_TestObjects.NewAccount();
        acc.Site_Type__c = st.ID;
        acc.Account_Number__c = '12345';
                
        Account acc2 = DS_TestObjects.NewAccount();
        acc2.Site_Type__c = st2.ID;
        acc2.Account_Number__c = '123456';
        
        insert new list<Account>{ acc, acc2 };
        
        Service_Contract__c sc = new Service_Contract__c();
        sc.Account__c = acc.ID;
        sc.Product_Code__c = 'SC-14.437.01';
        
        Service_Contract__c sc2 = new Service_Contract__c();
        sc2.Account__c = acc2.ID;
        sc2.Product_Code__c = 'SC-14.488.00';
        
        insert new list<Service_Contract__c>{ sc, sc2 };
        
        Business_Site__c bs = new Business_Site__c();
        bs.LMA_Account__c = acc.ID;
        bs.Account_Number__c = acc.Account_Number__c;
        bs.Status__c = 'inactive';
        bs.Account__c = acc.ID;
        bs.Franchise__c = 'Chevrolet';
       
        Business_Site__c bs2 = new Business_Site__c();
        bs2.LMA_Account__c = acc.ID;
        bs2.Account_Number__c = acc.Account_Number__c;
        bs2.Status__c = 'active';
        bs2.Account__c = acc2.ID;
        bs2.Franchise__c = 'Chevrolet';
        
        insert new list<Business_Site__c>{ bs, bs2 };
        
        bs.Account_Number__c = '12345';
        bs2.Account_Number__c = '12345';
        update new list<Business_Site__c>{ bs, bs2 };
        
        bs.Account_Number__c = null;
        update bs;
                
        delete bs;
    }
}