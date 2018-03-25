global class LG_ResourceAssignment
{
    @RemoteAction
    global static List<sObject> SearchProjects (String ProjectSearchTerm)
    {
        List<sObject> SearchList = null;
        
        if(ProjectSearchTerm != null)
        {
            if(ProjectSearchTerm.length() > 0)
            { 
                List<List<sObject>> SoslSearchList = 
                    [FIND :ProjectSearchTerm RETURNING mpm3__Milestone1_Project__c (Id, Name Order By Name)];
                
                if(SoslSearchList != null) { SearchList = (SoslSearchList[0] != null ? SoslSearchList[0] : null); }
            }
            else
            {
                SearchList = [Select Id, Name From mpm3__Milestone1_Project__c Order By Name];
            }
        }
        
        return SearchList;
    }
    
    @RemoteAction
    global static List<sObject> GetResources()
    {
        return [
            Select Id, Name, mpm3__User__c, mpm3__User__r.Name
            From mpm3__Milestone1_Resource__c
            Where mpm3__User__c != null
            And mpm3__User__r.IsActive = true
            Order By mpm3__User__r.Name ASC
        ];
    }
    
    @RemoteAction
    global static List<sObject> GetProjectTasks (Id ProjectId, Boolean AllTasks)
    {
        List<sObject> Tasks = null;
        
        if(ProjectId != null)
        {
            Tasks = Database.query(
                'Select Id, Name, CreatedDate, LastModifiedDate, mpm3__Project_Milestone__r.Name, mpm3__Resource__c, '
                        + 'mpm3__Resource__r.Name, mpm3__Project_Milestone__c, mpm3__Start_Date__c, mpm3__Due_Date__c, '
                        + 'Project_End_Date__c, Dealer_Name__c, mpm3__Total_Open_Successors__c '
                    + ' From mpm3__Milestone1_Task__c '
                    + ' Where mpm3__Project_Lookup__c = :ProjectId '
                    + (!AllTasks?' And mpm3__Resource__c = NULL ':'')
            );
        }
        
        return Tasks;
    }
    
    global class AssignResourcesResult
    {
        Boolean success;
        String message;
        List<sObject> objects;
        
        public AssignResourcesResult() { success = false; message = ''; objects = null; }
        public AssignResourcesResult(Boolean a, String b) { success = a; message = b; objects = null; }
        public AssignResourcesResult(Boolean a, String b, List<sObject> c) { success = a; message = b; objects = c; }
    }
    
    @RemoteAction
    global static AssignResourcesResult AssignResources (List<sObject> Tasks)
    {
        try { update Tasks; return new AssignResourcesResult(true, ''); }
        catch(Exception exc) { return new AssignResourcesResult(false, exc.getMessage()); }
    }
    
    global class ResourceNameTasks
    {
        global String TaskId;
        global String ResourceName;
    }
    
    @RemoteAction
    global static AssignResourcesResult AssignResourcesByName(List<ResourceNameTasks> Tasks)
    {
        List<mpm3__Milestone1_Resource__c> Resources = [
            Select Id, Name, mpm3__User__c, mpm3__User__r.Name
            From mpm3__Milestone1_Resource__c
            Where mpm3__User__c != null
            Order By mpm3__User__r.Name ASC
        ];
        
        List<mpm3__Milestone1_Task__c> TasksToUpdate = new List<mpm3__Milestone1_Task__c>();
        
        for(ResourceNameTasks t : Tasks)
        {
            Pattern ResourcePattern = Pattern.compile('.*'+t.ResourceName.toLowerCase()+'.*');
            
            mpm3__Milestone1_Task__c TaskToUpdate = new mpm3__Milestone1_Task__c(Id=t.TaskId);
            TaskToUpdate.mpm3__Resource__c = null;
            
            for(mpm3__Milestone1_Resource__c r : Resources) 
            {
                if(ResourcePattern.matcher(r.mpm3__User__r.Name.toLowerCase()).matches()) 
                {
                    TaskToUpdate.mpm3__Resource__c = r.Id;
                    break;
                }
            }
            
            TasksToUpdate.add(TaskToUpdate);
        }
        
        system.debug(TasksToUpdate);
        
        try { update TasksToUpdate; return new AssignResourcesResult(true, '', TasksToUpdate); }
        catch(Exception exc) { return new AssignResourcesResult(false, exc.getMessage()); }
    }
}