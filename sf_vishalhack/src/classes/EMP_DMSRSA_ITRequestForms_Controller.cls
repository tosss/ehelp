// 2016-03-23 vijay.manimaran@cdk.com - created
// 2016-07-20 matt.keefe@cdk.com - updated Record Type check logic
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
        list<Contact> ManagerIds = [
            Select HR_Manager__c 
            From Contact 
            where AccountId =: CustomSettings__c.getInstance().CDK_Global_Account_Id__c
            and Status__c = 'Active'
            and HR_Manager__c != null
            and User__c =: UserId
        ];
        
        list<Contact> CDKManagerContacts = [ 
            Select Id, HR_Manager__c, User__c,Status__c 
            From Contact 
            where Status__c = 'Active'
            and AccountId =: CustomSettings__c.getInstance().CDK_Global_Account_Id__c
            and HR_Manager__c IN :ManagerIds
        ];
        
        system.debug('*********' +Forms);
        
        list<User> u =[
            select Id, Profile.Name 
            from User 
            where Id =: Userinfo.getUserId() 
            and Profile.Name = 'ADPDS - Admin - System Administrator' 
        ];
        
        if(Forms != null)
        {
            for(Portal_Form__c CurrentForm : Forms)
            {
                String RecordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Portal_Form__c', CurrentForm.RecordTypeId);
                
                // 2016-07-20 matt.keefe@cdk.com - updated logic
                // if not of checked record types...
                if( !RecordTypeName.contains('DMS RSA') && !RecordTypeName.contains('HR') ) {
                    return true; // do not validate, simply return
                }
                
                // if of checked record types, and CDKManagerContacts have been returned from query
                if( (RecordTypeName.contains('DMS RSA') || RecordTypeName.contains('HR')) && CDKManagerContacts.size() > 0 ) {
                    return true; // contacts are returned, return true
                }
                else { // otherwise, for checked record types that do not have CDKManagerContacts returned
                    CurrentForm.addError('Sorry you do not have access'); // add an error
                    return false; // return false
                }
            }
        }
        else
        {
            if( CDKManagerContacts.size() > 0 || u.size() > 0 ) {
                return true;
            }
        }
        
        // default
        return false;
    }
}