/*
 * Author         Vishal Bandari
 * Created        22 April 2015
 * Description    Handles the Previous Process Coach and Previous EPC fields
 * Test Class     TraverProjectUpdate_Test
 * Code Coverage  100%
 * 
 * History
 * 22 April 2015    Vishal Bandari    Created Trigger
 */
public class TraverProjectUpdate_Handler 
{
    public static void updateEPCandProcessCoachField(List<Traver_Project__c> newList, Map<Id,Traver_Project__c> oldMap)
    {
        try
        {
            Set<Id> userIds = new Set<Id>();
            
            for(Traver_Project__c tp : oldMap.values())
            {
                if(tp.Epc__c!=null)
                {
                    userIds.add(tp.Epc__c);
                }
                if(tp.Process_Coach__c!=null)
                {
                    userIds.add(tp.Process_Coach__c);  
                }
            }
            
            Map<Id, User> UserMap = new Map<Id, User>([
                SELECT id, name, email, firstname, lastname
                FROM user 
                WHERE Id In: userIds
            ]);   
            
            for(Traver_Project__c traverProjectObj : newList)
            {
                Traver_Project__c traverProjectOld = oldMap.get(traverProjectObj.Id); 
                if(traverProjectObj.EPC__c!=traverProjectOld.EPC__c  &&  traverProjectObj.Previous_EPC__c!=(UserMap.get(traverProjectOld.EPC__c).FirstName+' '+UserMap.get(traverProjectOld.EPC__c).LastName))
                {
                    traverProjectObj.Previous_EPC__c = UserMap.get(traverProjectOld.EPC__c).FirstName+' '+UserMap.get(traverProjectOld.EPC__c).LastName;
                    traverProjectObj.Previous_EPC_Email__c = UserMap.get(traverProjectOld.EPC__c).Email;  
                }
                if(traverProjectObj.Process_Coach__c!=traverProjectOld.Process_Coach__c && traverProjectObj.Previous_Process_Coach__c!=UserMap.get(traverProjectOld.Process_Coach__c).FirstName+' '+UserMap.get(traverProjectOld.Process_Coach__c).LastName)
                {
                    traverProjectObj.Previous_Process_Coach__c = UserMap.get(traverProjectOld.Process_Coach__c).FirstName+' '+UserMap.get(traverProjectOld.Process_Coach__c).LastName; 
                    traverProjectObj.Previous_Process_Coach_Email__c= UserMap.get(traverProjectOld.Process_Coach__c).Email;   
                }
            }
        }
        
        catch(Exception e)
        {
            System.debug('Exception: '+e.getMessage()+' at '+e.getLineNumber());
        }
    }
}