/***********************************************************************************************************
*  2016-08-12 ragashalini.koka@cdk.com - RQ-07383 Created this class 
*  Description : Updates the fields based on the object 
*  History
*  2016-08-31 ragashalini.koka@cdk.com Added code to log the errors of the records which failed to process
*  2016-12-06 ragashalini.koka@cdk.com Added code to filter the records which are not effected
*  2017-05-17 - lalitha.adduru@cdk.com commented references to DESIGNATED_DSM_NAT_ENT__C as part of RQ-09180
* ***********************************************************************************************************/
global class ALL_Update_Email_Batch implements Database.Batchable<SObject>,Database.Stateful {
    
    global static final String currentClassName = 'ALL_Update_Email_Batch';
    global String query;
    public String processingObject;
    public String identifier;
    public Integer totalRecords;
    public Integer successfullyProcessedRecords;
    public Boolean logException;
    public List<Apex_Code_Exception__c> exceptionLogList;
    
    global ALL_Update_Email_Batch(String query, String identifier, Boolean logException) {
        //System.debug('batch class constructor');
        this.query = query;
        this.identifier = identifier;
        this.logException = logException;
        totalRecords = 0;
        successfullyProcessedRecords = 0;
        exceptionLogList = new List<Apex_Code_Exception__c>();
        //System.debug('formed query' + query);
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        //System.debug('batch job start');
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext context, List<SObject> resultsList ) {
        //System.debug('batch job execute');
        //System.debug('length of results list' + resultsList.size());
        
        if(resultsList.size() > 0) {
            exceptionLogList.clear();
          //  System.debug('results list : ' + resultsList);
            String objectName = resultsList[0].Id.getSobjectType().getDescribe().getName();
            processingObject = objectName;
            System.debug('objectName' + objectName);
            if(!objectName.equalsIgnoreCase('Order_Accuracy__c')) {
                resultsList = getData(objectName, resultsList);
            }
            else if(objectName.equalsIgnoreCase('Order_Accuracy__c')) {
                resultsList = updateOrderAccuracyEmailFields(resultsList);
            }
            
            
            List<Database.SaveResult> srList = Database.update(resultsList, false);
            totalRecords  += srList.size();
            for(Integer i = 0;i < srList.size(); i++) {
                Database.SaveResult sr  = srList[i];
                if(sr.isSuccess()) {
                    successfullyProcessedRecords++;
                }
                else {
                    //log the error
                    if(logException) {
                        for(Database.Error err : sr.getErrors()) {
                            Apex_Code_Exception__c codeException = new Apex_Code_Exception__c();
                            codeException.Name = String.valueOf(DateTime.now()) + Crypto.getRandomInteger();
                            codeException.User_Email__c = UserInfo.getUserEmail();
                            codeException.User_ID__c = UserInfo.getUserId();
                            codeException.User_Name__c = UserInfo.getUserName();
                            codeException.User_Timezone__c = String.valueOf(UserInfo.getTimeZone());
                            codeException.Time_of_Exception__c = DateTime.now();
                            codeException.Profile_ID__c = UserInfo.getProfileId();
                            codeException.Dml_ID__c = resultsList[i].Id;
                            codeException.Dml_Object_Type__c = resultsList[i].getSobjectType().getDescribe().getName();
                            codeException.isUpdate__c = true;
                            codeException.Exception_Type__c = 'System.DmlException';
                            codeException.Dml_Fields__c = String.join(err.getFields(), ',');
                            codeException.Dml_Status_Code__c = String.valueOf(err.getStatusCode());
                            codeException.Message__c = err.getMessage();
                            exceptionLogList.add(codeException);
                            
                        }
                    }
                }
            }
            
            if(exceptionLogList.size() > 0) {
                insert exceptionLogList;
            }
            
        }
        
        
    }
    
    public static List<SObject> updateOrderAccuracyEmailFields(List<SObject> resultsList) {
        Set<String> launchIdSet = new Set<String>();
        Set<String> caseIdSet = new Set<String>();
        Boolean isRecordModified = false;
        Set<Id> unModifiedRecordIdSet = new Set<Id>();
        
        for(SObject result : resultsList) {
            Object obj = result.get('Launch__c');
            if(obj != null) {
                launchIdset.add(String.valueOf(obj));
            }
            obj = result.get('Case__c');
            if(obj != null) {
                caseIdSet.add(String.valueOf(obj));
            }
        }
        
        Map<Id,Launch__c> launchMap = new Map<Id,Launch__c>([
            SELECT Id, Name, Account__c, 
            Account__r.DIGITAL_SERVICES_CAM__C, Account__r.DIGITAL_SERVICES_CAM__r.email, Account__r.Designated_DSM__c, 
            Account__r.Designated_DSM__r.Email, Account__r.Designated_DSM__r.ManagerId, Account__r.Designated_DSM__r.Manager.Email, 
            Account__r.Digital_Sales_Consultant__c, Account__r.Digital_Sales_Consultant__r.Email
            //Account__r.Designated_DSM_Nat_Ent__c, Account__r.Designated_DSM_Nat_Ent__r.Email, -- by lalitha
            //Account__r.Designated_DSM_Nat_Ent__r.ManagerId, Account__r.Designated_DSM_Nat_Ent__r.Manager.Email -- by lalitha
            FROM Launch__c
            WHERE Id IN :launchIdset
        ]);
        
        Map<Id,Case> caseMap = new Map<Id,Case>([
            SELECT Id, CaseNumber, AccountId, 
            Account.DIGITAL_SERVICES_CAM__C,Account.DIGITAL_SERVICES_CAM__r.email,Account.Designated_DSM__c, 
            Account.Designated_DSM__r.Email, Account.Designated_DSM__r.ManagerId, Account.Designated_DSM__r.Manager.Email, 
            Account.Digital_Sales_Consultant__c, Account.Digital_Sales_Consultant__r.Email
            //Account.Designated_DSM_Nat_Ent__c, Account.Designated_DSM_Nat_Ent__r.Email, -- by lalitha
            //Account.Designated_DSM_Nat_Ent__r.ManagerId, Account.Designated_DSM_Nat_Ent__r.Manager.Email -- by lalitha
            FROM Case
            WHERE Id IN :caseIdSet
        ]);
        
        for(SObject result : resultsList) {
            Launch__c currentLaunch = launchMap.get(String.valueOf(result.get('Launch__c')));
            Case currentCase = caseMap.get(String.valueOf(result.get('Case__c')));
            Account orderAccuracyAccount = null;
            isRecordModified = false;
            if(currentLaunch != null && currentLaunch.Account__c != null) {
                orderAccuracyAccount = (Account) currentLaunch.Account__r;
            }
            if(orderAccuracyAccount == null && currentCase != null && currentCase.Account != null) {
                orderAccuracyAccount = (Account) currentCase.Account;
            }
            
            if(orderAccuracyAccount == null) {
                if(result.get('DSM_Email__c') != null) {
                    result.put('DSM_Email__c', null);
                    isRecordModified = true;
                }
                if(result.get('DSC_Email__c') != null) {
                    result.put('DSC_Email__c', null);
                    isRecordModified = true;
                }
                if(result.get('DSM_DOS_Email') != null) {
                    result.put('DSM_DOS_Email__c', null);
                    isRecordModified = true;
                }
                if(result.get('DSM_Nat_Ent_Email__c') != null) {
                    result.put('DSM_Nat_Ent_Email__c', null);
                    isRecordModified = true;
                }
            }
            else {
                if(orderAccuracyAccount.Designated_DSM__c != null && orderAccuracyAccount.Designated_DSM__r.Email != null 
                   && result.get('DSM_Email__c') != null && result.get('DSM_Email__c') != orderAccuracyAccount.Designated_DSM__r.Email) {
                    result.put('DSM_Email__c', orderAccuracyAccount.Designated_DSM__r.Email);
                    isRecordModified = true;
                }
                if(orderAccuracyAccount.Digital_Sales_Consultant__c != null && orderAccuracyAccount.Digital_Sales_Consultant__r.Email != null 
                   && result.get('DSC_Email__c') != null && result.get('DSC_Email__c') != orderAccuracyAccount.Digital_Sales_Consultant__r.Email) {
                    result.put('DSC_Email__c', orderAccuracyAccount.Digital_Sales_Consultant__r.Email);
                    isRecordModified = true;
                }
                if(orderAccuracyAccount.Designated_DSM__c != null && orderAccuracyAccount.Designated_DSM__r.ManagerId != null
                   && OrderAccuracyAccount.Designated_DSM__r.Manager.Email != null && result.get('DSM_DOS_Email__c') != null 
                   && result.get('DSM_DOS_Email__c') != orderAccuracyAccount.Designated_DSM__r.Manager.Email) {
                       result.put('DSM_DOS_Email__c', orderAccuracyAccount.Designated_DSM__r.Manager.Email);
                       isRecordModified = true;
                   }
                /*if(orderAccuracyAccount.Designated_DSM_Nat_Ent__c != null && orderAccuracyAccount.Designated_DSM_Nat_Ent__r.Email != null 
                   && result.get('DSM_Nat_Ent_Email__c') != null && result.get('DSM_Nat_Ent_Email__c') != orderAccuracyAccount.Designated_DSM_Nat_Ent__r.Email) {
                       result.put('DSM_Nat_Ent_Email__c', orderAccuracyAccount.Designated_DSM_Nat_Ent__r.Email);
                       isRecordModified = true;
                   }*/
                
            }
            
            if(!isRecordModified) {
                unModifiedRecordIdSet.add(String.valueOf(result.get('Id')));
            }
            
        }
        
        return getValues(resultsList, unModifiedRecordIdSet);
    }
    global void finish(Database.BatchableContext context) {
        //System.debug('batch job finish');
        //System.debug('finished processing ' +  processingObject);
        
        if(context != null) {
            
            
            Update_Email_Fields__c updateEmailObj = Update_Email_Fields__c.getValues(identifier);
            updateEmailObj.Last_Run_Batch_Id__c = context.getJobId();
            updateEmailObj.Last_Run_Date__c = System.today();
            updateEmailObj.Total_Records_Processed_In_Last_Run__c = totalRecords;
            updateEmailObj.Successfully_Processed_In_Last_Run__c = successfullyProcessedRecords;
            update updateEmailObj;
            
            Boolean sendBatchCompleteMail = true;
            Map<Id,Update_Email_Fields__c> batchIdMap = new Map<Id,Update_Email_Fields__c>();
            
            for(Update_Email_Fields__c updateEmailRef : Update_Email_Fields__c.getAll().values()) {
                if(updateEmailRef.Run_Batch__c) {
                    if(updateEmailRef.Last_Run_Batch_Id__c == null) {
                        sendBatchCompleteMail = false;
                        batchIdMap.clear();
                        break;
                    }
                    else {
                        
                        batchIdMap.put(updateEmailRef.Last_Run_Batch_Id__c,updateEmailRef);
                    }
                }
            }
            if(batchIdMap.size() > 0) {
                sendEmail(batchIdMap);
            }
            
            
        }
        
        
    }
    
    private void sendEmail(Map<Id,Update_Email_Fields__c> batchIdMap) {
        
       // System.debug('send mail start');
        Job_Settings__c jobSettingRef = null;
        Map<String, Job_Settings__c> allJobSettingsMap = Job_Settings__c.getAll();
        
        if(allJobSettingsMap != null && !allJobSettingsMap.isEmpty()) 
        {
            for(Job_Settings__c jobSettings: allJobSettingsMap.values())
            { 
                if(jobSettings.Class_Name__c == currentClassName)
                {
                    jobSettingRef = jobSettings;
                } 
            }
        }
        
        if(jobSettingRef != null) {
            
            List<AsyncApexJob> batchJobs=[
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedDate,
                ExtendedStatus, CompletedDate
                FROM AsyncApexJob 
                WHERE Id IN :batchIdMap.keySet()  
            ];
            String style = '<style media="all" type="text/css">'
                + 'table {border-collapse: collapse;}'
                + 'table,td,th {border: 1px solid #ddd;font-size:14px;font-family:initial;}'
                + 'th,td {padding: 10px;text-align: left;}'
                + 'th {background-color:"#64d437";color:white;}'
                + '</style>';
            
            String msg = '<div style="overflow-x:auto;"><table>'
                +'<caption style="font-weight:bold;color:white;font-size:16px;">Batch Jobs Summary</caption>'
                + '<tr><th>Object</th>'
                + '<th>Job Start Date and Time</th>'
                + '<th>Job End Date and Time</th>'
                + '<th>Job Executed User</th>'
                + '<th>Job Status</th>'  
                + '<th>Records Successfully Processed</th>'
                + '<th>Records Failed To Process</th>'
                + '<th>Total Records Processed</th>'                  
                + '</tr>';
            
            for(AsyncApexJob job : batchJobs) {
                
                msg += '<tr><td> ' + batchIdMap.get(job.Id).Object_API_Name__c +'</td>'
                    + '<td>' + job.CreatedDate.format('MM/dd/yyyy K:mm:ss:SS a, z') +'</td>'
                    + '<td>' + job.CompletedDate.format('MM/dd/yyyy K:mm:ss:SS a, z') +'</td>'
                    + '<td>' + Userinfo.getName()+ ' ( '+UserInfo.getUserName()+' )' + '</td>'
                    + '<td>' + job.Status + '</td>'
                    + '<td>' + batchIdMap.get(job.Id).Successfully_Processed_In_Last_Run__c.round() + '</td>'
                    + '<td>' + (batchIdMap.get(job.Id).Total_Records_Processed_In_Last_Run__c.round() - batchIdMap.get(job.Id).Successfully_Processed_In_Last_Run__c).round() + '</td>'
                    + '<td>' + batchIdMap.get(job.Id).Total_Records_Processed_In_Last_Run__c.round() + '</td>'
                    + '</tr>';
            }   
            
            msg += '</table></div>';
            msg = style + msg;
            ALL_UtilitiesBatch.Logger log = new ALL_UtilitiesBatch.Logger();
            
            log.batchId = new List<Id>(batchIdMap.keySet())[0];
            log.title = currentClassName;
            log.description = 'Finished Updating Email fields in Records of ' + processingObject ;
            log.message = msg;
            log.processingLog = msg;
            ALL_UtilitiesBatch.finish(currentClassName, log);
            //System.debug('send mail stop');
        }
        
    }
    
    //fetches the values to be populated for the corresponding fields
    public static List<SObject> getData(String objectName, List<SObject> resultsList) {
        //stores the set of Ids which has atleast one not null email value
        Set<Id> filteredIdSet = new Set<Id>(); 
        
        try {
            Map<Id,SObject> sobjectMap = new Map<Id,SObject>();
            Map<String,Set<String>> referenceObjectToFieldsMap = getFieldsOfObjects(objectName, 'Reference_Object__c','Reference_Field__c');
            Map<String,Set<String>> sourceObjectToSourceFieldMap = getFieldsOfObjects(objectName, 'Object_API_Name__c','Source_Field__c'); 
            Map<String,Set<Id>> referenceObjectToIdList = new Map<String,Set<Id>>();
            for(SObject result : resultsList) {
                
                for(String fieldName : sourceObjectToSourceFieldMap.get(objectName)) {
                    String fieldValue = String.valueOf(result.get(fieldName));
                    if(fieldValue != null) {
                        String fieldValueObj  = Id.valueOf(fieldValue).getSObjectType().getDescribe().getName();
                        if(!referenceObjectToIdList.containsKey(fieldValueObj)) {
                            referenceObjectToIdList.put(fieldValueObj, new Set<Id>());
                        }
                        Set<Id> referenceValueSet = referenceObjectToIdList.get(fieldValueObj);
                        referenceValueSet.add(fieldValue);
                        referenceObjectToIdList.put(fieldValueObj, referenceValueSet);
                        filteredIdSet.add(String.valueOf(result.get('Id')));
                    }
                }
                
                
            }
            
            for(String obj : referenceObjectToFieldsMap.keySet()) {
                Set<Id> objectIdSet = referenceObjectToIdList.get(obj);
                if(objectIdSet != null) {
                    Set<String> fieldSet = referenceObjectToFieldsMap.get(obj);
                    fieldSet.add('Name');
                    String query = ALL_UpdateEmail_Controller.buildQuery(obj, null, 'Id IN :objectIdSet', new List<String>(fieldSet)); 
                    
                    List<SObject> result = Database.query(query);
                    
                    if(result != null) {
                        sobjectMap.putAll(result);
                    }
                }
            }
            System.debug('calling populate data');
            
            /* Map<Id,SObject> resultMap = new Map<Id,SObject>(resultsList);
Set<Id> allIdSet = resultMap.keySet();
Set<Id> IdsToRemove = allIdSet.clone();
IdsToRemove.removeAll(filteredIdSet);
System.debug('IdsToRemove' + IdsToRemove);
allIdSet.removeAll(IdsToRemove);
resultsList = resultMap.values();*/
            
            resultsList = populateData(resultsList, sobjectMap, objectName);
            
        }
        catch(Exception exp) {
            System.debug('exp' + exp.getLineNumber() + exp.getMessage());
        }
        return resultsList;
    } 
    
    //records are populated with the new values
    public static List<SObject> populateData(List<SObject> resultsList, Map<Id,SObject> sobjectMap, String objectName) {
        
        List<SObject> filteredList = filterCustomSettings('Object_API_Name__c', objectName);
        Map<String,String> destToSrcFieldMap = generateFieldMap(filteredList, 'Destination_Field__c', 'Source_Field__c');
        Map<String,String> destToRefFieldMap = generateFieldMap(filteredList, 'Destination_Field__c', 'Reference_Field__c');
        // System.debug('in populate data' + destToSrcFieldMap);
        Boolean isRecordModified = false;
        Set<Id> unModifiedRecordIdSet = new Set<Id>();
        for(SObject result : resultsList) {
            isRecordModified = false;
            for(String field : destToSrcFieldMap.keySet()) {
                String fieldValue = String.valueOf(result.get(destToSrcFieldMap.get(field)));
                
                if(fieldValue != null) {
                    try {
                        if( !String.valueOf(ALL_UtilitiesData.GetDataFromNestedFields('Name', sobjectMap.get(fieldValue))).containsIgnoreCase('retired')) {
                            Object value = ALL_UtilitiesData.GetDataFromNestedFields(destToRefFieldMap.get(field), sobjectMap.get(fieldValue));
                            //System.debug('field name : ' + field);
                            Object previousValue = result.get(field);
                            if(previousValue != null && previousValue != String.valueOf(value)) {
                                isRecordModified = true;
                                result.put(field, String.valueOf(value));
                            }
                        }
                        else {
                            if(String.valueOf(ALL_UtilitiesData.GetDataFromNestedFields('Name', sobjectMap.get(fieldValue))).containsIgnoreCase('retired')) {
                                 Object previousValue = result.get(field);
                                if(previousValue != null) {
                                    isRecordModified = true;
                                    result.put(field, null);
                                }
                            }
                          
                        }
                    }
                    catch(Exception e) {
                        // System.debug('in catch block' + e.getMessage() + e.getLineNumber() );
                        isRecordModified = true;
                        result.put(field, null);
                    }
                }
            }
            if(!isRecordModified) {
                unModifiedRecordIdSet.add(String.valueOf(result.get('Id')));
            }
        }
        
        // System.debug('result List' + resultsList);
        
        //System.debug('unmodified record Ids :' + unModifiedRecordIdSet);
        //System.debug('allIdSet :' + allIdSet + 'results List' + resultsList);  
        return getValues(resultsList, unModifiedRecordIdSet);
        
    }
    
    //removes the set of records that are not modified and prevents them from updating
    private static List<SObject> getValues(List<SObject> resultsList, Set<Id> unModifiedIdSet) {
        Map<Id,SObject> resultMap = new Map<Id,SObject>(resultsList);
        Set<Id> allIdSet = resultMap.keySet();
        allIdSet.removeAll(unModifiedIdSet);
        return resultMap.values();
    }
    
    
    private static List<SObject> filterCustomSettings(String fieldAPI, String value) {
        List<SObject> customSettingsDataList = Update_Email_Fields_Data__c.getAll().values();
        List<SObject> filteredDataList = new List<SObject>();
        
        for(SObject data : customSettingsDataList) {
            
            if(doesValueMatch(data, fieldAPI, value)) {
                filteredDataList.add(data);
            }
        } 
        
        return filteredDataList;
    }
    
    private static Map<String,String> generateFieldMap(List<SObject> dataList, String key, String value) {
        
        Map<String,String> srcToDestFieldMap = new Map<String,String>();
        
        for(SObject data : dataList) {
            srcToDestFieldMap.put(String.valueOf(data.get(key)), String.valueOf(data.get(value)));
        }
        
        return srcToDestFieldMap;
    }
    
    private static Map<String,Set<String>> getFieldsOfObjects(String objectName, String key, String value) {
        Map<String,Set<String>> objectToFieldsMap = new Map<String,Set<String>>();
        List<SObject> customSettingsDataList = Update_Email_Fields_Data__c.getAll().values();
        List<SObject> resultsList = filterCustomSettings('Object_API_Name__c', objectName);
        
        for(SObject result : resultsList) {
            String referenceObj = String.valueOf(result.get(key));
            if(!objectToFieldsMap.containsKey(referenceObj)) {
                objectToFieldsMap.put(referenceObj, new Set<String>());
            }
            Set<String> fieldsList =  objectToFieldsMap.get(referenceObj);
            fieldsList.add(String.valueof(result.get(value)));
            objectToFieldsMap.put(referenceObj, fieldsList);
            
        }
        return objectToFieldsMap;
    }
    
    private static Boolean doesValueMatch(SObject data, String fieldAPI, String value) {
        //using equals will give error if the retrieved value is null
        if(String.valueOf(data.get(fieldAPI)) == value) {
            return true;
        }
        return false;
    }
}