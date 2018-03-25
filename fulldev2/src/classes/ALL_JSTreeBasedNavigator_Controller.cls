/*--------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: The controller that receive and pass data to the page controller
Test Class: 
History
04/27/2015    Rey Austral      Created
10/05/2015	  Rey Austral	   Add limit of selecting number of parents
--------------------------------------------------------------*/
public class ALL_JSTreeBasedNavigator_Controller extends ALL_ComponentBase_Controller
{
    public List<ALL_JSTree_Relationship__c> customRelationList { get; set; }
    public String checkedParentIds { get; set; }
    public String checkedChildIds { get; set; }
    public String parentObjectName { get; set; }
    public String childObjectName { get; set; }    
    transient public String generatedJSON { get; set; } 
    public String openedIds { get; set; }
    public Boolean dataRefreshed { get; set; }
    //2015-22-5 PH TIME - Rey Austral - fix if the key is missing to avoid error
    public String keyPage { get; set; }  
    //2015-05-10 - Rey Austral - Add limitation of number of root parent can be selected
    public Integer maxSelectedRecord { get; set; }
    //get the instance of the page controller
    public ALL_RecordsView_Controller pageControl  
    {
        set; 
        get 
        { 
            return (ALL_RecordsView_Controller)pagecontroller.getThis(); 
        } 
    }
    
    //this call the method of the page that populate the tree
    public Boolean triggerRefresh 
    {
        get;
        set
        {
            if(value != null)
            {    
                if (value)
                {                    
                    triggerRefresh = value;                
                    generatedJSON = pageControl.populateJsonWrapper();
                    dataRefreshed = true;    
                }
                
            }            
        }
    }
    
    public ALL_JSTreeBasedNavigator_Controller() 
    { 
        //2015-22-5 PH TIME - Rey Austral - fix if the key is missing to avoid error
        Id objectId = ApexPages.currentPage().getParameters().get('id');    
        String objectName = objectId.getSObjectType().getDescribe().getName();	        
        keyPage = ApexPages.currentPage().getParameters().get('key');  
        if (objectName == 'SubProject__c' && keyPage == null)
        {
            keyPage = 'Milestone';
        }
        CustomSettings__c cs = CustomSettings__c.getInstance();
		maxSelectedRecord = 50;
		if (cs.Max_Milestone_Tree_Threshold__c != null)
		{
			maxSelectedRecord = (Integer)cs.Max_Milestone_Tree_Threshold__c;
		}
        generateEditButton();
    }
    
/*--------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Get information from the custom settings and generate the edit buttons
Test Class: 
History
04/27/2015    Rey Austral      Created
--------------------------------------------------------------*/
    public void generateEditButton()
    {
        //2015-22-5 PH TIME - Rey Austral - remove getting the key
        customRelationList = [Select Parent_Description__c, Parent_Object__c, Child_Description__c, Child_Object__c from ALL_JSTree_Relationship__c where Key__c =: keyPage Order by Order__c];        
    }  
    
/*--------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: get checked/selected data from the tree and pass it to the page controller
Test Class: 
History
04/27/2015    Rey Austral      Created
--------------------------------------------------------------*/
    public void somethingSelected()
    {   
        pageControl.openedCheckedIds = openedIds;
        pageControl.somethingIsSelected(parentObjectName,childObjectName,checkedParentIds,checkedChildIds);       
    }
    
}