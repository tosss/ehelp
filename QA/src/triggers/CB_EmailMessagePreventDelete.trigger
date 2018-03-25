trigger CB_EmailMessagePreventDelete on EmailMessage (before delete) 
{
    public static GlobalSettings__c gs = GlobalSettings__c.getInstance();
    
    if(gs.Email_2_Case_Prevent_Delete__c)
    {
	    Map<Id,Profile> profiles = new Map<Id,Profile>([Select Id, Name From Profile]);
	    
	    for(EmailMessage e : Trigger.Old)
	    {
	        Profile p = profiles.get(UserInfo.getProfileId());
	        String pName = p.Name.toLowerCase();
	        
	        if(gs.Email_2_Case_Email_Message_Profiles__c == null) { 
	            gs.Email_2_Case_Email_Message_Profiles__c = ''; }
	        
	        if(!gs.Email_2_Case_Email_Message_Profiles__c.toLowerCase().contains(pName))
	        {
	            e.addError('Your Profile does not have permission to delete Email Messages.');
	        }
	    }
    }
}