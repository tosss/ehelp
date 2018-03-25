/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Add Standard and Product Milestones Controller which displays a list of Milestone Definition records based on the SubProject Market's Milestone Definition Products
Test Class: IMP_ProductMilestonesController_Test
History
10/22/14    Michael Lasala      Created
02/11/15	Rey Austral			Add creation of task
------------------------------------------------------------*/
public with sharing class IMP_AddMilestones_Controller
{
    public String subProjectId;
    public SubProject__c subProject { get; set; }
    public List<milestoneDefinitionWrapper> milestoneDefinitionWrapperList { get; set; }
    public Boolean isValid { get; set; }
    
    public IMP_AddMilestones_Controller()
    {
         
        //Get SubProject__c record Id
        subProjectId = ApexPages.currentPage().getParameters().get('subProjectId');
        String entryType = ApexPages.currentPage().getParameters().get('type');
        if(subProjectId != null)
        {
            //Retrieve SubProject
            subProject = IMP_Project_Utility.retrieveSubProject(subProjectId);
            List<Milestone_Definition__c> milestoneDefinitionList = new List<Milestone_Definition__c>();
            if(entryType == 'Product')
            {       
                milestoneDefinitionList = loadProductMilestone();
            }
            else 
            {
                milestoneDefinitionList = loadStandardMilestone();
            }
            if(!milestoneDefinitionList.isEmpty())
            {
                milestoneDefinitionWrapperList = new List<milestoneDefinitionWrapper>();
                
                for(Milestone_Definition__c md: milestoneDefinitionList)
                {
                    //Add Milestone Definition records to wrapper list
                    milestoneDefinitionWrapperList.add(new milestoneDefinitionWrapper(md));
                }
            }
            
        }
    }
    
    public List<Milestone_Definition__c> loadProductMilestone() 
    {       
        List<Milestone_Definition__c> milestoneDefinitionList = new List<Milestone_Definition__c>();
        //Retrieve Milestone Definitions Product Ids based on SubProject Market
        Set<Id> milestoneDefinitionProductIdSet = IMP_Project_Utility.retrieveMilestoneDefinitionProductsIdSet(subProject.Market__c);
        
        if(!milestoneDefinitionProductIdSet.isEmpty())
        {           
            //Retrieve Milestone Definition records based on Milestone Definitions Products' Milestones
            milestoneDefinitionList = IMP_Project_Utility.retrieveMilestonesDefinitionsBySet(milestoneDefinitionProductIdSet);
        }
        return milestoneDefinitionList;
    }
    
    public List<Milestone_Definition__c> loadStandardMilestone() 
    {
        List<String> selectedProjectTypesList = new List<String>();
        selectedProjectTypesList.add(subProject.Project_Type__c);
        
        List<String> selectedMarketsList = new List<String>();
        selectedMarketsList.add(subProject.Market__c);
        
        //Retrieve Project Type of SubProject
        String projectTypeString = IMP_Project_Utility.buildProjectTypeString(selectedProjectTypesList);
        
        //Retrieve Market of SubProject
        String marketString = IMP_Project_Utility.buildProjectTypeString(selectedMarketsList);
        
        //Retrieve list of applicable Milestone Definitions based on Project Type and Product/s
        List<Milestone_Definition__c> projectTypeProductMilestoneDefinitionList = IMP_Project_Utility.retrieveProjectTypeProductMilestoneDefinitionList(projectTypeString,  marketString, false);
        return projectTypeProductMilestoneDefinitionList;
    }
    /*------------------------------------------------------------
    Author: Michael Lasala
    Company: Cloud Sherpas
    Description: Insert Project Milestone record/s based on selected Milestone Definition record/s
    Inputs: None
    Returns: Void
    History
    10/23/14      Michael Lasala      Created
	02/03/15	  Rey Austral		  Add creation of task
    ------------------------------------------------------------*/
    public void createProjectMilestones()
    {
        if(milestoneDefinitionWrapperList != null && !milestoneDefinitionWrapperList.isEmpty())
        {
            List<Project_Milestone__c> projectMilestonesToBeInsertedList = new List<Project_Milestone__c>();
            
            Set<Id> selectedMilestoneDefinitionIdsSet = new Set<Id>();
            
            Integer selectedCounter = 0;
            
            for(milestoneDefinitionWrapper mdw: milestoneDefinitionWrapperList)
            {
                //Iterate over selected Milestone Definition records
                if(mdw.isSelected)
                {
                    //Add to set to be used for retrieving child Activity Definition records
                    selectedMilestoneDefinitionIdsSet.add(mdw.milestoneDefinition.Id);
                    
                    //Get the Site of the subproject
                    List<SubProjectSite__c> siteList = IMP_Project_Utility.buildSiteNames(subProjectId);
                    //Build Project Milestone record
                    Project_Milestone__c projectMilestone = IMP_Project_Utility.buildProjectMilestone(mdw.milestoneDefinition, subProjectId, siteList);
                    
                    //Add to list of Project Milestone to be inserted
                    projectMilestonesToBeInsertedList.add(projectMilestone);
                } 
                else 
                {   
                    //Used for checking if any record was selected
                    selectedCounter++;
                }
            }
            
            //Validate if there are selected records to insert
            if(selectedCounter == milestoneDefinitionWrapperList.size())
            {
                //Flag for closing popup window if validations passed
                isValid = false;
                
                //Display error if no Milestone Definition records are selected
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, IMP_String_Utility.NO_MILESTONES_SELECTED ));
            } 
            else 
            {
                //Flag for closing popup window if validations passed
                isValid = true;
                
                //Insert Project Milestones
                if(!projectMilestonesToBeInsertedList.isEmpty())
                {
                    try
                    { 
                        insert projectMilestonesToBeInsertedList;
                    } 
                    catch (DmlException e)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
                        System.debug('$$$ insert projectMilestonesToBeInsertedList DmlException: '+e);
                    }
                    
                    List<Activity_Definition__c> activityDefinitionList = IMP_Project_Utility.retrieveActivityDefinitionsBySet(selectedMilestoneDefinitionIdsSet);
                    List<Project_Activity__c> projectActivityToBeInsertedList = new List<Project_Activity__c>();
                    
                    if(!activityDefinitionList.isEmpty())
                    {
                        for(Project_Milestone__c pm: projectMilestonesToBeInsertedList)
                        {
                            //Iterate through Activity Definition and instantiate a new Project_Activity__c record for each and map respective fields
                            for(Activity_Definition__c ad: activityDefinitionList)
                            {
                                if(ad.Milestone_Definition__c == pm.Milestone_Definition__c)
                                {
                                    //Build Project Activity Record
                                    Project_Activity__c projectActivity = IMP_Project_Utility.buildProjectActivity(ad, pm.Id, subProject);
                                    
                                    //Add Project Activity to list that will be inserted later
                                    projectActivityToBeInsertedList.add(projectActivity);
                                }
                            }
                        }
                        System.debug('$$$ projectActivityToBeInsertedList: ' + projectActivityToBeInsertedList);
                        
                        //Insert Project Activities
                        if(!projectActivityToBeInsertedList.isEmpty())
                        {
                            try
                            {                                
                                insert projectActivityToBeInsertedList;
                                //Phase 2 Rel 1
                                IMP_Project_Utility.createProjectTask(projectActivityToBeInsertedList,subProject);
                                //Phase 2 Rel 1
                            } 
                            catch (DmlException e)
                            {
                                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
                                System.debug('$$$ insert projectActivityToBeInsertedList DmlException: ' + e);
                            }
                        }
                    }
                }
            }
        }
    }
    
    /*------------------------------------------------------------
    Author: Michael Lasala
    Company: Cloud Sherpas
    Description: Project Milestone wrapper class which enables user to select records
    Inputs: 
    Returns: 
    History
    10/23/14    Michael Lasala      Created
    ------------------------------------------------------------*/
    public class milestoneDefinitionWrapper
    {
        public Milestone_Definition__c milestoneDefinition { get; set; }
        public Boolean isSelected { get; set; }
        
        public milestoneDefinitionWrapper(Milestone_Definition__c milestoneDefinition)
        {
            this.milestoneDefinition = milestoneDefinition;
            this.isSelected = false;
        }
    }
    
   
}