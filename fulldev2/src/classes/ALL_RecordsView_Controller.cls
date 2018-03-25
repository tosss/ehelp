/*--------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: The controller that handles communication between the tree component and the datatable component
Test Class: 
History
04/29/2015    Rey Austral      Created
05/19/2015    Matt Keefe       Updated - formatting
10/31/2015    Karl Simon       Updated generator variable - made it Transient.
01/20/2016    Venkata Shrivol  updated the redirectToViewPage variable
--------------------------------------------------------------*/
public class ALL_RecordsView_Controller extends ALL_PageBase_Controller
{
    transient private JSONGenerator generator;   
    public ALL_RecordsViewWrapper attributesCollection { get; set; }
    //2015-05-22 PH TIME - Rey Austral - change the object id from string to id
    public Id objectId { get; set; }
    public String key { get; set; }  
    public Boolean renderTree { get; set; }    
    public Boolean triggerRefresh { get; set; }
    public ALL_ComponentBase_Controller baseComponentController { get; set; }
    public ALL_JSTreeBasedNavigator_Controller jstreeNavigation { get; set; }
    public String childSelectedIds { get; set; }
    public String parentSelectedIds { get; set; }
    public String openedCheckedIds { get; set; }
    // 2015-05-15 PH DATE Rey Austral - to be pass on the javascript closePage() function
    public String redirectToViewPage { get; set; }
    // 2015-05-15 PH DATE Rey Austral - to be used in the sub header
    public SubProject__c subProject {get;set;}
    
    public class JSONGenerator 
    {
        List<JsonWrapper> jsonTreeData = new List<JsonWrapper>();
    }
    
    //2015-05-19 IST DATE Anirudh Singh- Added to display Parent Child Component
    public Boolean displayParentChildComponent{get; set;}
        
    //convert the class wrapper to json format
    public String generatedJSON 
    {
        get 
        {
            return JSON.serialize(generator);
        }
    }
    
    public override void setComponentController(ALL_ComponentBase_Controller compBaseController) 
    {
        baseComponentController = (ALL_ComponentBase_Controller)compBaseController;       
    }
    
    public override ALL_ComponentBase_Controller getMyComponentController() 
    {      
        return baseComponentController;
    }
    
    public ALL_RecordsView_Controller ()
    {        
        //2015-05-22 PH TIME - Rey Austral - fix if the key is missing to avoid error
        objectId = ApexPages.currentPage().getParameters().get('id');    
        
        //2015-06-19 PST - Karl Simon - test if the Browser is IE, and if it is, add a parameter to help override compatibility mode
        String userAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
        if (userAgent.contains('MSIE'))
        {
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');
        }
        String objectName = objectId.getSObjectType().getDescribe().getName();  
        
        key = ApexPages.currentPage().getParameters().get('key');  
        if (objectName == 'SubProject__c' && key == null)
        {
             key = 'Milestone';
        }
        System.debug('Constructing the page.  Key is: ' + key);  
        childSelectedIds = '';
        parentSelectedIds = '';
        openedCheckedIds = '';
        // 2015-05-15 PH DATE Rey Austral - to go back to the view page
        // 2015-05-27 Karl Simon - updated to now rever to IMP_SubProjectManagement1 instead of IMP_SubProjectManagement_2
        // 2016-01-20 - venkata.shrivol@cdk.com - changed this to new page
        redirectToViewPage = '/apex/IMP_MilestoneView?id=' + objectId;
        // 2015-05-15 PH DATE Rey Austral - to be used in the sub header
        subProject = IMP_Project_Utility.retrieveSubProject(objectId);
        triggerRefresh = true;
        
        //2015-05-19 IST DATE Anirudh Singh
        displayParentChildComponent=false;
    }
    
/*--------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: The method that populates the data of the datatable attributes 
Test Class: 
History
04/29/2015    Rey Austral      Created
--------------------------------------------------------------*/
    public override void somethingIsSelected(String parentName, String childName, String parentSelectedId, String childSelectedId)
    {
        system.debug(parentName);
        system.debug(childName);
        system.debug(parentSelectedId);
        system.debug(childSelectedId);
        
        if (parentSelectedId != null && childSelectedId!= null) 
        {
            //2015-05-22 PH DATE Rey Austral - Add new Parent_Requires_Children__c,GrandParent_Relationship_Field__c
            //2015-05-22 Karl Simon - Added Parent_FieldOrderSet__c, Child_FieldOrderSet__c to the custom setting query
            //25th May, 2015- Anirudh Singh- Added Grandparent_Display_Field__c to the query.
            //2015-07-29- anirudh.singh@cdk.com- Added Child_FieldstoDisableForRow__c, Parent_FieldstoDisableForRow__c.
            //2015-07-29- anirudh.singh@cdk.com- Added Child_DisableCheckField__c, Parent_DisableCheckField__c.
            ALL_JSTree_Relationship__c customRelationList =  [
                Select Parent_Relationship_Field_Name__c, Child_Relationship__c, Parent_Fieldset__c, Child_Fieldset__c, Field_To_Sort_Parent_Record__c,
                    Parent_Create_Enabled__c, Child_Create_Enabled__c, Parent_Requires_Children__c, GrandParent_Relationship_Field__c, 
                    Parent_FieldOrderSet__c, Child_FieldOrderSet__c, Grandparent_Display_Field__c , Parent_DisableCheckField__c, Parent_FieldstoDisableForRow__c,
                    Child_FieldstoDisableForRow__c, Child_DisableCheckField__c
                from ALL_JSTree_Relationship__c 
                where Key__c =: key 
                And Parent_Object__c = :parentName 
                and Child_Object__c =: childName 
                LIMIT 1
            ];  
            
            attributesCollection = new ALL_RecordsViewWrapper();
            attributesCollection.parentAPIName = parentName;
            attributesCollection.childAPIName = childName;
            attributesCollection.childRelationshipName = customRelationList.Child_Relationship__c;
            attributesCollection.parentrelationshipFieldName = customRelationList.Parent_Relationship_Field_Name__c;
            attributesCollection.parentColumnNames = convertFieldsetToString( readFieldSet( customRelationList.Parent_Fieldset__c, parentName ) );
            attributesCollection.childColumnNames = convertFieldsetToString( readFieldSet( customRelationList.Child_Fieldset__c, childName ) );
            //2015-05-22 Karl Simon - Added new attributes for the parent and child sort columns
            attributesCollection.parentFieldSortOrderAPINames = convertFieldsetToString( readFieldSet( customRelationList.Parent_FieldOrderSet__c, parentName ) );
            attributesCollection.childFieldSortOrderAPINames = convertFieldsetToString( readFieldSet( customRelationList.Child_FieldOrderSet__c, childName ) );
            //2016-01-20- anirudh.singh@cdk.com- Changed the value of the below parameter childSearchEnabled from true to false.
            attributesCollection.childSearchEnabled = false;
            attributesCollection.filterConditionParent ='where ID in (' + parentSelectedId + ')';
            attributesCollection.filterConditionChild = 'where ID in (' + childSelectedId + ')';
            attributesCollection.mode = 'Edit';
            attributesCollection.redirectURL = '';
            //25th May, 2015- Anirudh Singh- Commented 
            //attributesCollection.parentSortColumnName = customRelationList.Field_To_Sort_Parent_Record__c;
            attributesCollection.parentColumnWidths = '60px, 60px, 100px, 100px, 100px, 80px, 80px';
            attributesCollection.childColumnWidths = '100px, 100px, 100px, 100px, 100px, 100px, 100px';
            attributesCollection.quickSaveEnabled = true;
            attributesCollection.saveEnabled = true;
            //2015-05-22 Karl Simon - Updated the value of the deleteEnabled value from true to false
            attributesCollection.deleteEnabled = false;
            attributesCollection.massUpdateEnabled = true;
            attributesCollection.dataAvailable = true;
            attributesCollection.rerenderDatatable = true;
            //2015-05-22 PH DATE Rey Austral - Add new parameters for the new create activity
            attributesCollection.parentRequiresChildren = customRelationList.Parent_Requires_Children__c;
            attributesCollection.grandparentRelationshipField = customRelationList.GrandParent_Relationship_Field__c;
            
            //25th May, 2015- Anirudh Singh- Added grandparent display field.
            attributesCollection.grandparentDisplayFieldName=customRelationList.Grandparent_Display_Field__c;
            
            // 2015-05-13 PH DATE Rey Austral - rename the variable 
            if (IMP_Project_Utility.checkUserPermission(parentName, 'PermissionsCreate') && customRelationList.Parent_Create_Enabled__c)
            {
                attributesCollection.createNewParentEnabled = true;
            }
            else
            {
                attributesCollection.createNewParentEnabled = false;
            }
            
            // 2015-05-13 PH DATE Rey Austral - use createNewChildEnabled instead of childCreateEnabled
            if (IMP_Project_Utility.checkUserPermission(childName, 'PermissionsCreate') && customRelationList.Child_Create_Enabled__c)
            {
                attributesCollection.createNewChildEnabled = true;
            } 
            else
            {
                attributesCollection.createNewChildEnabled = false;
            }
            
            childSelectedIds = childSelectedId;
            parentSelectedIds = parentSelectedId;
           
            //2015-05-19 IST DATE Anirudh Singh
            displayParentChildComponent=true;
            
            //2015-07-29- anirudh.singh@cdk.com- Added the 4 parameters to be passed to Parent Child Component.
            //childFieldsToDisableForRow, parentFieldsToDisableForRow, childDisableCheckField, parentDisableCheckField.
            if(customRelationList.Child_FieldstoDisableForRow__c!=Null && customRelationList.Child_FieldstoDisableForRow__c!='')
            {
                attributesCollection.childFieldsToDisableForRow=convertFieldsetToString(readFieldSet(customRelationList.Child_FieldstoDisableForRow__c, childName));
            }
            if(customRelationList.Parent_FieldstoDisableForRow__c!=Null && customRelationList.Parent_FieldstoDisableForRow__c!='')
            {
                attributesCollection.parentFieldsToDisableForRow=convertFieldsetToString(readFieldSet(customRelationList.Parent_FieldstoDisableForRow__c, parentName));
            }
            attributesCollection.childDisableCheckField=customRelationList.Child_DisableCheckField__c;
            attributesCollection.parentDisableCheckField=customRelationList.Parent_DisableCheckField__c;
            
            system.debug('In somethingSelected.  displayParentChildComponent---->'+displayParentChildComponent+ ' and attributesCollection---->'+attributesCollection);
        }
    }
    
    /*--------------------------------------------------------------
    Author: Anirudh Singh
    Company: CDK Global
    Description: The method is used to set the Boolean parameter to rerender the Parent Child Component.
    History
    05/21/2015    Anirudh Singh      Created
    --------------------------------------------------------------*/
    public override void rerenderParentChildComponent()
    {
        system.debug('Start rerenderParentChildComponent---->');
        displayParentChildComponent=false;
        system.debug('End rerenderParentChildComponent---->'+displayParentChildComponent);
    }
    
/*--------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: The method that retrieve records from the database to be used in populating the tree component
Test Class: 
History
04/29/2015    Rey Austral      Created
--------------------------------------------------------------*/
    public String populateJsonWrapper()
    {
        String result = '';
         //2015-05-27 PH Time - Rey Austral - add Field_Order_Set__c to sort the tree        
        
        List<ALL_JSTree_Fields__c> customField = [
            Select Object_Name__c, Condition_Field__c, Parent_Field_Name__c, Description_Field_Name__c , Field_Order_Set__c
            from ALL_JSTree_Fields__c 
            where Key__c =: key
        ];
        
        if (customField.size() > 0)
        {
            generator = new JSONGenerator();
            for (ALL_JSTree_Fields__c field :customField )
            {                
                List<SObject> recordList = QueryRelated(field, objectId);
                
                for(SObject record : recordList)
                {
                    JsonWrapper jWrapper = new JsonWrapper();
                    String description = (String)record.get(field.Description_Field_Name__c);
                    
                    if (description != null && description.length() > 34)
                    {
                        jWrapper.text = description.substring(0,34) + '...';
                    }else 
                    {
                        jWrapper.text = description;
                    }
                    
                    jWrapper.id = (String)record.get('Id'); 
                    
                    if (field.Parent_Field_Name__c != null)
                    {
                        jWrapper.parent  = (String)record.get(field.Parent_Field_Name__c); 
                    } 
                    else
                    {
                        jWrapper.parent  = '#';
                    }
                    
                    JsonState state = new JsonState(); 
                    if (childSelectedIds != '' && childSelectedIds.contains(jWrapper.id ))
                    {
                        state.opened = true;
                        state.checked = true;
                    }
                    //open the tree node from the previous selected records
                    if (openedCheckedIds != '' && openedCheckedIds.contains(jWrapper.id ))
                    {
                        state.opened = true;
                    }
                    jWrapper.state = state;
                    
                    
                    JsonAdditionalData data = new JsonAdditionalData();
                    data.objectName = field.Object_Name__c;
                    data.description = description;
                    
                    jWrapper.data = data;
                    
                    generator.jsonTreeData.add(jWrapper); 
                }
            }            
        }  
        
        if (generator != null)
        {
            result = JSON.serialize(generator);
        }
        return result;
    }
    
    public List<SObject> QueryRelated (ALL_JSTree_Fields__c fields, String Id)
    {
        String query = '';
         //2015-05-27 PH Time - Rey Austral - include order by
        String orderBy = 'Order by ' + convertFieldsetToString( readFieldSet( fields.Field_Order_Set__c,  fields.Object_Name__c ) );
        if ( fields.Parent_Field_Name__c != null)
        {
            query = 'Select ID, ' + fields.Description_Field_Name__c + ',' + fields.Parent_Field_Name__c + 
                ' from ' + fields.Object_Name__c + 
                ' where ' + fields.Condition_Field__c + ' = \'' + Id.substring(0,15) + '\' ' + orderBy; 
        } 
        else
        {
            query = 'Select ID, ' + fields.Description_Field_Name__c + 
                ' from ' + fields.Object_Name__c + 
                ' where ' + fields.Condition_Field__c + ' = \'' + Id.substring(0,15) + '\' ' + orderBy; 
        }        
        
        List<SObject> recordsList =  Database.query(query);
        return recordsList;
    }
    
    public List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
        //Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        //Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.SObjectType SObjectTypeObj = Schema.getGlobalDescribe().get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        
        return fieldSetObj.getFields(); 
    }  
    
    public String convertFieldsetToString(List<Schema.FieldSetMember> objectFieldSet)
    {
        String result = '';
        for(Schema.FieldSetMember f : objectFieldSet){
            result += f.getFieldPath() + ',';
        }
        if (result != '')
        {
            result = result.subString(0, result.length() - 1);
        }        
        return result;
    }
    
    public override PageReference childProcessingComplete(Boolean withChanges)
    {
        if (withChanges)
        {
            //triggerRefresh = false;
            System.debug('called');
            System.debug('There were changes, through clicking the Save button.  Key is: ' + key);   
            jstreeNavigation  = (ALL_JSTreeBasedNavigator_Controller)baseComponentController;
            jstreeNavigation.triggerRefresh = true;
        } else 
        {
            // 2015-05-20 Karl - the page should reconstruct the datatable component with dataAvailable attribute set to false
            System.debug('There were no changes, and, the cancel button was clicked.  Key is: ' + key);  
        } 
        return null;
    }
    
    public class JsonWrapper
    {
        public String id { get; set; }         
        public String text { get; set; }  
        public String parent { get; set; }
        public JsonState state { get; set; }
        public JsonAdditionalData data { get; set; }
    }
    
    public class JsonState
    {
        public Boolean opened { get; set; }
        public Boolean checked { get; set; }
    }
    
    public class JsonAdditionalData
    {
        public String objectName { get; set; }
        public String description { get; set; }
    }   
    
}