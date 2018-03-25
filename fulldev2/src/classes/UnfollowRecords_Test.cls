@isTest
public class UnfollowRecords_Test
{
	//Author: Anirudh Singh
	//Dated: 16th April, 2015
	//Description: This is the test class for UnfollowRecords_Handler.
	
    static testMethod void validate()
    {
        List<Project__c> projectsList=new List<Project__c>();
        Project__c firstProject=new Project__c();
        firstProject.Name='Ani Test 1';
        firstProject.Project_Region__c='ALLIANCE-PC SOLUTIONS-ADMIN';
        firstProject.Project_Status__c='Open';
        projectsList.add(firstProject);
        
        Project__c secondProject=new Project__c();
        secondProject.Name='Ani Test 2';
        secondProject.Project_Region__c='ASBURY ADMIN';
        secondProject.Project_Status__c='Open';
        projectsList.add(secondProject);
        insert projectsList;
        
        List<SubProject__c> subProjectsList=new List<SubProject__c>();
        //SubProjects for first Project.
        for(Integer i=0; i<2; i++)
        {
		    SubProject__c subProject=new SubProject__c();
            subProject.Project__c=firstProject.Id;
            subProject.SubProject_Region__c='test'+i;
            subProject.Number_of_Rooftops__c=i;
            subProject.Number_of_User_Connections__c=i;
            subProject.Project_Type__c='Add-On';
            subProject.Secondary_Project_Type__c='Standard';
            subProject.Market__c='Dash - Small Auto';
            subProjectsList.add(subProject);
		}
        
        //SubProjects for second Project.
        for(Integer j=0; j<2; j++)
        {
		    SubProject__c subProject=new SubProject__c();
            subProject.Project__c=secondProject.Id;
            subProject.SubProject_Region__c='test'+j;
            subProject.Number_of_Rooftops__c=j;
            subProject.Number_of_User_Connections__c=j;
            subProject.Project_Type__c='Add-On';
            subProject.Secondary_Project_Type__c='Standard';
            subProject.Market__c='Dash - Small Auto';
            subProjectsList.add(subProject);
		}
        insert subProjectsList;
        
        List<EntitySubscription> listSubscriptionOnSubProjects=new List<EntitySubscription>();
        for(SubProject__c ref: subProjectsList)
        {
            EntitySubscription newEntitySub=new EntitySubscription();
            newEntitySub.ParentId=ref.Id;
            newEntitySub.SubscriberId=UserInfo.getUserId();
            listSubscriptionOnSubProjects.add(newEntitySub);
        }
        insert listSubscriptionOnSubProjects;
        
        Test.startTest();
        List<Project__c> updatedProjectsList=new List<Project__c>();
        firstProject.Project_Status__c='Closed';
        updatedProjectsList.add(firstProject);
        
        secondProject.Project_Status__c='Closed';
        updatedProjectsList.add(secondProject);
        
        update updatedProjectsList;
        Test.stopTest();
    }
}