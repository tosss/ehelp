//Author: Anirudh Singh
//Description: This is the controller for the class ALL_ParentChildRecordsController.
//Dated: 2015-02-01
//2015-05-19 MK - renamed from ALL_ParentChildRecordsController and added base class
public class ALL_ParentChildRecords_Controller extends ALL_ComponentBase_Controller
{
    //This Boolean variable is used to prevent the initialization of the setters twice on the load of the component.
    private Boolean initialized=false;
    
    //This String is used to hold the Parent API Name.
    public String fetchParentAPIName{get; set;}
    
    //This String is used to hold the Child API Name.
    public String fetchChildAPIName{get; set;}
    
    //This String is used to hold the relationship name of the Child Object.
    private String fetchChildRelationshipName{get; set;}
    
    //This List is used to hold the Parent Object Column Names.
    private List<String> parentColumnNames;
    
    //This List is used to hold the Parent Object Column Names excluding the relationship fields.
    private List<String> nonRelParentColumnNames;
    
    //This List is used to hold the Child Object Column Names.
    private List<String> childColumnNames;
    
    //This Boolean is used to determine whether the Child Search Panel should be enabled or not.
    public Boolean childSearch{get; set;}
    
    //This String is used as a condition on Parent records.
    private String parentCondition{get; set;}
    
    //This String is used as a condition on Child records.
    private String childCondition{get; set;}
    
    //This String is used as a condition on Parent records.
    public String displayMode{get; set;}
    
    //This String is used as a condition on Child records.
    public String redirectURLLocation{get; set;}
    
    //This Boolean variable is used to display the Create New Child button.
    public Boolean displayCreateNewChildButton{get; set;}
    
    //This List is used to hold the Parent Object Column Widths excluding the relationship fields.
    private List<String> parentColumnWidths;
    
    //This List is used to hold the Child Object Column Widths excluding the relationship fields.
    private List<String> childColumnWidths;
    
    //This Boolean variable is used to display the Edit button.
    public Boolean displayEditButton{get; set;}
    
    //This Boolean variable is used to display the Quick Save button.
    public Boolean displayQuickSaveButton{get; set;}
    
    //This Boolean variable is used to display the Save button.
    public Boolean displaySaveButton{get; set;}
    
    //This Boolean variable is used to display the Delete button.
    public Boolean displayDeleteButton{get; set;}
    
    //This Boolean variable is used to display the Mass Update button.
    public Boolean displayMassUpdateButton{get; set;}
    
    //This Boolean variable is used to display the Create New Parent button.
    public Boolean displayCreateNewParentButton{get; set;}
    
    //This Boolean variable is used to check if a child is required for the newly created Parent or not.
    private Boolean fetchParentRequiresChildren;
    
    //This String is used to hold the relationship Field Name On Parent, through which the Parent should be linked.
    public String fetchGrandparentRelationshipField{get; set;}
    
    //2015-05-25- anirudh.singh@cdk.com- Added
    //This String is used to hold the field Name to be displayed in the picklist for the grandparent.
    private String fetchGrandparentDisplayFieldName{get; set;}
    
    //2015-05-25- anirudh.singh@cdk.com- Added
    //This String is used for specifying the Parent column names according to which the sort should happen.
    private String fetchParentFieldSortOrderAPINames{get; set;}
    
    //2015-05-25- anirudh.singh@cdk.com- Added
    //This String is used for specifying the Child column names according to which the sort should happen.
    private String fetchChildFieldSortOrderAPINames{get; set;}
    
    //2015-07-16 anirudh.singh@cdk.com- Added
    private Map<String, Schema.SObjectType> globalDescMap=Schema.getGlobalDescribe();
    
    //2015-07-29- anirudh.singh@cdk.com- Added this parameter.
    //This String will hold the API Names of the Child Fields that need to be disabled for editing.
    public List<String> fetchChildFieldsToDisableForRow{get; set;}
    
    //2015-07-29- anirudh.singh@cdk.com- Added this parameter.
    //This String will hold the API Names of the Parent Fields that need to be disabled for editing.
    public List<String> fetchParentFieldsToDisableForRow{get; set;}
    
    //2015-07-29- anirudh.singh@cdk.com- Added this parameter.
    //This String will hold the API Name of the Child Field whose value will determine- 
    //for which records the fields specified in childFieldsToDisableForRow should be disabled.
    private String fetchChildDisableCheckField;
    
    //2015-07-29- anirudh.singh@cdk.com- Added this parameter.
    //This String will hold the API Name of the Parent Field whose value will determine- 
    //for which records the fields specified in parentFieldsToDisableForRow should be disabled.
    private String fetchParentDisableCheckField;
    
    //2015-07-29- anirudh.singh@cdk.com- Added this parameter.
    //This list will contain the Child record Ids for which the fields in the fetchChildFieldsToDisableForRow will be disabled.
    public List<String> childRecordIdsToBeDisabled{get; set;}
    
    //2015-07-29- anirudh.singh@cdk.com- Added this parameter.
    //This list will contain the Parent record Ids for which the fields in the fetchParentFieldsToDisableForRow will be disabled.
    public List<String> parentRecordIdsToBeDisabled{get; set;}
    
    // 2016-01-15 -venkata.shrivol@cdk.com - added this for tabindex RQ-05996
    public String tabIndexStringSet{
    	set;
    	get{
    		if(tabIndexStringSet == null || tabIndexStringSet ==''){
    			tabIndexStringSet = 'Planned Start Date;Planned End Date;CDK Assignee;Display on PSR';	
    		}
    		return tabIndexStringSet;
    	}
    }
    
    //This Object is used to hold the page controller.
    public ALL_PageBase_Controller pageController
    {
        get
        { 
            return (ALL_PageBase_Controller)pageController.getThis();
        }
        set; 
    } 
    
    //This property is used for setting the Child Column Widths.
    public ALL_RecordsViewWrapper fetchAllAttributes
    {
        get;
        set
        {
            if(!initialized && value!=Null)
            {
                init(value);
                system.debug('fetchAllAttributes---->'+value);
            }
        }
    }
    
    //This Boolean parameter is used for rendering the page only -
    //when all the required attributes for the component are provided by the page controller.
    public Boolean showData{get; set;}
    
    //This wrapper List is used to hold the Parent record, corresponding Child records and a Boolean value.
    //Boolean value is used to check whether the record is selected on the Visualforce Page or not.
    private List<ParentWrapper> parentWrapperList;
    
    //This is used to hold the Parent SObject Type which is used for initializing Parent records.
    private Schema.SObjectType targetTypeParent;
    
    //This is used to hold the Child SObject Type which is used for initializing Child records.
    private Schema.SObjectType targetTypeChild;
    
    //This is the Query Result that is iterated on the Visualforce Page to display the Parent and Child Records.
    public List<ParentWrapper> displayQueryResult
    {
        get
        {
            if(!initialized && fetchParentAPIName!=Null && fetchChildAPIName!=Null && fetchChildRelationshipName!=Null && nonRelParentColumnNames.size()>0 && childColumnNames.size()>0)
            {
                system.debug('Start displayQueryResult---->');
                system.debug('Limit SOQL---->'+Limits.getQueries()+'Limit Query Rows---->'+Limits.getQueryRows());
                populateWrapperLists();
                createParentColWidthWrapper();
                createChildColWidthWrapper();
                initialized=true;
                //2016-01-19- anirudh.singh@cdk.com- Added the below line to default the value of the autoPopulateChild variable.
                autoPopulateChild=true;
                system.debug('Limit SOQL---->'+Limits.getQueries()+'Limit Query Rows---->'+Limits.getQueryRows());
                system.debug('End displayQueryResult---->');
            }
            return parentWrapperList;
        }
        set
        {
            parentWrapperList=value;
        }
    }
    
    //It is a ColumnAndWidthsWrapper list of parent column names and width.
    private List<ColumnAndWidthsWrapper> parentColWidthList;
    
    //This list is used to display the parent columns and widths on visualforce page.
    public List<ColumnAndWidthsWrapper> displayParentColumnsAndWidthList
    {
        get
        {
            createParentColWidthWrapper(); // 2015-05-27 matt.keefe@cdk.com added to fix lookup error
            return parentColWidthList;
        }
        set
        {
            parentColWidthList=value;
            system.debug('displayParentColumnsAndWidthList---->');
        }
    }
    
    //It is a ColumnAndWidthsWrapper list of child column names and width.
    private List<ColumnAndWidthsWrapper> childColWidthList;
    
    //This list is used to display the child columns and widths on visualforce page.
    public List<ColumnAndWidthsWrapper> displayChildColumnsAndWidthList
    {
        get
        {
            createChildColWidthWrapper(); // 2015-05-27 matt.keefe@cdk.com added to fix lookup error
            return childColWidthList;
        }
        set
        {
            childColWidthList=value;
            system.debug('displayChildColumnsAndWidthList---->');
        }
    }
    
    //This is used for holding the Record Id of the Parent or Child record whose field is to be updated in View Mode.
    private Id recordIdForFieldUpdate{get; set;}
    
    //This String is used to hold the name of the field which is to be updated in View Mode.
    //It is used in the title of the Panel for Field Update.
    public String fieldNameToBeUpdated{get; set;}
    
    //This String is used to hold the API Name of the field to be updated in View Mode.
    public String fieldAPINameToBeUpdated{get; set;}
    
    //This Boolean property is used to display the Field Update Panel in View Mode.
    //The field can either be a Parent field or a Child field.
    public Boolean displayFieldInViewMode{get; set;}
    
    //This is used to hold a temporary Parent or Child Record for field update in View Mode.
    public sObject objectToUpdateInViewMode{get; set;}
    
    //This holds the Field API Name of the lookup field from which the Child record is linked to the Parent record.
    private String fieldNameLinkedToParent;
    
    //This is used to hold the Id of the Parent Record for which a New Child has to be created.
    public Id parentId{get; set;}
    
    //This List is used to hold the field API Name and a Boolean value for Parent.
    //Boolean value is used to check whether the record is selected on the Visualforce Page or not.
    public List<EmptyObjectWrapper> emptyObjFieldMapParent{get; set;}
    
    //This List is used to hold the field API Name and a Boolean value for Child.
    //Boolean value is used to check whether the record is selected on the Visualforce Page or not.
    public List<EmptyObjectWrapper> emptyObjFieldMapChild{get; set;}
    
    //This is the Empty Parent Record displayed on the Visualforce Page for Mass Update on Parent Records.
    public sObject emptyRecordParent{get; set;}
    
    //This is the Empty Child Record displayed on the Visualforce Page for Mass Update on Child Records.
    public sObject emptyRecordChild{get; set;}
    
    //This String variable is used to hold the newly created Parent Id.
    private String newParentId;
    
    //This Boolean parameter is used to prevent Clear All Changes function and Cancel function.
    public Boolean showChildRecForNewParentMessage{get; set;}
    
    //This Boolean parameter determines whether the changes on the records have been successfully saved or not.
    private Boolean saveSuccessfull;
    
    //2015-05-21- anirudh.singh@cdk.com- Added
    //This Boolean parameter determines whether the changes on the records have been successfully saved on Quick Save.
    private Boolean changesMade=false;
    
    //2015-05-21- anirudh.singh@cdk.com- Added
    //This Set will hold a set of Ids of the Parent of the Parent records.
    private Set<Id> grandparentIds;
    
    //2015-05-22- anirudh.singh@cdk.com- Added
    public String grandparentLabel{get; set;}
    
    //2015-05-22- anirudh.singh@cdk.com- Added
    //This String is used to hold the Grandparent selected by the User on the visualforce page.
    public String selectedGrandparent{get; set;}
    
    //2015-05-22- anirudh.singh@cdk.com- Added
    //This list is used to hold the grandparent values to be displayed on the visualforce page.
    private List<SelectOption> grandparentOptions;
    
    //2015-05-22- anirudh.singh@cdk.com- Added
    //This property is used for displaying the grandparent values on the Visualforce Page.
    public List<SelectOption> displayGrandparentOptions
    {
        get
        {
            return grandparentOptions; 
        }
        set
        {
            grandparentOptions=value;
        }
    }
    
    //2015-05-22- anirudh.singh@cdk.com- Added
    public Boolean displayGrandParentPanel{get; set;}
    
    //2015-06-24 vishal.bandari@cdk.com- Added
    //This variable holds the Ids of newly created parent records.
    private Set<Id> justCreatedParentIds=new Set<Id>();
    
    //2015-06-24 vishal.bandari@cdk.com- Added
    //This variable holds the Ids of newly created parent records.
    private Set<Id> justCreatedChildIds=new Set<Id>();
    
    //2015-07-16 anirudh.singh@cdk.com- Added
    //This variable holds the Ids of successfully created and updated parent records due to Quick Save.
    private Set<Id> createdUpdatedParentIds;
    
    //2016-01-14- anirudh.singh@cdk.com- Added
    //This variable is used to auto-populate the new Task created for new activity created by the user.
    public Boolean autoPopulateChild{get; set;}
    
    //This method is used for fetching the attributes passed from the Visualforce Page to the Parent Child Component.
    //They are then assigned to their respective variables, so that they can be used on the Visualforce Page.
    private void init(ALL_RecordsViewWrapper allAttributes)
    {
        system.debug('Start init---->');
        Boolean validInputs=true;
        
        //2015-05-22- anirudh.singh@cdk.com- Added
        //Initializing the following attributes for re-rendering the datatable with new selection.
        nonRelParentColumnNames=new List<String>();        
        parentColumnNames=new List<String>();
        childColumnNames=new List<String>();
        displayParentColumnsAndWidthList=new List<ColumnAndWidthsWrapper>();
        displayChildColumnsAndWidthList=new List<ColumnAndWidthsWrapper>();
        
        //2015-07-22 anirudh.singh@cdk.com- Added below line for initializing the parentColumnWidths, childColumnWidths and grandparentIds.
        //Earlier they were initialized at class level.
        parentColumnWidths=new List<String>();
        childColumnWidths=new List<String>();
        grandparentIds=new Set<Id>();
        
        //2015-09-29-anirudh.singh@cdk.com-Added emptyObjFieldMapParent, emptyObjFieldMapChild initialization lines.
        emptyObjFieldMapParent=new List<EmptyObjectWrapper>();
        emptyObjFieldMapChild=new List<EmptyObjectWrapper>();
        
        //If dataAvailable is false, no further processing should be done.
        if(allAttributes.dataAvailable==false)
        {
            ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Info, 'No data available for display.');
            ApexPages.addMessage(errMsg);
            validInputs=false;
        }
        //If dataAvailable is true, further processing should be done.
        else
        {
            //Parent API Name is fetched.
            if(allAttributes.parentAPIName!=Null && allAttributes.parentAPIName!='')
            {
                fetchParentAPIName=allAttributes.parentAPIName;
                //2015-07-16 anirudh.singh@cdk.com- Added the below IF Block.
                //2015-07-27 anirudh.singh@cdk.com Null check commented.
                //if(targetTypeParent==Null)
                //{
                    targetTypeParent=globalDescMap.get(fetchParentAPIName);
                //}
            }
            else
            {
                ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Error, 'Parent API Name is required for the component.');
                ApexPages.addMessage(errMsg);
                validInputs=false;
            }
            
            //Child API Name is fetched.
            if(allAttributes.childAPIName!=Null && allAttributes.childAPIName!='')
            {
                fetchChildAPIName=allAttributes.childAPIName;
                //2015-07-16 anirudh.singh@cdk.com- Added the below IF Block.
                //2015-07-27 anirudh.singh@cdk.com Null check commented.
                //if(targetTypeChild==Null)
                //{
                    targetTypeChild=globalDescMap.get(fetchChildAPIName);
                //}
            }
            else
            {
                ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Error, 'Child API Name is required for the component.');
                ApexPages.addMessage(errMsg);
                validInputs=false;
            }
            
            //Child Relationship Name is fetched.
            if(allAttributes.childRelationshipName!=Null && allAttributes.childRelationshipName!='')
            {
                fetchChildRelationshipName=allAttributes.childRelationshipName;
            }
            else
            {
                ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Error, 'Child Relationship Name is required for the component.');
                ApexPages.addMessage(errMsg);
                validInputs=false;
            }
            
            //Parent Column Names are fetched.
            if(allAttributes.parentColumnNames!=Null && allAttributes.parentColumnNames!='')
            {
                for(String str: allAttributes.parentColumnNames.replaceAll('(\\s+)', ' ').split(','))
                {
                    parentColumnNames.add(str.trim());
                    if(!str.toLowerCase().contains('__r'))
                    {
                        nonRelParentColumnNames.add(str.trim());
                    }
                }
            }
            else
            {
                ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Error, 'Parent Column Names are required for the component.');
                ApexPages.addMessage(errMsg);
                validInputs=false;
            }
            
            //Child Column Names are fetched.
            if(allAttributes.childColumnNames!=Null && allAttributes.childColumnNames!='')
            {
                for(String str: allAttributes.childColumnNames.replaceAll('(\\s+)', ' ').split(','))
                {
                    if(!str.toLowerCase().contains('__r'))
                    {
                        childColumnNames.add(str.trim());
                    }
                }
            }
            else
            {
                ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Error, 'Child Column Names are required for the component.');
                ApexPages.addMessage(errMsg);
                validInputs=false;
            }
            
            //childSearchEnabled is fetched which determines whether Child Search should be enabled or not.
            if(allAttributes.childSearchEnabled!=Null)
            {
                childSearch=allAttributes.childSearchEnabled;
            }
            else
            {
                childSearch=false;
            }
            
            //filterConditionParent is fetched which determines the WHERE condition for Parent records.
            parentCondition=allAttributes.filterConditionParent;
            
            //filterConditionChild is fetched which determines the WHERE condition for Child records.
            childCondition=allAttributes.filterConditionChild;
            
            //mode is fetched to determine whether the user should directly see edit or view page.
            displayMode=allAttributes.mode;
            
            //redirectURL is fetched to determine the page where the User should be redirected once Save or Cancel is performed.
            redirectURLLocation=allAttributes.redirectURL;
            
            //createNewChildEnabled is fetched which determines whether Create New Child button should be enabled or not.
            if(allAttributes.createNewChildEnabled!=Null)
            {
                displayCreateNewChildButton=allAttributes.createNewChildEnabled;
            }
            else
            {
                displayCreateNewChildButton=false;
            }
            
            //parentColumnWidths is fetched to determine the width of the Parent Columns.
            if(allAttributes.parentColumnWidths!=Null && allAttributes.parentColumnWidths!='')
            {
                for(String str: allAttributes.parentColumnWidths.replaceAll('(\\s+)', ' ').split(','))
                {
                    parentColumnWidths.add(str.trim());
                }
            }
            
            //childColumnWidths is fetched to determine the width of the Child Columns.
            if(allAttributes.childColumnWidths!=Null && allAttributes.childColumnWidths!='')
            {
                for(String str: allAttributes.childColumnWidths.replaceAll('(\\s+)', ' ').split(','))
                {
                    childColumnWidths.add(str.trim());
                }
            }
            
            //editEnabled determines whether edit button should be visible or not.
            if(allAttributes.editEnabled!=Null)
            {
                displayEditButton=allAttributes.editEnabled;
            }
            else
            {
                displayEditButton=false;
            }
            
            //quickSaveEnabled determines whether Quick Save button should be visible or not.
            if(allAttributes.quickSaveEnabled!=Null)
            {
                displayQuickSaveButton=allAttributes.quickSaveEnabled;
            }
            else
            {
                displayQuickSaveButton=false;
            }
            
            //saveEnabled determines whether Save button should be visible or not.
            if(allAttributes.saveEnabled!=Null)
            {
                displaySaveButton=allAttributes.saveEnabled;
            }
            else
            {
                displaySaveButton=false;
            }
            
            //deleteEnabled determines whether Delete button should be visible or not.
            if(allAttributes.deleteEnabled!=Null)
            {
                displayDeleteButton=allAttributes.deleteEnabled;
            }
            else
            {
                displayDeleteButton=false;
            }
            
            //massUpdateEnabled determines whether Mass Update button should be visible or not.
            if(allAttributes.massUpdateEnabled!=Null)
            {
                displayMassUpdateButton=allAttributes.massUpdateEnabled;
            }
            else
            {
                displayMassUpdateButton=false;
            }
            
            //createNewParentEnabled determines whether Create New Parent button should be visible or not.
            if(allAttributes.createNewParentEnabled!=Null)
            {
                displayCreateNewParentButton=allAttributes.createNewParentEnabled;
            }
            else
            {
                displayCreateNewParentButton=false;
            }
            
            //parentRequiresChildren determines whether Parent record must have atleast one Child record or not.
            if(allAttributes.parentRequiresChildren!=Null)
            {
                fetchParentRequiresChildren=allAttributes.parentRequiresChildren;
            }
            else
            {
                fetchParentRequiresChildren=false;
            }
            
            //This String is used to hold the relationship Field Name On Parent, through which the Parent should be linked.
            fetchGrandparentRelationshipField=allAttributes.grandparentRelationshipField;
            
            //This String is used to hold the field Name to be displayed in the picklist for the grandparent.
            fetchGrandparentDisplayFieldName=allAttributes.grandparentDisplayFieldName;
            
            //The Parent Column Names according to which the Parent records should be ordered.
            fetchParentFieldSortOrderAPINames=allAttributes.parentFieldSortOrderAPINames;
            
            //The Child Column Names according to which the Child records should be ordered.
            fetchChildFieldSortOrderAPINames=allAttributes.childFieldSortOrderAPINames;
            
            //2015-07-29- anirudh.singh@cdk.com- Added this.
            if(allAttributes.childFieldsToDisableForRow!=Null && allAttributes.childFieldsToDisableForRow!='')
            {
                fetchChildFieldsToDisableForRow=new List<String>();
                fetchChildFieldsToDisableForRow.addAll(fetchColumnLabels(fetchChildAPIName, allAttributes.childFieldsToDisableForRow));
            }
            
            //2015-07-29- anirudh.singh@cdk.com- Added this.
            if(allAttributes.parentFieldsToDisableForRow!=Null && allAttributes.parentFieldsToDisableForRow!='')
            {
                fetchParentFieldsToDisableForRow=new List<String>();
                fetchParentFieldsToDisableForRow.addAll(fetchColumnLabels(fetchParentAPIName, allAttributes.parentFieldsToDisableForRow));
            }
            
            //2015-07-29- anirudh.singh@cdk.com- Added this.
            fetchChildDisableCheckField=allAttributes.childDisableCheckField;
            
            //2015-07-29- anirudh.singh@cdk.com- Added this.
            fetchParentDisableCheckField=allAttributes.parentDisableCheckField;
        }
        
        if(!validInputs)
        {
            showData=false;
        }
        else
        {
            showData=true;
        }
        system.debug('End init---->');
    }
    
    //This method is used to construct the Query String.
    private String fetchQueryString(String scenario)
    {
        system.debug('Start fetchQueryString---->');
        List<sObject> queryResult=new List<sObject>();
        
        String queryString='SELECT';
        
        //Fetch columns to be queried for Parent object.
        queryString+=fetchColumnToBeQueried(parentColumnNames);
        
        //2015-07-29- anirudh.singh@cdk.com- Added the below IF Block.
        if(fetchParentDisableCheckField!=Null && fetchParentDisableCheckField!='' 
           && !(queryString.toLowerCase().indexOf((fetchParentDisableCheckField+',').toLowerCase())==0) 
           && !(queryString.toLowerCase().indexOf((' '+fetchParentDisableCheckField+',').toLowerCase())>0))
        {
            queryString+=' '+fetchParentDisableCheckField+',';
        }
        
        queryString+=' (SELECT';
        
        //Fetch columns to be queried for Child object.
        queryString+=fetchColumnToBeQueried(childColumnNames);
        
        String childColumnToBeQueried=fetchColumnToBeQueried(childColumnNames);
        
        //2015-07-29- anirudh.singh@cdk.com- Added the below IF Block.
        if(fetchChildDisableCheckField!=Null && fetchChildDisableCheckField!='' 
           && !(childColumnToBeQueried.toLowerCase().indexOf((fetchChildDisableCheckField+',').toLowerCase())==0) 
           && !(childColumnToBeQueried.toLowerCase().indexOf((' '+fetchChildDisableCheckField+',').toLowerCase())>0))
        {
            queryString+=' '+fetchChildDisableCheckField+',';
        }
        
        queryString=queryString.substring(0, queryString.length()-1);
        
        queryString+=' FROM '+fetchChildRelationshipName+' ';
        
        if(scenario=='initial')
        {
            //Fetch Child Filter Condition.
            queryString+=fetchFilterCondition(childCondition, 'child', fetchChildFieldSortOrderAPINames);
        }
        
        queryString+=')';
        
        queryString+=' FROM ' +fetchParentAPIName+' ';
        
        if(scenario=='initial')
        {
            //Fetch Parent Filter Condition.
            queryString+=fetchFilterCondition(parentCondition, 'parent', fetchParentFieldSortOrderAPINames);
        }
        else if(scenario=='quickSave')
        {
            queryString+='WHERE Id IN: createdUpdatedParentIds ';
        }
        
        system.debug('End fetchQueryString---->'+queryString);
        return queryString;
    }
    
    //2015-07-22 anirudh.singh@cdk.com- Added this method for optimization.
    //This method is used for fetching the Parent or Child column Names String to be fetched.
    private static String fetchColumnToBeQueried(List<String> columnNames)
    {
        system.debug('Start fetchColumnToBeQueried---->');
        String columnsToBeQueried='';
        
        for(Integer i=0; i<columnNames.size(); i++)
        {
            columnsToBeQueried+=' '+columnNames[i]+',';
        }
        
        system.debug('End fetchColumnToBeQueried---->');
        return columnsToBeQueried;
    }
    
    //2015-07-22 anirudh.singh@cdk.com- Added this method for optimization.
    //This method is used for fetching the filter conditions for Parent and Children records.
    private String fetchFilterCondition(String recordsFilterCondition, String objectType, String fetchFieldSortOrderAPINames)
    {
        system.debug('Start fetchFilterCondition---->');
        String filterCondition='';
        
        if(recordsFilterCondition!=Null && recordsFilterCondition!='' && recordsFilterCondition.toLowerCase().contains(' limit '))
        {
            Integer indexOfLimit=recordsFilterCondition.toLowerCase().indexOf(' limit ');
            String stringWithoutLimitCondition=recordsFilterCondition.toLowerCase().substring(0, indexOfLimit);
            String stringWithLimitCondition=recordsFilterCondition.toLowerCase().substring(indexOfLimit+1, recordsFilterCondition.length());
            
            if(objectType=='child' && justCreatedChildIds.size()>0)
            {
                stringWithoutLimitCondition+=' OR ID IN: justCreatedChildIds ';
            }
            else if(objectType=='parent' && justCreatedParentIds.size()>0)
            {
                stringWithoutLimitCondition+=' OR ID IN: justCreatedParentIds ';
            }
            
            filterCondition+=stringWithoutLimitCondition+' ';
            
            if(fetchFieldSortOrderAPINames!=Null && fetchFieldSortOrderAPINames!='')
            {
                filterCondition+=' ORDER BY '+fetchFieldSortOrderAPINames+' ASC ';
            }
            filterCondition+=stringWithLimitCondition;
        }
        else if(recordsFilterCondition!=Null && recordsFilterCondition!='' && recordsFilterCondition.toLowerCase().contains('limit '))
        {
            if(objectType=='child' && justCreatedChildIds.size()>0)
            {
                filterCondition+=' WHERE ID IN: justCreatedChildIds ';
            }
            else if(objectType=='parent' && justCreatedParentIds.size()>0)
            {
                filterCondition+=' WHERE ID IN: justCreatedParentIds ';
            }
            
            if(fetchFieldSortOrderAPINames!=Null && fetchFieldSortOrderAPINames!='')
            {
                filterCondition+=' ORDER BY ' +fetchFieldSortOrderAPINames +' ASC ';
            }
            filterCondition+=recordsFilterCondition;
        }
        else if(recordsFilterCondition!=Null && recordsFilterCondition!='' && (!recordsFilterCondition.toLowerCase().contains(' limit ')
                                                               && !recordsFilterCondition.toLowerCase().contains('limit ')))
        {
            filterCondition+=recordsFilterCondition;
            
            if(objectType=='child' && justCreatedChildIds.size()>0)
            {
                filterCondition+=' OR ID IN: justCreatedChildIds ';
            }
            else if(objectType=='parent' && justCreatedParentIds.size()>0)
            {
                filterCondition+=' OR ID IN: justCreatedParentIds ';
            }
            
            if(fetchFieldSortOrderAPINames!=Null && fetchFieldSortOrderAPINames!='')
            {
                filterCondition+=' ORDER BY ' +fetchFieldSortOrderAPINames +' ASC ';
            }
        }
        else
        {
            if(objectType=='child' && justCreatedChildIds.size()>0)
            {
                filterCondition+=' WHERE ID IN: justCreatedChildIds ';
            }
            else if(objectType=='parent' && justCreatedParentIds.size()>0)
            {
                filterCondition+=' WHERE ID IN: justCreatedParentIds ';
            }
            
            if(fetchFieldSortOrderAPINames!=Null && fetchFieldSortOrderAPINames!='')
            {
                filterCondition+=' ORDER BY ' +fetchFieldSortOrderAPINames +' ASC ';
            }
        }
        
        system.debug('End fetchFilterCondition---->');
        return filterCondition;
    }
    
    //2015-07-17 anirudh.singh@cdk.com - Earlier the method used to take List<sObject> queryResult as a parameter, '
    //2015-07-17 anirudh.singh@cdk.com - now it takes the query string and not the queryResult.
    //It is used to prepare a Wrapper List which is used on the Visualforce Page for displaying the Parent and Child records.
    private void populateWrapperLists()
    {
        system.debug('Start populateWrapperLists---->');
        parentWrapperList=new List<ParentWrapper>();
        
        //2015-07-29- anirudh.singh@cdk.com- Added.
        childRecordIdsToBeDisabled=new List<String>();
        
        //2015-07-29- anirudh.singh@cdk.com- Added.
        parentRecordIdsToBeDisabled=new List<String>();
        
        try
        {
            //2015-07-17 anirudh.singh@cdk.com - Earlier the method used to take List<sObject> queryResult as a parameter.
            //Now the query is done and iterated directly.
            for(sObject parentRec: Database.query(fetchQueryString('initial')))
            {
                ParentWrapper pRef=new ParentWrapper();
                pRef.parentSelected=false;
                pRef.parentRecord=parentRec;
                pRef.errParent='';
                pRef.childRecords=new List<ChildWrapper>();
                
                //2015-05-21- anirudh.singh@cdk.com
                if(fetchGrandparentRelationshipField!=Null)
                {
                    grandparentIds.add(String.valueOf(parentRec.get(fetchGrandparentRelationshipField)));
                }
                
                //2015-07-29- anirudh.singh@cdk.com- Added the below IF Block.
                if(fetchParentDisableCheckField!=Null && parentRec.get(fetchParentDisableCheckField)==true)
                {
                    parentRecordIdsToBeDisabled.add(String.valueOf(parentRec.get('Id')));
                }
                
                if(parentRec.getSObjects(fetchChildRelationshipName)!=Null)
                {
                    for(sObject childRec: parentRec.getSObjects(fetchChildRelationshipName))
                    {
                        ChildWrapper cRef=new ChildWrapper();
                        cRef.childSelected=false;
                        cRef.childRecord=childRec;
                        cRef.errChild='';
                        pRef.childRecords.add(cRef);
                        
                        //2015-07-29- anirudh.singh@cdk.com- Added the below IF Block.
                        if(fetchChildDisableCheckField!=Null && childRec.get(fetchChildDisableCheckField)==true)
                        {
                            childRecordIdsToBeDisabled.add(String.valueOf(childRec.get('Id')));
                        }
                    }
                }
                parentWrapperList.add(pRef);
            }
        }
        catch(Exception ex)
        {
            ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(errMsg);
        }
        
        system.debug('End populateWrapperLists---->');
    }
    
    //This method is used for creating a Parent Column Names and Width Wrapper List.
    //This list is then used on Visualforce Page for rendering the fields and set the widths of their column.
    private void createParentColWidthWrapper()
    {
        system.debug('Start createParentColWidthWrapper---->');
        parentColWidthList=new List<ColumnAndWidthsWrapper>();
        parentColWidthList.addAll(createColWidthWrapper(nonRelParentColumnNames, parentColumnWidths));
        system.debug('End createParentColWidthWrapper---->');
    }
    
    //This method is used for creating a Child Column Names and Width Wrapper List.
    //This list is then used on Visualforce Page for rendering the fields and set the widths of their column.
    private void createChildColWidthWrapper()
    {
        system.debug('Start createChildColWidthWrapper---->');
        childColWidthList=new List<ColumnAndWidthsWrapper>();
        childColWidthList.addAll(createColWidthWrapper(childColumnNames, childColumnWidths));
        system.debug('End createChildColWidthWrapper---->');
    }
    
    //2015-07-22 anirudh.singh@cdk.com- Added this method for optimization of code.
    private static List<ColumnAndWidthsWrapper> createColWidthWrapper(List<String> colNames, List<String> colWidths)
    {
        system.debug('Start createColWidthWrapper---->');
        List<ColumnAndWidthsWrapper> colWidthList=new List<ColumnAndWidthsWrapper>();
        
        for(Integer i=0; i<colNames.size(); i++)
        {
            ColumnAndWidthsWrapper ref=new ColumnAndWidthsWrapper();
            ref.columnName=colNames[i];
            
            if(colWidths.size()>i && colWidths[i]!=Null && colWidths[i]!='')
            {
                ref.columnWidth=colWidths[i];
            }
            else
            {
                ref.columnWidth='auto';
            }
            
            colWidthList.add(ref);
        }
        
        system.debug('End createColWidthWrapper---->');
        return colWidthList;
    }
    
    //This method is used for updating any Parent or Child field in View Mode.
    //It is invoked from the fieldUpdatePanel actionFunction.
    //It creates an Empty record for the Parent or Child object.
    public void displayFieldUpdatePanel()
    {
        system.debug('Start displayFieldUpdatePanel---->');
        fieldNameToBeUpdated=ApexPages.currentPage().getParameters().get('fieldName');
        recordIdForFieldUpdate=ApexPages.currentPage().getParameters().get('recordId');
        
        String sObjName=recordIdForFieldUpdate.getSObjectType().getDescribe().getName();
        Schema.SObjectType targetType=globalDescMap.get(sObjName);
        objectToUpdateInViewMode=targetType.newSObject();
        objectToUpdateInViewMode.put('Id', recordIdForFieldUpdate);
        
        Map<String, Schema.SObjectField> fieldMap=targetType.getDescribe().fields.getMap();
        
        for(String fName: fieldMap.keySet())
        {
            if(fieldNameToBeUpdated==fieldMap.get(fName).getDescribe().getLabel())
            {
                fieldAPINameToBeUpdated=String.valueOf(fieldMap.get(fName));
                break;
            }
        }
        
        for(ParentWrapper ref: parentWrapperList)
        {
            //It is checked whether the record to be updated with new Field Value is either Parent or Child.
            //And accordingly, the processing is done.
            if(ref.parentRecord.Id==recordIdForFieldUpdate)
            {
                objectToUpdateInViewMode.put(fieldAPINameToBeUpdated, ref.parentRecord.get(fieldAPINameToBeUpdated));
                break;
            }
            else
            {
                for(ChildWrapper cRef: ref.childRecords)
                {
                    if(cRef.childRecord.Id==recordIdForFieldUpdate)
                    {
                        objectToUpdateInViewMode.put(fieldAPINameToBeUpdated, cRef.childRecord.get(fieldAPINameToBeUpdated));
                        break;
                    }
                }
            }
        }
        
        displayFieldInViewMode=true;
        system.debug('End displayFieldUpdatePanel---->');
    }
    
    //This method is invoked from the Save button on the panel for Field Update in View Mode.
    //It is used to update the record.
    //The record can be either Parent or Child record.
    public void fieldUpdateInViewMode()
    {
        system.debug('Start fieldUpdateInViewMode---->');
        try
        {
            update objectToUpdateInViewMode;
        }
        catch(Exception ex)
        {
            ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(errMsg);
        }
        displayFieldInViewMode=false;
        system.debug('End fieldUpdateInViewMode---->');
    }
    
    //This method is used to close the Field Update Panel in View Mode.
    public void closeFieldUpdatePanel()
    {
        system.debug('Start closeFieldUpdatePanel---->');
        displayFieldInViewMode=false;
        system.debug('End closeFieldUpdatePanel---->');
    }
    
    //This method is invoked from Save(Id=SaveButton) and Save and Close(Id=SaveCloseButton) buttons.
    //This method is used to save the Parent and Child records edited and modified on the Visualforce Page.
    public PageReference saveMethod()
    {        
        system.debug('Start saveMethod---->');
        saveSuccessfull=true;
        
        List<sObject> parentsToBeUpdatedList=new List<sObject>();
        List<sObject> parentsToBeInsertedList=new List<sObject>();
        List<sObject> childsToBeUpdatedList=new List<sObject>();
        List<sObject> childsToBeInsertedList=new List<sObject>();
        
        //2015-07-16 anirudh.singh@cdk.com- Added
        createdUpdatedParentIds=new Set<Id>();
        
        //Parent Field Accessible, Creatable and Updateable is checked.
        Schema.DescribeSObjectResult typeDescriptionParent=targetTypeParent.getDescribe();
        Map<String, Schema.SObjectField> resultMapParent=typeDescriptionParent.Fields.getMap();
        
        //For inserting Parent records, only Accessible and Creatable needs to be checked.
        List<String> parentColsAccessibleCreatable=new List<String>();
        
        //For updating Parent records, both Accessible and Updateable needs to be checked.
        List<String> parentColsAccessibleUpdateable=new List<String>();
        
        for(String str: nonRelParentColumnNames)
        {
            Schema.DescribeFieldResult fieldDesc=resultMapParent.get(str).getDescribe();
            if(fieldDesc.isAccessible() && fieldDesc.isCreateable())
            {
                parentColsAccessibleCreatable.add(str);
            }
            if(fieldDesc.isAccessible() && fieldDesc.isUpdateable())
            {
                parentColsAccessibleUpdateable.add(str);
            }
        }
        
        //Child Field Accessible, Creatable and Updateable is checked.
        Schema.DescribeSObjectResult typeDescriptionChild=targetTypeChild.getDescribe();
        Map<String, Schema.SObjectField> resultMapChild=typeDescriptionChild.Fields.getMap();
        
        //For inserting Child records, only Accessible and Creatable needs to be checked.
        List<String> childColsAccessibleCreatable=new List<String>();
        
        //For updating Child records, both Accessible and Updateable needs to be checked.
        List<String> childColsAccessibleUpdateable=new List<String>();
        
        for(String str: childColumnNames)
        {
            Schema.DescribeFieldResult fieldDesc=resultMapChild.get(str).getDescribe();
            if(fieldDesc.isAccessible() && fieldDesc.isCreateable())
            {
                childColsAccessibleCreatable.add(str);
            }
            if(fieldDesc.isAccessible() && fieldDesc.isUpdateable())
            {
                childColsAccessibleUpdateable.add(str);
            }
        }
        
        for(ParentWrapper parent: parentWrapperList)
        {
            List<ChildWrapper> childs=parent.childRecords;
            if(parent.parentSelected==true)
            {
                sObject newParent=targetTypeParent.newSObject();
                
                //If the Record Id is present in the Parent Record.
                //It means an Update has to be performed.
                if(String.valueOf(parent.parentRecord.Id)!=Null && String.valueOf(parent.parentRecord.Id)!='')
                {
                    for(String col: parentColsAccessibleUpdateable)
                    {
                        if(col!='Id')
                        {
                            newParent.put(col, parent.parentRecord.get(col));
                        }
                    }
                    newParent.put('Id', parent.parentRecord.get('Id'));
                    
                    parentsToBeUpdatedList.add(newParent);
                }
                //If the Record Id is not present in the Parent Record.
                //It means an Insert has to be performed.
                else
                {
                    for(String col: parentColsAccessibleCreatable)
                    {
                        if(col!='Id')
                        {
                            newParent.put(col, parent.parentRecord.get(col));
                        }
                    }
                    
                    //2015-05-22- anirudh.singh@cdk.com
                    if(fetchGrandparentRelationshipField!=Null && fetchGrandparentRelationshipField!='')
                    {
                        newParent.put(fetchGrandparentRelationshipField, parent.parentRecord.get(fetchGrandparentRelationshipField));
                    }
                    
                    parentsToBeInsertedList.add(newParent);
                }
            }
            
            if(childs.size()>0)
            {
                for(ChildWrapper child: childs)
                {
                    if(child.childSelected==true)
                    {
                        sObject newChild=targetTypeChild.newSObject();
                        
                        //If the Record Id is present in the Child Record.
                        //It means an Update has to be performed.
                        if(String.valueOf(child.childRecord.Id)!=Null && String.valueOf(child.childRecord.Id)!='')
                        {
                            for(String col: childColsAccessibleUpdateable)
                            {
                                if(col!='Id')
                                {
                                    newChild.put(col, child.childRecord.get(col));
                                }
                            }
                            newChild.put('Id', child.childRecord.get('Id'));
                            childsToBeUpdatedList.add(newChild);
                        }
                        //If the Record Id is not present in the Child Record.
                        //It means an Insert has to be performed.
                        else
                        {
                            for(String col: childColsAccessibleCreatable)
                            {
                                if(col!='Id')
                                {
                                    newChild.put(col, child.childRecord.get(col));
                                }
                            }
                            
                            //2015-05-20- anirudh.singh@cdk.com- This is needed to attach new Child records to the Parent.
                            newChild.put(fieldNameLinkedToParent, child.childRecord.get(fieldNameLinkedToParent));
                            
                            childsToBeInsertedList.add(newChild);
                        }
                    }
                }
            }
        }
        
        //Parent Records are Updated and the results are obtained.
        List<Database.SaveResult> parentUpdateResults=Database.Update(parentsToBeUpdatedList, false);
        
        //Parent Records are Inserted and the results are obtained.
        List<Database.SaveResult> parentInsertResults=Database.Insert(parentsToBeInsertedList, false);
        
        //Child Records are Updated and the results are obtained.
        List<Database.SaveResult> childUpdateResults=Database.Update(childsToBeUpdatedList, false);
        
        //Child Records are Inserted and the results are obtained.
        List<Database.SaveResult> childInsertResults=Database.Insert(childsToBeInsertedList, false);
        
        //Clear all the Wrapper Checkboxes for the Parent and Child Records.
        clearWrapperCheckboxesUpdateRecords(parentsToBeUpdatedList, parentUpdateResults, childsToBeUpdatedList, childUpdateResults);
        
        if(parentsToBeInsertedList.size()>0)
        {
            clearCheckboxesInsertParentRecords(parentsToBeInsertedList, parentInsertResults);
        }
        
        if(childsToBeInsertedList.size()>0)
        {
            clearCheckboxesInsertChildRecords(childsToBeInsertedList, childInsertResults);
        }
        
        if(fetchParentRequiresChildren)
        {
            childRecordForParentSaved();
        }
        
        if(saveSuccessfull && ApexPages.currentPage().getParameters().get('saveScenario')=='Save')
        {
            system.debug('Save successful---->');
            pageController.childProcessingComplete(true);
        }
        
        //2015-07-16 anirudh.singh@cdk.com- Added for fetching the Parent updated and created records from database.
        if(changesMade && createdUpdatedParentIds.size()>0)
        {
            refetchParentCreatedUpdatedRecords();
        }
        
        system.debug('End saveMethod---->');
        return Null;
    }
    
    //This is used to clear the Wrapper checkboxes for Parent and Child records which are being updated.
    //The Wrapper Lists are iterated and the checkbox value is set to false.
    //If there is any error in the updating records, the same is displayed on the Visualforce Page.
    private void clearWrapperCheckboxesUpdateRecords(List<sObject> parentsToBeUpdatedList, List<Database.SaveResult> parentUpdateResults, 
                                                     List<sObject> childsToBeUpdatedList, List<Database.SaveResult> childUpdateResults)
    {
        system.debug('Start clearWrapperCheckboxesUpdateRecords---->');
        
        for(ParentWrapper parent: parentWrapperList)
        {
            for(Integer i=0; i<parentsToBeUpdatedList.size(); i++)
            {
                sObject origRecord=parentsToBeUpdatedList[i];
                Database.SaveResult sResult=parentUpdateResults[i];
                if(sResult.isSuccess() && sResult.getId()==parent.parentRecord.get('Id') && parent.parentSelected==true)
                {
                    system.debug('Success Parent Update---->');
                    parent.parentSelected=false;
                    parent.errParent='';
                    
                    //2015-05-22- anirudh.singh@cdk.com- Added
                    //This is used to set the parameter to determine whether changes were made on the page using Quick Save.
                    //Changes here refer to successful save of records using Quick Save.
                    determineChangeMade();
                    
                    //2015-07-16 anirudh.singh@cdk.com- Added
                    createdUpdatedParentIds.add(sResult.getId());
                }
                else if(!sResult.isSuccess() && origRecord.get('Id')==parent.parentRecord.get('Id') && parent.parentSelected==true)
                {
                    system.debug('Fail Parent Update---->');
                    saveSuccessfull=false;
                    parent.errParent=fetchErrorMessages(sResult.getErrors(), 'save');
                }
            }
            
            List<ChildWrapper> childs=parent.childRecords;
            
            if(childs.size()>0)
            {
                for(ChildWrapper child: childs)
                {
                    for(Integer j=0; j<childsToBeUpdatedList.size(); j++)
                    {
                        sObject origRecord=childsToBeUpdatedList[j];
                        Database.SaveResult sResult=childUpdateResults[j];
                        if(sResult.isSuccess() && sResult.getId()==child.childRecord.get('Id') && child.childSelected==true)
                        {
                            system.debug('Success Child Update---->');
                            child.childSelected=false;
                            child.errChild='';
                            
                            //2015-05-21- anirudh.singh@cdk.com- Added
                            //This is used to set the parameter to determine whether changes were made on the page using Quick Save.
                            //Changes here refer to successful save of records using Quick Save.
                            determineChangeMade();
                            
                            //2015-07-16 anirudh.singh@cdk.com- Added
                            createdUpdatedParentIds.add(String.valueOf(parent.parentRecord.get('Id')));
                        }
                        else if(!sResult.isSuccess() && origRecord.get('Id')==child.childRecord.get('Id') && child.childSelected==true)
                        {
                            system.debug('Fail Child Update---->');
                            saveSuccessfull=false;
                            child.errChild=fetchErrorMessages(sResult.getErrors(), 'save');
                        }
                    }
                }
            }
        }
        
        system.debug('End clearWrapperCheckboxesUpdateRecords---->');
    }
    
    //This method is used to clear the wrapper checkboxes for the successfully inserted Parent records.
    //If the New Parent record to be inserted is not successfully inserted and an error occurs, the same is displayed on the Visualforce Page.
    private void clearCheckboxesInsertParentRecords(List<sObject> parentsToBeInsertedList, List<Database.SaveResult> parentInsertResults)
    {
        system.debug('Start clearCheckboxesInsertParentRecords---->');
        for(ParentWrapper parent: parentWrapperList)
        {
            if(parent.parentRecord.get('Id')=='' || parent.parentRecord.get('Id')==Null)
            {
                for(Integer k=0; k<parentsToBeInsertedList.size(); k++)
                {
                    Database.SaveResult sResult=parentInsertResults[k];
                    
                    if(sResult.isSuccess() && parent.parentSelected==true)
                    {
                        system.debug('Success Parent Insert---->');
                        parent.parentSelected=false;
                        parent.errParent='';
                        parent.parentRecord.Id=sResult.getId();
                        
                        //2015-06-24 vishal.bandari@cdk.com- Added
                        justCreatedParentIds.add(sResult.getId());
                        
                        //Create a new Child record row if the fetchParentRequiresChildren is true.
                        if(fetchParentRequiresChildren && parent.childRecords.size()==0)
                        {
                            newParentId=sResult.getId();
                            createNewChild();
                            
                            //2016-01-14- anirudh.singh@cdk.com- Added the below line to reset the value of the autoPopulateChild variable.
                            autoPopulateChild=true;
                        }
                        
                        //2015-05-21- anirudh.singh@cdk.com- Added
                        //This is used to set the parameter to determine whether changes were made on the page using Quick Save.
                        //Changes here refer to successful save of records using Quick Save.
                        determineChangeMade();
                        
                        //2015-07-16 anirudh.singh@cdk.com- Added
                        createdUpdatedParentIds.add(sResult.getId());
                    }
                    else if(!sResult.isSuccess() && parent.parentSelected==true)
                    {
                        system.debug('Fail Parent Insert---->');
                        saveSuccessfull=false;
                        parent.errParent=fetchErrorMessages(sResult.getErrors(), 'save');
                    }
                }
            }
        }
        system.debug('End clearCheckboxesInsertParentRecords---->');
    }
    
    //This method is used to clear the wrapper checkboxes for the successfully inserted child records.
    //If the New Child record to be inserted is not successfully inserted and an error occurs, the same is displayed on the Visualforce Page.
    private void clearCheckboxesInsertChildRecords(List<sObject> childsToBeInsertedList, List<Database.SaveResult> childInsertResults)
    {
        system.debug('Start clearCheckboxesInsertChildRecords---->');
        for(ParentWrapper parent: parentWrapperList)
        {
            List<ChildWrapper> childs=parent.childRecords;
            if(childs.size()>0)
            {
                for(ChildWrapper child: childs)
                {
                    if(child.childRecord.get('Id')=='' || child.childRecord.get('Id')==Null)
                    {
                        for(Integer k=0; k<childsToBeInsertedList.size(); k++)
                        {
                            sObject origRecord=childsToBeInsertedList[k];
                            Database.SaveResult sResult=childInsertResults[k];
                            
                            if(origRecord.get(fieldNameLinkedToParent)==parent.parentRecord.get('Id') &&
                               origRecord.get(fieldNameLinkedToParent)==child.childRecord.get(fieldNameLinkedToParent))
                            {
                                Boolean recordsMatch=false;
                                for(String str: childColumnNames)
                                {
                                    if(origRecord.get(str)==child.childRecord.get(str))
                                    {
                                        recordsMatch=true;
                                    }
                                    else
                                    {
                                        recordsMatch=false;
                                        break;
                                    }
                                }
                                
                                if(recordsMatch==true && sResult.isSuccess() && child.childSelected==true)
                                {
                                    system.debug('Success Child Insert---->');
                                    child.childSelected=false;
                                    child.errChild='';
                                    child.childRecord.Id=sResult.getId();
                                    
                                    //2015-06-24 vishal.bandari@cdk.com- Added
                                    justCreatedChildIds.add(sResult.getId());
                                    
                                    //2015-05-21- anirudh.singh@cdk.com
                                    //This is used to set the parameter to determine whether changes were made on the page using Quick Save.
                                    //Changes here refer to successful save of records using Quick Save.
                                    determineChangeMade();
                                    
                                    //2015-07-16 anirudh.singh@cdk.com- Added
                                    createdUpdatedParentIds.add(String.valueOf(parent.parentRecord.get('Id')));
                                }
                                else if(recordsMatch==true && !sResult.isSuccess() && child.childSelected==true)
                                {
                                    system.debug('Fail Child Insert---->');
                                    saveSuccessfull=false;
                                    child.errChild=fetchErrorMessages(sResult.getErrors(), 'save');
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug('End clearCheckboxesInsertChildRecords---->');
    }
    
    //2015-07-22 anirudh.singh@cdk.com- Added below method for code optimization.
    private static String fetchErrorMessages(List<Database.Error> errorsGenerated, String mode)
    {
        system.debug('Start fetchErrorMessages---->');
        String errMessage='';
        
        for(Database.Error err: errorsGenerated)
        {
            ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Error, err.getMessage());
            ApexPages.addMessage(errMsg);
            
            if(errMessage=='')
            {
                errMessage=err.getMessage();
            }
            else if(errMessage!='' && !errMessage.contains(err.getMessage()))
            {
                errMessage+=' | '+err.getMessage();
            }
            
            if(mode.toLowerCase()=='delete')
            {
                errMessage=errMessage.replaceAll('\n', '');
            }
        }
        
        system.debug('End fetchErrorMessages---->');
        return errMessage;
    }
    
    //This method is used for creating a new Parent record.
    public void createNewParent()
    {
        system.debug('Start createNewParent---->');
        
        sObject sObj=targetTypeParent.newSObject();
        
        //2015-05-22- anirudh.singh@cdk.com- Added
        if(fetchGrandparentRelationshipField!=Null && fetchGrandparentRelationshipField!='')
        {
            sObj.put(fetchGrandparentRelationshipField, selectedGrandparent);
        }
        
        ParentWrapper pRef=new ParentWrapper();
        pRef.parentSelected=true;
        pRef.parentRecord=sObj;
        pRef.errParent='';
        pRef.childRecords=new List<ChildWrapper>();
        parentWrapperList.add(0, pRef);
        
        system.debug('End createNewParent---->');
    }
    
    //2015-05-22- anirudh.singh@cdk.com- Added
    //This method is used for creating New Parent record with Grandparent record linked to it.
    public void createNewParentWGrandparent()
    {
        system.debug('Start createNewParentWGrandparent---->');
        
        //Nullify the previous selected value
        selectedGrandparent=Null;
        
        try
        {
            //Fetching the Grandparent API Name.
            List<Id> grandparentIdsList=new List<Id>(grandparentIds);
            String grandparentSObjName=grandparentIdsList[0].getSObjectType().getDescribe().getName();
            grandparentLabel=grandparentIdsList[0].getSObjectType().getDescribe().getLabel();
            
            //Creating query for grandparent.
            String grandparentQueryString='SELECT Id, '+fetchGrandparentDisplayFieldName+' FROM ';
            grandparentQueryString+=grandparentSObjName+' WHERE Id IN: grandparentIdsList';
            
            //Fetching the results in a list.
            List<sObject> grandparentRecordsList=new List<sObject>();
            grandparentRecordsList=Database.query(grandparentQueryString);
            
            grandparentRecordsList.sort();
            
            if(grandparentRecordsList.size()>0)
            {
                grandparentOptions=new List<SelectOption>();
                
                for(Integer i=0; i<grandparentRecordsList.size(); i++)
                {
                    grandparentOptions.add(new SelectOption(String.valueOf(grandparentRecordsList[i].get('Id')), String.valueOf(grandparentRecordsList[i].get(fetchGrandparentDisplayFieldName))));
                }
            }
            
            //Display the grandparentSelectionPanel
            displayGrandparentPanel=true;
        }
        catch(Exception ex)
        {
            ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(errMsg);
        }
        
        system.debug('End createNewParentWGrandparent---->');
    }
    
    public void closeGrandparentPanel()
    {
        system.debug('Start closeGrandparentPanel---->');
        //Hide the grandparentSelectionPanel
        displayGrandparentPanel=false;
        
        createNewParent();
        system.debug('End closeGrandparentPanel---->');
    }
    
    public void cancelGrandparentPanel()
    {
        system.debug('Start cancelGrandparentPanel---->');
        //Hide the grandparentSelectionPanel
        displayGrandparentPanel=false;
        //2016-01-19- anirudh.singh@cdk.com- Added the below line to reset the value of the autoPopulateChild variable.
        autoPopulateChild=true;
        system.debug('End cancelGrandparentPanel---->');
    }
    
    //This method is used to check if the Child is saved for the new Parent record.
    private void childRecordForParentSaved()
    {
        system.debug('Start childRecordForParentSaved---->');
        showChildRecForNewParentMessage=false;
        
        for(ParentWrapper parent: parentWrapperList)
        {
            if(newParentId!=Null && parent.parentRecord.get('Id')==newParentId)
            {
                if(parent.childRecords.size()>0)
                {
                    for(ChildWrapper child: parent.childRecords)
                    {
                        if(child.childRecord.get('Id')=='' || child.childRecord.get('Id')==Null)
                        {
                            showChildRecForNewParentMessage=true;
                        }
                        else
                        {
                            showChildRecForNewParentMessage=false;
                            break;
                        }
                    }
                }
            }
        }
        
        if(showChildRecForNewParentMessage)
        {
            saveSuccessfull=false;
            ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Info, 'A new Child record must be created for the new Parent record. A Child row has been added below the new Parent record. Please provide appropriate values and save the record.');
            ApexPages.addMessage(errMsg);
        }
        else
        {
            newParentId=Null;
        }
        
        system.debug('End childRecordForParentSaved---->');
    }
    
    //2015-05-22- anirudh.singh@cdk.com- Added
    //This method is used to check if the Scenario is Quick Save or not.
    //If Scenario is Quick Save and any of the modified records are successfully updated or any new records are successfully inserted,
    //then changeMade Boolean parameter is set to true.
    private void determineChangeMade()
    {
        system.debug('Start determineChangeMade---->');
        if(Apexpages.currentPage().getParameters().get('quickSaveScenario')=='Quick Save')
        {
            system.debug('Quick Save Successful---->');
            changesMade=true;
        }
        system.debug('End determineChangeMade---->');
    }
    
    //This method is invoked from the jQuery when the Delete Records functionality is used.
    //It gets a list of Ids for either the Parent or Child records.
    //These Ids are then used to delete the records.
    @RemoteAction
    public static Map<String, String> deleteRecords(List<Id> idList)
    {
        system.debug('Start deleteRecords---->');
        List<sObject> recordsToBeDeletedList=new List<sObject>();
        
        String sObjName=idList[0].getSObjectType().getDescribe().getName();
        Map<String, Schema.SObjectType> globalDescMap=Schema.getGlobalDescribe();
        Schema.SObjectType targetType=globalDescMap.get(sObjName);
        
        for(Id id: idList)
        {
            sObject sObj=targetType.newSObject();
            sObj.id=id;
            recordsToBeDeletedList.add(sObj);
        }
        
        Map<String, String> deleteRecordsMap=new Map<String, String>();
        
        List<Database.DeleteResult> deleteResults=Database.delete(recordsToBeDeletedList, false);
        
        for(Integer i=0; i<recordsToBeDeletedList.size(); i++)
        {
            sObject origRecord=recordsToBeDeletedList[i];
            Database.DeleteResult dResult=deleteResults[i];
            
            if(dResult.isSuccess())
            {
                system.debug('Successfully Deleted---->');
                deleteRecordsMap.put(dResult.getId(), '');
            }
            else if(!dResult.isSuccess())
            {
                system.debug('Fail Deleted---->');
                String errors=fetchErrorMessages(dResult.getErrors(), 'delete');
                deleteRecordsMap.put(String.valueOf(origRecord.get('Id')), errors);
            }
        }
        
        system.debug('End deleteRecords---->');
        return deleteRecordsMap;
    }
    
    //This method is invoked from the button with Id=createNewChild.
    //This is used for initializes a new Child Record.
    //It adds a new empty row in the Wrapper and the same is displayed on the Visualforce Page.
    public PageReference createNewChild()
    {
        system.debug('Start createNewChild---->');
        //An sObject reference is created for the Child Record.
        sObject child=Null;
        
        //This holds the Field API Name of the lookup field from which the Child record is linked to the Parent record.
        fieldNameLinkedToParent=Null;
        
        //It gives Parent object properties or describe results.
        Schema.DescribeSObjectResult describeResult=targetTypeParent.getDescribe();
        
        //It gives you all the childRelationships associated with the account.
        List<Schema.ChildRelationship> childRelationshipsList=describeResult.getChildRelationships();
        
        //The relationship field API Name is obtained here.
        for(Schema.ChildRelationship relName: childRelationshipsList)
        {
            if(relName.getRelationshipName()==fetchChildRelationshipName)
            {
                fieldNameLinkedToParent=String.valueOf(relName.getField());
                break;
            }
        }
        
        for(ParentWrapper parent: parentWrapperList)
        {
            //2016-01-14- anirudh.singh@cdk.com- Added the below parentId!=Null && parentId==Null condition to the below IF Block condition.
            if((parentId!=Null && parent.parentRecord.Id==parentId) || (parentId==Null && parent.parentRecord.Id==newParentId))
            {
                ChildWrapper cWrap=new ChildWrapper();
                sObject sObj=targetTypeChild.newSObject();
                
                if(fieldNameLinkedToParent!=Null && parentId!=Null)
                {
                    sObj.put(fieldNameLinkedToParent, parentId);
                    
                    //2016-01-14- anirudh.singh@cdk.com- Added the below code to auto-poulate Child record values from Parent when trying to create new Child for existing Parent record.
                    sObj=autoPopulateChildRecords(parent, sObj);
                }
                else if(fieldNameLinkedToParent!=Null && newParentId!=Null)
                {
                    sObj.put(fieldNameLinkedToParent, newParentId);
                    
                    //2016-01-14- anirudh.singh@cdk.com- Added the code to check if the user checks the checkbox for auto-populating Child on Creation of new Parent record.
                    if(autoPopulateChild)
                    {
                        sObj=autoPopulateChildRecords(parent, sObj);
                    }
                }
                
                cWrap.childRecord=sObj;
                cWrap.childSelected=true;
                cWrap.errChild='';
                
                //If the Parent has more than 1 Child Record, the new Empty Child Record is added at the First position.
                //Else it is added directly to the Wrapper.
                if(parent.childRecords.size()>0)
                {
                    parent.childRecords.add(0, cWrap);
                }
                else
                {
                    parent.childRecords.add(cWrap);
                }
                break;
            }
        }
        parentId=Null;
        
        system.debug('End createNewChild---->');
        return Null;
    }
    
    //2016-01-18- anirudh.singh@cdk.com- Added the below method for auto-poulating details from Parent to Child records.
    private sObject autoPopulateChildRecords(ParentWrapper parent, sObject sObj)
    {
        system.debug('Start autoPopulateChildRecords---->');
        
        Schema.DescribeSObjectResult typeDescriptionChild=targetTypeChild.getDescribe();
        Map<String, Schema.SObjectField> resultMapChild=typeDescriptionChild.Fields.getMap();
        
        for(String childColName: childColumnNames)
        {
            Schema.DescribeFieldResult fieldDesc=resultMapChild.get(childColName).getDescribe();
            if(fieldDesc.isAccessible() && fieldDesc.isUpdateable())
            {
                for(String parentColName: nonRelParentColumnNames)
                {
                    if(childColName==parentColName)
                    {
                        sObj.put(childColName, parent.parentRecord.get(parentColName));
                    }
                }
            }
        }
        system.debug('End autoPopulateChildRecords---->');
        return sObj;
    }
    
    //This method is invoked from the selectionParentPanel actionFunction.
    //This method is used to display the Parent Panel, where the User can select the fields
    //to Mass Update on the selected Parent records.
    //emptyObjFieldMapParent is created which is iterated on Visualforce Page and
    //displayed as the field names and checkboxes.
    public void displayParentSelectionPanel()
    {
        system.debug('Start displayParentSelectionPanel---->');
        emptyObjFieldMapParent=new List<EmptyObjectWrapper>();
        
        //Parent Field Accessible and Updateable
        Schema.DescribeSObjectResult typeDescriptionParent=targetTypeParent.getDescribe();
        Map<String, Schema.SObjectField> resultMapParent=typeDescriptionParent.Fields.getMap();
        
        for(String str: nonRelParentColumnNames)
        {
            Schema.DescribeFieldResult fieldDesc=resultMapParent.get(str).getDescribe();
            if(fieldDesc.isAccessible() && fieldDesc.isUpdateable())
            {
                EmptyObjectWrapper ref=new EmptyObjectWrapper();
                ref.selected=false;
                ref.field=str;
                emptyObjFieldMapParent.add(ref);
            }
        }
        emptyRecordParent=targetTypeParent.newSObject();
        system.debug('End displayParentSelectionPanel---->');
    }
    
    //This method is invoked from the selectionChildPanel actionFunction.
    //This method is used to display the Child Panel, where the User can select the fields
    //to Mass Update on the selected Child records.
    //emptyObjFieldMapChild is created which is iterated on Visualforce Page and
    //displayed as the field names and checkboxes.
    public void displayChildSelectionPanel()
    {
        system.debug('Start displayChildSelectionPanel---->');
        emptyObjFieldMapChild=new List<EmptyObjectWrapper>();
        
        //Child Field Accessible and Updateable
        Schema.DescribeSObjectResult typeDescriptionChild=targetTypeChild.getDescribe();
        Map<String, Schema.SObjectField> resultMapChild=typeDescriptionChild.Fields.getMap();
        
        for(String str: childColumnNames)
        {
            Schema.DescribeFieldResult fieldDesc=resultMapChild.get(str).getDescribe();
            if(fieldDesc.isAccessible() && fieldDesc.isUpdateable())
            {
                EmptyObjectWrapper ref=new EmptyObjectWrapper();
                ref.selected=false;
                ref.field=str;
                emptyObjFieldMapChild.add(ref);
            }
        }
        emptyRecordChild=targetTypeChild.newSObject();
        system.debug('End displayChildSelectionPanel---->');
    }
    
    //This method is invoked from the jQuery for updating the Parent or Child records, depending on the selection.
    @RemoteAction
    public static Map<String, String> MassUpdate(String objectAPIName, List<String> recordIdsList, 
                                                 List<String> fieldsToUpdateList, List<String> updatedFieldValuesList,
                                                List<String> recordIdsToBeDisabledList, List<String> fieldsToDisableForRowList)
    {
        system.debug('Start MassUpdate---->');
        List<String> typeList=new List<String>();
        
        Map<String, Schema.SObjectType> globalDescMap=Schema.getGlobalDescribe();
        Schema.SObjectType targetType=globalDescMap.get(objectAPIName);
        Map<String, Schema.SObjectField> fieldMap=targetType.getDescribe().fields.getMap();
        
        //sObject Field Accessible and Updateable
        Schema.DescribeSObjectResult typeDescription=targetType.getDescribe();
        Map<String, Schema.SObjectField> resultMap=typeDescription.Fields.getMap();
        List<String> colsAccessibleUpdateable=new List<String>();
        
        for(Integer i=0; i<fieldsToUpdateList.size(); i++)
        {
            Schema.DescribeFieldResult fieldDesc=resultMap.get(fieldsToUpdateList[i]).getDescribe();
            if(fieldDesc.isAccessible() && fieldDesc.isUpdateable())
            {
                colsAccessibleUpdateable.add(fieldsToUpdateList[i]);
            }
        }
        
        for(Integer i=0; i<colsAccessibleUpdateable.size(); i++)
        {
            typeList.add('string');
        }
        
        for(Integer i=0; i<colsAccessibleUpdateable.size(); i++)
        {
            for(String key: fieldMap.KeySet())
            {
                if(fieldsToUpdateList[i]==key)
                {
                    typeList[i]=String.ValueOf(fieldMap.get(key).getDescribe().getType());
                }
            }
        }
        
        //2015-08-05- anirudh.singh@cdk.com- Added recordIdsToBeDisabled, fieldsToDisableForRow.
        Set<String> recordIdsToBeDisabled=new Set<String>();
        Set<String> fieldsToDisableForRow=new Set<String>();
        recordIdsToBeDisabled.addAll(recordIdsToBeDisabledList);
        
        //2015-08-05- anirudh.singh@cdk.com- Added this For Loop.
        for(Integer i=0; i<fieldsToDisableForRowList.size(); i++)
        {
            for(String fieldRef: fieldMap.keySet())
            {
                if(fieldsToDisableForRowList[i].toLowerCase()==fieldMap.get(fieldRef).getDescribe().getLabel().toLowerCase())
                {
                    fieldsToDisableForRow.add(fieldRef.toLowerCase());
                    break;
                }
            }
        }
        
        List<sObject> updateRecordsList=new List<sObject>();
        
        for(String recId: recordIdsList)
        {
            sObject sObj=targetType.newSObject();
            sObj.Id=recId;
            
            for(Integer i=0; i<colsAccessibleUpdateable.size(); i++)
            {
                Object value=typeCasting(typeList[i], updatedFieldValuesList[i]);
                
                //2015-06-03- anirudh.singh@cdk.com- Added
                //Added this IF to check if the value is Null or Blank, then the field value should not get updated.
                //2015-08-05- anirudh.singh@cdk.com- Added additional conditions in the below IF Block.
                if(String.valueOf(value)!='' && String.valueOf(value)!=Null && 
                   (!recordIdsToBeDisabled.contains(recId) || 
                    (recordIdsToBeDisabled.contains(recId) && !fieldsToDisableForRow.contains(colsAccessibleUpdateable[i]))))
                {
                    sObj.put(colsAccessibleUpdateable[i], value);
                }
            }
            updateRecordsList.add(sObj);
        }
        
        //2015-06-02- anirudh.singh@cdk.com- Added the below code for displaying errors on records on Visualforce Page for Mass Update.
        Map<String, String> massUpdateRecords=new Map<String, String>();
        
        List<Database.SaveResult> updateResult=Database.update(updateRecordsList, false);
        
        for(Integer i=0; i<updateRecordsList.size(); i++)
        {
            sObject origRecord=updateRecordsList[i];
            Database.SaveResult uResult=updateResult[i];
            
            if(uResult.isSuccess())
            {
                system.debug('Success Update---->');
                massUpdateRecords.put(uResult.getId(), '');
            }
            else if(!uResult.isSuccess())
            {
                system.debug('Fail Update---->');
                String errors=fetchErrorMessages(uResult.getErrors(), 'mass update');
                massUpdateRecords.put(String.valueOf(origRecord.get('Id')), errors);
            }
        }
        system.debug('End MassUpdate---->');
        return massUpdateRecords;
    }
    
    //This method is invoked from the MassUpdate method for typecasting the field values from String to their respective datatypes.
    private static Object typeCasting(String dataType, String value)
    {
        system.debug('Start typeCasting---->');
        dataType=dataType.toLowerCase();
        Boolean stringType=(dataType.equals('string') || dataType.equals('calculated') || dataType.equals('comobobox') || 
                            dataType.equals('email') || dataType.equals('id') || dataType.equals('multipicklist') || 
                            dataType.equals('phone') || dataType.equals('picklist') || dataType.equals('reference') || 
                            dataType.equals('textarea') || dataType.equals('url'));
        Boolean doubleType=(dataType.equals('double'));
        Boolean integerType=(dataType.equals('int') || dataType.equals('integer'));
        Boolean decimalType=(dataType.equals('decimal') || dataType.equals('currency') || dataType.equals('percent'));
        Boolean booleanType=(dataType.equals('boolean') || dataType.equals('bool') || dataType.equals('checkbox'));
        Boolean dateTimeType=(dataType.equals('datetime') || dataType.equals('date/time'));
        Boolean dateType=(dataType.equals('date'));
        Boolean longType=(dataType.equals('long'));
        
        if(stringType)
        {
            return value;
        }
        else if(doubleType)
        {
            return Double.valueOf(value);
        }
        else if(integerType)
        {
            return Integer.valueOf(value);
        }
        else if(decimalType)
        {
            return Decimal.valueOf(value);
        }
        else if(booleanType)
        {
            if(value=='1')
            {
                return true;   
            }
            else if(value=='0')
            {
                return false;
            }
            return Boolean.valueOf(value);
        }
        else if(dateTimeType)
        {
            return DateTime.parse(value);
        }
        else if(dateType)
        {
            return Date.parse(value);
        }
        else if(longType)
        {
            return Long.valueOf(value);
        }
        
        system.debug('End typeCasting---->');
        return value;
    }
    
    //This method is used for fetching the Parent and Child Records when Delete or Clear All Changes buttons are used.
    //It invokes populateWrapperLists Method.
    public void reloadMethod()
    {
        system.debug('Start reloadMethod---->');
        populateWrapperLists();
        //2016-01-19- anirudh.singh@cdk.com- Added the below line to default the value of the autoPopulateChild variable.
        autoPopulateChild=true;
        system.debug('End reloadMethod---->');
    }
    
    public void cancelMethod()
    {
        system.debug('Start cancelMethod---->');
        
        //2015-05-22 PH TIME - Rey Austral - Quick fix for re-rendering the datatable with new selection.
        //the following variable reset will enable the init function to go through full reconstruction
        initialized=false;
        
        //2015-05-22- anirudh.singh@cdk.com- Commented the below code.
        /*nonRelParentColumnNames=new List<String>();        
        parentColumnNames=new List<String>();
        childColumnNames=new List<String>();
        displayParentColumnsAndWidthList=new List<ColumnAndWidthsWrapper>();
        displayChildColumnsAndWidthList=new List<ColumnAndWidthsWrapper>();*/
        
        //2015-05-20 Karl - can we pass the variable for whether or not the records have changes instead of false?
        //2015-05-21- anirudh.singh@cdk.com- Made changes for passing changesMade parameter to the childProcessingComplete,
        //if the changes were successfully saved on Quick Save and then User clicked on Cancel.
        pageController.childProcessingComplete(changesMade);
        
        // 2015-05-20 Karl - TODO: rerender datatable with dataAvailable parameter set to false
        //2015-05-21- anirudh.singh@cdk.com- Invoking rerenderParentChildComponent Method to rerender the Parent Child Component.
        pageController.rerenderParentChildComponent();
        
        //2015-07-22 anirudh.singh@cdk.com- Added below line for re-initializing the justCreatedParentIds, justCreatedChildIds.
        justCreatedParentIds=new Set<Id>();
        justCreatedChildIds=new Set<Id>();
        
        system.debug('End cancelMethod---->'+changesMade);
    }
    
    //2015-05-21- anirudh.singh@cdk.com- Added
    public void saveAndCloseMethod()
    {
        system.debug('Start saveAndCloseMethod---->');
        
        //2015-05-22 PH TIME - Rey Austral - Quick fix for re-rendering the datatable with new selection.
        //the following variable reset will enable the init function to go through full reconstruction
        initialized=false;
        
        //2015-05-22- anirudh.singh@cdk.com- Commented the below code.
        /*nonRelParentColumnNames=new List<String>();        
        parentColumnNames=new List<String>();
        childColumnNames=new List<String>();
        displayParentColumnsAndWidthList=new List<ColumnAndWidthsWrapper>();
        displayChildColumnsAndWidthList=new List<ColumnAndWidthsWrapper>();*/
        
        pageController.rerenderParentChildComponent();
        
        //2015-07-22 anirudh.singh@cdk.com- Added below line for re-initializing the justCreatedParentIds, justCreatedChildIds.
        justCreatedParentIds=new Set<Id>();
        justCreatedChildIds=new Set<Id>();
        
        system.debug('End saveAndCloseMethod---->');
    }
    
    //2015-05-28- anirudh.singh@cdk.com- Added
    public void massUpdateMethod()
    {
        system.debug('Start massUpdateMethod---->');
        initialized=false;
        system.debug('End massUpdateMethod---->');
    }
    
    @RemoteAction
    public static String fetchUserId(String typedValue, String objectName, String fieldAPIName)
    {
        system.debug('Start fetchUserId---->');
        String recId;
        
        List<String> fields=new List<String>();
        
        Map<String, Schema.SObjectType> globalDescMap=Schema.getGlobalDescribe();
        Schema.SObjectType sobjType=globalDescMap.get(objectName);
        Schema.DescribeSObjectResult result=sobjType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap=result.fields.getMap();
        
        Schema.SObjectField field=fieldMap.get(fieldAPIName);                                                      
        Schema.DescribeFieldResult fieldDesc=field.getDescribe();
        String referenceToLookupObject;
        
        for(Schema.SObjectType reference: fieldDesc.getReferenceTo())
        {
            referenceToLookupObject=reference.getDescribe().getName();
        }
        
        //2015-09-29- anirudh.singh@cdk.com- Added IsActive=true for querying active users.
        String queryString='SELECT Id FROM '+referenceToLookupObject+' WHERE IsActive=true AND Name LIKE '+'\'%'+typedValue+'%\'';
        
        List<sObject> record=Database.query(queryString);
        
        if(record!=Null && record.size()>0)
        {
            recId=String.valueOf(record[0].get('Id'));
        }
        
        system.debug('End fetchUserId---->');
        return recId;
    }
    
    //2015-06-02- anirudh.singh@cdk.com- Added for handling mass update errors.
    public PageReference errorOnRecords()
    {
        system.debug('Start errorOnRecords---->');
        populateWrapperLists();
        
        String recordsList=String.valueOf(ApexPages.currentPage().getParameters().get('recordsList'));
        String typeOfUpdateScenario=String.valueOf(ApexPages.currentPage().getParameters().get('typeOfUpdateScenario'));
        
        Map<String, Object> recIdAndErrorMap=new Map<String, Object>();
        recIdAndErrorMap=(Map<String, Object>)JSON.deserializeUntyped(recordsList);
        
        if(recIdAndErrorMap.size()>0)
        {
            for(ParentWrapper parent: parentWrapperList)
            {
                if(typeOfUpdateScenario=='parentRec')
                {
                    for(String key: recIdAndErrorMap.keySet())
                    {
                        if(parent.parentRecord.get('Id')==key && 
                           (String.valueOf(recIdAndErrorMap.get(key))=='' || String.valueOf(recIdAndErrorMap.get(key))==Null))
                        {
                            parent.parentSelected=false;
                            parent.errParent='';
                        }
                        else if(parent.parentRecord.get('Id')==key && 
                                String.valueOf(recIdAndErrorMap.get(key))!='' && String.valueOf(recIdAndErrorMap.get(key))!=Null)
                        {
                            ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(recIdAndErrorMap.get(key)));
                            ApexPages.addMessage(errMsg);
                            parent.parentSelected=true;
                            parent.errParent=String.valueOf(recIdAndErrorMap.get(key));
                        }
                    }
                }
                else if(typeOfUpdateScenario=='childRec')
                {
                    List<ChildWrapper> childs=parent.childRecords;
                    
                    if(childs.size()>0)
                    {
                        for(ChildWrapper child: childs)
                        {
                            for(String key: recIdAndErrorMap.keySet())
                            {
                                if(child.childRecord.get('Id')==key && 
                                   (String.valueOf(recIdAndErrorMap.get(key))=='' || String.valueOf(recIdAndErrorMap.get(key))==Null))
                                {
                                    child.childSelected=false;
                                    child.errChild='';
                                }
                                else if(child.childRecord.get('Id')==key && 
                                        String.valueOf(recIdAndErrorMap.get(key))!='' && String.valueOf(recIdAndErrorMap.get(key))!=Null)
                                {
                                    ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(recIdAndErrorMap.get(key)));
                                    ApexPages.addMessage(errMsg);
                                    child.childSelected=true;
                                    child.errChild=String.valueOf(recIdAndErrorMap.get(key));
                                }
                            }
                        }
                    }
                }
            }
        }
        
        system.debug('End errorOnRecords---->');
        return Null;
    }
    
    //2015-07-16 anirudh.singh@cdk.com- Added the below the method.
    //2015-07-16 anirudh.singh@cdk.com- This method is used for refetching the Child records from database
    //and updated the wrapper with the updated field values so that any change made 
    //from Workflow, Triggers should get reflected on Parent Child View.
    private void refetchParentCreatedUpdatedRecords()
    {
        system.debug('Start refetchParentCreatedUpdatedRecords---->');
        
        try
        {
            for(sObject parentRec: Database.query(fetchQueryString('quickSave')))
            {
                for(ParentWrapper parent: parentWrapperList)
                {
                    if(createdUpdatedParentIds.contains(String.valueOf(parent.parentRecord.get('Id'))) 
                       && parentRec.get('Id')==parent.parentRecord.get('Id'))
                    {
                        if(parent.errParent==Null || parent.errParent=='')
                        {
                            parent.parentRecord=parentRec;
                        }
                        
                        if(parentRec.getSObjects(fetchChildRelationshipName)!=Null && parent.childRecords!=Null
                           && parentRec.getSObjects(fetchChildRelationshipName).size()>0 && parent.childRecords.size()>0)
                        {
                            for(sObject childRec: parentRec.getSObjects(fetchChildRelationshipName))
                            {
                                for(ChildWrapper child: parent.childRecords)
                                {
                                    if(childRec.get('Id')==child.childRecord.get('Id') && (child.errChild==Null || child.errChild==''))
                                    {
                                        child.childRecord=childRec;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch(Exception ex)
        {
            ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(errMsg);
        }
        
        system.debug('End refetchParentCreatedUpdatedRecords---->');
    }
    
    //2015-06-16 anirudh.singh@cdk.com -Added
    //This method is used for fetching the Field Labels using the objectAPIName and columnAPINames.
    public static List<String> fetchColumnLabels(String objectAPIName, String columnAPINames)
    {
        system.debug('Start fetchColumnLabels---->');
        List<String> columnLabels=new List<String>();
        
        Map<String, Schema.SObjectType> globalDescMap=Schema.getGlobalDescribe();
        Schema.SObjectType sobjType=globalDescMap.get(objectAPIName);  
        Schema.DescribeSObjectResult describeResult=sobjType.getDescribe();  
        Map<String, Schema.SObjectField> schemaMap=describeResult.fields.getMap();  
        
        for(String str: columnAPINames.replaceAll('(\\s+)', '').split(','))  
        {  
            Schema.SObjectField field=schemaMap.get(str.trim());                                                      
            String fieldLabel=field.getDescribe().getLabel();
            columnLabels.add(fieldLabel);
        }
        
        system.debug('End fetchColumnLabels---->'+columnLabels);
        return columnLabels;
    }
    
    //This is a Wrapper Class to wrap Boolean Value, Parent Record and Child Records of the Parent together.
    public class ParentWrapper
    {
        public Boolean parentSelected{get; set;}
        public sObject parentRecord{get; set;}
        public List<ChildWrapper> childRecords{get; set;}
        public String errParent{get; set;}
    }
    
    //This is a Wrapper Class to wrap Boolean Value and Child Record together.
    public class ChildWrapper
    {
        public Boolean childSelected{get; set;}
        public sObject childRecord{get; set;}
        public String errChild{get; set;}
    }
    
    //This Wrapper class is used to wrap columnApiName and columnWidth together.
    public class ColumnAndWidthsWrapper
    {
        public String columnName{get; set;}
        public String columnWidth{get; set;}
    }
    
    //This is a Wrapper Class to wrap Boolean Value and Field API Name together. 
    public with sharing class EmptyObjectWrapper
    {
        public Boolean selected{get; set;}
        public String field{get; set;}
    }
}