/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Add Standard and Product Milestones Controller which displays a list of Milestone Definition records based on the SubProject Market's Milestone Definition Products
Test Class: IMP_ProductMilestonesController_Test
History
10/22/14    Michael Lasala      Created
02/11/15	Rey Austral			Add creation of task
09/21/15	Rey Austral			Move the creation of Activity in the Project Utility
10/01/15	Rey Austral		    Change the milestoneDefinitionProjectMap type from Map<Id, Project_Milestone__c> to Map<Id, List<Project_Milestone__c>>
------------------------------------------------------------*/
public with sharing class IMP_AddMilestones_Controller
{
    public String subProjectId;
    public SubProject__c subProject { get; set; }
    public List<milestoneDefinitionWrapper> milestoneDefinitionWrapperList { get; set; }
    public Boolean isValid { get; set; }
    public List<SubProjectSite__c> subProjecSiteList { get; set; }
    public List<SelectOption> siteOptions { get; set; }
    public String selectedSite { get;  set; }   
    public Boolean showSite { get; set; }
    public IMP_AddMilestones_Controller()
    {
         
        //Get SubProject__c record Id
        subProjectId = ApexPages.currentPage().getParameters().get('subProjectId');
        
        if(subProjectId != null)
        {
            //Retrieve SubProject
            subProject = IMP_Project_Utility.retrieveSubProject(subProjectId);
            subProjecSiteList = [Select Id, Name, Account__c,Account__r.Name From SubProjectSite__c where subproject__c =:  subprojectId];
            //2015-07-30 Rey Austral, Remove the loading of milestone and add loading of site
            //create an option for the select list
            //only product milestone has the requirement to select a site before selecting the milestone
            String entryType = ApexPages.currentPage().getParameters().get('type');
            if(entryType == 'Product')
            {
                Map<String,String> optionsMap = new Map<String,String>();
                optionsMap.put('', '--None--');
                for (SubProjectSite__c site : subProjecSiteList) 
                {
                    optionsMap.put(site.Id, site.Name + ' - ' + site.Account__r.Name);
                }
                siteOptions = IMP_Project_Utility.buildSelectOption(optionsMap, false);
                siteOptions.sort();
                if (siteOptions.size() == 1) 
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'There is no existing site for this sub project, Please create a new site first.'));                     
                }
                showSite = true;
            }
            else
            {
                //load the milestone if the entry is for the standard milestone
                selectedSite = null;
                showSite = false;
                loadMilestone();
            }            
        }
    }
    
    public void loadMilestone()
    {
        //2015-07-30 Rey Austral - Method that the site onchange use to load the milestone
        ApexPages.getMessages().clear();
        String entryType = ApexPages.currentPage().getParameters().get('type');
        milestoneDefinitionWrapperList = new List<milestoneDefinitionWrapper>();
        if ((selectedSite == null || selectedSite == '') && entryType == 'Product') 
        {
            milestoneDefinitionWrapperList = null;
        }
        else
        {
            List<Milestone_Definition__c> milestoneDefinitionList = new List<Milestone_Definition__c>();
            //load the appropriate milestone records
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
                Map<Id, Project_Milestone__c> alreadyExistingMilestoneDefIdtoProjectMilestoneMap = new Map<Id, Project_Milestone__c>();
                Set<Id> projectTypeProductMilestoneDefinitionSet = (new Map<Id,Milestone_Definition__c>(milestoneDefinitionList)).keyset();
                
                //get the existing milestone that has the selected site and milestone definition on it                
                List<Project_Milestone__c> existingMilestone =  IMP_Project_Utility.findExistingSubProjectRecsForMilestoneDefs(projectTypeProductMilestoneDefinitionSet ,subProject.id,selectedSite);
                for (Project_Milestone__c miles : existingMilestone)
                {    
                    //extend the filter of existine milestone, already created product milestone and rms milestone that has non-rms activity should be included in the map 
                    //the milestone here will not be added in the list(milestoneDefinitionWrapperList)
                    //standard milestone will not use this function, standard milestone will always be shown in the list
                    if (miles.RMS_Owned_flag__c == false || 
                        (miles.RMS_Owned_flag__c == true && miles.Non_RMS_Owned_Standard_Activities_Create__c == true))
                    {
                        alreadyExistingMilestoneDefIdtoProjectMilestoneMap.put(miles.Milestone_Definition__c, miles);                        
                    }                                        
                }                
                
                //do not include milestone defintion that is already created in the project milestone 
                //but include milestone that was generated by the rms integration that has no non-rms activity record created on it
                for(Milestone_Definition__c md: milestoneDefinitionList)
                {
                    //Add Milestone Definition records to wrapper list
                    if (!alreadyExistingMilestoneDefIdtoProjectMilestoneMap.containsKey(md.id))
                    {
                       milestoneDefinitionWrapperList.add(new milestoneDefinitionWrapper(md)); 
                    }                    
                }
            }
            
            if (milestoneDefinitionWrapperList.isEmpty() && !milestoneDefinitionList.isEmpty())
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'You already have added all Milestone to the site.  Please either select a different site, or exit by clicking the ‘Cancel button’')); 
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
	09/21/15	  Rey Austral		  Move the creation of Activity in the Project Utility
	10/01/15	  Rey Austral		  Change the milestoneDefinitionProjectMap type from Map<Id, Project_Milestone__c> to Map<Id, List<Project_Milestone__c>>
    ------------------------------------------------------------*/
    public void createProjectMilestones()
    {
        if(milestoneDefinitionWrapperList != null && !milestoneDefinitionWrapperList.isEmpty())
        {
            Map<Id, List<Project_Milestone__c>> milestoneDefinitionProjectMap = new Map<Id, List<Project_Milestone__c>>();            
            List<Milestone_Definition__c> selectedMilestoneDefinitionsList = new List<Milestone_Definition__c>();            
            Integer selectedCounter = 0;
            
            for(milestoneDefinitionWrapper mdw: milestoneDefinitionWrapperList)
            {
                //Iterate over selected Milestone Definition records
                if(mdw.isSelected)
                {
                    //Add to set to be used for retrieving child Activity Definition records
                    selectedMilestoneDefinitionsList.add(mdw.milestoneDefinition);                  
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
                if(!selectedMilestoneDefinitionsList.isEmpty())
                {
                    //createProjectMilestones will determine if the milestone definiton will be created or not and the activity will just append to the existinge milestone record 
                    milestoneDefinitionProjectMap = IMP_Project_Utility.createProjectMilestones(subProject.Id, '',  '', selectedMilestoneDefinitionsList, selectedSite); 
                    system.debug('$$milestoneDefinitionProjectMap ' + milestoneDefinitionProjectMap);
                    //2015-09-21 Rey Austral - Move the creation of Activity in the Project Utility
                    Map<Id,Subproject__c> subprojectMap = new Map<Id,Subproject__c>();
                    subprojectMap.put(subProject.id, subProject);
                    String errorMessage = IMP_Project_Utility.createProjectActivity(subprojectMap,milestoneDefinitionProjectMap );
                    if (!errorMessage.equals(''))
                    {
                      isValid = false;  
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