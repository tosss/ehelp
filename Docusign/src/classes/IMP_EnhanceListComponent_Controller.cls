/*------------------------------------------------------------
Author:      Jerick Laurio
Company:     Cloud Sherpas
Description: [Phase 2 Rel 1] Controller responsible for supporting the IMP_EnhanceListTabComponent, 
                primarily providing data processing for the attributes passed onto the IMP_EnhanceListTabComponent component
Test Class:  
History
02/04/15     Jerick Laurio          Drafted
03/16/15     Jerick Laurio          Created
03/20/15     Jerick Laurio          Cleaned and refactored
------------------------------------------------------------*/
public class IMP_EnhanceListComponent_Controller
{
    
    IMP_ListViewDataSetting__c listViewSetting;

    /**
     * @description Custom Getter/Setter used to store current tab selection
     * @author Jerick Laurio
     * @date 16.MAR.2015
     * @param N/A
     * @return String
     * @history 04.FEB.2015     Jerick Laurio       Code Drafted
     *          16.MAR.2015     Jerick Laurio       Code Created
     */
    public String selectedIndex
    {
        get
        {
            if(selectedIndex==null)
            {
                //retrieve Custom Setting values
                listViewSetting = IMP_ListViewDataSetting__c.getInstance(UserInfo.getProfileId());
                if(listViewSetting == null)
                {
                    listViewSetting = IMP_ListViewDataSetting__c.getOrgDefaults();
                }
                //setting default seacted tab index
                selectedIndex='0';
                System.debug('\n\n@@@@@[GETTER selectedIndex] DEFAULT ='+selectedIndex+'@@@@@\n\n');
                //retrieve the default SObject item set up on custom setting
                for(IMP_Library.genericDataTableAttributeWrapper wrapper:dataTableWrapper)
                {
                    if(wrapper.objectApiName == listViewSetting.DefaultSObject__c)
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
     * @description Custom Getter/Setter used to store SObjects to be displayed the its standard list views
     * @author Jerick Laurio
     * @date 16.MAR.2015
     * @param N/A
     * @return List<IMP_Library.genericDataTableAttributeWrapper>
     * @history 04.FEB.2015     Jerick Laurio       Code Drafted
     *          16.MAR.2015     Jerick Laurio       Code Created
     */
    public List<IMP_Library.genericDataTableAttributeWrapper> dataTableWrapper 
    {
        get
        {
            if(dataTableWrapper==null)
            {
                Map<String, IMP_Library.genericDataTableAttributeWrapper> dataTableWrapperMap = new Map<String, IMP_Library.genericDataTableAttributeWrapper>();
                Map<String,Schema.Sobjecttype> globalDescribeMap = Schema.getGlobalDescribe();
                //iterate thru list of object to be displayed and wrapped it for display
                for(String objectAPIdata : objectsToDisplayList)
                {
                    System.debug('\n\n@@@@@[GETTER dataTableWrapper] {dataTableWrapperMap} objectAPIdata='+objectAPIdata+'@@@@@\n\n');
                    String objectAPI = objectAPIdata.split('&#124;')[1];
                    System.debug('\n\n@@@@@[GETTER dataTableWrapper] {dataTableWrapperMap} objectAPI='+objectAPI +'@@@@@\n\n');
                    //retrieve SOBject describe
                    Schema.sobjectType sObjType = globalDescribeMap.get(String.valueOf(objectAPI).toLowerCase());
                    Schema.Describesobjectresult dscribeObjResult = sObjType.getDescribe();
                    //populate wrapper class genericDataTableAttributeWrapper
                    IMP_Library.genericDataTableAttributeWrapper tableItem = new IMP_Library.genericDataTableAttributeWrapper();
                    tableItem.index = Integer.valueOf(objectAPIdata.split('&#124;')[0]);
                    tableItem.objectLabelName = dscribeObjResult.getLabel();
                    tableItem.objectApiName = dscribeObjResult.getName();
                    tableItem.objectIdPrefixCode = dscribeObjResult.getKeyPrefix();
                    tableItem.objectEntityId = dscribeObjResult.getName();
                    //store wrapped data setting index as key and wrapped data as value 
                    dataTableWrapperMap.put(objectAPIdata.split('&#124;')[0],tableItem);
                }

                //arranging wrapped data based on index for display order in component
                IMP_Library.genericDataTableAttributeWrapper[] indexedData = new IMP_Library.genericDataTableAttributeWrapper[]{};
                for(Integer index=0; index < dataTableWrapperMap.values().size(); index++)
                {
                    indexedData.add(dataTableWrapperMap.get(String.valueOf(index)));
                }
                //store indexed wrapped data list for componene use
                dataTableWrapper=indexedData;
            }

            System.debug('\n\n@@@@@[GETTER dataTableWrapper] {dataTableWrapper} ='+dataTableWrapper+'@@@@@\n\n');
            return dataTableWrapper;
        }
        set;
    }
    
    /**
     * @description Custom Getter/Setter used to retrieve objects from custom setting which will be displayed on the VF component
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
                //initialize Custom SEtting variable
                listViewSetting = IMP_ListViewDataSetting__c.getInstance(UserInfo.getProfileId());
                if(listViewSetting == null)
                {
                    listViewSetting = IMP_ListViewDataSetting__c.getOrgDefaults();
                }
                System.debug('\n\n@@@@@[GETTER objectsToDisplayList]{listViewSetting}'+listViewSetting+'@@@@@\n\n');
                List<String> temp = new List<String>();
               //check if Sobject setting was set up 
                if(listViewSetting.SObjectAPINames__c!=null)
                {
                    //retrieve SObject per new line
                    String[] objectAPIString = String.valueOf(listViewSetting.SObjectAPINames__c).split('\n'); 
                    //iterate thru the list
                    for(Integer index=0; index < objectAPIString.size(); index++)
                    {
                        //store retrieved data adding index for display arrangement
                        temp.add(index+'&#124;'+objectAPIString[index].trim());
                        System.debug('\n\n@@@@@[GETTER objectsToDisplayList]{listViewSetting}temp='+temp+'@@@@@\n\n');
                    }
                    objectsToDisplayList = temp;
                }
                else
                {
                    //error
                    objectsToDisplayList = new List<String>();
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 
                            IMP_String_Utility.ENHANCED_LIST_CUSTOM_SETTING_MISSING);
                    ApexPages.addMessage(errMsg);
                }                    
            }
            System.debug('\n\n@@@@@{GETTER objectsToDisplayList]{objectsToDisplayList}'+objectsToDisplayList+'@@@@@\n\n');
            return objectsToDisplayList;
        }
        set;
    }

    /**
     * @description The constructor of the class. Initializes variable values.
     * @author Jerick Laurio
     * @date 16.MAR.2015
     * @param N/A
     * @return N/A
     */
    public IMP_EnhanceListComponent_Controller()
    {
        //Constructor
    }
    
    /**
     * @description A method to update selected tab index variable which will be retrieved from URL parameter
     * @author Jerick Laurio
     * @date 16.MAR.2015
     * @param N/A
     * @return N/A
     */
    public void toggleTabItems()
    {
        selectedIndex = Apexpages.currentPage().getParameters().get('strIndex');
    }
}