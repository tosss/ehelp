//2015-11-27 : vishal.bandari@cdk.com - RQ-05289:changed testMethod1 method to add contact record type
@isTest
private class EMP_HRInvoluntaryController_Test{
    
    static testMethod void testMethod1() {
        Test.startTest();
        
        Account ac = new Account();
        ac.name ='test';
        insert ac;
        
        Page_Component__c pg = new Page_Component__c();
        pg.name='EMP_HRInvoluntaryTermination';
        insert pg;
        
        Contact ct = new Contact();
        ct.Accountid=ac.id;
        ct.Firstname ='test';
        ct.LastName ='TEstLastName';
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        ct.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Internal HR Contact');
        insert ct;
        
        CustomSettings__c setting = new CustomSettings__c();
        setting.Name = 'Test Setting';
        setting.CDK_Global_Account_Id__c = ac.id;
        insert setting;
        
        EMP_HRInvoluntaryController objEmp = new EMP_HRInvoluntaryController();
        EMP_HRInvoluntaryController.SearchContacts(null);
        EMP_HRInvoluntaryController.SearchContacts('test');
        EMP_HRInvoluntaryController.submitForm(ct.id, System.today().format(), '00', '00', 'AM');
        EMP_HRInvoluntaryController.submitForm(ct.id, System.today().format(), null, null, null);
        EMP_HRInvoluntaryController.submitForm(ct.id, System.today().format(), '00', null, null);
        EMP_HRInvoluntaryController.submitForm(ct.id, System.today().format(), '00', '00', null);
        
        Date dt = System.today()-2;
        EMP_HRInvoluntaryController.submitForm(ct.id, dt.format(), '00', '00', 'AM');
        EMP_HRInvoluntaryController.submitForm(ct.id, null, '00', '00', 'AM');
        EMP_HRInvoluntaryController.submitForm(null, System.today().format(), '00', '00', 'AM');
        
        EMP_HRInvoluntaryController.result objr = new EMP_HRInvoluntaryController.result();
        EMP_HRInvoluntaryController.result objrTemp = new EMP_HRInvoluntaryController.result(true);
        
        // EMP_HRInvoluntaryController.result.submitForm(ct.id, null, null, null, null);
        /*EMP_HRInvoluntaryController.EMP_HRInvoluntaryController.result.submitForm(ct.id, System.today()+'', null, null, null);
        EMP_HRInvoluntaryController.EMP_HRInvoluntaryController.result.submitForm(ct.id, System.today()+'', '00', null, null);
        EMP_HRInvoluntaryController.EMP_HRInvoluntaryController.result.submitForm(ct.id, System.today()+'', '00', '00', null);
        EMP_HRInvoluntaryController.EMP_HRInvoluntaryController.result.submitForm(ct.id, System.today()+'', '00', '00', 'AM');
        */
        
        objEmp.doCancel();
        
        
        Test.stopTest();
        
    }
    
}