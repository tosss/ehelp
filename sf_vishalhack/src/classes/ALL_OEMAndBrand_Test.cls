// 5/24/2016 - siva.pragada@cdk.com - created
@isTest
public class ALL_OEMAndBrand_Test 
{
    @TestSetup static void insertObjects()
    {
        Site_Type__c st = DS_TestObjects.NewSiteType();
        st.Name = 'Local Marketing';
        st.Active__c = true;
        
        Site_Type__c st2 = DS_TestObjects.NewSiteType();
        st2.Name = 'Auto';
        st2.Active__c = true;
        
        Site_Type__c sType = DS_TestObjects.NewSiteType();
        sType.Active__c = true;
        sType.Name = 'Brand';
        sType.Corporation_Flag__c = true;
        sType.District_Flag__c = true;
        sType.Group_Flag__c = true;
        
        insert new list<Site_Type__c>{ st, st2, sType };
            
        Account acc = DS_TestObjects.NewAccount();
        acc.Site_Type__c = st.ID;
        acc.Account_Number__c = '12345';
        
        Account acc2 = DS_TestObjects.NewAccount();
        acc2.Site_Type__c = st2.ID;
        acc2.Account_Number__c = '123456';
        acc2.Migration_ID__c = '90000000';
        
        Account brandAccount = new Account();
        Id brandREcordTypeID = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account', 'CDK OEM/Brand');
        brandAccount.Name = 'Chevrolet';
        brandAccount.Migration_ID__c = 'CVLT - Auto';
        brandAccount.RecordTypeId = brandREcordTypeID;
        brandAccount.Site_Type__c = sType.ID;
        brandAccount.Franchise__c = 'Chevrolet';
        
        Account brandAccount2 = new Account();        
        brandAccount2.Name = 'Bentley';
        brandAccount2.Migration_ID__c = 'BNTL - Auto';
        brandAccount2.RecordTypeId = brandREcordTypeID;
        brandAccount2.Site_Type__c = sType.ID;
        brandAccount2.Franchise__c = 'Bentley';
        
        
        insert new list<Account>{ acc, acc2, brandAccount, brandAccount2 };
       
        BrandRelationship__c Br = new BrandRelationship__c();
        Br.Migration_ID__c = 'BNTL - Auto' + '@' + '90000000';
        //Br.Brand__c = Brand2.ID;
        Br.Dealership__c = acc2.ID;
        insert Br;
            
        Business_Site__c bs = new Business_Site__c();
        bs.LMA_Account__c = acc.ID;
        bs.Account_Number__c = acc.Account_Number__c;
        bs.Status__c = 'inactive';
        bs.Account__c = acc.ID;
        bs.Franchise__c = 'Chevrolet';
        bs.Region__c = 'North America';
        bs.CID__c = 'cid';
        bs.IMR__c = 'imr';
        bs.Region__c = 'Pacific Ocean';
        
        Business_Site__c bs2 = new Business_Site__c();
        bs2.LMA_Account__c = acc.ID;
        bs2.Account_Number__c = acc.Account_Number__c;
        bs2.Status__c = 'active';
        bs2.Account__c = acc2.ID;
        bs2.Franchise__c = 'Bentley';
        bs2.Region__c = 'South America';
        bs2.CID__c = 'cid2';
        bs2.IMR__c = 'imr2';
        
                
        insert new list<Business_Site__c>{ bs, bs2 };
    }
    
    static testMethod void uniTest()
    {
        list<Business_Site__c> bSiteList = [Select ID From Business_Site__c];
        Update bSiteList;
    }
}