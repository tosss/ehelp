//2017-04-17 - lalitha.adduru@cdk.com - created this handler - RQ-09019 
//2017-02-20 - lalitha.adduru@cdk.com - created updateCoachingEPCEmailField method as part of RQ-08240
//2017-04-18 - lalitha.adduru@cdk.com - commented out references to Process_Coach__c, TRV_Process_Coach__c  - RQ-08733
public class ALL_TraverProject_Handler 
{
    public static void onBeforeInsert(List<Traver_Project__c> newTraverList)
    {
        populateTraverEmailFields(newTraverList, null);
    }
    
    public static void onBeforeUpdate(List<Traver_Project__c> newTraverList, Map<Id,Traver_Project__c> oldTraverMap)
    {
        populateTraverEmailFields(newTraverList, oldTraverMap);
		updatePreviousEPC(newTraverList, oldTraverMap);
		updateCoachingEPCEmailField(newTraverList, oldTraverMap);
    }
    
    public static void populateTraverEmailFields(List<Traver_Project__c> traverProjectNewList, Map<Id, Traver_Project__c> traverProjectOldMap)
    {
        Set<Id> traverResourceIds = new Set<Id>();
        Set<Traver_Project__c> relevantTraverProjects = new Set<Traver_Project__c>();
        
        for(Traver_Project__c traverProject : traverProjectNewList)
        {
            if(traverProject.Id == null)
            {
                relevantTraverProjects.add(traverProject);
                traverResourceIds.add(traverProject.TRV_EPC__c);
                traverResourceIds.add(traverProject.PSC__c);
            }
            else if(traverProjectOldMap.get(traverProject.Id) != null)
            {
                if(traverProject.TRV_EPC__c != traverProjectOldMap.get(traverProject.Id).TRV_EPC__c)
                {
                    traverResourceIds.add(traverProject.TRV_EPC__c);
                    relevantTraverProjects.add(traverProject);
                }
                
                if(traverProject.PSC__c != traverProjectOldMap.get(traverProject.Id).PSC__c)
                {
                    traverResourceIds.add(traverProject.PSC__c);
                    relevantTraverProjects.add(traverProject);
                }
            }
        }
        
        populateEPC_PSC_Email(relevantTraverProjects, traverResourceIds);
    }
    
    private static void populateEPC_PSC_Email(Set<Traver_Project__c> relevantTraverProjects, Set<Id> traverResourceIds)
    {
        Map<Id, TRV_Resource__c> traverResourceMap = new Map<Id, TRV_Resource__c>([
            SELECT Id, TRV_Resource__c, TRV_Resource__r.Email 
            FROM TRV_Resource__c 
            WHERE TRV_Resource__c != null 
            AND (Id IN: traverResourceIds)
        ]);
        
        for(Traver_Project__c traverProject : relevantTraverProjects)
        {
            traverProject.TRV_EPC_Email__c = (traverProject.TRV_EPC__c == null) ? '' : 
            ( traverResourceMap.get(traverProject.TRV_EPC__c) != null ? traverResourceMap.get(traverProject.TRV_EPC__c).TRV_Resource__r.Email : '');
			
            traverProject.TRV_PSC_Email__c = (traverProject.TRV_PSC__c == null) ? '' : 
            ( traverResourceMap.get(traverProject.TRV_PSC__c) != null ? traverResourceMap.get(traverProject.TRV_PSC__c).TRV_Resource__r.Email : '');
        	//traverProject.TRV_Process_Coach_Email__c = (traverProject.TRV_Process_Coach__c == null) ? '' : ( traverResourceMap.get(traverProject.TRV_Process_Coach__c) != null ? traverResourceMap.get(traverProject.TRV_Process_Coach__c).TRV_Resource__r.Email : '');
        }
    }
    
    //moved from TraverProjectUpdate_Handler
    public static void updatePreviousEPC(List<Traver_Project__c> newList, Map<Id, Traver_Project__c> oldMap)
    {
        try
        {
            Set<Id> userIds = new Set<Id>();
            for(Traver_Project__c traverProject : oldMap.values())
            {    
                userIds.add(traverProject.EPC__c);
                //userIds.add(traverProject.Process_Coach__c);
            }
            
            Map<Id, User> userMap = new Map<Id, User>([
                SELECT Id, Name, Email, Firstname, Lastname
                FROM User 
                WHERE Id In: userIds
            ]);   
            
            for(Traver_Project__c traverProjectObj : newList)
            {
                Traver_Project__c traverProjectOld = oldMap.get(traverProjectObj.Id);
                
                if(traverProjectObj.EPC__c!=traverProjectOld.EPC__c 
                   && userMap.get(traverProjectOld.EPC__c)!= null 
                   && traverProjectObj.Previous_EPC__c!=userMap.get(traverProjectOld.EPC__c).Name)
                {
                    traverProjectObj.Previous_EPC__c = userMap.get(traverProjectOld.EPC__c).Name;
                    traverProjectObj.Previous_EPC_Email__c = userMap.get(traverProjectOld.EPC__c).Email;
                }
                //if(traverProjectObj.Process_Coach__c!=traverProjectOld.Process_Coach__c 
                //	&& traverProjectObj.Previous_Process_Coach__c!=userMap.get(traverProjectOld.Process_Coach__c).FirstName+' '+userMap.get(traverProjectOld.Process_Coach__c).LastName)
                //{
                //	traverProjectObj.Previous_Process_Coach__c = userMap.get(traverProjectOld.Process_Coach__c).FirstName+' '+userMap.get(traverProjectOld.Process_Coach__c).LastName; 
                //	traverProjectObj.Previous_Process_Coach_Email__c = userMap.get(traverProjectOld.Process_Coach__c).Email;   
                //}
            }
        }
        catch(Exception ex)
        {
            system.debug('Exception: '+ex.getMessage()+' at '+ex.getLineNumber());
        }
    }
    
    public static void updateCoachingEPCEmailField(List<Traver_Project__c> newList, Map<Id, Traver_Project__c> oldMap)
    {
        //Map if Traver_Project--c --> List<Traver_Coaching__c>
        Map<Id, List<Traver_Coaching__c>> traverProjectToCoachingMap = new Map<Id, List<Traver_Coaching__c>>();
        
        for(Traver_Coaching__c coaching : new List<Traver_Coaching__c>([
            SELECT Id, EPC_Email__c, Traver_Project__c 
            FROM Traver_Coaching__c 
            WHERE Traver_Project__c IN :newList
        ]))
        {
            if(traverProjectToCoachingMap.containsKey(coaching.Traver_Project__c))
            {
            	traverProjectToCoachingMap.get(coaching.Traver_Project__c).add(coaching);
            }
            else
            {
                traverProjectToCoachingMap.put(coaching.Traver_Project__c, new List<Traver_Coaching__c>{coaching});
            }
        }
        
        Map<Id, Traver_Coaching__c> coachingToUpdate = new Map<Id, Traver_Coaching__C>();
        for(Traver_Project__c project: newList)
        {
            Traver_Project__c oldProject = (oldMap==null || oldMap.get(project.Id)==null) ? new Traver_Project__c() : oldMap.get(project.Id);
            
            if(Project.TRV_EPC_Email__c != oldProject.TRV_EPC_Email__c && traverProjectToCoachingMap.get(project.Id) != null)
            {
                for(Traver_Coaching__c coaching : traverProjectToCoachingMap.get(project.Id))
                {
                    coaching.EPC_Email__c = project.TRV_EPC_Email__c;
                    coachingToUpdate.put(coaching.Id, coaching);
                }
            }
        }
        
        if(!coachingToUpdate.isEmpty())
        {
            update coachingToUpdate.values();
        }
    }
}