global with sharing class LG_MassUpdateTasks
{
    global sObject[] Tasks {get;set;}
    
    global LG_MassUpdateTasks() 
    {
    	Tasks = [Select Id, Name, mpm3__Complete_Percent__c, mpm3__Project_Milestone__c, 
    		mpm3__Task_Stage__c, mpm3__Start_Date__c, mpm3__Due_Date__c, mpm3__Complete__c 
    		From mpm3__Milestone1_Task__c Where mpm3__Project_Milestone__c = :ApexPages.currentPage().getParameters().get('id')];
    }
    
    @RemoteAction
    global static String MarkCompleted(List<String> Selected)
    {
    	List<Id> SelectedIds = new List<Id>();
    	
    	for(String id : Selected)
    	{
    		try { Id i = id; SelectedIds.add(i); } catch (Exception e) { return e.getMessage(); }
    	}
    	
    	if(!SelectedIds.IsEmpty())
    	{
    		List<mpm3__Milestone1_Task__c> TasksToUpdate = new List<mpm3__Milestone1_Task__c>();
    		List<mpm3__Milestone1_Task__c> Tasks = [Select Id, mpm3__Complete__c From mpm3__Milestone1_Task__c Where Id IN :SelectedIds];
    		
    		for(mpm3__Milestone1_Task__c t : Tasks) 
    		{
    			if(t.mpm3__Complete__c != true)
    			{
    				t.mpm3__Complete__c = true;
    				TasksToUpdate.add(t);
    			}
    		}
    		
    		try
    		{
    			update TasksToUpdate;
    		}
    		catch (Exception e) { return e.getMessage(); }
    	}
    	
    	return 'Success!';
    }
}