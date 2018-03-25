trigger CB_AttachmentPreventDelete on Attachment (before delete) 
{
    public static GlobalSettings__c gs = GlobalSettings__c.getInstance();   
    
    if(gs.Email_2_Case_Prevent_Delete__c)
    {
	    ALL_Profile_Access_Settings__c profileSettings = ALL_Profile_Access_Settings__c.getInstance();
        
	    for(Attachment a : Trigger.Old)
	    {
	        String parent = String.valueOf(a.ParentId);
	        
	        if(!profileSettings.Email_2_Case_Email_Attachment__c &&
	          parent.startsWith('02s')) // if the parent is an Email object (Email object Ids begin with 02s)
	        {
	            a.addError('Your Profile does not have permission to delete Email Attachments.');
	        }
	    }
    }
}