public class LookUpController
{
    public String type{get;set;}
    public Account acc{get;set;}
    public User usr{get;set;}
    public LookUpController()
    {
        if(type=='Account' || type=='User')
        {
        	acc= [select id,parentId, createdbyId from Account Limit 1];
        }
    }
}