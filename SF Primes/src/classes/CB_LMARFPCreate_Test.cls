//Request - 04926: RFP to USIM contacts via VF Page and route to LMA Strategist - Test class for CB_LMA_RFP_Extension
//10/08/15 smitha.simhadri@cdk.com Created
//2015-11-27    vishal.bandari@cdk.com    RQ-05289:changed setupTestData method to add contact record type
@isTest
public class CB_LMARFPCreate_Test {    
    
    @TestSetup static void setupTestData()
    {
        
        System.debug('Start Time is: ' +  DateTime.now().getTime());
        
        
        Site_Type__c LMsiteType = DS_TestObjects.NewSiteType();
        //LMsiteType.Name='Local Marketing';
        LMsiteType.Name='Advertisers';
        LMsiteType.Corporation_Flag__c=true;
        LMsiteType.Active__c=true;              
        //insert LMsitetype;
        
        Site_Type__c siteType = DS_TestObjects.NewSiteType();
        //siteType.Name='Test Site Type';
        siteType.Name='Local Marketing';
        siteType.Corporation_Flag__c=true;
        siteType.Active__c=true; 
        
        insert new list<Site_Type__c> { sitetype, LMsitetype};
        
        //Creating account records.
        Account agencyAcct=DS_TestObjects.NewAccount(); 
        agencyAcct.Name='Test Agency Acct';
        agencyAcct.Site_Type__c=LMsiteType.Id;
        insert agencyAcct;
        System.debug('New Agency Account Id '+ agencyAcct.Id);
        
        
        System.debug('New Site Type Id: '+ sitetype.Id);
        
        Account LMAacct=DS_TestObjects.NewAccount(); 
        LMAacct.name='Test BG LMA Acct';
        LMAacct.ParentId=agencyAcct.Id;
        LMAacct.Site_Type__c=siteType.Id;
        //insert LMAacct;
        //System.debug('New LMA Acct Id: '+ LMAAcct.Id);      
        
        User newUser=DS_TestObjects.NewUser();
        newUser.UserName='LMARFPtest@cdk.com'; 
        newUser.Email='LMARFPtest@cdk.com'; 
        newUser.Alias='LMARFP1';
        newUser.EmailEncodingKey='UTF-8'; 
        newUser.FirstName='Apex';
        newUser.LastName='Test User';
        newUser.LanguageLocaleKey='en_US';
        newUser.LocaleSIDKey='en_US';        
        Profile p = [select Id from Profile Where Name='ADPDS - Admin - System Administrator'];
        newUser.profileid=p.Id;
        newUser.TimeZoneSIDKey='America/Chicago';            
        newUser.ADID__c='LMARFP1';
        newUser.FederationIdentifier = 'LMARFP1';     
        insert newUser;     
        System.debug('New user Inserted: ' + newUser.Id);       
        
        
        Contact newContact = DS_TestObjects.NewContact();
        newContact.LastName = 'Test User';
        newContact.FirstName = 'Apex';
        newContact.Title__c = 'Manager';
        newContact.Department__c = 'Service';
        newContact.Role__c = 'Test Role' ;
        newContact.User__c = newUser.Id;
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        newContact.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        newContact.AccountId = agencyAcct.Id  ;
        
        system.RunAs(DS_TestObjects.CurrentUser()) { insert newContact; }
        
        System.debug('New Contact Inserted: ' + newContact.Id);
        
        Manufacturer__C newMfgr = new Manufacturer__c();
        newMfgr.name='Buick';
        insert newMfgr;
        System.debug('New manufacturer inserted: '+ newMfgr.Id);
        
        Manufacturer_At_DealerShip__c newMfgrAtDlr = new Manufacturer_At_Dealership__c();
        //newMfgrAtDlr.name = 'Test Mfgr At Dlrship';
        newMfgrAtDlr.manufacturer__C=newMfgr.id;
        newMfgrAtDlr.account__c=agencyAcct.id;
        //insert newMfgrAtDlr;
        //System.debug('New Mfgr At Dealership Inserted: '+ newMfgrAtDlr.Id);
        
        Business_Site__C newBusSite = new Business_Site__c();
        newBusSite.Franchise__c = 'Buick';
        newBusSite.status__c = 'A';
        //insert newBusSite;
        //System.debug('New Business Site Inserted: '+ newBusSite.Id);
        
        CB_LMA_Mfgr_Record_Types__c newRecTypeCS = new CB_LMA_Mfgr_Record_Types__c();
        newRecTypeCS.Name = 'Buick';
        newRecTypeCS.Franchise__c = 'Buick';
        newRecTypeCS.Record_Type__c='BG';
        //insert newRecTypeCS;
        //System.debug('New record in custom setting CB_LMA_Mfgr_Record_Types__c Inserted: ' + newRecTypeCS.Id);
        
        CB_LMA_RFP_Models__c newModelCS1 = new CB_LMA_RFP_Models__c(name = 'Acadia', manufacturer__c = 'BG');
        //insert newModelCS1;
        //System.debug('New Model - Acadia Inserted in custom setting CB_LMA_RFP_Models__c: ' + newModelCS1.Id);
        
        CB_LMA_RFP_Models__c newModelCS2 = new CB_LMA_RFP_Models__c(name = 'Acadia Denali', manufacturer__c = 'BG');
        //insert newModelCS2;
        //System.debug('New Model - Acadia Denali Inserted in custom setting CB_LMA_RFP_Models__c: ' + newModelCS2.Id);
        
        CB_LMA_RFP_Models__c newModelCS3 = new CB_LMA_RFP_Models__c(name = 'Encore', manufacturer__c = 'BG');
        //insert newModelCS3;
        //System.debug('New Model - Encore Inserted in custom setting CB_LMA_RFP_Models__c: ' + newModelCS3.Id);
        
        CB_LMA_RFP_Models__c newModelCS4= new CB_LMA_RFP_Models__c(name = 'Enclave', manufacturer__c = 'BG');
        //insert newModelCS4;    
        //System.debug('New Model - Enclave Inserted in custom setting CB_LMA_RFP_Models__c: ' + newModelCS4.Id);
        
        insert new list<sObject>{newModelCS1, newModelCS2, newModelCS3, newModelCS4, newRecTypeCS, newBusSite, newMfgrAtDlr, LMAacct};
        
    }   
    
    private static Account getAccount()
    {
        list<Account> actList = [select Id from Account where Name = 'Test BG LMA Acct'];
        Account act;
        if(actList.size() == 0){
            system.assert(false,'no test account');
        } else {
            act = actList[0];
        }
        
        return act;
    }
    
    private static User getUser()
    {
        User testUser = [select Id from User where firstname='Apex' and lastname='Test User'];
        return testUser;
        
    }
    
    
    public static testMethod void testLMARFP() 
    {
        
        User LMAUser = getUser();
        System.debug('new LMAUser retrieved is: '+LMAuser);
        
        System.runAs(LMAUser)            
        {
            LMA_RFP__c lmaRfp = new LMA_RFP__c();
            
            ApexPages.StandardController stdController = new ApexPages.standardController(lmaRfp);
            
            CB_LMARFPCreate_Extension LMARFPExt = new CB_LMARFPCreate_Extension(stdController);
            
            Set<String> testRecTypes = LMARFPExt.rfpRecTypes;
            System.debug('testRecTypes are: '+testRecTypes);
            
            List<SelectOption> testSelOptRecTypes = LMARFPExt.getRFPrecTypeOptions();
            System.debug('testSelOptRecTypes are: '+testSelOptRecTypes);
            
            LMARFPExt.selectedRecType = 'BG';
            
            List<Account> testLMAs = LMARFPExt.lmas;
            System.debug('testLMAs are: '+testLMAs);
            
            LMARFPExt.getlmaoptions();
            System.debug('LMAAccts are: '+LMARFPExt.LMAAccts);
            System.debug('LMAModels are: '+LMARFPExt.LMAModels);            
            
            
            LMARFPExt.selectedLMA = 'Test BG LMA Acct';
            LMARFPExt.selectedModelOne = 'Acadia';
            LMARFPExt.selectedModelTwo = 'Encore';
            LMARFPExt.selectedModelThree = null;
            LMARFPExt.selectedModelFour = null;
            
            
            lmarfp.Strategy_Split_1__c='100% Retention';          
            lmarfp.Strategy_Split_2__c='50% Conquest/50% Retention';
            PageReference pgRef = LMARFPExt.Save();
            System.debug('Page Reference is: '+pgRef);
            
            System.assertNotEquals(null, pgRef);    
            
            LMA_RFP__c LMARFPInsRec = [
                Select id, name
                from LMA_RFP__c
                where id = :LMARFPExt.rfp.id];
            
            System.assertNotEquals(null, LMARFPInsRec.Id);            
            
            System.debug('End Time is: ' +  DateTime.now().getTime());
            
            
        }
    }
}