/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Add Product Milestones Controller which displays a list of Milestone Definition records based on the SubProject Market's Milestone Definition Products
Test Class: IMP_ProductMilestonesController_Test
History
10/22/14    Michael Lasala      Created
------------------------------------------------------------*/
public with sharing class IMP_ProductMilestones_Controller{
    
    public String subProjectId;
    public SubProject__c subProject {get;set;}
    public List<milestoneDefinitionWrapper> milestoneDefinitionWrapperList {get;set;}
    public Boolean isValid {get;set;}
    
    public IMP_ProductMilestones_Controller(){
        
        //Get SubProject__c record Id
        subProjectId = ApexPages.currentPage().getParameters().get('subProjectId');
        
        if(subProjectId != null){
            
            //Retrieve SubProject
            subProject = IMP_Project_Utility.retrieveSubProject(subProjectId);
            
            //Retrieve Milestone Definitions Product Ids based on SubProject Market
            Set<Id> milestoneDefinitionProductIdSet = IMP_Project_Utility.retrieveMilestoneDefinitionProductsIdSet(subProject.Market__c);
            
            if(!milestoneDefinitionProductIdSet.isEmpty()){
                
                //Retrieve Milestone Definition records based on Milestone Definitions Products' Milestones
                List<Milestone_Definition__c> milestoneDefinitionList = IMP_Project_Utility.retrieveMilestonesDefinitionsBySet(milestoneDefinitionProductIdSet);
                
                if(!milestoneDefinitionList.isEmpty()){
                    
                    milestoneDefinitionWrapperList = new List<milestoneDefinitionWrapper>();
                    
                    for(Milestone_Definition__c md: milestoneDefinitionList){
                        
                        //Add Milestone Definition records to wrapper list
                        milestoneDefinitionWrapperList.add(new milestoneDefinitionWrapper(md));
                    }
                }
            }
        }
    }
    
    /*------------------------------------------------------------
	Author: Michael Lasala
	Company: Cloud Sherpas
	Description: Insert Project Milestone record/s based on selected Milestone Definition record/s
	Inputs: None
	Returns: Void
	History
	10/23/14      Michael Lasala      Created
	------------------------------------------------------------*/
    public void createProjectMilestones(){
        
        if(!milestoneDefinitionWrapperList.isEmpty()){
            
            List<Project_Milestone__c> projectMilestonesToBeInserted = new List<Project_Milestone__c>();
            
            Set<Id> selectedMilestoneDefinitionIds = new Set<Id>();
            
            Integer selectedCounter = 0;
            
            for(milestoneDefinitionWrapper mdw: milestoneDefinitionWrapperList){
                
                //Iterate over selected Milestone Definition records
                if(mdw.isSelected){
                    
                    //Add to set to be used for retrieving child Activity Definition records
                    selectedMilestoneDefinitionIds.add(mdw.milestoneDefinition.Id);
                    
                    //Build Project Milestone record
                    Project_Milestone__c projectMilestone = IMP_Project_Utility.buildProjectMilestone(mdw.milestoneDefinition, subProjectId, null);
                    
                    //Add to list of Project Milestone to be inserted
                    projectMilestonesToBeInserted.add(projectMilestone);
                } else {
                    
                    //Used for checking if any record was selected
                    selectedCounter++;
                }
            }
            
            //Validate if there are selected records to insert
            if(selectedCounter == milestoneDefinitionWrapperList.size()){
                
                //Flag for closing popup window if validations passed
                isValid = false;
                
                //Display error if no Milestone Definition records are selected
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, 'No Milestones selected'));
                
            } else {
                //Flag for closing popup window if validations passed
                isValid = true;
                
                //Insert Project Milestones
                if(!projectMilestonesToBeInserted.isEmpty()){
                    try{ 
                        insert projectMilestonesToBeInserted;
                    } catch (DmlException e){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
                        System.debug('$$$ insert projectMilestonesToBeInserted DmlException: '+e);
                    }
                    
                    List<Activity_Definition__c> activityDefinitionList = IMP_Project_Utility.retrieveActivityDefinitionsBySet(selectedMilestoneDefinitionIds);
                    List<Project_Activity__c> projectActivityToBeInserted = new List<Project_Activity__c>();
                    
                    if(!activityDefinitionList.isEmpty()){
                        
                        for(Project_Milestone__c pm: projectMilestonesToBeInserted){
                            
                            //Iterate through Activity Definition and instantiate a new Project_Activity__c record for each and map respective fields
                            for(Activity_Definition__c ad: activityDefinitionList){
                                
                                if(ad.Milestone_Definition__c == pm.Milestone_Definition__c){
                                    
                                    //Build Project Activity Record
                                    Project_Activity__c projectActivity = IMP_Project_Utility.buildProjectActivity(ad, pm.Id, subProject);
                                    
                                    //Add Project Activity to list that will be inserted later
                                    projectActivityToBeInserted.add(projectActivity);
                                }
                            }
                        }
                        System.debug('$$$ projectActivityToBeInserted: '+projectActivityToBeInserted);
                        
                        //Insert Project Activities
                        if(!projectActivityToBeInserted.isEmpty()){
                            
                            try{
                                
                                insert projectActivityToBeInserted;
                                
                            } catch (DmlException e){
                                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
                                System.debug('$$$ insert projectActivityToBeInserted DmlException: '+e);
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
    public class milestoneDefinitionWrapper{
        public Milestone_Definition__c milestoneDefinition {get;set;}
        public Boolean isSelected {get;set;}
        
        public milestoneDefinitionWrapper(Milestone_Definition__c milestoneDefinition){
            this.milestoneDefinition = milestoneDefinition;
            this.isSelected = false;
        }
    }
}