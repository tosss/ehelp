/*------------------------------------------------------------
Author:      Jerick Laurio
Company:     Cloud Sherpas
Description: [Phase 2 Rel 1]Controller responsible for supporting the ALL_DataTableComponent, 
                primarily providing data processing for the attributes passed onto the ALL_DataTableComponent component
Test Class:  
History
02/04/15     Jerick Laurio          Drafted
03/16/15     Jerick Laurio          Created
03/20/15     Jerick Laurio          Cleaned and refactored
04/01/15     Sam Oberes             Commented out the globalDscribeMap variable declaration and initialization because the Schema.getGlobalDescribe() causes the 'Insufficient Privileges' error whenever the page using this component is refreshed
------------------------------------------------------------*/

public class ALL_DataTableComponent_Controller 
{
    public final Integer PAGE_SIZE = 5;
    //page variables 
    public String objLabelName {get;set;}
    public String objApiName {get;set;}
    public String objIdPrefixCode {get;set;}
    public String objEntityId {get;set;}
    public String selectQueryString {get;set;}
    public String selectWhereClauseString {get;set;}
    public Integer queryLimitNum {get;set;}
    public String selectOrderString {get;set;}
    public Boolean objConsoleOpenInSubTab {get;set;}
    public Boolean showFilter{get;set;}
    public String filterFieldSetName{get;set;}
    public String columnFieldSetName{get;set;}
    public Boolean useAltColumns{get;set;}
    public String altColumnsJSONString{get;set;}
    public Integer recordsPerPage{get;set;}
    public Integer size {get;set;}
    public Integer noOfRecords{get; set;}
    public Boolean showEditAll { get; set; }
    
    //private variables
    //Map<String,Schema.Sobjecttype> globalDescribeMap = Schema.getGlobalDescribe();
    Map<String,Schema.Sobjecttype> globalDescribeMap
    {
        get 
        {
            if (globalDescribeMap == null) 
            {
                globalDescribeMap = Schema.getGlobalDescribe();
            }
            return globalDescribeMap;
        }
        set;
    }
    IMP_DataTableUISetting__c uisetting;
    Decimal maxNumberOfQueryResult;
    Decimal minNumberOfCharAllowed;
    Decimal numberRecordsPerObject;

    /**
     * @description Custom Getter/Setter used as a flag for displaying the DataTable based on provided component attribute: selectQueryString
     * @author Jerick Laurio
     * @date 10.FEB.2015
     * @param N/A
     * @return Boolean
     * @history 04.FEB.2015     Jerick Laurio       Code Drafted
     *          10.FEB.2015     Jerick Laurio       Code Created
     */
    public Boolean isDisplayTable
    {
        get
        {
            System.debug('*****[isDisplayTable]*****');
            if(selectQueryString!=null&&String.isNotBlank(selectQueryString)&&selectQueryString!='')
            {
                return true;
            }
            return false;
        }
    }
    
    /**
     * @description Custom Getter/Setter used to retrieve all fields contained on the fieldset attribute of the component: columnFieldSetName
     * @author Jerick Laurio
     * @date 10.FEB.2015
     * @param N/A
     * @return Boolean
     * @history 04.FEB.2015     Jerick Laurio       Code Drafted
     *          10.FEB.2015     Jerick Laurio       Code Created
     */
    public Map<String,List<IMP_Library.fieldAPILabelWrapper>> fieldsPerObjectMap 
    {
        get
        {
            Map<String,List<IMP_Library.fieldAPILabelWrapper>> temp = new Map<String,List<IMP_Library.fieldAPILabelWrapper>>();
            if(fieldsPerObjectMap==null){
                System.debug('\n\n*****[GETTER fieldsPerObjectMap]columnFieldSetName='+columnFieldSetName+'\n\n');
                //check if columnFieldSetName was set
                if(String.isNotEmpty(columnFieldSetName)&&String.isNotBlank(columnFieldSetName))
                {
                    //retieve object and fieldset description 
                    Schema.sobjectType sObjType = globalDescribeMap.get(objApiName);
                    System.debug('\n\n*****[GETTER fieldsPerObjectMap]sObjType='+sObjType+'\n\n');                    
                    Schema.Describesobjectresult dscribeObjResult = sObjType.getDescribe();
                    Schema.FieldSet objFieldSet = dscribeObjResult.FieldSets.getMap().get(columnFieldSetName.toLowerCase());
                    //check if fieldset exists
                    if (objFieldSet != null) 
                    {
                        List<Schema.FieldSetMember> fieldSetMemberList = objFieldSet.getFields();
                        List<IMP_Library.fieldAPILabelWrapper> fieldList = new List<IMP_Library.fieldAPILabelWrapper>();
                        //iterate thru all the fields inside the fieldset and then wrapped into fieldAPILabelWrapper class
                        for(Schema.FieldSetMember fsetMember : fieldSetMemberList)
                        {
                            if(fsetMember.getFieldPath()!='Id')
                            {
                                IMP_Library.fieldAPILabelWrapper apiWrap = new IMP_Library.fieldAPILabelWrapper(); 
                                apiWrap.apiName = fsetMember.getFieldPath();
                                apiWrap.label = fsetMember.getLabel();
                                fieldList.add(apiWrap);
                            }
                        }
                        System.debug('\n\n*****[GETTER fieldsPerObjectMap][JSON serialize]='+System.JSON.serialize(fieldList)+'*****\n\n');
                        temp.put(objApiName,fieldList);
                    }
                }
                else
                {
                    //Generic wrapped fields when no column fieldset is set 
                    List<IMP_Library.fieldAPILabelWrapper> fieldList = new List<IMP_Library.fieldAPILabelWrapper>();
                    IMP_Library.fieldAPILabelWrapper apiWrap = new IMP_Library.fieldAPILabelWrapper(); 
                    apiWrap.apiName = 'Name';
                    apiWrap.label = 'Name';
                    fieldList.add(apiWrap);
                    temp.put(objApiName,fieldList);
                }
                fieldsPerObjectMap = temp;
            }
            return fieldsPerObjectMap;
        }
        set;
    }

    /**
     * @description Custom Getter/Setter used to retrieve all records processed from the StandardSetController 
     *                  and wrapped onto a class together with the currently logged in user's subscription: EntitySubscription object
     * @author Jerick Laurio
     * @date 10.FEB.2015
     * @param N/A
     * @return IMP_Library.genericSObjectWrapper
     * @history 04.FEB.2015     Jerick Laurio       Code Drafted
     *          10.FEB.2015     Jerick Laurio       Code Created
     *          05.MAR.2015     Sam Oberes          Added isFollowed logic
     *          01.APR.2015     Sam Oberes          Commented out the globalDscribeMap variable declaration and initialization because
     *                                                1) it is not used 
     *                                                2) the Schema.getGlobalDescribe() causes the 'Insufficient Privileges' error whenever the page using this component is refreshed
     */
    public IMP_Library.genericSObjectWrapper recordsPerObj
    {
        get
        {
            System.debug('*****[recordsPerObj]*****');
            IMP_Library.genericSObjectWrapper recordObj = initializeRecords();
            
                
            System.debug('*****[recordsPerObj]'+recordObj+'*****');
            return recordObj;
        }
        set;
    }
    
    /**
     * @description Custom Getter/Setter for initializing the StandardSetController that is used for records retrieval and table page navigation
     * @author Jerick Laurio
     * @date 10.FEB.2015
     * @param N/A
     * @return ApexPages.StandardSetController
     * @history 04.FEB.2015     Jerick Laurio       Code Drafted
     *          10.FEB.2015     Jerick Laurio       Code Created
     *          23.MAR.2015     Jerick Laurio       Cleaned and Refarctored; Added error handling.
     */
    public ApexPages.StandardSetController setCon 
    {
        get
        {
            //standard set controller population
            if(setCon == null)
            {
                setCon = initializeStandardSet();
            }
                
            System.debug('\n\n*****[setCon]='+setCon+'*****\n\n');
            return setCon;
        }
        set;
    }
    
    /**
     * @description Custom Getter/Setter to retrieve all fields contained on the fieldset attribute of the component for filtering functionality: filterFieldSetName
     * @author Jerick Laurio
     * @date 10.FEB.2015
     * @param N/A
     * @return List<IMP_Library.fieldAPILabelWrapper>
     * @history 10.FEB.2015     Jerick Laurio       Code Created
     *          11.MAR.2015     Sam Oberes          Added multipicklist-type selection for Project_Task__c.Status__c
     *          23.MAR.2015     Jerick Laurio       Cleaned and Refarctored; Added error handling.
     */
    public List<IMP_Library.fieldAPILabelWrapper> filterFieldList 
    {
        get
        {
            if(filterFieldList==null)
            {

                List<IMP_Library.fieldAPILabelWrapper> fieldList = new List<IMP_Library.fieldAPILabelWrapper>();
                //check if filter functionality is enabled and fieldset for this functionality was setup
                if(showFilter!=null&&showFilter==true&&filterFieldSetName!=null)
                {
                    //retrieving field set describe
                    Schema.sobjectType sObjType = Schema.getGlobalDescribe().get(objApiName);
                    System.debug('\n\n*****[initializeFilterObject()]sObjType='+sObjType+'\n\n');
                    filterObject = sObjType.newSObject(null, false);
                    System.debug('\n\n*****[initializeFilterObject()]filterObject='+filterObject+'\n\n');
                    Schema.Describesobjectresult dscribeObjResult = sObjType.getDescribe();
                    try
                    {
                        Schema.FieldSet objFieldSet = dscribeObjResult.FieldSets.getMap().get(filterFieldSetName.toLowerCase());
                        //check if fieldset exists
                        if (objFieldSet != null) 
                        {
                            List<Schema.FieldSetMember> fieldSetMemberList = objFieldSet.getFields();
                            //iterate thru all the fields inside the fieldset and then wrapped into fieldAPILabelWrapper class
                            for(Schema.FieldSetMember fsetMember : fieldSetMemberList)
                            {
                                System.debug('\n\n*****[initializeFilterObject()]fsetMember='+fsetMember+'\n\n');
                                if(fsetMember.getFieldPath()!='Id')
                                {
                                    IMP_Library.fieldAPILabelWrapper apiWrap = new IMP_Library.fieldAPILabelWrapper(); 
                                    apiWrap.apiName = fsetMember.getFieldPath();
                                    apiWrap.label = fsetMember.getLabel();
                                    apiWrap.type = String.valueOf(fsetMember.getType());
                                    //custom filter display setup
                                    //Multipicklist to be displayed as dropdown list
                                    if(fsetMember.getType()==Schema.DisplayType.MultiPicklist)
                                    {
                                        apiWrap.isMultiPicklist = true;
                                        List<SelectOption> picklistValues = new List<SelectOption>();
                                        picklistValues.add(new SelectOption('', ' --None-- '));
                                        System.debug('\n\n*****[initializeFilterObject()]dscribeObjResult.fields.getMap()='+dscribeObjResult.fields.getMap()+'\n\n');
                                        for(Schema.PicklistEntry entry:
                                                dscribeObjResult.fields.getMap().get(
                                                        String.valueOf(fsetMember.getFieldPath().toLowerCase())).getDescribe().getPickListValues()
                                        )
                                        {
                                            picklistValues.add(new SelectOption(entry.getLabel(), entry.getValue()));
                                        }/**/
                                        apiWrap.picklistValues = picklistValues;
                                    }
                                    //specific fields customized displayed
                                    if (apiWrap.apiName == 'Status__c' || apiWrap.apiName == 'SubProject_Status__c') 
                                    {
                                        apiWrap.isMultiPicklist = true;
                                        List<SelectOption> picklistValues = new List<SelectOption>();
                                        
                                        picklistValues.add(new SelectOption('', ' --None-- '));
                                        picklistValues.add(new SelectOption('Not Applicable', 'Not Applicable'));
                                        picklistValues.add(new SelectOption('Complete', 'Complete'));
                                        picklistValues.add(new SelectOption('In Progress', 'In Progress'));
                                        picklistValues.add(new SelectOption('Assigned', 'Assigned'));
                                        picklistValues.add(new SelectOption('Unassigned', 'Unassigned'));

                                        apiWrap.picklistValues = picklistValues;
                                    }
                                    fieldList.add(apiWrap);
                                }
                            }
                        }
                    }
                    catch(Exception e)
                    {
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 
                                IMP_String_Utility.ERROR_FIELDSET_INITIALIZATION+e.getMessage());
                        ApexPages.addMessage(errMsg);
                    }
                }
                System.debug('\n\n*****[filterFieldList]fieldList='+fieldList+'\n\n');
                System.debug('\n\n*****[filterFieldList]filterObject='+filterObject+'\n\n');
                filterFieldList = fieldList;
            }
            return filterFieldList;
        }
        set;
    }

    /**
     * @description Custom Getter/Setter to initialize the object that will be used for filtering functionality
     * @author Jerick Laurio
     * @date 10.FEB.2015
     * @param N/A
     * @return List<IMP_Library.fieldAPILabelWrapper>
     * @history 10.FEB.2015     Jerick Laurio       Code Created
     *          11.MAR.2015     Sam Oberes          Added multipicklist-type selection for Project_Task__c.Status__c
     *          23.MAR.2015     Jerick Laurio       Cleaned and Refarctored; Added error handling.
     */
    public SObject filterObject 
    {
        get
        {
            if(filterObject==null){ 
                try
                {
                    //retrieve filter sobject describe            
                    Schema.sobjectType sObjType = globalDescribeMap.get(objApiName);
                    System.debug('\n\n*****[CONSTRUCTOR]sObjType='+sObjType+'\n\n');
                    //initialize a new instance of sobject
                    filterObject = sObjType.newSObject(null, false);

                }
                catch(Exception e)
                {
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 
                            IMP_String_Utility.ERROR_FILTER_OBJECT_INITIALIZATION+e.getMessage());
                    ApexPages.addMessage(errMsg);
                }
            }
            System.debug('\n\n*****[CONSTRUCTOR]{filterObject}='+filterObject+'\n\n');
            return filterObject;
        }
        set;
    }


    /**
     * @description The constructor of the class. Initializes initial values.
     * @author Jerick Laurio
     * @date 10.FEB.2015
     * @param N/A
     * @return N/A
     */
    public ALL_DataTableComponent_Controller() 
    {
        System.debug('*****[CONSTRUCTOR]*****');
        recordsPerObj = new IMP_Library.genericSObjectWrapper();
        //getting values custom setting for search index
        uisetting = IMP_DataTableUISetting__c.getInstance(UserInfo.getProfileId());
        if(uisetting == null)
        {
            uisetting = IMP_DataTableUISetting__c.getOrgDefaults();
        }
        //retrieve data table ui setup defaults
        maxNumberOfQueryResult = (Decimal)uisetting.get('MaxNumberOfSearchResults__c');
        numberRecordsPerObject = (Decimal)uisetting.get('NumberOfRecordsPerObject__c');
        pageNumber = 0;
    }

    
    /**
     * @description A method that initializes the table fieldset map
     * @author Jerick Laurio
     * @date 10.FEB.2015
     * @param N/A
     * @return N/A
     */
    public void initializeTableObject()
    {
        System.debug('*****[initializeTableObject]*****');
        System.debug('\n\n*****[initializeTableObject()]columnFieldSetName='+columnFieldSetName+'\n\n');
        //check if fieldset for datatable was set up
        if(String.isNotEmpty(columnFieldSetName)&&String.isNotBlank(columnFieldSetName))
        {
            //retrieving field set describe
            Schema.sobjectType sObjType = globalDescribeMap.get(objApiName);
            System.debug('\n\n*****[initializeTableObject()]sObjType='+sObjType+'\n\n');
            
            Schema.Describesobjectresult dscribeObjResult = sObjType.getDescribe();
            Schema.FieldSet objFieldSet = dscribeObjResult.FieldSets.getMap().get(columnFieldSetName.toLowerCase());
            if (objFieldSet != null) 
            {
                List<Schema.FieldSetMember> fieldSetMemberList = objFieldSet.getFields();
                List<IMP_Library.fieldAPILabelWrapper> fieldList = new List<IMP_Library.fieldAPILabelWrapper>();
                //iterate thru all the fields inside the fieldset and then wrapped into fieldAPILabelWrapper class
                for(Schema.FieldSetMember fsetMember : fieldSetMemberList)
                {
                    if(fsetMember.getFieldPath()!='Id')
                    {
                        IMP_Library.fieldAPILabelWrapper apiWrap = new IMP_Library.fieldAPILabelWrapper(); 
                        apiWrap.apiName = fsetMember.getFieldPath();
                        apiWrap.label = fsetMember.getLabel();
                        fieldList.add(apiWrap);
                    }
                }
                fieldsPerObjectMap.put(objApiName,fieldList);
            }
        }
        else{
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 
                    IMP_String_Utility.DATATABLE_COLUMN_FIELDSET_MISSING);
            ApexPages.addMessage(errMsg);
        }
    }

    /**
     * @description A method that initializes the filter section field list
     * @author Jerick Laurio
     * @date 10.FEB.2015
     * @param fieldSetName String value that field set name
     * @return N/A
     */
    public void initializeFilterObject()
    {
        //check if filter functionality is enabled and fieldset for this functionality was setup
        if(showFilter!=null&&showFilter==true&&filterFieldSetName!=null)
        {
            //retrieving field set describe
            Schema.sobjectType sObjType = globalDescribeMap.get(objApiName);
            System.debug('\n\n*****[initializeFilterObject()]sObjType='+sObjType+'\n\n');
            System.debug('\n\n*****[initializeFilterObject()]filterObject='+filterObject+'\n\n');
            Schema.Describesobjectresult dscribeObjResult = sObjType.getDescribe();
            Schema.FieldSet objFieldSet = dscribeObjResult.FieldSets.getMap().get(filterFieldSetName.toLowerCase());
            if (objFieldSet != null) 
            {
                List<Schema.FieldSetMember> fieldSetMemberList = objFieldSet.getFields();
                List<IMP_Library.fieldAPILabelWrapper> fieldList = new List<IMP_Library.fieldAPILabelWrapper>();
                //iterate thru all the fields inside the fieldset and then wrapped into fieldAPILabelWrapper class
                for(Schema.FieldSetMember fsetMember : fieldSetMemberList)
                {
                    if(fsetMember.getFieldPath()!='Id')
                    {
                        IMP_Library.fieldAPILabelWrapper apiWrap = new IMP_Library.fieldAPILabelWrapper(); 
                        apiWrap.apiName = fsetMember.getFieldPath();
                        apiWrap.label = fsetMember.getLabel();
                        fieldList.add(apiWrap);
                    }
                }
                filterFieldList = fieldList;
            }
        }       
        else
        {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 
                    IMP_String_Utility.FILTER_COLUMN_FIELDSET_MISSING);
            ApexPages.addMessage(errMsg);
        }
            
    }

    /**
     * @description A method that initializes the standard set controller
     * @author Jerick Laurio
     * @date 10.FEB.2015
     * @param N/A
     * @return ApexPages.StandardSetController
     */
    public ApexPages.StandardSetController initializeStandardSet()
    {
        ApexPages.StandardSetController returnSetCon;
        if(selectQueryString!=null&&String.isNotBlank(selectQueryString)&&selectQueryString!='')
        {
            //retieving records per page
            if(recordsPerPage!=null)
            {
                //overridden value from attribute
                size = (Integer)recordsPerPage;
            }
            else
            {
                //defaults from custom setting
                size = (Integer)numberRecordsPerObject; 
            }
            //retieving select query string
            String qString = selectQueryString;
            //retieving select query where clause string
            if(selectWhereClauseString!=null)
            {
                qString += ' '+ selectWhereClauseString;
            }
            //retieving select query order clause string
            if(selectOrderString!=null)
            {
                qString += ' '+ selectOrderString;
            }
            //retieving select query limit clause string
            if(queryLimitNum!=null)
            {
                //overridden value from attribute
                qString += ' LIMIT '+ queryLimitNum;
            }
            else
            {
                //defaults from custom setting
                qString += ' LIMIT '+ (Integer)maxNumberOfQueryResult;
            }
            System.debug('\n\n*****[CS_DataTableCC.GET setCon()]qString='+qString+'\n\n');
            
            try
            {
                //StandardSetController initialization
                returnSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(qString));
                //StandardSetController page size setup
                returnSetCon.setPageSize(size);
                //retrieving the number of records
                noOfRecords = returnSetCon.getResultSize();
                //StandardSetController starting page setup
                returnSetCon.setPageNumber(1);
                returnSetCon.first();

            }
            catch(Exception e)
            {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 
                        IMP_String_Utility.ERROR_STANDARDSETCONTROLLER_INITIALIZATION+e.getMessage());
                ApexPages.addMessage(errMsg);                  
            }
        }
        else
        {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 
                    IMP_String_Utility.DATATABLE_SELECT_QUERY_MISSING);
            ApexPages.addMessage(errMsg);
        }

        return returnSetCon;
    }

    /**
     * @description A method that initializes the record set
     * @author Jerick Laurio
     * @date 10.FEB.2015
     * @param N/A
     * @return IMP_Library.genericSObjectWrapper
     */
    public IMP_Library.genericSObjectWrapper initializeRecords()
    {
        IMP_Library.genericSObjectWrapper recordObj = new IMP_Library.genericSObjectWrapper();
        //Map<String,Schema.sobjectType> globalDscribeMap = Schema.getGlobalDescribe();
        //check if StandardSetController is initialized
        if(setCon!=null)
        {
            //retrieving records from StandardSetController
            recordObj.sObjList = setCon.getRecords();
            List<IMP_Library.genericSelectSObjectWrapper> wrapperList = new List<IMP_Library.genericSelectSObjectWrapper>();
            //collating all ids the user is following
            Set<Id> esParentIdSet = new Set<Id>();
            for (EntitySubscription es : [SELECT ParentId FROM EntitySubscription WHERE SubscriberId = :UserInfo.getUserId()]) 
            {
                esParentIdSet.add(es.ParentId);
            }
            //wrapping the records from setCon
            for (SObject record : setCon.getRecords()) 
            {
                IMP_Library.genericSelectSObjectWrapper wrapper = new IMP_Library.genericSelectSObjectWrapper();
                wrapper.sObj = record;
                wrapper.isSelected = false;
                wrapper.isFollowed = esParentIdSet.contains((Id)record.get('Id'));
                wrapperList.add(wrapper);

            }
            //sorting the wrapped records
            wrapperList.sort();
            recordObj.selectSObjList = wrapperList;
            recordObj.selectSObjList.sort();
            //retrieving the fields of the object
            //checking if map is initialized
            if(fieldsPerObjectMap==null)
            {
                //getting values custom setting for search index
                uisetting = IMP_DataTableUISetting__c.getInstance(UserInfo.getProfileId());
                if(uisetting == null)
                {
                    uisetting = IMP_DataTableUISetting__c.getOrgDefaults();
                }
                
                if(String.isNotEmpty(columnFieldSetName)&&String.isNotBlank(columnFieldSetName))
                {
                    initializeTableObject();
                }
            }
            //add the fields list onto the wrapped records
            recordObj.fieldList = fieldsPerObjectMap.get(objApiName);
            recordObj.sObjListsize = recordObj.sObjList.size();
        }

        return recordObj;
    }

    /**
     * @description A method that resets to standard set controller to adjust the records based on the filter set in.
     * @author Jerick Laurio
     * @date 10.FEB.2015
     * @param N/A
     * @return N/A
     */
    public void refreshQuery()
    {
        String additionalWhereCondition = '';
        System.debug('\n\n*****[refreshQuery]filterObject='+filterObject+'\n\n');
        System.debug('\n\n*****[refreshQuery]filterFieldList='+filterFieldList+'\n\n');
        //check if filter object is initialized
        if(filterObject!=null)
        {
            //retieving records per page
            if(recordsPerPage!=null)
            {
                //overridden value from attribute
                size = (Integer)recordsPerPage;
            }
            else
            {
                //defaults from custom setting
                size = (Integer)numberRecordsPerObject; 
            }
            //retieving select query string
            String qString = selectQueryString;
            Boolean needsEndingParenthesis = false;
            //retieving select query where clause string
            if(selectWhereClauseString!=null)
            {
                qString += ' '+ selectWhereClauseString;
                //String additionalWhereCondition = '';
                if(filterObject!=null)
                {
                    //retrieve and compose additional where clause filters from filter object
                    for(IMP_Library.fieldAPILabelWrapper fieldWrap:filterFieldList)
                    {
                        if(filterObject.get(fieldWrap.apiName)!=null && filterObject.get(fieldWrap.apiName)!='')
                        {                           
                            if(additionalWhereCondition=='')
                            {
                                additionalWhereCondition += ' AND ('+fieldWrap.apiName+' = ';
                                needsEndingParenthesis = true;
                            }
                            else
                            {
                                additionalWhereCondition += ' AND '+fieldWrap.apiName+' = ';
                            }
                            
                            additionalWhereCondition += createFilterViaFieldType(fieldWrap.Type, filterObject, fieldWrap.apiName);
                        }
                    }
                    if(needsEndingParenthesis)
                    {
                        additionalWhereCondition+=')';
                    }
                }
                qString += additionalWhereCondition;
            }
            else 
            {
                //composing where when no selectWhereClauseString set up
                selectWhereClauseString = ' WHERE ';
                for(IMP_Library.fieldAPILabelWrapper fieldWrap:filterFieldList)
                {
                    //retrieve and compose where clause filters from filter object
                    if(filterObject.get(fieldWrap.apiName)!=null && filterObject.get(fieldWrap.apiName)!='')
                    {
                        if(additionalWhereCondition=='')
                        {
                            additionalWhereCondition += ' ('+fieldWrap.apiName+' = ';
                            needsEndingParenthesis = true;
                        }
                        else
                        {
                            additionalWhereCondition += ' AND '+fieldWrap.apiName+' = ';
                        }
                        
                        additionalWhereCondition += createFilterViaFieldType(fieldWrap.Type, filterObject, fieldWrap.apiName);
                    }
                }
                if(needsEndingParenthesis)
                {
                    additionalWhereCondition+=')';
                }
                if (String.isNotBlank(additionalWhereCondition)) 
                {
                    qString += ' ' + selectWhereClauseString + additionalWhereCondition;
                }
            }
            //retieving select query order clause string
            if(selectOrderString!=null)
            {
                qString += ' '+ selectOrderString;
            }
            //retieving select query limit clause string
            if(queryLimitNum!=null)
            {
                //overridden value from attribute
                qString += ' LIMIT '+ queryLimitNum;
            }
            else
            {
                //defaults from custom setting
                qString += ' LIMIT '+ (Integer)maxNumberOfQueryResult;
            }
            System.debug('\n\n*****[refreshQuery]qString='+qString+'\n\n');
            
            //setting new instance of StandardSetController
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(qString));
            setCon.setPageSize(size);
            noOfRecords = setCon.getResultSize();
            setCon.setPageNumber(1);
            setCon.first();
        }
        System.debug('\n\n*****[refreshQuery]additionalWhereCondition='+additionalWhereCondition+'');
    }

    /**
     * @description A method that resets to standard set controller to adjust the records based on the filter set in.
     * @author Jerick Laurio
     * @date 10.FEB.2015
     * @param N/A
     * @return N/A
     */
    public void resetTable()
    {
        System.debug('\n\n*****[resetTable]*****\n\n');
        filterObject = null;
        setCon = null;
        recordsPerObj = null;
        setCon = initializeStandardSet();
        recordsPerObj = initializeRecords();
    }

    /**
     * @description A method that creates where clause filters string based on field type
     * @author Jerick Laurio
     * @date 20.MAR.2015
     * @param N/A
     * @return N/A
     */
    public String createFilterViaFieldType(String fieldType, Sobject filterObj, String fieldAPIName)
    {
        String returnString = '';
        //check field type and create where clause string accordingly
        if(fieldType=='Date' || fieldType=='DateTime' || fieldType=='Boolean' || fieldType=='Currency' || fieldType=='Double' || fieldType=='Integer')
        {
            System.debug('\n\n*****[createFilterViaFieldType]fieldType='+fieldType+'\n\n');
            if(fieldType=='Date')
            {
                returnString += formatDate((DateTime)filterObj.get(fieldAPIName));
            }
            else if(fieldType=='DateTime')
            {
                returnString += formatDateTime((DateTime)filterObj.get(fieldAPIName));
            }
            else
            {
                returnString += filterObj.get(fieldAPIName);
            }
        }
        else
        {
            returnString += '\''+filterObj.get(fieldAPIName)+'\'';
        }

        return returnString;
    }

    /**
     * @description A method that formats the integer into 2digit format. This is for date filtering
     * @author Jerick Laurio
     * @date 14.MAR.2015
     * @param Integer 
     * @return String
     */
    public String formatInteger(Integer num)
    {
        System.debug('\n\n*****[formatInteger]num='+num+'*****\n\n');
        String newInteger = '';
        if(num<10)
        {
            newInteger = '0'+num;
        }
        else
        {
            newInteger = ''+num;
        }
        System.debug('\n\n*****[formatInteger]num='+num+'\n\nnewInteger='+newInteger+'*****\n\n');
        return newInteger;
    }

    /**
     * @description A method that formats the datetime obj into string format. This is for date filtering
     * @author Jerick Laurio
     * @date 20.MAR.2015
     * @param Integer 
     * @return String
     */
    public String formatDate(DateTime objDateTime)
    {
        String returnString = '';
        Integer year = objDateTime.yearGmt();
        Integer month = objDateTime.monthGmt();
        Integer day = objDateTime.dayGMT();
        returnString = formatInteger(year)+'-'+formatInteger(month)+'-'+formatInteger(day);
        return returnString;
    }

    /**
     * @description A method that formats the datetime obj into string format. This is for date/datetime filtering
     * @author Jerick Laurio
     * @date 14.MAR.2015
     * @param Integer 
     * @return String
     */
    public String formatDateTime(DateTime objDateTime)
    {
        String returnString = '';
        Integer year = objDateTime.yearGmt();
        Integer month = objDateTime.monthGmt();
        Integer day = objDateTime.dayGMT();
        Integer hourGMT =objDateTime.hourGMT();
        Integer minuteGMT = objDateTime.minuteGMT();
        Integer secondGMT = objDateTime.secondGMT();
        returnString = formatInteger(year)+'-'+formatInteger(month)+'-'+formatInteger(day)+' '+formatInteger(hourGMT)+':'+formatInteger(minuteGMT)+':'+formatInteger(secondGMT);
        return returnString;
    }

    /**
     * @description A pagination method. Determines if there is have a next page
     * @author Jerick Laurio
     * @date 03.FEB.2015
     * @param N/A
     * @return Boolean
     */
    public Boolean hasNext 
    {
        get 
        {
            System.debug('\n\n*****[hasNext]*****\n\n');
            Boolean returnBool = false;
            if(setCon!=null)
            {
                returnBool = setCon.getHasNext();
            }
            return returnBool;
        }
        set;
    }

    /**
     * @description A pagination method. Determines if there is have a previous page
     * @author Jerick Laurio
     * @date 03.FEB.2015
     * @param N/A
     * @return Boolean
     */
    public Boolean hasPrevious 
    {
        get 
        {
            System.debug('\n\n*****[hasPrevious]*****\n\n');
            Boolean returnBool = false;
            if(setCon!=null)
            {
                returnBool = setCon.getHasPrevious();
            }
            return returnBool;
        }
        set;
    }
    
    /**
     * @description A pagination method. Determines the current page number.
     * @author Jerick Laurio
     * @date 03.FEB.2015
     * @param N/A
     * @return Integer
     */
    public Integer pageNumber 
    {
        get 
        {
            System.debug('\n\n*****[pageNumber]*****\n\n');
            Integer returnInt = 0;
            if(setCon!=null)
            {
                returnInt = setCon.getPageNumber();
            }
            return returnInt;
        }
        set;
    }
  
    /**
     * @description A pagination method. Retrieves the first page of the table
     * @author Jerick Laurio
     * @date 03.FEB.2015
     * @param N/A
     * @return N/A
     */
    public void first() 
    {
        System.debug('\n\n*****[first]*****\n\n');
        filterObject = null;
        if(setCon!=null)
        {
            setCon.first();
        }
        
    }
    /**
     * @description A pagination method. Retrieves the last page of the table
     * @author Jerick Laurio
     * @date 03.FEB.2015
     * @param N/A
     * @return N/A
     */
    public void last() 
    {
        System.debug('\n\n*****[last]*****\n\n');
        if(setCon!=null)
        {
            setCon.last();
        }
    }
    
    /**
     * @description A pagination method. Retrieves the previous page of the table
     * @author Jerick Laurio
     * @date 03.FEB.2015
     * @param N/A
     * @return N/A
     */
    public void previous() 
    {
        System.debug('\n\n*****[previous]*****\n\n');
        if(setCon!=null)
        {
            setCon.previous();
        }
        
    }
    /**
     * @description A pagination method. Retrieves the next page of the table
     * @author Jerick Laurio
     * @date 03.FEB.2015
     * @param N/A
     * @return N/A
     */
    public void next() 
    {
        System.debug('\n\n*****[next]*****\n\n');
        if(setCon!=null)
        {
            setCon.next();
        }
        
    }

    
}