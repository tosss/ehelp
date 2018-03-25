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
            Map<Id, Project_Milestone__c> milestoneDefinitionProjectMap = IMP_Project_Utility.createProjectMilestones(subProject.Id, projectTypeString,  marketString);
            
            //Retrieve Activity_Definition__c records based on Milestone Definition results
            List<Activity_Definition__c> activityDefinitionList = IMP_Project_Utility.retrieveActivityDefinitionsBySet(milestoneDefinitionProjectMap.keySet());
            
            if(!milestoneDefinitionProjectMap.keySet().isEmpty() && !activityDefinitionList.isEmpty())
            {
                //Build Project Activity records
                List<Project_Activity__c> projectActivitiesToInsertList = new List<Project_Activity__c>();
                
                //Iterate through Activity Definition and instantiate a new Project_Activity__c record for each and map respective fields
                for(Activity_Definition__c ad: activityDefinitionList)
                {
                    Project_Activity__c projectActivity = IMP_Project_Utility.buildProjectActivity(ad, milestoneDefinitionProjectMap.get(ad.Milestone_Definition__c).Id, subProject);
                    
                    //Add Project Activity to list that will be inserted later
                    projectActivitiesToInsertList.add(projectActivity);
                }
                
                //Insert Project Activities
                if(!projectActivitiesToInsertList.isEmpty())
                {
                    try
                    {
                        insert projectActivitiesToInsertList;
                        //Phase 2 Rel 1
                        //call the function to create the task
                        IMP_Project_Utility.createProjectTask(projectActivitiesToInsertList,subProject);
                        //Phase 2 Rel 1
                        //Set SubProject flag to true
                        subProject.Milestones_Auto_Generated_Flag__c = true;
                    } 
                    catch (Exception ex) 
                    {
                        return ex.getMessage();
                    }
                }
                
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
                return IMP_String_Utility.NO_MILESTONES_FOUND_BASED_ON_CRITERIA;
            }
        }
        else
        {
            return IMP_String_Utility.EID_CANNOT_BE_SET_TO_PAST;
        }
        
        return 'true';
    }
}