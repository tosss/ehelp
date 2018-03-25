trigger DS_ProjectOwner on mpm3__Milestone1_Project__c (after insert, after update) 
{
	// create a list of Projects
	Map<Id,mpm3__Milestone1_Project__c> ProjectsToProcess = new Map<Id,mpm3__Milestone1_Project__c>();
	
	// for each Project in the inserting or updating set
	for(mpm3__Milestone1_Project__c p : Trigger.New)
	{
		// get the old version of the Project, if there is one
		mpm3__Milestone1_Project__c o = null;
		if(Trigger.oldMap != null) { o = Trigger.oldMap.get(p.Id); }
		
		// if there was an old version of the Project
		if(o != null)
		{
			// compare the old Owner, if changed add to the Map of Projects to Process
			if(p.OwnerId != o.OwnerId) { ProjectsToProcess.put(p.Id,p); }
		}
		else
		{
			// there was no previous Owner
			ProjectsToProcess.put(p.Id,p);
		}
	}
	
	// create a list of Milestones to Update
	List<mpm3__Milestone1_Milestone__c> MilestonesToUpdate = new List<mpm3__Milestone1_Milestone__c>();
	
	// if there were any Projects to Process
	if(!ProjectsToProcess.IsEmpty())
	{
		// query all of the Milestones associated with the Projects
		List<mpm3__Milestone1_Milestone__c> Milestones = [
			Select Id, OwnerId, mpm3__Project__r.OwnerId  
			From mpm3__Milestone1_Milestone__c 
			Where mpm3__Project__c IN :ProjectsToProcess.keyset()
		];
		
		// if Milestones were returned
		if(!Milestones.IsEmpty())
		{
			// for each Milestone, set the OwnerId to the Project OwnerId
			for(mpm3__Milestone1_Milestone__c m : Milestones)
			{
				m.OwnerId = m.mpm3__Project__r.OwnerId;
				MilestonesToUpdate.add(m);
			}
		}
	}
	
	// if there are Milestones to Update
	if(!MilestonesToUpdate.IsEmpty()) 
	{
		// update them
		update MilestonesToUpdate;
	}
}