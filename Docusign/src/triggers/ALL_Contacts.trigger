//2015-06-25 vishal.bandari@cdk.com  RQ-04894 change requested in request

trigger ALL_Contacts on Contact(after insert, after update)
{
    try
    {
        //Handler for Contacts after insert and after update
        DS_CDKGlobalAccountContacts_Handler.updateUser(Trigger.New, Trigger.oldMap);
                
    }
    catch(Exception e)
    {
        System.debug('Exception: '+e.getMessage()+' at '+e.getLineNumber());
    }
    
}