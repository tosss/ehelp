/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Use in the mass update function in the milestone page
Test Class: IMP_MilestoneMassUpdateController_Test
History
02/11/15	Rey Austral			Created
------------------------------------------------------------*/
public class IMP_MilestoneMassUpdate_Controller 
{
    public Project_Milestone__c massUpdateMilestone { get; set; }
    public Project_Activity__c massUpdateActivity { get; set; }
    public Project_Task__c massUpdateTask { get; set; }
    public List<SelectOption> exIdList { get; set; }
    public List<SelectOption> siteOptionsList { get; set; }
    public Map<String,String> externalIdMap { get; set; }
    
    public IMP_MilestoneMassUpdate_Controller() 
    {
        siteValueOption();
        ExternalIds();
    }
    
    public void siteValueOption()
    {
        Id objectId = ApexPages.currentPage().getParameters().get('id');
        Map<String, String> optionsMap = new Map<String, String>();
        optionsMap.put('', '--None--');
        
        //Retrieve Sites related to SubProject in string format
        List<SubProjectSite__c> siteNamesList = IMP_Project_Utility.buildSiteNames(objectId);
        
        if(siteNamesList != null)
        {
            siteNamesList.sort();
            for(SubProjectSite__c s: siteNamesList)
            {
                optionsMap.put(s.Id, s.Account__r.Name);
            }
        }
        siteOptionsList = IMP_Project_Utility.buildSelectOption(optionsMap, false);
    }
    
    public void ExternalIds()
    {
        Id objectId = ApexPages.currentPage().getParameters().get('id');
        externalIdMap = new Map<String,String>();
        Map<String, String> optionsMap = new Map<String, String>();
        optionsMap.put('', '--None--');
        
        //Retrieve all records of Custom Setting
        Map<String, IMP_ExternalReferenceRecordTypes__c> externalReferencesSettings = IMP_ExternalReferenceRecordTypes__c.getAll();
        
        String query = 'SELECT ';
        
        if(!externalReferencesSettings.keySet().isEmpty())
        {
            
            List<String> externalReferenceRecordTypeNames = new List<String>();
            
            //Iterate over custom setting to get External Reference Partner Id and Record Type Name
            for(IMP_ExternalReferenceRecordTypes__c rt: externalReferencesSettings.values())
            {
                query += rt.Partner_Id__c+',';
                externalReferenceRecordTypeNames.add(rt.Name);
            }
            
            //Retrieve Record Type data
            Schema.DescribeSObjectResult resSchema = SubProject_External_Reference__c.sObjectType.getDescribe();
            Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();
            
            Set<Id> recordTypeIds = new Set<Id>();
            Map<Id, String> recordTypeMap = new Map<Id, String>();
            
            if(!externalReferenceRecordTypeNames.isEmpty())
            {
                for(String nameFromList: externalReferenceRecordTypeNames)
                {
                    for(String nameFromRecordTypeInfo: recordTypeInfo.keySet())
                    {
                        if(nameFromList == nameFromRecordTypeInfo)
                        {
                            //Add Record Type Id to set to be used as a filter in retrieving SubProject External Reference records
                            recordTypeIds.add(recordTypeInfo.get(nameFromList).getRecordTypeId());
                            
                            //Put Record Type Id as key and Name as value to be used for retrieving matching Id Field API Name for SubProject External Reference record
                            recordTypeMap.put(recordTypeInfo.get(nameFromList).getRecordTypeId(), nameFromList);
                        }
                    }
                }
                
                //Build SOQL query
                query += 'RecordTypeId, External_Entity_Name__c FROM '+IMP_Project_Utility.OBJECT_NAME_SUBPROJECT_EXTERNAL_REFERENCE+' WHERE '+IMP_Project_Utility.OBJECT_NAME_SUBPROJECT+' =: objectId  AND '+IMP_Project_Utility.FIELD_NAME_RECORDTYPEID+' IN: recordTypeIds';
                System.debug('debug$$ ' + query);
                //Retrieve SubProject External Reference records
                List<SubProject_External_Reference__c> subProjectExternalReferenceList = Database.query(query);
                
                if(!subProjectExternalReferenceList.isEmpty())
                {
                    for(SubProject_External_Reference__c er: subProjectExternalReferenceList)
                    {
                        //Get matching Id field of record's Record Type from Custom Setting
                        String matchingIdField = IMP_ExternalReferenceRecordTypes__c.getInstance(recordTypeMap.get(er.RecordTypeId)).Partner_Id__c;
                        
                        //Get value of matching Id field from record
                        optionsMap.put(String.valueOf(er.get(matchingIdField)), String.valueOf(er.External_Entity_Name__c));
                        externalIdMap.put(String.valueOf(er.get(matchingIdField)), String.valueOf(er.External_Entity_Name__c));
                    }
                }
            }
        }
        
        exIdList = IMP_Project_Utility.buildSelectOption(optionsMap, false);
    }    
    
}