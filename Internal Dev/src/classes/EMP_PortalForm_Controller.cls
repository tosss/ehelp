public class EMP_PortalForm_Controller 
{
    public Portal_Form__c PortalForm {get;set;}
    public String FormRecordTypeId {get;set;}
    
    public EMP_PortalForm_Controller() 
    {
        PortalForm = new Portal_Form__c();
    }
    
    public Boolean getHasMessages() {
        return ApexPages.hasMessages();
    }
    
    public void Save() 
    {
        if(FormRecordTypeId != null) { PortalForm.RecordTypeId = FormRecordTypeId; }
        system.debug(FormRecordTypeId);
        database.upsert(PortalForm);
    }
}