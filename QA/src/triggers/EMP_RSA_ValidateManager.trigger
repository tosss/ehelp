trigger EMP_RSA_ValidateManager on Portal_Form__c (before insert, before update) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
       Boolean ItRequest = EMP_DMSRSA_ITRequestForms_Controller.validateFormAccess(Userinfo.getUserId(), Trigger.New);
    }
    
}