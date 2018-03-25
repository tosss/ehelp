/*------------------------------------------------------------
Author:      Jerick Laurio
Company:     Cloud Sherpas
Description: [Phase 2 Rel 1]Controller responsible for supporting the IMP_FollowedRecordsTabComponent, primarily providing data processing for the attributes passed onto the IMP_FollowedRecordsTabComponent component
Test Class:  
History
02/04/15     Jerick Laurio          Drafted
03/16/15     Jerick Laurio          Created
03/20/15     Jerick Laurio          Cleaned and refactored
------------------------------------------------------------*/

public class IMP_FollowedRecords_Controller 
{
    public List<EntitySubscription> subscriptionList {get;set;}
    public List<IMP_Library.genericDataTableAttributeWrapper> dataTableWrapper {get;set;}
    public Map<String, Set<Id>> objectIdMap {get;set;}

    Map<String,Schema.Sobjecttype> globalDescribeMap = Schema.getGlobalDescribe();

    public IMP_FollowedRecordsSetting__c followedRecDTSetting {get;set;}

    /**
     * @description Custom Getter/Setter used to store/retrieve current user data table setting
     * @author Jerick Laurio
     * @date 22.APR.2015
     * @param N/A
     * @return IMP_FollowedRecordsSetting__c
     * @history 22.APR.2015     Jerick Laurio       Code Drafted
     */
    public IMP_FollowedRecordsSetting__c userDTSetting 
    {
        get
        {
            if(userDTSetting==null)
            {
                userDTSetting = IMP_FollowedRecordsSetting__c.getInstance(UserInfo.getUserId());
                if(userDTSetting==null)
                {
                    userDTSetting = IMP_FollowedRecordsSetting__c.getInstance();

                }
            }
            
            return userDTSetting;
        }
        set;
    }

    /**
     * @description Custom Getter/Setter used to store current tab selection
     * @author Jerick Laurio
     * @date 22.APR.2015
     * @param N/A
     * @return String
     * @history 22.APR.2015     Jerick Laurio       Code Drafted
     *          22.APR.2015     Jerick Laurio       Code Created
     */
    public String selectedIndex
    {
        get
        {
            if(selectedIndex==null)
            {
                
                //setting default seacted tab index
                selectedIndex='0';
                System.debug('\n\n@@@@@[GETTER selectedIndex] DEFAULT ='+selectedIndex+'@@@@@\n\n');
                //retrieve the default SObject item set up on custom setting
                for(IMP_Library.genericDataTableAttributeWrapper wrapper:dataTableWrapper)
                {
                    if(wrapper.objectApiName == userDTSetting.Selected_SObject__c)
                    {
                        selectedIndex = String.valueOf(wrapper.index);
                        System.debug('\n\n@@@@@[GETTER selectedIndex] DEFAULT SETTING ='+selectedIndex+'@@@@@\n\n');
                        break;
                    }
                }
            }
            System.debug('\n\n@@@@@[GETTER selectedIndex] ='+selectedIndex+'@@@@@\n\n');
            return selectedIndex;
        }
        set;
    }

    /**
     * @description Custom Getter/Setter used to store current tab selection
     * @author Jerick Laurio
     * @date 16.MAR.2015
     * @param N/A
     * @return String
     * @history 04.FEB.2015     Jerick Laurio       Code Drafted
     *          16.MAR.2015     Jerick Laurio       Code Created
     */
    public String selected 
    {
        get
        {
            System.debug('\n\n*****BEFORE[GETTER]selected='+selected);
            if(selected==null)
            {
                selected = 'Project__c';
            }
            System.debug('\n\n*****AFTER[GETTER]selected='+selected);
            return selected;
        }
        set;
    }
    
    /**
     * @description Custom Getter/Setter used to retrieve all objects from  custom setting:IMP_FollowedRecordsSetting__c
     * @author Jerick Laurio
     * @date 16.MAR.2015
     * @param N/A
     * @return List<String>
     * @history 04.FEB.2015     Jerick Laurio       Code Drafted
     *          16.MAR.2015     Jerick Laurio       Code Created
     */
    public List<String> objectsToDisplayList
    {
        get
        {
            if(objectsToDisplayList == null)
            {
                //check if IMP_FollowedRecordsSetting__c is initialized
                followedRecDTSetting = IMP_FollowedRecordsSetting__c.getInstance(UserInfo.getProfileId());
                if(followedRecDTSetting == null)
                {
                    followedRecDTSetting = IMP_FollowedRecordsSetting__c.getOrgDefaults();
                }
                System.debug('\n\n@@@@@[GETTER objectsToDisplayList]{followedRecDTSetting}'+followedRecDTSetting+'@@@@@\n\n');
                List<String> temp = new List<String>();
                //check if custom setting field have been set up
                if(followedRecDTSetting.SobjectFieldsetPair__c!=null)
                {
                    //retrieve data from field which is in the formatted of [SObject API Name].[Fieldset API Name] and new SObject pair per line
                    //retrieve entry per line
                    String[] objectAPIString = String.valueOf(followedRecDTSetting.SobjectFieldsetPair__c).split('\n'); 
                    for(Integer index=0; index < objectAPIString.size(); index++)
                    {
                        //retrieve sobject api name by splitting via \\.
                        String[] objectAPIFielseSetString = objectAPIString[index].trim().split('\\.');
                        System.debug('\n\n@@@@@[GETTER objectsToDisplayList]{objectAPIFielseSetString}'+objectAPIFielseSetString+'@@@@@\n\n');
                        //store value including the index and delimiter
                        temp.add(index+'&#124;'+objectAPIFielseSetString[0]);
                        System.debug('\n\n@@@@@[GETTER objectsToDisplayList]{followedRecDTSetting}temp='+temp+'@@@@@\n\n');
                    }
                    
                    objectsToDisplayList = temp;
                }
                else
                {
                    //error
                    objectsToDisplayList = new List<String>();
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 
                            IMP_String_Utility.FOLLOWED_RECORDS_CUSTOM_SETTING_MISSING);
                    ApexPages.addMessage(errMsg);
                }                    
            }
            System.debug('\n\n@@@@@{GETTER objectsToDisplayList]{objectsToDisplayList}'+objectsToDisplayList+'@@@@@\n\n');
            return objectsToDisplayList;
        }
        set;
    }

    /**
     * @description Custom Getter/Setter used to retrieve all objects' fieldset set up on custom setting:IMP_FollowedRecordsSetting__c
     * @author Jerick Laurio
     * @date 16.MAR.2015
     * @param N/A
     * @return Map<String,String>
     * @history 04.FEB.2015     Jerick Laurio       Code Drafted
     *          16.MAR.2015     Jerick Laurio       Code Created
     */
    public Map<String,String> objectsFieldSetMap
    {
        get
        {
            if(objectsFieldSetMap == null)
            {
                //check if IMP_FollowedRecordsSetting__c is initialized
                if(followedRecDTSetting==null)
                {

                    followedRecDTSetting = IMP_FollowedRecordsSetting__c.getInstance(UserInfo.getProfileId());
                    if(followedRecDTSetting == null)
                    {
                        followedRecDTSetting = IMP_FollowedRecordsSetting__c.getOrgDefaults();
                    }
                    
                }
                System.debug('\n\n@@@@@[GETTER objectsFieldSetMap]{followedRecDTSetting}'+followedRecDTSetting+'@@@@@\n\n');
                Map<String,String> temp = new Map<String,String>();
                //check if custom setting field have been set up
                if(followedRecDTSetting.SobjectFieldsetPair__c!=null)
                {
                    //retrieve data from field which is in the formatted of [SObject API Name].[Fieldset API Name] and new SObject pair per line
                    //retrieve entry per line
                    String[] objectAPIString = String.valueOf(followedRecDTSetting.SobjectFieldsetPair__c).split('\n'); 
                    for(Integer index=0; index < objectAPIString.size(); index++)
                    {
                        //retrieve sobject api name by splitting via \\.
                        String[] objectAPIFielseSetString = objectAPIString[index].trim().split('\\.');
                        //store value sobject apiname as key, fieldset api name as value
                        temp.put(objectAPIFielseSetString[0], objectAPIFielseSetString[1]);
                        System.debug('\n\n@@@@@[GETTER objectsFieldSetMap]{followedRecDTSetting}temp='+temp+'@@@@@\n\n');
                    }
                    objectsFieldSetMap = temp;
                }
                else
                {
                    //error
                    objectsFieldSetMap = new Map<String,String>(); 
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL, IMP_String_Utility.FOLLOWED_RECORDS_CUSTOM_SETTING_MISSING);
                    ApexPages.addMessage(errMsg);
                }                    
            }
            System.debug('\n\n@@@@@{GETTER objectsFieldSetMap]{objectsFieldSetMap}'+objectsFieldSetMap+'@@@@@\n\n');
            return objectsFieldSetMap;
        }
        set;
    }

    /**
     * @description The constructor of the class. Initializes variable values.
     * @author Jerick Laurio
     * @date 16.MAR.2015
     * @param N/A
     * @return N/A
     * @history 25.MAR.2015     Samuel Oberes       used IMP_Project_Utility's createSOQLSelect instead of this controller's local version
     *          07.APR.2015     Samuel Oberes       changed showFollowLink value to true
     */
    public IMP_FollowedRecords_Controller() 
    {
        populateWrapper();
    }

    /**
     * @description A method that populates the data wrapper
     * @author Jerick Laurio
     * @date 16.MAR.2015
     * @param N/A
     * @return String
     */
    public void populateWrapper()
    {
        Map<String, IMP_Library.genericDataTableAttributeWrapper> dataTableWrapperMap = new Map<String, IMP_Library.genericDataTableAttributeWrapper>();
        dataTableWrapper = new List<IMP_Library.genericDataTableAttributeWrapper>();
        //query method for getting all followed records of currently logged in user
        subscriptionList = [SELECT Id, NetworkId, ParentId, SubscriberId, Subscriber.Name, Parent.Name FROM EntitySubscription 
                            WHERE SubscriberId=:UserInfo.getUserId() ORDER BY ParentId LIMIT 100];
        objectIdMap = new Map<String, Set<Id>>();
        //iterate thru query results storing record ids per sobject
        for(EntitySubscription subscription : subscriptionList)
        {
            Id subscribeToObjId = subscription.ParentId;
            System.debug('*****[populateWrapper][CS_FollowedRecordsCC]subscribeToObjId='+subscribeToObjId+'*****\n\n');
            System.debug('*****[populateWrapper][CS_FollowedRecordsCC]getSobjectType='+subscribeToObjId.getSobjectType()+'*****\n\n');
            System.debug('*****[populateWrapper][CS_FollowedRecordsCC]ID describe='+subscribeToObjId.getSobjectType().getDescribe()+'*****\n\n');

            Set<Id> tempSet = new Set<Id>();
            String objectApiName = subscribeToObjId.getSobjectType().getDescribe().getName();
            if(objectIdMap.containsKey(objectApiName))
            {
                tempSet = objectIdMap.get(objectApiName);
            }
            tempSet.add(subscribeToObjId);
            objectIdMap.put(objectApiName, tempSet);
            
        }
        System.debug('*****[populateWrapper][CS_FollowedRecordsCC]objectIdMap='+objectIdMap+'*****\n\n');
        Integer counter = 1;
        //iterate thru objects to be displayed to populate a wrapper class that will be used for the generic data table component 
        for(String objectAPIdata : objectsToDisplayList)
        {
            System.debug('\n\n#####[populateWrapper] {dataTableWrapperMap} objectAPIdata='+objectAPIdata+'#####\n\n');
            String objectAPI = objectAPIdata.split('&#124;')[1];
            //retrieve sobject describe
            Schema.sobjectType sObjType = globalDescribeMap.get(objectAPI);
            Schema.Describesobjectresult dscribeObjResult = sObjType.getDescribe();
            System.debug('\n\n#####[populateWrapper] {dataTableWrapperMap} objectsFieldSetMap='+objectsFieldSetMap+'#####\n\n');
            Schema.FieldSet columnFieldSet = dscribeObjResult.FieldSets.getMap().get(String.valueOf(objectsFieldSetMap.get(objectAPI)).toLowerCase());
            System.debug('\n\n#####[populateWrapper] {dataTableWrapperMap} columnFieldSet='+columnFieldSet+'#####\n\n');
            //populate genericDataTableAttributeWrapper class
            IMP_Library.genericDataTableAttributeWrapper tableItem = new IMP_Library.genericDataTableAttributeWrapper();
            tableItem.index = Integer.valueOf(objectAPIdata.split('&#124;')[0]);
            tableItem.objectLabelName = dscribeObjResult.getLabel();
            tableItem.objectApiName = dscribeObjResult.getName();
            tableItem.objectIdPrefixCode = dscribeObjResult.getKeyPrefix();
            tableItem.objectEntityId = dscribeObjResult.getName();
            if(objectIdMap.containsKey(objectAPI))
            {

                tableItem.queryString = IMP_Project_Utility.createSOQLSelect(columnFieldSet, objectAPI);
                tableItem.whereClauseString = ' WHERE Id IN '+createStringIdSet(objectIdMap.get(objectAPI));
                tableItem.queryLimit = 1000;

                tableItem.showDebug = false;
                tableItem.showEditLink = false;
                tableItem.showNewButton = false;
                tableItem.showFollowLink = true;
                tableItem.selectable = false;
                tableItem.allowMultiSelect = false;
                tableItem.objectConsoleOpenInSubTab = false;
                tableItem.rowsPerPage = 5;//(Integer)dtUISetting.NumberOfRecordsPerObject__c;
                tableItem.tableColumnFieldsetName = String.valueOf(objectsFieldSetMap.get(objectAPI)).toLowerCase();
                tableItem.showFilterSection = false;
            }
                
            dataTableWrapperMap.put(objectAPIdata.split('&#124;')[0],tableItem);
        }

        //arranging objects based on index custom setting setup
        IMP_Library.genericDataTableAttributeWrapper[] indexedData = new IMP_Library.genericDataTableAttributeWrapper[]{};
        for(Integer index=0; index < dataTableWrapperMap.values().size(); index++)
        {
            indexedData.add(dataTableWrapperMap.get(String.valueOf(index)));
        }
        System.debug('\n\n#####[populateWrapper] {indexedData} ='+indexedData+'#####\n\n');
        dataTableWrapper = indexedData;
    }

     /**
     * @description A method that formats the set of ids for query string composition
     * @author Jerick Laurio
     * @date 16.MAR.2015
     * @param N/A
     * @return String
     */
    public String createStringIdSet(Set<Id> ids)
    {
        String returnString = '';
        for(Id recordId : ids)
        {
            if(returnString=='')
            {
                returnString = '(\''+ recordId+'\'';
            }
            else
            {
                returnString += ',\''+ recordId+'\'';
            }
        }
        returnString += ')';
        return returnString;
    }

    /**
     * @description A method that saves the currently selected tab object
     * @author Jerick Laurio
     * @date 16.MAR.2015
     * @param N/A
     * @return N/A
     */
    //@RemoteAction static
    public void saveUserDataTableSetting()
    {
        IMP_FollowedRecordsSetting__c profileDTSetting = IMP_FollowedRecordsSetting__c.getInstance();
        List<IMP_FollowedRecordsSetting__c> userDTSettingList = [SELECT SetupOwnerId, Name, Id, SobjectFieldsetPair__c, Selected_SObject__c 
                FROM IMP_FollowedRecordsSetting__c WHERE SetupOwnerId =:UserInfo.getUserId()];

        //String strIndex, String objectAPIName
        String strIndex = Apexpages.currentPage().getParameters().get('strIndex');
        selectedIndex = strIndex;
        String objectAPIName = '';
        //retrieve the default SObject item set up on custom setting
        for(IMP_Library.genericDataTableAttributeWrapper wrapper:dataTableWrapper)
        {
            if(wrapper.index == Integer.valueOf(strIndex))
            {
                objectAPIName = wrapper.objectAPIName;
                break;
            }
        }
        System.debug('\n\n#####[saveUserDataTableSetting] {strIndex} ='+strIndex+'#####\n\n');
        System.debug('\n\n#####[saveUserDataTableSetting] {objectAPIName} ='+objectAPIName+'#####\n\n');
        if(userDTSettingList.size()>0){
            IMP_FollowedRecordsSetting__c userDTSetting = userDTSettingList[0];
            userDTSetting.Selected_SObject__c = objectAPIName;
            update userDTSetting;
        }
        else{
            IMP_FollowedRecordsSetting__c userDTSetting = new IMP_FollowedRecordsSetting__c();
            userDTSetting.Name = 'IMP_FollowedRecordsDataTableSetting (User)';
            userDTSetting.SetupOwnerId = UserInfo.getUserId();
            userDTSetting.Selected_SObject__c = objectAPIName;
            userDTSetting.SobjectFieldsetPair__c = profileDTSetting.SobjectFieldsetPair__c;
            
            System.debug('\n\n#####[saveUserDataTableSetting] {userDTSetting} ='+userDTSetting+'#####\n\n');
            insert userDTSetting;
        }
        
    }

    /**
     * @description A method that creates a SOQL query string based on the field set and sobject setup on custom setting
     * @author Jerick Laurio
     * @date 16.MAR.2015
     * @param N/A
     * @return String
     * @history 25.MAR.2015     Samuel Oberes       commented out to force usage of IMP_Project_Utility's version
     */
    //public String createSOQLSelect(Schema.FieldSet fieldSetName, String objectAPIName)
    //{
    //    System.debug('\n\n#####[createSOQLSelect] objectAPIName='+objectAPIName+'#####\n\n');
    //    System.debug('\n\n#####[createSOQLSelect] fieldSetName='+fieldSetName+'#####\n\n');
    //    List<Schema.FieldSetMember> fieldSetMemberList = fieldSetName.getFields();
    //    String soqlSelectQueryString = 'SELECT Id';
    //    for(Schema.FieldSetMember fsetMember : fieldSetMemberList)
    //    {
    //        if(fsetMember.getFieldPath()!='Id')
    //        {
    //            soqlSelectQueryString += ', '+fsetMember.getFieldPath();
    //        }
    //    }
    //    soqlSelectQueryString += ' FROM '+objectAPIName;
    //    return soqlSelectQueryString;
    //}
}