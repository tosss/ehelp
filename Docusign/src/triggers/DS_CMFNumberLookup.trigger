trigger DS_CMFNumberLookup on mpm3__Milestone1_Project__c (before insert, before update) 
{
    List<mpm3__Milestone1_Project__c> ProjectsToProcess = new List<mpm3__Milestone1_Project__c>();
    List<String> CMFNumbers = new List<String>();
    
    for(mpm3__Milestone1_Project__c p : Trigger.New)
    {
        // if null, continue on to the next project in loop
        if(p.CMF_Number__c == null) 
        {
            p.CMF_Lookup__c = null; 
            continue; 
        }
        
        Object OldCMFNumber = (Trigger.OldMap != null ? 
        	(Trigger.OldMap.get(p.Id) != null ? Trigger.OldMap.get(p.Id).get('CMF_Number__c') : null) : 
        	null
    	);
        
        if(p.CMF_Number__c != OldCMFNumber)
        {
            ProjectsToProcess.add(p);
            CMFNumbers.add(p.CMF_Number__c);
        }
    }
    
    List<CMF_Info__c> CMFs = [Select Id, Name, Ship_CMF__c From CMF_Info__c Where Ship_CMF__c IN :CMFNumbers];
    Map<String, CMF_Info__c> CMFsByNumber = new Map<String, CMF_Info__c>();
    
    if(!CMFs.IsEmpty()) 
    {
        for(CMF_Info__c c : CMFs) { CMFsByNumber.put(c.Ship_CMF__c, c); }
    }
    
    if(!ProjectsToProcess.IsEmpty())
    {
        for(mpm3__Milestone1_Project__c p : ProjectsToProcess)
        {
            CMF_Info__c CMF = CMFsByNumber.get(p.CMF_Number__c);
            
            if(CMF != null)
            {
                p.Dealer_Name__c = CMF.Name;
                p.CMF_Lookup__c = CMF.Id;
            }
            else
            {
                p.CMF_Lookup__c = null;
            }
        }
    }

}