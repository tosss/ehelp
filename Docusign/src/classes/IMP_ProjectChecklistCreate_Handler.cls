/*------------------------------------------------------------
Author: Karl Simon
Company: Cloud Sherpas       
Description:  Creating Project checklists for each project
Test Class: IMP_ProjectChecklistCreate_Test
History
09/10/14    Karl Simon      Created
------------------------------------------------------------*/
public class IMP_ProjectChecklistCreate_Handler
{
    public static void createChecklist(List <Project__c> NewProjList)
    {
        List<Project_Checklist__c> CheckliststoCreate = new List<Project_Checklist__c>();
        List<Checklist_Category__c> ChecklistCategoryList = new List<Checklist_Category__c>();
        List<Checklist_Item__c> ChecklistItemList = new List<Checklist_Item__c>();
        List<Checklist_Answer__c> CreatedAnswerList = new List<Checklist_Answer__c>();
        Map<String, Project_Checklist__c> CategorytoChecklistMap = new Map <String, Project_Checklist__c>();
        
        // Begin creating Project checklists for each project within the inbound project list.
        // Obtain the list of checklist categories, and for each project, iterate through the list of categories, and through each iteration, create a new Project Checkliist object.
        // Insert after building and adding the new Project Checklist objects to a list.
        if(NewProjList !=null && !NewProjList.IsEmpty())
        {
            ChecklistCategoryList = IMP_Project_Utility.retrieveAllActiveCheckListCategories();
            //ChecklistCategoryList = [SELECT Id, Name, Active__c FROM Checklist_Category__c WHERE Active__c = true];
            for (Project__c proj : NewProjList)
            {
                
                for (Checklist_Category__c currCat : ChecklistCategoryList)
                {
                    
                    Project_Checklist__c projchklist = new Project_Checklist__c(Project__c = proj.Id, Item_Category__c = currCat.Id);
                    CheckliststoCreate.add(projchklist);
                    CategorytoChecklistMap.put(projchklist.Item_Category__c, projchklist);
                }
            }
            
            if(!CheckliststoCreate.isEmpty()){
                insert CheckliststoCreate;
            }
            // Now create Answers
            // Retrieve all Checklist Items and the just-created Project checklists
            // Iterate through the list of Project Checklists, and within a Project Checklist, within the Checklist Items.
            // Within each Checklist Item iteration, create a new Checklist Answer object.
            // Insert after building and adding the new Checklist Answer objects to a list.
            ChecklistItemList = IMP_Project_Utility.retrieveChecklistItems();
            //ChecklistItemList = [SELECT Name, Active__c, Item_Category__c, Order__c FROM Checklist_Item__c WHERE Active__c = true];
            
            for (Project__c proj : NewProjList)
            { 
                
                //List<Project_Checklist__c> projchklists = IMP_Project_Utility.retrieveProjectCheckList(proj.Id);
                //List<Project_Checklist__c> projchklists = [SELECT Id, Name, Project__c, Item_Category__c FROM Project_Checklist__c WHERE Project__c = :proj.Id];
                
                for (Checklist_Item__c item : ChecklistItemList)
                {
                    Checklist_Answer__c createdAnswer = new Checklist_Answer__c();
                    if(CategorytoChecklistMap.size()>0 && CategorytoChecklistMap.containsKey(item.Item_Category__c)) //check if map containskey
                    {
                        Project_Checklist__c tempprojcheck = CategorytoChecklistMap.get(item.Item_Category__c);
                        createdAnswer.Project_Checklist__c = tempprojcheck.Id;
                    }
                    else
                    {
                        break;
                    }
                    createdAnswer.Item__c = item.Id;
                    createdAnswerList.add(createdAnswer);
                }
            }

            if(!createdAnswerList.isEmpty()){
                insert createdAnswerList;
            }
        }
    }
}