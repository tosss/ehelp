/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: ALL_DataTableComponent_Extension test class
History
03/24/15     Samuel Oberes       Created
03/26/15     Kimiko Roberto      Removed reference from SObjectEntityId__c field
04/10/15     Samuel Oberes       changed tifa to tasksImFollowingAttribute
04/14/15     Samuel Oberes       Uncommented dtos.SObjectEntityId__c
04/27/15     Samuel Oberes       Commented dtos.SObjectEntityId__c (refer to AI-242)
------------------------------------------------------------*/
@isTest
private class IMP_ViewAllTasks_Controller_Test {

    private static String OBJECT_API_NAME;
    private static String OBJECT_LABEL;
    private static String OBJECT_SAMPLE_COLUMNFIELDSET_NAME;
    private static String OBJECT_SAMPLE_FILTERFIELDSET_NAME;
    private static String OBJECT_SAMPLE_ORDERBY_CLAUSE;
    private static String OBJECT_SAMPLE_WHERE_CLAUSE;

    static 
    {
        OBJECT_API_NAME = 'Project_Task__c';
        OBJECT_LABEL = 'Project Task';
        OBJECT_SAMPLE_COLUMNFIELDSET_NAME = 'ProjectTaskDataTableFields';
        OBJECT_SAMPLE_FILTERFIELDSET_NAME = 'ProjectTaskFilterFields';
        OBJECT_SAMPLE_ORDERBY_CLAUSE = 'SubProject_Name__c, Milestone_Description__c, Activity_Description__c, Name DESC';
        OBJECT_SAMPLE_WHERE_CLAUSE = 'Id IN (SELECT ParentId FROM EntitySubscription WHERE SubscriberId = \'' + UserInfo.getUserId() + '\' )';

        IMP_DataTableObjectSetting__c dtos   = new IMP_DataTableObjectSetting__c();
        dtos.Name                            = OBJECT_API_NAME;
        dtos.SObjectLabelName__c             = OBJECT_LABEL;
        //dtos.SObjectEntityId__c              = OBJECT_API_NAME; // required field so do not delete until this is permanently removed in a future release
        dtos.DataTableColumnFieldsetName__c  = OBJECT_SAMPLE_COLUMNFIELDSET_NAME;
        dtos.DataTableFilterFieldsetName__c  = OBJECT_SAMPLE_FILTERFIELDSET_NAME;
        dtos.DataTableSortingAndDirection__c = OBJECT_SAMPLE_ORDERBY_CLAUSE;
        dtos.DataTableWhereClause__c         = OBJECT_SAMPLE_WHERE_CLAUSE;

        try
        {
            insert dtos;
        }
        catch (DmlException e)
        {
            System.debug('DBG: Error encountered >>> ' + e.getMessage());
        }
    }

    private static testmethod void constructor_Test()
    {
        IMP_ViewAllTasks_Controller ctrlr = new IMP_ViewAllTasks_Controller();
        System.assertEquals(0, ApexPages.getMessages().size());
    }

    private static testmethod void tasksImFollowingAttribute_Test() {
        // INIT
        Map<String, Schema.Sobjecttype> globalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjType = globalDescribeMap.get(OBJECT_API_NAME);
        Schema.DescribeSObjectResult dscribeObjResult = sObjType.getDescribe();

        // TESTS PROPER
        IMP_ViewAllTasks_Controller ctrlr = new IMP_ViewAllTasks_Controller();
        IMP_Library.genericDataTableAttributeWrapper t = ctrlr.tasksImFollowingAttribute;

        System.assertEquals(t.showDebug               , false);
        System.assertEquals(t.objectApiName           , OBJECT_API_NAME);
        System.assertEquals(t.objectLabelName         , OBJECT_LABEL);
        System.assertEquals(t.objectEntityId          , OBJECT_API_NAME);
        System.assertEquals(t.filterObjectFieldsetName, OBJECT_SAMPLE_FILTERFIELDSET_NAME);
        System.assertEquals(t.tableColumnFieldsetName , OBJECT_SAMPLE_COLUMNFIELDSET_NAME);
        System.assertEquals(t.orderClause             , ' ORDER BY ' + OBJECT_SAMPLE_ORDERBY_CLAUSE);
    }

    private static testmethod void getLabel_Test() 
    {
        IMP_ViewAllTasks_Controller ctrlr = new IMP_ViewAllTasks_Controller();
        System.assertEquals('Project Task', ctrlr.getLabel());
    }

    private static testmethod void getKeyPrefix_Test() 
    {
        // INIT
        Map<String, Schema.Sobjecttype> globalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjType = globalDescribeMap.get(OBJECT_API_NAME);
        Schema.DescribeSObjectResult dscribeObjResult = sObjType.getDescribe();
        
        // TESTS PROPER        
        IMP_ViewAllTasks_Controller ctrlr = new IMP_ViewAllTasks_Controller();
        System.assertEquals(dscribeObjResult.getKeyPrefix(), ctrlr.getKeyPrefix());
    }

    private static testmethod void getFieldSetByName_Test() 
    {
        // INIT
        Map<String, Schema.Sobjecttype> globalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjType = globalDescribeMap.get(OBJECT_API_NAME);
        Schema.DescribeSObjectResult dscribeObjResult = sObjType.getDescribe();
        
        // TESTS PROPER        
        IMP_ViewAllTasks_Controller ctrlr = new IMP_ViewAllTasks_Controller();
        System.assertEquals(dscribeObjResult.FieldSets.getMap().get(OBJECT_SAMPLE_COLUMNFIELDSET_NAME.toLowerCase()).getDescription(), ctrlr.getFieldSetByName(OBJECT_SAMPLE_COLUMNFIELDSET_NAME).getDescription());
    }

}