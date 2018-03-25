trigger CB_EmailMessagePreventDelete on EmailMessage (before delete) 
{
    public static GlobalSettings__c gs = GlobalSettings__c.getInstance();
    
    if(gs.Email_2_Case_Prevent_Delete__c)
    { 
        ALL_Profile_Access_Settings__c profileSettings = ALL_Profile_Access_Settings__c.getInstance();
        
	    for(EmailMessage e : Trigger.Old)
	    {
	        if(!profileSettings.Email_2_Case_Email_Message__c)
	        {
	            e.addError('Your Profile does not have permission to delete Email Messages.');
	        }
	    }
    }
}