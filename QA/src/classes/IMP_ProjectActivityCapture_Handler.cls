/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Project Activity Detail Capture handler which is used for the Project Activity Capture Batch job to process records 
1. Retrieve SubProject External Reference Ids of Open SubProjects
2. Retrieve Mapping Rules from Project Activity Detail Mapping Rule object
3. Generate query/ies to retrieve External Entity records
4. Map values on Project Activity based on External Entity records according to Mapping Rules from 2.
5. Return list of Project Activities for update to the Batchable class

Test Class: 
History
09/23/14    Michael Lasala      Created
09/24/14    Michael Lasala      Refactored to cater all record types scenario
10/07/14    Michael Lasala      Changed return to List<Project_Activity__c> to process records inside batch apex
03/31/15    Samuel Oberes       Replaced project activity references to project task
------------------------------------------------------------*/
public class IMP_ProjectActivityCapture_Handler{
    
    public List<Project_Task__c> IMP_ProjectActivityCapture_Handler(String recordTypeName, Set<Id> subProjectIds){
        
        List<Project_Task__c> tasksForUpdate = new List<Project_Task__c>();
        
        //Retrieve Ids of related SubProject External Reference records from the SubProject Id set
        system.Debug('******subProjectIds:' + subProjectIds.size());
        system.Debug('******recordTypeName:' + recordTypeName);
        Set<String> subProjectExternalReferenceIds = IMP_Project_Utility.retrieveSubProjectExternalReferences(subProjectIds, recordTypeName);
        System.debug('$$$ subProjectExternalReferenceIds: '+subProjectExternalReferenceIds.size());
        system.debug('$$$ subProjectIds' + subProjectIds);
        //Retrieve active Project Activity Detail Mapping Rule records based on Record Type/s
        List<Project_Activity_Detail_Mapping_Rule__c> activityDetailMappings = IMP_Project_Utility.projectActivityDetailsToCaptureFields(recordTypeName, true);
        System.debug('$$$ activityDetailMappings: '+activityDetailMappings.size());
        
        if(!activityDetailMappings.isEmpty()){
            
            //Used if Record Type is specified
            Set<String> sourceFieldNames = new Set<String>();
            String query;
            
            //Used if no Record Type is specified
            Map<String, set<String>> sourceFieldNamesMap = new Map<String, set<String>>();
            List<String> queryList = new List<String>();
            
            Map<String, String> fieldMetaMap = new Map<String, String>();
            
            List<sObject> captureDetailList = new List<sObject>();
            
            for(Project_Activity_Detail_Mapping_Rule__c padmr: activityDetailMappings){
                
                //Add all fields for building of query string
                if(recordTypeName != ''){
                    sourceFieldNames.add(padmr.Source_API_Field_Name__c.toLowerCase());
                    
                } else {
                    
                    //Per Record Type
                    if(sourceFieldNamesMap.containsKey(padmr.External_Entity_Type__c))
                    {
                    	
                        sourceFieldNamesMap.get(padmr.External_Entity_Type__c).add(padmr.Source_API_Field_Name__c.toLowerCase());
                        
                    } else {
                        
                        Set<String> tempSet = new Set<String>();
                        tempSet.add(padmr.Source_API_Field_Name__c);
                        sourceFieldNamesMap.put(padmr.External_Entity_Type__c, tempSet);
                    } 
                }
                system.debug('$$$ metaMap : ' +  padmr.Target_Unique_Act_Plus_Date_Type__c + ' - ' + padmr.Source_API_Field_Name__c);
                //Put key and value for identifying which Date field from the External Entity record will be used to map in the Project Activity record
                fieldMetaMap.put(padmr.Target_Unique_Act_Plus_Date_Type__c, padmr.Source_API_Field_Name__c.toLowerCase());
            }
            
            System.debug('$$$ sourceFieldNames: '+sourceFieldNames.size());
            System.debug('$$$ fieldMetaMap: '+fieldMetaMap.keySet());
            System.debug('$$$ sourceFieldNamesMap: '+sourceFieldNamesMap.keySet());
            
            //Generate single query if Record Type is specified
            // 2015-08-26 Kimiko Roberto - Added a check to the if statement to determine subProjectExternalReferenceIds size
            if(!sourceFieldNames.isEmpty() && subProjectExternalReferenceIds.size() > 0){
            system.Debug('******recordTypeName:' + recordTypeName);
            system.Debug('******sourceFieldNames:' + sourceFieldNames);  
            system.Debug('******subProjectExternalReferenceIds:' + subProjectExternalReferenceIds); 
            list<String> sourceFieldNamesList = new list<String>(sourceFieldNames);     
                //Generate query string based on parameters
                query = IMP_Project_Utility.generateQueryString(recordTypeName, sourceFieldNamesList, subProjectExternalReferenceIds);
                System.debug('$$$ ETO query:'+query);
                
                if(query != null){
                    
                    //Retrieve External Entity records related to SubProject External Reference Id set of passed Record Type
                    captureDetailList = Database.query(query);
                }
            } 
            
            //Generate multiple queries if Record Type is not specified
            // 2015-08-26 Kimiko Roberto - Added a check to the if statement to determine subProjectExternalReferenceIds size
            if(!sourceFieldNamesMap.keySet().isEmpty()  && subProjectExternalReferenceIds.size() > 0)
            {
            	map<string, list<string>> sourceFieldNamesListMap = new map<string, list<string>>();
            	for(string entityType:sourceFieldNamesMap.keySet())
            	{
            			sourceFieldNamesListMap.put(entityType, new list<String>(sourceFieldNamesMap.get(entityType)));
            	}    
                //Generate query string per record type
                queryList = IMP_Project_Utility.generateAllQueryStrings(sourceFieldNamesListMap, subProjectExternalReferenceIds);
                System.debug('$$$ queryList:'+queryList.size());
                if (queryList != null) {
                    System.debug('$$$ queryList >>> ' + queryList);
                }
                
                if(!queryList.isEmpty()){
                    
                    //Iterate over list of query strings (per Record Type)
                    for(String q: queryList){
                        
                        //===================================================================================
                        // QUERY IN LOOP: ASSUMPTION IS THAT RECORD TYPES WILL NOT REACH A SIGNIFICANT COUNT
                        //===================================================================================
                        
                        //Retrieve External Entity records related to SubProject External Reference Id set of each Record Type
                        List<sObject> tempDetailList = Database.query(q);
                        
                        if(!tempDetailList.isEmpty()){
                            
                            //Add all records to List<sObject>
                            for(sObject o: tempDetailList){
                                captureDetailList.add(o);
                            }
                        }
                    }
                }
            }
            
            System.debug('$$$ captureDetailList: '+captureDetailList.size());
            
            if(!captureDetailList.isEmpty()){
                
                Map<String, Date> sourceFieldValueMap = new Map<String, Date>();
                Map<Id, Map<String, Date>> sourceIdToFieldValueMap = new Map<Id, Map<String, Date>>();
                
                for(sObject o: captureDetailList){
                    
                    //Instantiate new map per sObject record
                    sourceFieldValueMap = new Map<String, Date>();
                    
                    if(!sourceFieldNames.isEmpty()){
                        
                        for(String s: sourceFieldNames){
                            system.debug('$$$ sourceFieldNames : ' + s + ' - ' + Date.valueOf(o.get(s)) + ' - ' + o.Id);
                            //Used for getting the actual dates from the external entity records
                            sourceFieldValueMap.put(s, Date.valueOf(o.get(s)));
                            
                            //Used for identifying each record's date field API names and actual dates based on record's Id
                            sourceIdToFieldValueMap.put(o.Id, sourceFieldValueMap);
                        }
                        
                    } 
                    
                    if(!sourceFieldNamesMap.keySet().isEmpty()){
                        
                        for(String recordType: sourceFieldNamesMap.keySet()){
                            
                            //Retrieve custom setting record per Record Type
                            IMP_ExternalReferenceRecordTypes__c customSetting = IMP_ExternalReferenceRecordTypes__c.getInstance(recordType);
                            
                            //Construct a new sObject based on custom setting's source object API name
                            sObject sObj = Schema.getGlobalDescribe().get(customSetting.Source_Object_API_Name__c).newSObject();
                            
                            //Compare iterated record's sObject type to sObj type
                            if(o.getSObjectType() == sObj.getSObjectType()){
                                
                                //Retrieve list of source fields based on Record Type
                                for(String s: sourceFieldNamesMap.get(customSetting.Name)){
                                    system.debug('$$$ sourceFieldNames 2 : ' + s + ' - ' + Date.valueOf(o.get(s)) + ' - ' + o.Id);
                                    //Used for getting the actual dates from the external entity records
                                    sourceFieldValueMap.put(s, Date.valueOf(o.get(s)));
                                    
                                    //Used for identifying each record's date field API names and actual dates based on record's Id
                                    sourceIdToFieldValueMap.put(o.Id, sourceFieldValueMap);
                                }
                            }
                        }
                        
                    }
                }
                
                System.debug('$$$ sourceFieldValueMap:'+sourceFieldValueMap.keySet());
                System.debug('$$$ sourceIdToFieldValueMap:'+sourceIdToFieldValueMap.keySet());
                //Process records
                tasksForUpdate = IMP_Project_Utility.processActivityDetails(subProjectIds, subProjectExternalReferenceIds, fieldMetaMap, sourceIdToFieldValueMap, recordTypeName);
            }
        }
        return tasksForUpdate;
    }   
}