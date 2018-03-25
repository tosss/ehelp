public class DS_TraverProjectUpdate 
{
    public static void validate(List<Task> taskList)
    {        
        // Get corresponding traverProjectIds and dates-to-be-updated into a Map
        // This Map helps us in preventing multiple soql queries.
        Map<Id, Task> IdtoTaskMap = new map<id, Task>(); // map<WhatId, Task>
        
        for(Task ts : taskList)
        {
            if(ts.WhatId != null)
            {
                if(ts.Subject == 'EPC Intro Call & Process' || ts.WhatId.getSObjectType() == Schema.Traver_Project__c.sObjecttype) 
                {
                    IdtoTaskMap.put(ts.WhatId, ts);
                }  
            }
        }
        
        // using about Map, get all required traverProject records
        List<Traver_Project__c> traverProjectList  = new List<Traver_Project__C>(); 
        
        if(IdToTaskMap.keySet() != null && !IdToTaskMap.keySet().isEmpty())
        {
        	traverProjectList =  [select id, Lets_Get_Started__c, Account__r.Name from Traver_Project__c where id in :IdtoTaskMap.keyset()];
    	}
        
        system.debug(traverProjectList);
        
        List<Traver_Project__c> traverProjectsToUpdate = new List<Traver_Project__C>();
        
        // update each traver project record with the Lets_Get_Started__c field we stored in the map.
        if(traverProjectList != null && !traverProjectList.isEmpty())
        {
            for(Traver_Project__c tp : traverProjectList)
            {
                // collect traver projects that are updated with new lets get started value 
                if(IdtoTaskMap.get(tp.Id).Subject == 'EPC Intro Call & Process')
                {
                    Date getStarted = IdtoTaskMap.get(tp.id).Lets_Get_Started__c;
                    
                    if(getStarted != null)
                    {
                        tp.Lets_Get_Started__c = getStarted;
                    }
                    
                    traverProjectsToUpdate.add(tp);
                }
                
                // update the Traver account field in the Task object
                String AccountName  = tp.Account__r.Name;
                
                if(AccountName != null)
                {   
                    IdToTaskMap.get(tp.Id).Traver_Account__c = AccountName; 
                }              
            }
        }
        
        // update the traver projects.
        if(!traverProjectsToUpdate.isEmpty())
        {
        	Database.SaveResult[] Results = database.update(traverProjectsToUpdate, false);           
            for(Database.SaveResult ds: Results)
            {
                if(ds.isSuccess())
                {
                    system.debug(ds.getId() + 'is sucessfully updated');
                }
                else
                {
                    for(Database.Error de: ds.getErrors())
                    {
                        if(de.getMessage() != null)
                        {
                            system.debug(de.getMessage());                                                       
                        }
                    }
                }
            }
        }
    }
}