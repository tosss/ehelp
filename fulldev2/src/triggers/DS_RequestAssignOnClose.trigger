trigger DS_RequestAssignOnClose on Request__c (before update) 
{
    list<Id> CreatedByIds = new list<Id>();
    
    for(Request__c r : Trigger.new)
    {
        CreatedByIds.add(r.CreatedById);
    }
    
    map<Id, User> Users = new map<Id, User>([
        select Id, Name, IsActive
        from User
        Where Id IN :CreatedByIds
    ]);
    
    for(Request__c r : Trigger.new)
    {
        if(r.Status__c != null) 
        {
            User CurrentUser = Users.get(r.CreatedById);
            
            if(r.Status__c.toLowerCase().contains('closed') && r.OwnerId != r.CreatedById && CurrentUser.IsActive) 
            { 
                r.OwnerId = r.CreatedById; 
            }
        }
    }
}