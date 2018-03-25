/*******************************************************************************
**RQ-08648  02/22/2017 Created Vijay.Manimaran@cdk.com

********************************************************************************* */
@isTest
public class ALL_PortalForm_Handler_Test {
    
    @Testsetup
    public static void setupData()
    {               
        
        Id AccountRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account', 'ADPDS Other Account');
        Id ContactRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Internal HR Contact');
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'Manager Termination Form');
        Id workFlowRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('WorkFlow__c', 'COM - Employees Termination');
        Id portalFormsPRCRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'COM Bank of America');
        Id workFlowPRCRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('WorkFlow__c', 'COM - Procurement');
        
        User ur = DS_TestObjects.NewUser();
        insert ur;
        Account a = new Account(
            Name = 'CDK Global',
            RecordTypeId = AccountRecordTypeId
        ); 
        {
            insert a;
        }
        User u = [select id from user Limit 1];
        
        Contact contactObj1 = DS_TestObjects.NewContact();
        contactObj1.RecordTypeId = ContactRecordTypeId;
        contactObj1.AccountId = a.Id;
        contactobj1.User__c = U.id;
        insert contactObj1;
        
        Contact contactObj = DS_TestObjects.NewContact();
        contactObj.RecordTypeId = ContactRecordTypeId;
        contactobj.User__c = UserInfo.getUserId();
        contactobj.AccountId = a.Id;
        contactobj.HR_Manager__c = contactObj1.Id;
        insert contactobj;
        
        
        Contact contactObj3 = DS_TestObjects.NewContact();
        contactObj3.RecordTypeId = ContactRecordTypeId;
        contactObj3.AccountId = a.Id;
        contactobj3.User__c = U.id;
        contactobj3.HR_Manager__c = contactobj.Id;
        contactObj3.FirstName = 'testing';
        contactObj3.LastName = 'test_LastName';
        insert contactobj3;
    }
    
    static testMethod void testBankofAmericaController() 
    {
        
        Id AccountRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account', 'ADPDS Other Account');
        Id ContactRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Internal HR Contact');
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'Manager Termination Form');
        Id workFlowRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('WorkFlow__c', 'COM - Employees Termination');
        Id portalFormsPRCRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'COM Bank of America');
        Id workFlowPRCRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('WorkFlow__c', 'COM - Procurement');
        
        test.startTest();
        
        ALL_PortalForm_Handler PFH = new ALL_PortalForm_Handler();
        Contact contactSelected = [Select id, FirstName from Contact where FirstName ='testing'];
                Portal_Form__c portalForms_BOA = new Portal_Form__c();
        portalForms_BOA.Contact__c = contactSelected.id;
        portalForms_BOA.RecordTypeId = portalFormsPRCRecordTypeID;
        Portal_Form__c pForms_BOA =  EMP_ManagerTermination_Controller.createPortalForms(portalForms_BOA);

        
        Portal_Form__c portalForms = new Portal_Form__c();
        portalForms.Contact__c = contactSelected.id;
        portalForms.RecordTypeId = portalFormsRecordTypeID;
        portalForms.Mgr_Term_HRBP_Email__c ='test@gmail.com';
        Portal_Form__c pForms =  EMP_ManagerTermination_Controller.createPortalForms(portalForms);
        Portal_Form__c pf = [select Id, Name,recordtypeID, CreatedDate, CreatedById,Contact__r.Name,Contact__r.hr_Manager__r.Name, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, 
                             LastReferencedDate, DMSRSA_Associate_Name__c, HR_Termination_Date__c, Contact__c, Mgr_Term_Form_Completed__c, Mgr_Term_Involuntary_Reason__c,
                             Mgr_Term_Involuntary__c, Mgr_Term_Q017_HRBP_Email__c, Mgr_Term_Q018_Pass__c, Mgr_Term_Q01_myCareer__c, 
                             Mgr_Term_Q01a_myCareer__c, Mgr_Term_Q02_HRBP__c, Mgr_Term_Q03_employeeData__c, Mgr_Term_Q04_employeeFleetVechicle__c,
                             Mgr_Term_Q05_employeeCarAllowance__c, Mgr_Term_Q06_employeeAddress__c, Mgr_Term_Q07_employeeCellPhone__c, 
                             Mgr_Term_Q08_employeeExpenseReport__c, Mgr_Term_Q09_employeeDirectReport__c, Mgr_Term_Q09a_employeeDirectReport__c,
                             Mgr_Term_Q10_employeeeTime__c, Mgr_Term_Q11_employeeCanada__c, Mgr_Term_Q12_salesEmployee__c,Mgr_Term_HRBP_Email__c,
                             Mgr_Term_Q13_employeeEquipment__c, Mgr_Term_Q13a_employeeEquipment__c, Mgr_Term_Q14_employeeFacility__c,
                             Mgr_Term_Q15_employeeKeys__c, Mgr_Term_Q16_clientDocuments__c, Mgr_Term_Q17_creditCard__c, Mgr_Term_Q18_Immigration__c, 
                             Mgr_Term_Q19_employeeDirectReport__c, Mgr_Term_Q20_salesEmployee__c, Mgr_Term_Q21_employeeCellPhone__c, Mgr_Term_Work_Location__c,
                             Termination_Manager__r.Name from Portal_Form__c where contact__c =: contactSelected.Id];
        
        Portal_Form__c pforms_1 = EMP_ManagerTermination_Controller.insertAssociate(portalForms,  pf.id, 'true');
        
        list<Portal_Form__c> portalFormsList = new list<Portal_Form__c>();
        portalFormsList = [select Id,recordtypeID, Name, CreatedDate, CreatedById,Contact__r.Name,Contact__r.hr_Manager__r.Name, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, 
                           LastReferencedDate, DMSRSA_Associate_Name__c, HR_Termination_Date__c, Contact__c, Mgr_Term_Form_Completed__c, Mgr_Term_Involuntary_Reason__c,
                           Mgr_Term_Involuntary__c, Mgr_Term_Q017_HRBP_Email__c, Mgr_Term_Q018_Pass__c, Mgr_Term_Q01_myCareer__c, Mgr_Term_HRBP_Email__c,
                           Mgr_Term_Q01a_myCareer__c, Mgr_Term_Q02_HRBP__c, Mgr_Term_Q03_employeeData__c, Mgr_Term_Q04_employeeFleetVechicle__c,
                           Mgr_Term_Q05_employeeCarAllowance__c, Mgr_Term_Q06_employeeAddress__c, Mgr_Term_Q07_employeeCellPhone__c, 
                           Mgr_Term_Q08_employeeExpenseReport__c, Mgr_Term_Q09_employeeDirectReport__c, Mgr_Term_Q09a_employeeDirectReport__c,
                           Mgr_Term_Q10_employeeeTime__c, Mgr_Term_Q11_employeeCanada__c, Mgr_Term_Q12_salesEmployee__c,
                           Mgr_Term_Q13_employeeEquipment__c, Mgr_Term_Q13a_employeeEquipment__c, Mgr_Term_Q14_employeeFacility__c,
                           Mgr_Term_Q15_employeeKeys__c, Mgr_Term_Q16_clientDocuments__c, Mgr_Term_Q17_creditCard__c, Mgr_Term_Q18_Immigration__c, 
                           Mgr_Term_Q19_employeeDirectReport__c, Mgr_Term_Q20_salesEmployee__c, Mgr_Term_Q21_employeeCellPhone__c, Mgr_Term_Work_Location__c,
                           Termination_Manager__r.Name from Portal_Form__c where id =: pforms_1.Id];
        ALL_PortalForm_Handler.insertUpdateWorkflow(portalFormsList);
        set<Id> pfid = new set<Id>();
        for(Portal_Form__c PFS: portalFormsList){
            pfid.add(PFS.id);
        }
      	ALL_PortalForm_Handler.updatePortalForms(pfid);
        test.stopTest();
    }
}