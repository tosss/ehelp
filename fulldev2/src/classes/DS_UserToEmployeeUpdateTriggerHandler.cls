public class DS_UserToEmployeeUpdateTriggerHandler 
{    
    /*public static Void UserToEmployee(list<User> NewList, map<Id, User> NewMap, Map<Id, User> OldMap) 
    {
        list<Employee_Information__c> updatedEmps = new list<Employee_Information__c> ();
        set<string> changedEmps = new set<string>();
        set<string> Userlist = new set<string>();
        set<string> NonManagerList = new set<string>();
        set<string> ManagerList = new set<string>();
        
        for(user u : NewList) 
        {
            if (u.phone != OldMap.get(u.id).phone || 
                u.Extension != OldMap.get(u.id).Extension || 
                u.Fax != OldMap.get(u.id).Fax || 
                u.MobilePhone != OldMap.get(u.id).MobilePhone || 
                u.City != OldMap.get(u.id).City || 
                u.State != OldMap.get(u.id).State || 
                u.PostalCode != OldMap.get(u.id).PostalCode || 
                u.Country != OldMap.get(u.id).Country || 
                u.firstname != OldMap.get(u.id).firstname || 
                u.lastname != OldMap.get(u.id).lastname) 
            {
                userlist.add(u.id);
                NonManagerList.add(u.id);
            }  
            
            if (u.managerid != OldMap.get(u.id).managerid) 
            {
                userlist.add(u.ManagerId);
                ManagerList.add(u.ManagerId);
            }
        }
        
        map<string, Employee_Information__c> Empinfomap = new map<string, Employee_Information__c>();
        map<string, Employee_Information__c> EmpManagerinfomap = new map<string, Employee_Information__c>();
        
        list<Employee_Information__c> QueriedEmployeeInformation = [
            select f.user__C, f.Address__c, f.City__c, f.State__c, f.Ext__c, f.Fax__c, f.Name, f.Postal__c,
            f.Work__c, f.Manager__c
            from Employee_Information__c f
            where user__c =  : NewMap.keyset()
        ];
        
        if (QueriedEmployeeInformation != null && !QueriedEmployeeInformation.IsEmpty()) {
            for (Employee_Information__c f : QueriedEmployeeInformation) {
                Empinfomap.put(f.user__C, f);
                //EmpManagerinfomap.put(f.manager__r.user__C, f);
            }
        }
        
        list<Employee_Information__c> QueriedEmployeeInformation1 = [
            select Manager__r.User__c, Manager__r.Id, user__c
            from Employee_Information__c f
            where User__c in : Managerlist
        ];
        
        map<String, Employee_Information__c> userMgrRev = new map<String, Employee_Information__c>();
        if (QueriedEmployeeInformation1 != null && !QueriedEmployeeInformation1.IsEmpty()) {
            for (Employee_Information__c f : QueriedEmployeeInformation1) {
                // test if manager__r is null
                UserMgrRev.put(f.user__C, f);
            }
        }
        
        for (user u : NewList) 
        {
            if (Empinfomap.containskey(u.id)) 
            {
                if (NonManagerList.contains(u.id)) 
                {
                    // test for oldmap in case we add insert operation later
                    
                    if (u.firstname != OldMap.get(u.id).firstname || u.lastname != OldMap.get(u.id).lastname) 
                    {
                        String NewLastName = u.Lastname;
                        String NewLastNameWithoutRetired = (
                            NewLastName.toLowerCase().endsWith('-retired') ? NewLastName.substring(0, NewLastName.toLowerCase().lastIndexOf('-retired')) : NewLastName);
                        
                        String OldLastName = OldMap.get(u.id).Lastname;
                        String OldLastNameWithoutRetired =
                            (OldLastName.toLowerCase().endsWith('-retired') ?
                             OldLastName.substring(0, OldLastName.toLowerCase().lastIndexOf('-retired')) :
                             OldLastName);
                        
                        system.debug('51-----' + u.firstname + 'lastname----' + NewLastName);
                        Empinfomap.get(u.id).name = u.firstname + ' ' + NewLastName;
                    }
                    
                    if (u.phone != OldMap.get(u.id).phone) {
                        Empinfomap.get(u.id).work__c = u.Phone;
                    }
                    
                    if (u.Extension != OldMap.get(u.id).Extension) {
                        Empinfomap.get(u.id).Ext__c = u.Extension;
                    }
                    
                    // if(u.Email != OldMap.get(u.id).Email ){
                    //       Empinfomap.get(u.id).E_Mail__c = u.Email;
                    //  }
                    
                    if (u.Fax != OldMap.get(u.id).Fax) {
                        Empinfomap.get(u.id).Fax__c = u.Fax;
                    }
                    
                    if (u.MobilePhone != OldMap.get(u.id).MobilePhone) {
                        Empinfomap.get(u.id).Mobile__c = u.MobilePhone;
                    }
                    
                    // 2014-02-18 MK - this was both commented out and uncommented in previous version
                    //   because one of these statements was uncommented, this functionality is uncommented as well
                    if (u.Street != OldMap.get(u.id).Street) {
                        Empinfomap.get(u.id).address__c = u.Street;
                    }
                    
                    if (u.City != OldMap.get(u.id).City) {
                        Empinfomap.get(u.id).City__c = u.City;
                    }
                    
                    if (u.State != OldMap.get(u.id).State) {
                        Empinfomap.get(u.id).State__c = u.State;
                    }
                    
                    if (u.PostalCode != OldMap.get(u.id).PostalCode) {
                        Empinfomap.get(u.id).Postal__c = u.PostalCode;
                    }
                    
                    if (u.Country != OldMap.get(u.id).Country) {
                        Empinfomap.get(u.id).Country__c = u.Country;
                    }
                    
                    // if(u.Title != OldMap.get(u.id).Title){
                    //       Empinfomap.get(u.id).Title__c = u.Title  ;
                    // }
                    
                }  
                
                if (u.ManagerId != OldMap.get(u.id).ManagerId) {
                    system.debug(UserMgrRev);
                    if (UserMgrRev != null && !UserMgrRev.IsEmpty()) {                       
                        Empinfomap.get(u.id).Manager__c = userMgrRev.get(u.Managerid).id;
                    } else {
                        Empinfomap.get(u.id).Manager__c = null;
                    }
                }
            }
        }
        
        try{
            update Empinfomap.values();
        } 
        catch(DmlException e) { }
    }
    
    public static void MakeFederationIDRequired(List<User> NewUserList, Map<Id, User> NewUserMap)
    {
        for(User u: NewUserList)
        {
            if(u.FederationIdentifier == null || String.isEmpty(u.FederationIdentifier))
            {
                if (!Test.isRunningTest() &&              // run if not test
                    u.IsActive &&                         // and user is active
                    u.Non_Interactive_User__c != true &&  // and user is not a non-interactive user
                    u.Sales_Automation_User__c != true)   // and user is not a sales-automation user
                {
                    //u.addError('Federation ID is required to save the record');
                    u.FederationIdentifier.addError('Federation ID is required to save the record');
                }
            }
        }        
    }
    
    // 2016-03-01 - lalitha.adduru@cdk.com - prevent contact creation on new sales user - RQ-06386
    public static void preventContactOnNewSalesUser(List<User> newUserList)
    {
        Map<Id,Contact> contactsToUpdate = new Map<id, Contact>();
        Map<Id, User> usersToUpdate = new Map<id, User>();
        Set<Id> contactIdSet = new Set<Id>();
        List<User> requiredUserList = new List<User>();
        
        // get those users where EMP_Contact__c is filled prior to saving
        for(User newUser : newUserList)
        {
            if(newUser.EMP_Contact__c != null)
            {
                system.debug('newUser.EMP_Contact__c -- >'+newUser.EMP_Contact__c);
                contactIdSet.add(newUser.EMP_Contact__c);
                requiredUserList.add(newUser);
            }
        }
        
        // get corresponding contacts
        Map<Id, Contact> contactMap = new Map<Id, Contact>([Select id,User__c from Contact where Id in :contactIdSet]);
        
        // update the retrieved contacts with user__c and vendor_id__c fields
        for(User newUser : requiredUserList)
        {
            contactMap.get(newUser.EMP_Contact__c).User__c = newUser.Id;
            contactMap.get(newUser.EMP_Contact__c).Vendor_Id__c = newUser.Contact_Vendor_ID__c; 
            contactsToUpdate.put(contactMap.get(newUser.EMP_Contact__c).id, contactMap.get(newUser.EMP_Contact__c));
        }
        
        List<User> originalUserList = [select id, FederationIdentifier from User where id Not In :newUserList and EMP_Contact__c in :contactIdSet];
        
        Map<string,User> federationIdToUserMap = new Map<String, User>();
        
        for(User oldUser : originalUserList)
        {
            
            String federationId = oldUser.FederationIdentifier;
            if(federationId != null || !String.isBlank(federationId))
            {
                federationId = federationId.remove('_'); // for comparision
            	federationIdToUserMap.put(federationId,oldUser);
            }
        }
        
        for(User newUser : requiredUserList)
        {
            String federationId = newUser.FederationIdentifier;
            if(federationIdToUserMap.get(federationId) != null)
            {
                User oldUser = federationIdToUserMap.get(federationId);
                oldUser.EMP_Contact__c = null;
                oldUser.Contact_Vendor_ID__c = null;
                usersToUpdate.put(oldUser.id, oldUser);
            }            
        }
        
        update contactsToUpdate.values();
        update usersToUpdate.values();
        
    }*/
}