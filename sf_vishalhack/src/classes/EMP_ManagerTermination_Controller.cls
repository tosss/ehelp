/*******************************************************************************
** RQ-08648 02/22/2017 Created Vijay.Manimaran@cdk.com

********************************************************************************* */
public class EMP_ManagerTermination_Controller {
    
    @AuraEnabled
    Public static Portal_Form__c createPortalForms(Portal_Form__c portalForms){
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'Manager Termination Form');
        Id workFlowRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('WorkFlow__c', 'COM - Employees Termination');
        
        Portal_Form__c PF = New Portal_Form__c();
        try{
            PF = [SELECT
                  Id, Name, CreatedDate,Contact__r.Name,Contact__r.hr_Manager__r.Name, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,
                  LastViewedDate,LastReferencedDate, DMSRSA_Associate_Name__c, HR_Termination_Date__c, Contact__c, Mgr_Term_Form_Completed__c, Mgr_Term_Involuntary_Reason__c,
                  Mgr_Term_Involuntary__c, Mgr_Term_Q017_HRBP_Email__c, Mgr_Term_Q018_Pass__c, Mgr_Term_Q01_myCareer__c, 
                  Mgr_Term_Q01a_myCareer__c, Mgr_Term_Q02_HRBP__c, Mgr_Term_Q03_employeeData__c, Mgr_Term_Q04_employeeFleetVechicle__c,
                  Mgr_Term_Q05_employeeCarAllowance__c, Mgr_Term_Q06_employeeAddress__c, Mgr_Term_Q07_employeeCellPhone__c, 
                  Mgr_Term_Q08_employeeExpenseReport__c, Mgr_Term_Q09_employeeDirectReport__c, Mgr_Term_Q09a_employeeDirectReport__c,
                  Mgr_Term_Q10_employeeeTime__c, Mgr_Term_Q11_employeeCanada__c, Mgr_Term_Q12_salesEmployee__c,
                  Mgr_Term_Q13_employeeEquipment__c, Mgr_Term_Q13a_employeeEquipment__c, Mgr_Term_Q14_employeeFacility__c,
                  Mgr_Term_Q15_employeeKeys__c, Mgr_Term_Q16_clientDocuments__c, Mgr_Term_Q17_creditCard__c, Mgr_Term_Q18_Immigration__c, 
                  Mgr_Term_Q19_employeeDirectReport__c, Mgr_Term_Q20_salesEmployee__c, Mgr_Term_Q21_employeeCellPhone__c, Mgr_Term_Work_Location__c,
                  Termination_Manager__r.Name
                  FROM Portal_Form__c 
                  WHERE  contact__c =: portalForms.contact__c
                  AND Termination_Manager__c =: UserInfo.getUserId()
                 ];
        }catch(exception ex){
            if(portalForms.contact__c != null){
                PF.recordtypeId =portalFormsRecordTypeID;
                PF.Contact__c = portalForms.contact__c;
                PF.Termination_Manager__c = UserInfo.getUserId();
                PF.Mgr_Term_Work_Location__c= portalForms.Mgr_Term_Work_Location__c;
                PF.Mgr_Term_Involuntary__c = portalForms.Mgr_Term_Involuntary__c;
                upsert PF;
                system.debug('PF'+PF);
            }
        }
        return PF;
    }
    
    @AuraEnabled
    public static string managerReport(string assocaiteId){
        if(assocaiteId == Null){
            list<Contact> Contacts = [select id, name,hr_manager__c,hr_manager__r.name, hr_manager__r.hr_manager__c from contact where hr_manager__c =: UserInfo.getUserId()];
            if(Contacts.size() >0){
                return 'Success';
            }
        }else{
            
            Contact Contactobjs = [select id, name,hr_manager__c,hr_manager__r.name, hr_manager__r.hr_manager__c from contact where user__c =: UserInfo.getUserId()];
            
            list<Contact> allContacts = [
                						 Select id, name,hr_manager__c,hr_manager__r.name, hr_manager__r.hr_manager__c,hr_manager__r.hr_manager__r.hr_manager__c,
                                         hr_manager__r.hr_manager__r.hr_manager__r.hr_manager__c,hr_manager__r.hr_manager__r.hr_manager__r.hr_manager__r.hr_manager__c
                                         From contact 
                						 Where id =: assocaiteId];
 
            
            List<PermissionSetAssignment> lstcurrentUserPerSet =    [   
                													 SELECT Id, PermissionSet.Name,AssigneeId
                                                                     FROM PermissionSetAssignment
                                                                     WHERE AssigneeId = :Userinfo.getUserId() 
            														];
            system.debug(' vijay -----> lstcurrentUserPerSet' + lstcurrentUserPerSet);
            
            Boolean user_has_permission = false;
            for ( PermissionSetAssignment psa : lstcurrentUserPerSet ) {
                System.debug('vijay -----> psa.PermissionSet.Name' + psa.PermissionSet.Name);
                if ( psa.PermissionSet.Name.equals('COM Access to Executive Administrative') ) {
                    user_has_permission = true;
                }
            }
            
            for(Contact c : allContacts){
                if(c.hr_manager__c == Contactobjs.id || (user_has_permission == true && Contactobjs.HR_Manager__c == c.HR_Manager__c))
                {
                    return 'Success';
                    break;
                    
                }else if(c.hr_manager__r.hr_manager__c == Contactobjs.id || (user_has_permission == true && Contactobjs.HR_Manager__c == c.hr_manager__r.hr_manager__c))
                {
                    return 'Success';
                }else if(c.hr_manager__r.hr_manager__r.hr_manager__c == Contactobjs.id || (user_has_permission == true && Contactobjs.HR_Manager__c == c.hr_manager__r.hr_manager__r.hr_manager__c))
                {
                    return 'Success';
                }else if(c.hr_manager__r.hr_manager__r.hr_manager__r.hr_manager__c == Contactobjs.id || (user_has_permission == true && Contactobjs.HR_Manager__c == c.hr_manager__r.hr_manager__r.hr_manager__r.hr_manager__c))
                {
                    return 'Success';
                }else if(c.hr_manager__r.hr_manager__r.hr_manager__r.hr_manager__r.hr_manager__c == Contactobjs.id || (user_has_permission == true && Contactobjs.HR_Manager__c == c.hr_manager__r.hr_manager__r.hr_manager__r.hr_manager__r.hr_manager__c))
                {
                    return 'Success';
                }
            }	
            
        }
        return 'Failure';
    }
    
    
    @AuraEnabled
    Public static list<Portal_Form__c> fetchPendingTermination(){
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'Manager Termination Form');
        Id workFlowRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('WorkFlow__c', 'COM - Employees Termination');
        list<Portal_Form__c> portalformslist = new list<Portal_Form__c>();
        portalformslist =  [
          		  SELECT
                  Id, Name, CreatedDate, CreatedById,Contact__r.Name,Contact__r.hr_Manager__r.Name, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, 
                  LastReferencedDate, DMSRSA_Associate_Name__c, HR_Termination_Date__c, Contact__c, Mgr_Term_Form_Completed__c, Mgr_Term_Involuntary_Reason__c,
                  Mgr_Term_Involuntary__c, Mgr_Term_Q017_HRBP_Email__c, Mgr_Term_Q018_Pass__c, Mgr_Term_Q01_myCareer__c, 
                  Mgr_Term_Q01a_myCareer__c, Mgr_Term_Q02_HRBP__c, Mgr_Term_Q03_employeeData__c, Mgr_Term_Q04_employeeFleetVechicle__c,
                  Mgr_Term_Q05_employeeCarAllowance__c, Mgr_Term_Q06_employeeAddress__c, Mgr_Term_Q07_employeeCellPhone__c, 
                  Mgr_Term_Q08_employeeExpenseReport__c, Mgr_Term_Q09_employeeDirectReport__c, Mgr_Term_Q09a_employeeDirectReport__c,
                  Mgr_Term_Q10_employeeeTime__c, Mgr_Term_Q11_employeeCanada__c, Mgr_Term_Q12_salesEmployee__c,
                  Mgr_Term_Q13_employeeEquipment__c, Mgr_Term_Q13a_employeeEquipment__c, Mgr_Term_Q14_employeeFacility__c,
                  Mgr_Term_Q15_employeeKeys__c, Mgr_Term_Q16_clientDocuments__c, Mgr_Term_Q17_creditCard__c, Mgr_Term_Q18_Immigration__c, 
                  Mgr_Term_Q19_employeeDirectReport__c, Mgr_Term_Q20_salesEmployee__c, Mgr_Term_Q21_employeeCellPhone__c, Mgr_Term_Work_Location__c,
            	  Termination_Manager__r.Name
                  FROM Portal_Form__c 
             	  WHERE Termination_Manager__c =: userinfo.getUserId()
            	  AND recordtypeId =: portalFormsRecordTypeID
        ];
        return portalformslist;
    }
    
    @AuraEnabled
    Public static string checkAccess(){
        Id contactRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Internal HR Contact');
        system.debug('userinfo.getUserId() '+userinfo.getUserId());
                system.debug('contactRecordTypeId'+contactRecordTypeId);
		system.debug('********* '+[select id  from contact where user__c =: userinfo.getUserId() and recordtypeId =: contactRecordTypeId ]);
        Contact contactObj = [select id  from contact where user__c =: userinfo.getUserId() and recordtypeId =: contactRecordTypeId ];
        
        list<Contact> contactlist = new list<contact>();
        contactlist = [select id , name , hr_manager__c from contact where hr_manager__c =: contactObj.id];
        if(contactlist.size() > 0){
            return 'Success';
        }else{
            return 'Failure';
        }
    }
    
    @AuraEnabled 
    Public static Portal_Form__c fetchAssociateTerminated(ID portalForms){ 
        
        list<Portal_Form__c> portalFormlist = new list<Portal_Form__c>();
        portalFormlist = EMP_ManagerTermination_Controller.fetchPendingTermination();
        Portal_Form__c pForm = new Portal_Form__c();
        for(Portal_Form__c PFs :portalFormlist){
            if(PFs.contact__c == portalForms){
                pForm = PFs;
            }
        }
        return pForm;
    }
    
    @AuraEnabled
    Public static Portal_Form__c insertAssociate(Portal_Form__c pforms,String pformsID, String completedFlag)
    {
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'Manager Termination Form');
        Id workFlowRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('WorkFlow__c', 'COM - Employees Termination');
        Contact contactObj   = [
            Select id , name , hr_manager__c,HR_Business_Partner__c,HR_Business_Partner__r.Email 
            From contact
            Where id =:  pforms.contact__c
        ];
        Portal_Form__c PFS = new Portal_Form__c();
        PFS.recordtypeId = portalFormsRecordTypeID;
        PFS.ID = pformsID;
        PFS.Mgr_Term_Q01_myCareer__c = pforms.Mgr_Term_Q01_myCareer__c;
        PFS.Mgr_Term_HRBP_Email__c = pforms.Mgr_Term_HRBP_Email__c;
        PFS.Mgr_Term_Q01a_myCareer__c = pforms.Mgr_Term_Q01a_myCareer__c;
        PFS.Mgr_Term_Q02_HRBP__c = pforms.Mgr_Term_Q02_HRBP__c;
        PFS.Mgr_Term_Q03_employeeData__c =pforms.Mgr_Term_Q03_employeeData__c;
        PFS.Mgr_Term_Q04_employeeFleetVechicle__c =pforms.Mgr_Term_Q04_employeeFleetVechicle__c;
        PFS.Mgr_Term_Q05_employeeCarAllowance__c=pforms.Mgr_Term_Q05_employeeCarAllowance__c;
        PFS.Mgr_Term_Q06_employeeAddress__c=pforms.Mgr_Term_Q06_employeeAddress__c;
        PFS.Mgr_Term_Q07_employeeCellPhone__c=pforms.Mgr_Term_Q07_employeeCellPhone__c;
        PFS.Mgr_Term_Q08_employeeExpenseReport__c=pforms.Mgr_Term_Q08_employeeExpenseReport__c;
        PFS.Mgr_Term_Q09_employeeDirectReport__c=pforms.Mgr_Term_Q09_employeeDirectReport__c;
        PFS.Mgr_Term_Q09a_employeeDirectReport__c = pforms.Mgr_Term_Q09a_employeeDirectReport__c;
        PFS.Mgr_Term_Q10_employeeeTime__c =pforms.Mgr_Term_Q10_employeeeTime__c;
        PFS.Mgr_Term_Q11_employeeCanada__c=pforms.Mgr_Term_Q11_employeeCanada__c;
        PFS.Mgr_Term_Q12_salesEmployee__c=pforms.Mgr_Term_Q12_salesEmployee__c;
        PFS.Mgr_Term_Q13a_employeeEquipment__c=pforms.Mgr_Term_Q13a_employeeEquipment__c;
        PFS.Mgr_Term_Q13_employeeEquipment__c=pforms.Mgr_Term_Q13_employeeEquipment__c;
        PFS.Mgr_Term_Q14_employeeFacility__c=pforms.Mgr_Term_Q14_employeeFacility__c;
        PFS.Mgr_Term_Q15_employeeKeys__c=pforms.Mgr_Term_Q15_employeeKeys__c;
        PFS.Mgr_Term_Q16_clientDocuments__c=pforms.Mgr_Term_Q16_clientDocuments__c;
        PFS.Mgr_Term_Q17_creditCard__c = pforms.Mgr_Term_Q17_creditCard__c;
        PFS.Mgr_Term_Q017_HRBP_Email__c = contactObj.HR_Business_Partner__r.Email;
        PFS.Mgr_Term_Q018_Pass__c = pforms.Mgr_Term_Q018_Pass__c;
        PFS.Mgr_Term_Q18_Immigration__c = pforms.Mgr_Term_Q18_Immigration__c;
        PFS.Mgr_Term_Q19_employeeDirectReport__c = pforms.Mgr_Term_Q19_employeeDirectReport__c;
        PFS.Mgr_Term_Q20_salesEmployee__c = pforms.Mgr_Term_Q20_salesEmployee__c;
        PFS.Mgr_Term_Q21_employeeCellPhone__c = pforms.Mgr_Term_Q21_employeeCellPhone__c;
        PFS.Mgr_Term_Form_Completed__c = pforms.Mgr_Term_Form_Completed__c;
        PFS.Mgr_Term_Work_Location__c = pforms.Mgr_Term_Work_Location__c;
        PFS.Mgr_Term_Involuntary__c = pforms.Mgr_Term_Involuntary__c;
        PFS.Mgr_Term_Involuntary_Reason__c = pforms.Mgr_Term_Involuntary_Reason__c;
       
        
        if(completedFlag == 'true')
        {
            PFS.Mgr_Term_Form_Completed__c = true;
        }else{
            PFS.Mgr_Term_Form_Completed__c = false;
            
        }
        update PFS;
        PFS = EMP_ManagerTermination_Controller.fetchAssociateTerminated(pforms.Contact__c);
        return PFS;
    }
}