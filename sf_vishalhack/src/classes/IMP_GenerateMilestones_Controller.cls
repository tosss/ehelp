/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Method called from Generate Milestone custom button in SubProject page layout via JavaScript
Inputs: SubProject Id
Returns: Error/Success String
History
11/07/14    Kimiko Roberto      Created
11/26/14    Kimiko Roberto      Added checking for Estimated install dates to prevent creating of milestones if the date is set to the past.
02/11/15	Rey Austral			Add Task in the creation of milestone
09/21/15	Rey Austral			Move the create activity in the project utility
10/01/15	Rey Austral		    Change the milestoneDefinitionProjectMap type from Map<Id, Project_Milestone__c> to Map<Id, List<Project_Milestone__c>>
------------------------------------------------------------*/

global class IMP_GenerateMilestones_Controller
{
    webservice static String getStandardMilestones(Id subProjectId)
    { 
        //Retrieve SubProject record
        SubProject__c subProject = IMP_Project_Utility.retrieveSubProject(subProjectId);
        
        List<String> selectedProjectTypesList = new List<String>();
        selectedProjectTypesList.add(subProject.Project_Type__c);
        
        List<String> selectedMarkets = new List<String>();
        selectedMarkets.add(subProject.Market__c);
        
        //Build Project Type string to be used for query
        String projectTypeString = IMP_Project_Utility.buildProjectTypeString(selectedProjectTypesList);
        
        //Build Market string to be used for query
        String marketString = IMP_Project_Utility.buildProjectTypeString(selectedMarkets);
        
        //Retrieve Milestone Definition records based on selected Project Type and Product/s
        if(subProject.Estimated_Install_Date_EID__c >= date.Today())
        {
            //2015-08-03 Rey Austral - Add new parameter in createProjectMilestones
            Map<Id, List<Project_Milestone__c>> milestoneDefinitionProjectMap = IMP_Project_Utility.createProjectMilestones(subProject.Id, projectTypeString,  marketString, NULL, NULL);
            //2015-09-21 Rey Austral - Move the creation of Activity to the Project utility
            String errorMessage = '';
            Map<Id,Subproject__c> subprojectMap = new Map<Id,Subproject__c>();
            subprojectMap.put(subProject.id, subProject);            
            //Create the activity and task if fail return the error
            errorMessage = IMP_Project_Utility.createProjectActivity(subprojectMap,milestoneDefinitionProjectMap);
            
            if (errorMessage.equals(''))
            {  
                //update the Milestones_Auto_Generated_Flag__c if the milestone , activty and task is successfully created
                subProject.Milestones_Auto_Generated_Flag__c = true;
                try
                {
                    update subProject;
                } 
                catch (Exception ex)
                {
                    return ex.getMessage();
                }
            }   
            else
            {
                return errorMessage;
            }            
        }
        else
        {
            return IMP_String_Utility.EID_CANNOT_BE_SET_TO_PAST;
        }
        
        return 'true';
    }
}