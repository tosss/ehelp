/*------------------------------------------------------------
Author:      Jerick Lauio   
Company:     Cloud Sherpas
Description: [Phase 2 Rel 1]TestClass for ALL_DataTableSample_Controller
History
02/04/15     Jerick Laurio          Drafted
03/13/15     Jerick Laurio          Created
03/20/15     Jerick Laurio          Cleaned and refactored
------------------------------------------------------------*/

@isTest
private class ALL_DataTableComponent_Controller_Test
{

    /************************************************
     * Author: jlaurio@cloudsherpas.com
     * Date: 3/13/2015
     * Description: TestClass for ALL_DataTableSample_Controller
     ***********************************************/
    @isTest
    static void testDataTable_Test1()
    {

        IMP_DataTableUISetting__c uiSetting = IMP_TestFactory_Helper.createDataTableUISetting();
        insert uiSetting;

        Project__c testProject              = IMP_TestFactory_Helper.buildProject(1);
            testProject.CMF_Numbers__c      = 'testCMFNumber';
            testProject.Project_Status__c   = 'Open';
            testProject.Project_Region__c   = 'ARG-CANADA';
        insert testProject;

        SubProject__c subProjectRec             = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
            subProjectRec.SubProject_Region__c  = 'Alliance PC Solutions Admin';
            subProjectRec.Number_of_User_Connections__c = 10;
            subProjectRec.Secondary_Project_Type__c     = 'Competitive Buy-Sell';
        insert subProjectRec;

        EntitySubscription followRec = IMP_TestFactory_Helper.createFollowedRecord(subProjectRec.Id);
        insert followRec;
        
        ALL_DataTableComponent_Controller csDataTableInstance = new ALL_DataTableComponent_Controller();
        csDataTableInstance.objLabelName            = 'testObjectLabelName';
        csDataTableInstance.objApiName              = 'SubProject__c';
        csDataTableInstance.objIdPrefixCode         = '09213';
        csDataTableInstance.objEntityId             = '096171097412';
        csDataTableInstance.selectQueryString       = 'select Id, Name, Project_Type__c, SubProject_Status__c From SubProject__c';
        csDataTableInstance.selectWhereClauseString = 'WHERE Project_Type__c=\'Unhook\'';
        csDataTableInstance.queryLimitNum           = 5;
        csDataTableInstance.selectOrderString       = 'ORDER BY Id DESC';
        csDataTableInstance.objConsoleOpenInSubTab  = true;
        csDataTableInstance.showFilter              = true;
        csDataTableInstance.filterFieldSetName      = 'SubProjectFilterFields';
        csDataTableInstance.columnFieldSetName      = 'SubProjectDataTableFields';
        csDataTableInstance.useAltColumns           = true;
        csDataTableInstance.altColumnsJSONString    = 'testAltColumnJSON';
        csDataTableInstance.recordsPerPage          = 10;
        csDataTableInstance.size                    = 10;
        csDataTableInstance.noOfRecords             = 10;
        csDataTableInstance.showEditAll             = true;
        
        Boolean isDisplayTable = csDataTableInstance.isDisplayTable;
        Map<String,List<IMP_Library.fieldAPILabelWrapper>> fieldsPerObjectMap = csDataTableInstance.fieldsPerObjectMap;
        IMP_Library.genericSObjectWrapper recordsPerObj = csDataTableInstance.recordsPerObj;
        List<IMP_Library.fieldAPILabelWrapper> filterFieldList = csDataTableInstance.filterFieldList;
        SObject filterObject = csDataTableInstance.filterObject;
        IMP_Library.fieldAPILabelWrapper fieldWrap = new IMP_Library.fieldAPILabelWrapper();
        filterObject.put('SubProject_Status__c', 'Open');
        
        csDataTableInstance.initializeTableObject();
        csDataTableInstance.initializeFilterObject();
        Boolean hasNext = csDataTableInstance.hasNext;
        Boolean hasPrevious = csDataTableInstance.hasPrevious;
        Integer pagenumber = csDataTableInstance.pageNumber;

        IMP_Library.fieldAPILabelWrapper apiWrap = new IMP_Library.fieldAPILabelWrapper(); 
        apiWrap.apiName = 'CreatedDate';
        apiWrap.label = 'Created Date';
        apiWrap.type = 'DateTime';
        filterFieldList.add(apiWrap);

        apiWrap.apiName = 'Contract_Roll_Called__c';
        apiWrap.label = 'Contract Roll Called';
        apiWrap.type = 'Date';
        filterFieldList.add(apiWrap);

        csDataTableInstance.filterFieldList = filterFieldList;
        
        filterObject.put('SubProject_Status__c', 'Open');
        filterObject.put('Contract_Roll_Called__c', Date.today());

        csDataTableInstance.filterObject = subProjectRec;
        csDataTableInstance.refreshQuery();
        csDataTableInstance.resetTable();
        csDataTableInstance.formatInteger(5);
        csDataTableInstance.formatDateTime(DateTime.now());

        system.assert(fieldsPerObjectMap!=null);
        system.assert(recordsPerObj!=null);
        system.assert(filterFieldList!=null);
        system.assert(filterObject!=null);
        system.assert(apiWrap!=null);
    }

    /************************************************
     * Author: jlaurio@cloudsherpas.com
     * Date: 3/13/2015
     * Description: TestClass for ALL_DataTableSample_Controller
     ***********************************************/
    @isTest
    static void testDataTable_Test2()
    {

        IMP_DataTableUISetting__c uiSetting = IMP_TestFactory_Helper.createDataTableUISetting();
        insert uiSetting;

        Project__c testProject              = IMP_TestFactory_Helper.buildProject(1);
            testProject.CMF_Numbers__c      = 'testCMFNumber';
            testProject.Project_Status__c   = 'Open';
            testProject.Project_Region__c   = 'ARG-CANADA';
        insert testProject;

        SubProject__c subProjectRec             = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
            subProjectRec.SubProject_Region__c  = 'Alliance PC Solutions Admin';
            subProjectRec.Number_of_User_Connections__c = 10;
            subProjectRec.Secondary_Project_Type__c     = 'Competitive Buy-Sell';
        insert subProjectRec;

        EntitySubscription followRec = IMP_TestFactory_Helper.createFollowedRecord(subProjectRec.Id);
        insert followRec;
        
        ALL_DataTableComponent_Controller csDataTableInstance = new ALL_DataTableComponent_Controller();
        csDataTableInstance.objLabelName            = 'testObjectLabelName';
        csDataTableInstance.objApiName              = 'SubProject__c';
        csDataTableInstance.objIdPrefixCode         = '09213';
        csDataTableInstance.objEntityId             = '096171097412';
        csDataTableInstance.selectQueryString       = 'select Id, Name, Project_Type__c, SubProject_Status__c From SubProject__c';
        csDataTableInstance.selectWhereClauseString = 'WHERE Project_Type__c=\'Unhook\'';
        csDataTableInstance.selectOrderString       = 'ORDER BY Id DESC';
        csDataTableInstance.objConsoleOpenInSubTab  = true;
        csDataTableInstance.showFilter              = true;
        csDataTableInstance.filterFieldSetName      = 'SubProjectFilterFields';
        csDataTableInstance.columnFieldSetName      = 'SubProjectDataTableFields';
        csDataTableInstance.useAltColumns           = true;
        csDataTableInstance.altColumnsJSONString    = 'testAltColumnJSON';
        csDataTableInstance.recordsPerPage          = 10;
        csDataTableInstance.size                    = 10;
        csDataTableInstance.noOfRecords             = 10;
        csDataTableInstance.showEditAll             = true;
        
        Boolean isDisplayTable = csDataTableInstance.isDisplayTable;
        Map<String,List<IMP_Library.fieldAPILabelWrapper>> fieldsPerObjectMap = csDataTableInstance.fieldsPerObjectMap;
        IMP_Library.genericSObjectWrapper recordsPerObj = csDataTableInstance.recordsPerObj;
        List<IMP_Library.fieldAPILabelWrapper> filterFieldList = csDataTableInstance.filterFieldList;
        SObject filterObject = csDataTableInstance.filterObject;
        IMP_Library.fieldAPILabelWrapper fieldWrap = new IMP_Library.fieldAPILabelWrapper();
        filterObject.put('SubProject_Status__c', 'Open');
        
        csDataTableInstance.initializeTableObject();
        csDataTableInstance.initializeFilterObject();
        Boolean hasNext = csDataTableInstance.hasNext;
        Boolean hasPrevious = csDataTableInstance.hasPrevious;
        Integer pagenumber = csDataTableInstance.pageNumber;

        IMP_Library.fieldAPILabelWrapper apiWrap = new IMP_Library.fieldAPILabelWrapper(); 
        apiWrap.apiName = 'CreatedDate';
        apiWrap.label = 'Created Date';
        apiWrap.type = 'DateTime';
        filterFieldList.add(apiWrap);

        apiWrap.apiName = 'Contract_Roll_Called__c';
        apiWrap.label = 'Contract Roll Called';
        apiWrap.type = 'Date';
        filterFieldList.add(apiWrap);

        csDataTableInstance.filterFieldList = filterFieldList;
        
        filterObject.put('SubProject_Status__c', 'Open');
        filterObject.put('Contract_Roll_Called__c', Date.today());

        csDataTableInstance.filterObject = filterObject;
        csDataTableInstance.refreshQuery();
        csDataTableInstance.resetTable();
        csDataTableInstance.formatInteger(5);
        csDataTableInstance.formatDateTime(DateTime.now());

        system.assert(fieldsPerObjectMap!=null);
        system.assert(recordsPerObj!=null);
        system.assert(filterFieldList!=null);
        system.assert(filterObject!=null);
        system.assert(apiWrap!=null);
    }

    /************************************************
     * Author: jlaurio@cloudsherpas.com
     * Date: 3/13/2015
     * Description: TestClass for ALL_DataTableSample_Controller
     ***********************************************/
    @isTest
    static void testDataTableNoWhereClause()
    {
        
        IMP_DataTableUISetting__c uiSetting = IMP_TestFactory_Helper.createDataTableUISetting();
        insert uiSetting;

        Project__c testProject              = IMP_TestFactory_Helper.buildProject(1);
            testProject.CMF_Numbers__c      = 'testCMFNumber';
            testProject.Project_Status__c   = 'Open';
            testProject.Project_Region__c   = 'ARG-CANADA';
        insert testProject;

        SubProject__c subProjectRec             = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
            subProjectRec.SubProject_Region__c  = 'Alliance PC Solutions Admin';
            subProjectRec.Number_of_User_Connections__c = 10;
            subProjectRec.Secondary_Project_Type__c     = 'Competitive Buy-Sell';
        insert subProjectRec;
        
        ALL_DataTableComponent_Controller csDataTableInstance = new ALL_DataTableComponent_Controller();
        csDataTableInstance.objLabelName            = 'testObjectLabelName';
        csDataTableInstance.objApiName              = 'SubProject__c';
        csDataTableInstance.selectQueryString       = 'select Id, Name, Project_Type__c, SubProject_Status__c From SubProject__c';
        csDataTableInstance.queryLimitNum           = 5;
        csDataTableInstance.selectWhereClauseString = null; 
        csDataTableInstance.showFilter              = true;
        csDataTableInstance.filterFieldSetName      = 'SubProjectFilterFields';
        csDataTableInstance.columnFieldSetName      = '';

        ApexPages.StandardSetController setCon = csDataTableInstance.setCon;
        Boolean isDisplayTable = csDataTableInstance.isDisplayTable;
        Map<String,List<IMP_Library.fieldAPILabelWrapper>> fieldsPerObjectMap = csDataTableInstance.fieldsPerObjectMap;
        IMP_Library.genericSObjectWrapper recordsPerObj = csDataTableInstance.recordsPerObj;
        List<IMP_Library.fieldAPILabelWrapper> filterFieldList = csDataTableInstance.filterFieldList;
        
        SObject filterObject = csDataTableInstance.filterObject;
        IMP_Library.fieldAPILabelWrapper fieldWrap = new IMP_Library.fieldAPILabelWrapper();

        
        csDataTableInstance.initializeTableObject();
        csDataTableInstance.initializeFilterObject();
        Boolean hasNext = csDataTableInstance.hasNext;
        Boolean hasPrevious = csDataTableInstance.hasPrevious;
        Integer pagenumber = csDataTableInstance.pageNumber;
        
        IMP_Library.fieldAPILabelWrapper apiWrap = new IMP_Library.fieldAPILabelWrapper(); 
        apiWrap.apiName = 'Contract_Roll_Called__c';
        apiWrap.label = 'Contract Roll Called';
        apiWrap.type = 'Date';
        filterFieldList.add(apiWrap);
        csDataTableInstance.filterFieldList = filterFieldList;
        
        filterObject.put('SubProject_Status__c', 'Open');
        filterObject.put('Contract_Roll_Called__c', Date.today());

        csDataTableInstance.filterObject = filterObject;
        csDataTableInstance.refreshQuery();
        csDataTableInstance.first();
        csDataTableInstance.last();
        csDataTableInstance.previous();
        csDataTableInstance.next();

        system.assert(apiWrap!=null);
    }

    /************************************************
     * Author: jlaurio@cloudsherpas.com
     * Date: 3/13/2015
     * Description: TestClass for ALL_DataTableSample_Controller
     ***********************************************/
    @isTest
    static void testDataTableNegativeTest()
    {
        
        IMP_DataTableUISetting__c uiSetting = IMP_TestFactory_Helper.createDataTableUISetting();
        insert uiSetting;

        Project__c testProject              = IMP_TestFactory_Helper.buildProject(1);
            testProject.CMF_Numbers__c      = 'testCMFNumber';
            testProject.Project_Status__c   = 'Open';
            testProject.Project_Region__c   = 'ARG-CANADA';
        insert testProject;

        SubProject__c subProjectRec             = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
            subProjectRec.SubProject_Region__c  = 'Alliance PC Solutions Admin';
            subProjectRec.Number_of_User_Connections__c = 10;
            subProjectRec.Secondary_Project_Type__c     = 'Competitive Buy-Sell';
        insert subProjectRec;
        
        ALL_DataTableComponent_Controller csDataTableInstance = new ALL_DataTableComponent_Controller();
        csDataTableInstance.objLabelName            = 'testObjectLabelName';
        csDataTableInstance.objApiName              = 'SubProject__c';
        //csDataTableInstance.selectQueryString       = 'select Id, Name, Project_Type__c, SubProject_Status__c From SubProject__c';
        csDataTableInstance.selectWhereClauseString = null; 
        csDataTableInstance.showFilter              = false;
        //csDataTableInstance.filterFieldSetName      = 'SubProjectFilterFields';
        csDataTableInstance.columnFieldSetName      = '';

        ApexPages.StandardSetController setCon = csDataTableInstance.setCon;
        Boolean isDisplayTable = csDataTableInstance.isDisplayTable;
        Map<String,List<IMP_Library.fieldAPILabelWrapper>> fieldsPerObjectMap = csDataTableInstance.fieldsPerObjectMap;
        IMP_Library.genericSObjectWrapper recordsPerObj = csDataTableInstance.recordsPerObj;
        List<IMP_Library.fieldAPILabelWrapper> filterFieldList = csDataTableInstance.filterFieldList;
        
        SObject filterObject = csDataTableInstance.filterObject;
        IMP_Library.fieldAPILabelWrapper fieldWrap = new IMP_Library.fieldAPILabelWrapper();

        
        csDataTableInstance.initializeTableObject();
        try{
            csDataTableInstance.initializeFilterObject();
        }
        catch(Exception e){
            System.debug('\n\n*****Exception='+e);
        }
        Boolean hasNext = csDataTableInstance.hasNext;
        Boolean hasPrevious = csDataTableInstance.hasPrevious;
        Integer pagenumber = csDataTableInstance.pageNumber;
        
        csDataTableInstance.first();
        csDataTableInstance.last();
        csDataTableInstance.previous();
        csDataTableInstance.next();
        csDataTableInstance.formatDate(Datetime.now());
        //system.assert(apiWrap!=null);
    }
}