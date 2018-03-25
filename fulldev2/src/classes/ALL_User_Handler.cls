public class ALL_User_Handler 
{
    public static void createNewContactAndPolicy(Map<Id,User> newUserMap)
    {
        List<User> newUserList = new List<User>();
        newUserList = newUserMap.values();
        
        // get newly inserted user to corresponding contact map
        Map<ID, Contact> userToContactMap = new Map<ID, Contact>();
        userToContactMap = EMP_PolicyUtility.getUserIdToContactMap( newUserList );
        
        Set<ID> createPolicyForUsers = new Set<ID>();        
        Set<ID> createContactForUsers = new Set<ID>();
        for(User newUser: newUserList)
        {
            EMP_User_HireDate__c hireDateDefaults = EMP_User_HireDate__c.getOrgDefaults(); 
            
            if (newUser.Contractor__c == false && newUser.Non_Employee__c == false && newUser.Non_Interactive_User__c == false)
            { 
                //If the Map doesnt contain id - contact does not exists.
                if(!userToContactMap.containsKey(newUser.ID))
                {
                    // if(usr.Hire_Date__c==null || usr.Hire_Date__c < hd.Hire_Date__c)
                    // {
                    createContactForUsers.add(newUser.ID);
                    //  }
                }
                
                if(newUser.Hire_Date__c != null && newUser.Hire_Date__c >=  hireDateDefaults.Hire_Date__c)
                {
                    createPolicyForUsers.add(newUser.ID);
                }  
            }
        }
        
        EMP_PolicyUtility.createNewContact(createContactForUsers);
        EMP_PolicyUtility.createNewPolicy(createPolicyForUsers);        
    }
    
}