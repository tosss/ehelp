@isTest
public class EMP_DMSRSA_ITRequestForms_Test {
    @testSetup static void prepareTestData()
    {
        Account acct= new Account();
        acct.Name ='CDK Global';
        acct.Segment_Code__c = 'NAAT';
        acct.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account','ADPDS HR Internal');
        insert acct;
        
        CustomSettings__c cs=CustomSettings__c.getOrgDefaults();
        if(cs==Null)
        {
            cs=new CustomSettings__c();
        }
        cs.CDK_Global_Account_Id__c=acct.Id;
        insert cs;
        
        system.debug('**********cdk account ' +acct.id);
        Contact con = new Contact();
        con.LastName = 'testL';
        con.FirstName = 'testF'; 
        con.Email = 'tbd@test.com';
        con.AccountId = acct.id;
        con.Status__c = 'Active';
        con.User__c= userinfo.getUserId();
        insert con;
        
        Contact con1 = new Contact();
        con1.LastName = 'testLN';
        con1.FirstName = 'testFN'; 
        con1.Email = 'tbd@testn.com';
        con1.AccountId = acct.id;
        con1.Status__c = 'Active';
        con1.User__c= userinfo.getUserId();
        con1.HR_Manager__c = con.Id;
        insert con1;
        
        Contact con2 = new Contact();
        con2.LastName = 'testL1';
        con2.FirstName = 'testF1'; 
        con2.Email = 'tbd@test1.com';
        con2.AccountId =acct.id;
        con2.Status__c ='Active';
        con2.User__c= userinfo.getUserId();
        con2.HR_Manager__c = con1.Id;
        insert con2;
        
        Portal_Form__c aform = new Portal_Form__c();
        system.debug('***  con1.LastName '+  con1.LastName); 
        aform.DMSRSA_Associate_Name__c = con2.id;
        aform.DMS_RSA_Type__c = 'DMS RSA Associate';
        aform.DMSRSA_Group_Name__c = 'test group';
        aform.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c','DMS RSA Associate');
        insert aform;

    }
    
    static testMethod void testValidateFormAccess() 
    {
        test.startTest();
        
        list<Portal_Form__c> portalForms = new list<Portal_Form__c>();
        
        portalForms = [select id, name,recordTypeID from Portal_Form__c limit 1 ];
        
        EMP_DMSRSA_ITRequestForms_Controller.validateFormAccess(userinfo.getUserId(), portalForms);
        EMP_DMSRSA_ITRequestForms_Controller controllerreq = new EMP_DMSRSA_ITRequestForms_Controller();
        controllerreq.showPage= true;
        
        test.stopTest();
    }
    
}