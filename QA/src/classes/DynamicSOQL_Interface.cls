public interface DynamicSOQL_Interface 
{
    ID CurrentUserId();
    ID getRecordTypeId(string sObjectName, string recordTypeName);
    string getAdminUser();
   
    
    /*
    string CurrentUserName();
    string CurrentLoginUserName();
    string CurrentUserFirstName();
    string CurrentUserLastName();
    */
}