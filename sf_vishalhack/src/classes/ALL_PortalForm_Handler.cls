/*******************************************************************************
**RQ-08648  02/22/2017 Created Vijay.Manimaran@cdk.com

********************************************************************************* */

public class ALL_PortalForm_Handler {
    
    public static void insertUpdateWorkflow(list<Portal_Form__c> newPortalForms){
        Id workFlowRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('WorkFlow__c', 'COM - Employees Termination');
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'Manager Termination Form');
        Id portalFormsPRCRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'COM Bank of America');
        Id workFlowPRCRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('WorkFlow__c', 'COM - Procurement');
        
        list<WorkFlow__c> lstworkFlow = new list<WorkFlow__c>();
        WorkFlow__c workFlow = new WorkFlow__c();
        list<Portal_Form__c> portalformlist = new list<Portal_Form__c>();
        for(Portal_Form__c pForm: newPortalForms){
            if(pForm.Mgr_Term_Form_Completed__c == true && pForm.RecordTypeId == portalFormsRecordTypeID){
                workFlow.contact__c = pForm.contact__c;
                workFlow.RecordTypeId = workFlowRecordTypeId;
                workFlow.Mgr_Term_Form_Completed__c = pForm.Mgr_Term_Form_Completed__c;
                workFlow.Mgr_Term_HRBP_Email__c = pForm.Mgr_Term_HRBP_Email__c;
                workFlow.Mgr_Term_Work_Location__c = pForm.Mgr_Term_Work_Location__c;
                workFlow.Mgr_Term_Involuntary__c = pForm.Mgr_Term_Involuntary__c;
                workFlow.Mgr_Term_Q01_myCareer__c = pForm.Mgr_Term_Q01_myCareer__c;     
                workFlow.Mgr_Term_Q01a_myCareer__c = pForm.Mgr_Term_Q01a_myCareer__c;
                workFlow.Mgr_Term_Q02_HRBP__c = pForm.Mgr_Term_Q02_HRBP__c;
                workFlow.Mgr_Term_Q03_employeeData__c =pForm.Mgr_Term_Q03_employeeData__c;
                workFlow.Mgr_Term_Q04_employeeFleetVechicle__c =pForm.Mgr_Term_Q04_employeeFleetVechicle__c;
                workFlow.Mgr_Term_Q05_employeeCarAllowance__c=pForm.Mgr_Term_Q05_employeeCarAllowance__c;
                workFlow.Mgr_Term_Q06_employeeAddress__c=pForm.Mgr_Term_Q06_employeeAddress__c;
                workFlow.Mgr_Term_Q07_employeeCellPhone__c=pForm.Mgr_Term_Q07_employeeCellPhone__c; 
                workFlow.Mgr_Term_Q08_employeeExpenseReport__c=pForm.Mgr_Term_Q08_employeeExpenseReport__c;
                workFlow.Mgr_Term_Q09_employeeDirectReport__c=pForm.Mgr_Term_Q09_employeeDirectReport__c;
                workFlow.Mgr_Term_Q10_employeeeTime__c =pForm.Mgr_Term_Q10_employeeeTime__c;
                workFlow.Mgr_Term_Q11_employeeCanada__c=pForm.Mgr_Term_Q11_employeeCanada__c;
                workFlow.Mgr_Term_Q12_salesEmployee__c=pForm.Mgr_Term_Q12_salesEmployee__c;
                workFlow.Mgr_Term_Q13a_employeeEquipment__c=pForm.Mgr_Term_Q13a_employeeEquipment__c;
                workFlow.Mgr_Term_Q13_employeeEquipment__c=pForm.Mgr_Term_Q13_employeeEquipment__c;
                workFlow.Mgr_Term_Q14_employeeFacility__c=pForm.Mgr_Term_Q14_employeeFacility__c;
                workFlow.Mgr_Term_Q15_employeeKeys__c=pForm.Mgr_Term_Q15_employeeKeys__c;
                workFlow.Mgr_Term_Q16_clientDocuments__c=pForm.Mgr_Term_Q16_clientDocuments__c;
                workFlow.Mgr_Term_Q017_HRBP_Email__c=pForm.Mgr_Term_Q017_HRBP_Email__c  ;
                workFlow.Mgr_Term_Q018_Pass__c=pForm.Mgr_Term_Q018_Pass__c;
                workFlow.Mgr_Term_Q18_Immigration__c = pForm.Mgr_Term_Q18_Immigration__c;
                workFlow.Mgr_Term_Q19_employeeDirectReport__c = pform.Mgr_Term_Q19_employeeDirectReport__c;
                workFlow.Mgr_Term_Q20_salesEmployee__c = pform.Mgr_Term_Q20_salesEmployee__c;
                workFlow.Mgr_Term_Q21_employeeCellPhone__c = pform.Mgr_Term_Q21_employeeCellPhone__c;
                lstworkFlow.add(workFlow);
            }
            if(pForm.RecordTypeId == portalFormsPRCRecordTypeID){
                workFlow.id =  pForm.WorkFlow__c;
                workflow.Portal_Form_Name__c = pForm.Name;
                workFlow.contact__c =  pForm.contact__c;
                workFlow.RecordTypeID = workFlowPRCRecordTypeId;
                workFlow.PRC_Name_on_Card__c = pForm.BOA_NameOnCard__c;
                workFlow.PRC_Mailing_Address__c = pForm.BOA_Mailing_Address__c;
                workFlow.PRC_Address_Line_2__c = pForm.BOA_Address_Line_2__c;
                workFlow.PRC_Address_Line_3__c = pForm.BOA_Address_Line_3__c;
                workFlow.PRC_Address_Line_4__c = pForm.BOA_Address_Line_4__c;
                workFlow.PRC_City__c = pForm.BOA_City__c;
                workFlow.PRC_State_Province__c = pForm.BOA_State_Province__c;
                workFlow.PRC_Zip_Code__c = pForm.BOA_ZipCode__c;
                workFlow.PRC_BOA_Phone__c = pForm.BOA_Phone__c;
                workFlow.PRC_Date_of_Birth__c = pForm.BOA_Date_of_Birth__c;
                workFlow.PRC_Country__c = pForm.BOA_Country__c;
                workFlow.PRC_Selected_Card__c = pForm.BOA_SelectedCard__c;
                workFlow.PRC_Beginning_Date__c = pForm.BOA_Beginning_Date__c;
                workFlow.PRC_End_Date__c = pForm.BOA_End_Date__c;
                workFlow.PRC_Increase_Justification__c = pForm.BOA_Increase_Justification__c;
                workFlow.PRC_Currency_USD_CAD__c = pForm.BOA_Currency_USD_CAD__c;
                workFlow.PRC_Card_Type_Last_4_digits_card_number__c = pForm.BOA_Card_Type__c;
                workFlow.PRC_Manager__c = pForm.BOA_Manager__c;
                workFlow.PRC_Manager_Email__c = pForm.BOA_ManagerEmail__c;
                workFlow.PRC_Manager_Response_date__c = pForm.BOA_Manager_Response_date__c;
                workFlow.PRC_Procurement_Manager_Response_Date__c = pForm.BOA_Procurement_Manager_Response_Date__c;
                workFlow.PRC_Approvals__c = pForm.BOA_Manager_Approval__c;
                workFlow.Description__c = pForm.BOA_Rejection_Reason__c;
                workFlow.PRC_Status__c = pForm.PRC_Status__c;
                workFlow.PRC_sendEmail__c = pForm.BOA_sendEmail__c;
                workFlow.PRC_BOA_BirthDate__c = pForm.BOA_Date_of_Birth__c;
                lstworkFlow.add(workFlow); 
            }
        }
        upsert lstWorkFlow;
    }
    
    public static void updatePortalForms(set<Id> portalFormID)
    {
        system.debug('am inside contact obj in handle Vijay ');
        
        Id workFlowRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('WorkFlow__c', 'COM - Employees Termination');
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'Manager Termination Form');
        Id portalFormsPRCRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'COM Bank of America');
        Id workFlowPRCRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('WorkFlow__c', 'COM - Procurement');
        
        list<Portal_Form__c> portalFormlist =[
            Select BOA_SelectedCard__c,workflow__c,Name,BOA_Registered_T_E_Card__c,BOA_Registered_PCard__c,BOA_Access_to_Pcard__c,recordtypeID,            
            Id,  CreatedDate, CreatedById,Contact__r.Name,Contact__r.hr_Manager__r.Name, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, 
            LastReferencedDate, DMSRSA_Associate_Name__c, HR_Termination_Date__c, Contact__c, Mgr_Term_Form_Completed__c, Mgr_Term_Involuntary_Reason__c,
            Mgr_Term_Involuntary__c, Mgr_Term_Q017_HRBP_Email__c, Mgr_Term_Q018_Pass__c, Mgr_Term_Q01_myCareer__c, Mgr_Term_HRBP_Email__c,
            Mgr_Term_Q01a_myCareer__c, Mgr_Term_Q02_HRBP__c, Mgr_Term_Q03_employeeData__c, Mgr_Term_Q04_employeeFleetVechicle__c,
            Mgr_Term_Q05_employeeCarAllowance__c, Mgr_Term_Q06_employeeAddress__c, Mgr_Term_Q07_employeeCellPhone__c, 
            Mgr_Term_Q08_employeeExpenseReport__c, Mgr_Term_Q09_employeeDirectReport__c, Mgr_Term_Q09a_employeeDirectReport__c,
            Mgr_Term_Q10_employeeeTime__c, Mgr_Term_Q11_employeeCanada__c, Mgr_Term_Q12_salesEmployee__c,
            Mgr_Term_Q13_employeeEquipment__c, Mgr_Term_Q13a_employeeEquipment__c, Mgr_Term_Q14_employeeFacility__c,
            Mgr_Term_Q15_employeeKeys__c, Mgr_Term_Q16_clientDocuments__c, Mgr_Term_Q17_creditCard__c, Mgr_Term_Q18_Immigration__c, 
            Mgr_Term_Q19_employeeDirectReport__c, Mgr_Term_Q20_salesEmployee__c, Mgr_Term_Q21_employeeCellPhone__c, Mgr_Term_Work_Location__c,
            Termination_Manager__r.Name
            From Portal_Form__c 
            Where Id IN: portalFormID
        ];   
        set<ID> contactIDs = new set<ID>();
        for(Portal_Form__c PFS: portalFormlist){
            contactIDs.add(PFS.Contact__c);
        }
        system.debug('am inside contact obj in handle Vijay contactIDs'+contactIDs);
        
        map<ID, WorkFlow__c> mapWorkFlow = new map<ID,WorkFlow__c>([
            Select 
            id , recordtypeID,PRC_Selected_Card__c,Portal_Form_Name__c,Contact__c
            From WorkFlow__c 
            Where contact__c IN: contactIDs AND recordtypeID =:workFlowPRCRecordTypeId
        ]);
        list<contact> updateContact = new list<contact>();
        list<Contact> contactObj = [
            Select
            Id, HR_Manager__c, User__c, HR_Manager__r.user__r.Email, FirstName, LastName, HR_Manager__r.Name, Name,
            BOA_Access_to_Pcard__c, BOA_Registered_T_E_Card__c,HR_Manager__r.User__r.Id,Email,
            BOA_Requested_Pcard__c, Vendor_Id__c, user__r.Contractor__c,HR_Manager__r.Email
            From Contact
            Where id IN: contactIDs and AccountId = :CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c
        ];
        system.debug('am inside contact obj in handle Vijay contactIDs'+contactObj);
        
        String recordtypeName;
        list<Portal_Form__c> portalformlst = new list<Portal_Form__c>();
        for(Portal_Form__c PF: portalFormlist)
        {
            for(WorkFlow__c wf : mapWorkFlow.values())
            {
                if((PF.Contact__c == wf.Contact__c && PF.BOA_SelectedCard__c == wf.PRC_Selected_Card__c 
                   && wf.RecordTypeId == workFlowPRCRecordTypeId) || (PF.Contact__c == wf.Contact__c && wf.RecordTypeId == portalFormsRecordTypeID ))
                {
                    recordtypeName = wf.RecordTypeId;
                    if(wf.Id != null || wf.Id != '')
                    {
                        PF.WorkFlow__c = wf.Id;
                    }
                    portalformlst.add(PF); 
                }
                
                
                
                
            }
        }
        
        //update contact record for Bank of America requested cards.
        for(contact con : contactObj){
            for(Portal_Form__c PF: portalFormlist){
                if(PF.RecordTypeId == portalFormsPRCRecordTypeID){
                    recordtypeName ='BOA';
                    if(PF.BOA_Registered_T_E_Card__c == true && PF.Contact__c == con.id){
                        con.BOA_Registered_T_E_Card__c = true;
                    }
                    if(PF.BOA_Registered_PCard__c == true && PF.Contact__c == con.id){
                        con.BOA_Requested_Pcard__c = true;
                    }
                    if(PF.BOA_Access_to_Pcard__c == true && PF.Contact__c == con.id){
                        con.BOA_Access_to_Pcard__c = true;
                    }
                }
            }
            updateContact.add(con);
        }
        if(recordtypeName == 'BOA'){
            system.debug('updateCOntact'+updateContact);
            update updateContact; 
        }
        update portalformlst;
    }
    
    public static void deletePortalForms(set<Id> PortalFormID)
    {
        list<Portal_Form__c> portalFormlist =[
            Select Id, Name, CreatedDate, CreatedById,Contact__r.Name,Contact__r.hr_Manager__r.Name, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, 
            LastReferencedDate, DMSRSA_Associate_Name__c, HR_Termination_Date__c, Contact__c, Mgr_Term_Form_Completed__c, Mgr_Term_Involuntary_Reason__c,
            Mgr_Term_Involuntary__c, Mgr_Term_Q017_HRBP_Email__c, Mgr_Term_Q018_Pass__c, Mgr_Term_Q01_myCareer__c, RecordTypeId,
            Mgr_Term_Q01a_myCareer__c, Mgr_Term_Q02_HRBP__c, Mgr_Term_Q03_employeeData__c, Mgr_Term_Q04_employeeFleetVechicle__c,
            Mgr_Term_Q05_employeeCarAllowance__c, Mgr_Term_Q06_employeeAddress__c, Mgr_Term_Q07_employeeCellPhone__c, 
            Mgr_Term_Q08_employeeExpenseReport__c, Mgr_Term_Q09_employeeDirectReport__c, Mgr_Term_Q09a_employeeDirectReport__c,
            Mgr_Term_Q10_employeeeTime__c, Mgr_Term_Q11_employeeCanada__c, Mgr_Term_Q12_salesEmployee__c,Mgr_Term_HRBP_Email__c,
            Mgr_Term_Q13_employeeEquipment__c, Mgr_Term_Q13a_employeeEquipment__c, Mgr_Term_Q14_employeeFacility__c,
            Mgr_Term_Q15_employeeKeys__c, Mgr_Term_Q16_clientDocuments__c, Mgr_Term_Q17_creditCard__c, Mgr_Term_Q18_Immigration__c, 
            Mgr_Term_Q19_employeeDirectReport__c, Mgr_Term_Q20_salesEmployee__c, Mgr_Term_Q21_employeeCellPhone__c, Mgr_Term_Work_Location__c,
            Termination_Manager__r.Name,BOA_SelectedCard__c 
            From Portal_Form__c 
            Where Id IN: portalFormID
        ];              

       /* set<ID> contactIDs = new set<ID>();
        for(Portal_Form__c PFS: portalFormlist){
            contactIDs.add(PFS.Contact__c);
        }
        system.debug('am here '+contactIDs);
        map<ID, WorkFlow__c> mapWorkFlow = new map<ID,WorkFlow__c>([
            SELECT 
            id , RecordTypeId,PRC_Selected_Card__c,Portal_Form_Name__c,contact__c
            FROM WorkFlow__c 
            WHERE contact__c IN: contactIDs 
            AND RecordTypeId =: workFlowRecordTypeId
        ]);

        list<Portal_Form__c> PortalFormlst = new list<Portal_Form__c>();
        for(Portal_Form__c PF : portalFormlist){
            for(WorkFlow__c WF: mapWorkFlow.values()){
                if((PF.contact__c == WF.contact__c && PF.RecordTypeId == portalFormsRecordTypeID) || (PF.RecordTypeId == bankofAmericaRecordTypeID)  ){
                    PortalFormlst.add(PF);
                }
            }
        }*/
        delete portalFormlist;
    }
}