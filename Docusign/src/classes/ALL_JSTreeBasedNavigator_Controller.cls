/*--------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: The controller that receive and pass data to the page controller
Test Class: 
History
04/27/2015    Rey Austral      Created
--------------------------------------------------------------*/
public class ALL_JSTreeBasedNavigator_Controller extends ALL_ComponentBase_Controller
{
    public List<ALL_JSTree_Relationship__c> customRelationList { get; set; }
    public String checkedParentIds { get; set; }
    public String checkedChildIds { get; set; }
    public String parentObjectName { get; set; }
    public String childObjectName { get; set; }    
    public String generatedJSON { get; set; } 
    public String openedIds { get; set; }
    public Boolean dataRefreshed { get; set; }
    //2015-22-5 PH TIME - Rey Austral - fix if the key is missing to avoid error
    public String key { get; set; }  
    
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
        key = ApexPages.currentPage().getParameters().get('key');  
        if (objectName == 'SubProject__c' && key == null)
        {
            key = 'Milestone';
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
        customRelationList = [Select Parent_Description__c, Parent_Object__c, Child_Description__c, Child_Object__c from ALL_JSTree_Relationship__c where Key__c =: key Order by Order__c];        
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