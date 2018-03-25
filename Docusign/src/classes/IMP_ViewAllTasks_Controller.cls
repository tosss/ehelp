/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Controller responsible for supporting the IMP_ViewAllTasksPage, primarily providing data for the ALL_DataTableComponent component
Test Class:  IMP_ViewAllTasks_Controller_Test
History
03/20/15     Samuel Oberes       Created
------------------------------------------------------------*/
public class IMP_ViewAllTasks_Controller 
{
    private Map<String, Schema.SObjectType> globalDescribeMap;
    private String objectApiName { get; set; }
    private IMP_DataTableObjectSetting__c dtSetting;

    IMP_ListViewDataSetting__c listViewSetting;

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Custom Getter/Setter used to store current tab selection
    History:
    05/21/15     Samuel Oberes    Created
    ------------------------------------------------------------*/
    public String selectedIndex
    {
        get
        {
            if(selectedIndex==null)
            {
                selectedIndex='0';
                System.debug('\n\n@@@@@[GETTER selectedIndex] DEFAULT ='+selectedIndex+'@@@@@\n\n');
            }
            System.debug('\n\n@@@@@[GETTER selectedIndex] ='+selectedIndex+'@@@@@\n\n');
            return selectedIndex;
        }
        set;
    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: A method to update selected tab index variable which will be retrieved from URL parameter
    History:
    05/21/15     Samuel Oberes    Created
    ------------------------------------------------------------*/
    public void toggleTabItems()
    {
        selectedIndex = Apexpages.currentPage().getParameters().get('strIndex');
    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: The constructor. All private members are initialized here.
    History:
    03/20/15     Samuel Oberes    Created
    ------------------------------------------------------------*/
    public IMP_ViewAllTasks_Controller() 
    {
        globalDescribeMap = Schema.getGlobalDescribe();
        dtSetting = IMP_DataTableObjectSetting__c.getInstance('Project_Task__c');

        try
        {
            this.objectApiName = dtSetting.Name;
        }
        catch (Exception e)
        {
            this.showApexError();
        }
    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Builds a wrapper that is to be consumed by the ALL_DataTableComponent
    Returns:     IMP_Library.genericDataTableAttributeWrapper
    History:
    03/20/15     Samuel Oberes    Created
    04/10/15     Samuel Oberes    changed tifa to tasksImFollowingAttribute
    ------------------------------------------------------------*/
    public IMP_Library.genericDataTableAttributeWrapper tasksImFollowingAttribute 
    { 
        get 
        {
            IMP_Library.genericDataTableAttributeWrapper t = new IMP_Library.genericDataTableAttributeWrapper();
            try {
                t.showDebug = false;
                t.objectApiName = this.objectApiName;
                t.objectLabelName = this.getLabel();
                t.objectEntityId = dtSetting.Name;
                t.objectIdPrefixCode = this.getKeyPrefix();
                t.filterObjectFieldsetName = dtSetting.DataTableFilterFieldsetName__c;
                t.tableColumnFieldsetName = dtSetting.DataTableColumnFieldsetName__c;
                t.queryString = IMP_Project_Utility.createSOQLSelect(this.getFieldSetByName(t.tableColumnFieldsetName), t.objectApiName);

                String userId = UserInfo.getUserId();
                t.whereClauseWithValues = new Map<String, Map<Integer, String>> { 
                    'WHERE ' + dtSetting.DataTableWhereClause__c => new Map<Integer, String> { 
                        0 => userId
                    } 
                };

                t.queryLimit = 1000;

                String orderByClause = dtSetting.DataTableSortingAndDirection__c;
                if (!String.isBlank(orderByClause)) 
                {
                    t.orderClause = ' ORDER BY ' + orderByClause;
                }

                t.showFilterSection = true;
                t.rowsPerPage = 10;
                t.showEditAllAttr = false;
                t.selectable = true;
                t.showFollowLink = true;
                t.allowInlineEditing = false;
            }
            catch (Exception e) 
            {
                this.showApexError();
            }
            return t;
        } 
        set; 
    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Extracts the label of the SObject type stated in the constructor
    Returns:     String
    History:
    03/20/15     Samuel Oberes    Created
    ------------------------------------------------------------*/
    @TestVisible
    private String getLabel() 
    {
        Schema.DescribeSObjectResult dscribeObjResult = getDescribedSObject();
        return dscribeObjResult.getLabel();
    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Extracts the key prefix of the SObject type stated in the constructor
    Returns:     String
    History:
    03/20/15     Samuel Oberes    Created
    ------------------------------------------------------------*/
    @TestVisible
    private String getKeyPrefix() 
    {
        Schema.DescribeSObjectResult dscribeObjResult = getDescribedSObject();
        return dscribeObjResult.getKeyPrefix();
    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Extracts a fieldset (based on the passed 'fieldsetName' argument) of an SObject type stated in the constructor
    Inputs:      String - fieldSetName
    Returns:     Schema.FieldSet
    History:
    03/20/15     Samuel Oberes    Created
    ------------------------------------------------------------*/
    @TestVisible
    private Schema.FieldSet getFieldSetByName(String fieldSetName) 
    {
        Schema.DescribeSObjectResult dscribeObjResult = getDescribedSObject();
        return dscribeObjResult.FieldSets.getMap().get(fieldSetName.toLowerCase());
    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Describes an object based on its API name and returns a Schema.DescribeSObjectResult
    Inputs:      -
    Returns:     Schema.DescribeSObjectResult
    History:
    03/20/15     Samuel Oberes    Created
    ------------------------------------------------------------*/
    private Schema.DescribeSObjectResult getDescribedSObject() 
    {
        if (globalDescribeMap == null) { globalDescribeMap = Schema.getGlobalDescribe(); }

        Schema.SObjectType sObjType = globalDescribeMap.get(this.objectAPIName);
        Schema.DescribeSObjectResult descResult;
        try
        {
            descResult = sObjType.getDescribe();
        }
        catch (Exception e)
        {
            this.showApexError();
        }
        return descResult;
    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: The error message to show when the SObject doesn't exist or encountered an error.
    History:
    03/20/15     Samuel Oberes    Created
    ------------------------------------------------------------*/
    private void showApexError() 
    {
        String[] arguments = new String[] { this.objectAPIName };
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, String.format(IMP_String_Utility.DATATABLE_UNSPECIFIC_ERROR, arguments)));
    }

}