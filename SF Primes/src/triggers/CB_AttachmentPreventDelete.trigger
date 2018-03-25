trigger CB_AttachmentPreventDelete on Attachment (before delete) 
{
    public static GlobalSettings__c gs = GlobalSettings__c.getInstance();
    
    if(gs.Email_2_Case_Prevent_Delete__c)
    {
	    Map<Id,Profile> profiles = new Map<Id,Profile>([Select Id, Name From Profile]);
	    
	    for(Attachment a : Trigger.Old)
	    {
	        Profile p = profiles.get(UserInfo.getProfileId());
	        String pName = p.Name.toLowerCase();
	        
	        if(gs.Email_2_Case_Email_Attachment_Profiles__c == null) { 
	            gs.Email_2_Case_Email_Attachment_Profiles__c = ''; }
	        
	        String parent = String.valueOf(a.ParentId);
	        
	        if(!gs.Email_2_Case_Email_Attachment_Profiles__c.toLowerCase().contains(pName)
	        && parent.startsWith('02s')) // if the parent is an Email object (Email object Ids begin with 02s)
	        {
	            a.addError('Your Profile does not have permission to delete Email Attachments.');
	        }
	    }
    }
}