public class EMP_DMSRSA_ITRequestForms_Controller 
{
    public boolean showPage {get;set;}
    
    public static final String NOACCESSMESSAGE = 'Sorry you do not have access to DMS RSA IT Request Forms Page.';
    
    public EMP_DMSRSA_ITRequestForms_Controller()
    {
        
        if(EMP_DMSRSA_ITRequestForms_Controller.validateFormAccess(userinfo.getUserId(), null)) {
            showPage = true;
        }
        else {
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, NOACCESSMESSAGE);
            apexpages.addmessage(msg);
        }
    }
    
    public static boolean validateFormAccess(Id UserId, list<Portal_Form__c> Forms) 
    {
        
        list<Contact> ManagerIds =[
            Select HR_Manager__c 
            From Contact 
            where AccountId =: CustomSettings__c.getInstance().CDK_Global_Account_Id__c
            and Status__c = 'Active'
            and HR_Manager__c != null
            and User__c =: UserId
        ];
        
        
        list<Contact> CDKContacts = [ 
            Select id, HR_Manager__c, User__c,Status__c 
            From Contact 
            where
            Status__c = 'Active'
            and AccountId =: CustomSettings__c.getInstance().CDK_Global_Account_Id__c
            and HR_Manager__c IN :ManagerIds
        ];
        
        system.debug('*********' +Forms);
        
        list<User> u =[
            select id, profile.Name from User where id =: Userinfo.getUserId() and  profile.Name ='ADPDS - Admin - System Administrator' 
        ];
      
        
        if(Forms != null)
        {
            system.debug('****** hello am here');
            for(Portal_Form__c CurrentForm : Forms)
            {
                    String RecordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Portal_Form__c', CurrentForm.RecordTypeId);
                    if(CDKContacts.size()>0 && ( RecordTypeName.contains('DMS RSA') ||RecordTypeName.contains('HR'))){
                        system.debug('yes entered');
                        return true;
                    }
                    else { 
                        CurrentForm.addError('Sorry you do not have access');
                        return false;
                      } 
            }
        }
        else
        {
            if(CDKContacts.size()>0 || u.size()>0) {
                return true;
            }
        }
        // default
        return false;
    }
}