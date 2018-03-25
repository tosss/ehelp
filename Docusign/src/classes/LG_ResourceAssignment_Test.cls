@IsTest
public class LG_ResourceAssignment_Test
{
    public static testmethod void Test()
    {
    	mpm3__Milestone1_Project__c project = new mpm3__Milestone1_Project__c(
    		Name = 'Unit Test Project'
    	);
    	insert project;
    	
    	LG_ResourceAssignment.SearchProjects('');
    	LG_ResourceAssignment.SearchProjects('Unit Test');
    	LG_ResourceAssignment.SearchProjects('ABC');
        
        string UserExtensionDefault = 'apex-test-objects';
        string UserExtension = UserExtensionDefault;
        
        try
        {
            UserExtension = UserExtension.substring(UserExtension.lastIndexOf('.')+1,UserExtension.length());
            if(UserExtension == 'com') { UserExtension = UserExtensionDefault; }
        } catch (Exception ex) { UserExtension = 'apex-test-objects'; }
        
        Profile P = DS_TestObjects.getStandardProfile();
        User NewUser = new User(
            UserName='matt_keefe@adp.com.' + String.valueOf(DateTime.now().millisecond()) + '.' + UserExtension,
            Email='matt_keefe@adp.com', 
            Alias='atest',
            EmailEncodingKey='UTF-8', 
            FirstName='Apex',
            LastName='Test User', 
            LanguageLocaleKey='en_US', 
            LocaleSIDKey='en_US', 
            profileid = P != null ? P.Id : null, 
            //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
            TimeZoneSIDKey='America/Chicago',
            ADID__c='atestu'
        );
        insert NewUser;
        
    	mpm3__Milestone1_Resource__c resource = new mpm3__Milestone1_Resource__c(Name = 'Unit Test Resource', mpm3__User__c = NewUser.Id);
    	insert resource;
    	
    	List<sObject> resources = LG_ResourceAssignment.GetResources();
    	
    	mpm3__Milestone1_Milestone__c milestone = new mpm3__Milestone1_Milestone__c(Name = 'Unit Test Milestone', mpm3__Project__c = project.Id);
    	insert milestone;
    	
    	List<mpm3__Milestone1_Task__c> tasks = new List<mpm3__Milestone1_Task__c>();
    	for(Integer i=0; i < 10; i++)
    	{
    		tasks.add(
    			new mpm3__Milestone1_Task__c(
    				Name = 'Unit Test Task ' + String.valueOf(i), 
    				mpm3__Project_Milestone__c = milestone.Id,
    				mpm3__Project_Lookup__c = project.Id
				)
    		);
    	}
    	insert tasks;
    	
    	LG_ResourceAssignment.GetProjectTasks(project.Id, false);
    	LG_ResourceAssignment.GetProjectTasks(project.Id, true);
    	
    	LG_ResourceAssignment.AssignResourcesResult arr1 = new LG_ResourceAssignment.AssignResourcesResult();
    	LG_ResourceAssignment.AssignResourcesResult arr2 = new LG_ResourceAssignment.AssignResourcesResult(false, '');
    	LG_ResourceAssignment.AssignResourcesResult arr3 = new LG_ResourceAssignment.AssignResourcesResult(false, '', new List<sObject>());
    	
    	for(mpm3__Milestone1_Task__c t : tasks) { t.mpm3__Resource__c = t.Id; }
    	LG_ResourceAssignment.AssignResources(tasks);
    	
    	for(mpm3__Milestone1_Task__c t : tasks) { t.mpm3__Resource__c = resource.Id; }
    	LG_ResourceAssignment.AssignResources(tasks);
    	
    	LG_ResourceAssignment.ResourceNameTasks rnt = new LG_ResourceAssignment.ResourceNameTasks();
    	rnt.ResourceName = resource.Name;
    	rnt.TaskId = tasks[0].Id;
    	
    	List<LG_ResourceAssignment.ResourceNameTasks> rnts = new List<LG_ResourceAssignment.ResourceNameTasks>();
    	rnts.add(rnt);
    	
    	LG_ResourceAssignment.AssignResourcesByName(rnts);
    }
}