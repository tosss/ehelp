public class ALL_CreateTask_Helper 
{ 
    public static map<string, string> FieldNamesMap;
    public static map<string, string> FieldValuesMap;
    
    public ALL_CreateTask_Helper()
    {
        map<string, map<string, string>> FieldValuesOrganizedMap = ALL_UtilitiesData.OrganizeFieldValueConditionsInaMap();        
        
        FieldNamesMap = FieldValuesOrganizedMap.get('FieldNames');
        FieldValuesMap = FieldValuesOrganizedMap.get('FieldValues'); 
        
    }    
    
    public static map<string, map<string, list<Create_Task_Settings__c>>> TaskCustomSettingDataProcesser(
        map<string, map<string, list<Create_Task_Settings__c>>> TaskMap, string sObjectType)
    {
        List<Create_Task_Settings__c> CTSsettings = Create_Task_Settings__c.getAll().values();
        
        for(Create_Task_Settings__c cts: CTSsettings)
        {            
            if(cts.sObject__c.toLowerCase() == sObjectType.toLowerCase())
            {
                if(cts.Record_Type__c != null)
                {
                    map<string, list<Create_Task_Settings__c>> InnerTaskMap = TaskMap.get(cts.Record_Type__c);
                    if(InnerTaskMap == null){ InnerTaskMap = new map<string, list<Create_Task_Settings__c>>();}
                    
                    if(cts.Task_Subject_Type__c != null)
                    {                        
                        list<Create_Task_Settings__c> TaskQuote = InnerTaskMap.get(cts.Task_Subject_Type__c);
                        if(TaskQuote == null){ TaskQuote = new list<Create_Task_Settings__c>();}
                        TaskQuote.add(cts);
                        InnerTaskMap.put(cts.Task_Subject_Type__c, TaskQuote);
                        TaskMap.put(cts.Record_Type__c, InnerTaskMap);
                    }                                    
                }               
            }
        }        
        return TaskMap;
    }    
    
    public static List<Task> CreateTasksForAnySobject(map<ID, sObject> newsObjectMap, map<ID, sObject> oldsObjectMap)
    {  
        map<ID, map<string, boolean>> booleanMapToCreateTask = booleanMapToCreateTask(newsObjectMap);       
        Map<string, list<sObject>> RecordTypeTosObjectRecords = new Map<string, list<sObject>>();
        RecordTypeTosObjectRecords = ALL_UtilitiesDescribe.RecordTypeTosObjects(newsObjectMap.values());
        map<ID, sObject> closeCompletedRecordsMap = new map<ID, sObject>();
        boolean closeCompletedTasks = false;
        
        //system.debug(RecordTypeTosObjectRecords);
        
        // get all the custom settings for Laser approval Process 
        List<Create_Task_Settings__c> CreateTaskSettings = Create_Task_Settings__c.getAll().values();
        
        map<string, map<string, list<Create_Task_Settings__c>>> TaskMap = new  map<string, map<string, list<Create_Task_Settings__c>>>();
        //template: {'RecordType' => { 'Task Subject' => list<('Order Type', 'Order Status')>}}
        //ex: {'RecordType' => { 'Quote Follow Up' => list<('Buy Sell Elite', 'Artwork to LFD Team')>}}
        
        map<string, map<string, string>> FieldValuesOrganizedMap = new map<string, map<string, string>>();
        
        string sObjectType = ALL_UtilitiesDescribe.sObjectTypeFinder(newsObjectMap.values()[0]);
        
        TaskMap = ALL_CreateTask_Helper.TaskCustomSettingDataProcesser(TaskMap, sObjectType); system.debug(TaskMap);
                
        system.debug(FieldValuesOrganizedMap);
        system.debug(FieldNamesMap);
        system.debug(FieldValuesMap);
        
        List<Task> TobeInsertedTaskList = new List<Task>();
        
        if(RecordTypeTosObjectRecords != null && !RecordTypeTosObjectRecords.isEmpty())
        {
            for(string recordType: RecordTypeTosObjectRecords.keySet())
            {
                List<sObject> CurrentsObjectList = RecordTypeTosObjectRecords.get(recordType); 
                
                map<string, list<Create_Task_Settings__c>> TempInnerTaskMap = TaskMap.get(recordType); 
                
                system.debug(Trigger.isInsert + '---' + TempInnerTaskMap);
                
                if(CurrentsObjectList != null && !CurrentsObjectList.isEmpty())
                {
                    for(sObject sObj: CurrentsObjectList) 
                    { 
                        sObject olderVersionObj = oldsObjectMap.get(sObj.ID);
                        
                        map<string, boolean> currentRecordbooleanMapToCreateTask = booleanMapToCreateTask != null ? booleanMapToCreateTask.get(sObj.ID) : new map<string, boolean>();
                        
                        system.debug(currentRecordbooleanMapToCreateTask);
                                                
                        if(TempInnerTaskMap != null && !TempInnerTaskMap.isEmpty())
                        {                                
                            for(string SubjectOfTask: TempInnerTaskMap.keySet())
                            {                                
                                List<Create_Task_Settings__c> CTSList = TempInnerTaskMap.get(SubjectOfTask);
                                
                                system.debug(SubjectOfTask);
                                system.debug(CTSList);
                                
                                if(CTSList != null && !CTSList.isEmpty())
                                {
                                    for(Create_Task_Settings__c cts: CTSList)
                                    {   
                                        Boolean ValuesMatch = ALL_CreateTask_Helper.CompareTheValues(cts.Identifier__c, sObj);
                                        boolean fieldValuesChanged = false;
                                        System.debug('valuematch' + ValuesMatch);
                                        if(olderVersionObj != null)
                                        {
                                            fieldValuesChanged = allFieldValuesComparison(cts.Identifier__c, sObj, oldsObjectMap.get(sObj.ID));
                                        }
                                        
                                        
                                        if(cts.Close_Completed_Tasks__c && Trigger.isUpdate)
                                        { 
                                            closeCompletedRecordsMap.put(sObj.ID, sObj);
                                            closeCompletedTasks = true;
                                        }
                                        
                                        if(ValuesMatch)
                                        { System.debug('values match' + Trigger.isInsert + fieldValuesChanged + cts.Close_Completed_Tasks__c + cts.Name);
                                            if(Trigger.isInsert || fieldValuesChanged)                                                
                                            {System.debug('inside values match' + cts.Close_Completed_Tasks__c);
                                                boolean createTask = true;
                                                
                                                system.debug(SubjectOfTask);
                                                system.debug(currentRecordbooleanMapToCreateTask);
                                                
                                                if(cts.Close_Completed_Tasks__c)
                                                {
                                                    if(currentRecordbooleanMapToCreateTask == null || currentRecordbooleanMapToCreateTask.isEmpty())
                                                    {
                                                        createTask = true;
                                                    }
                                                    else if(currentRecordbooleanMapToCreateTask.get(SubjectOfTask) == null)
                                                    {
                                                        createTask = true;
                                                    }
                                                    else if(currentRecordbooleanMapToCreateTask.get(SubjectOfTask))
                                                    {
                                                        createTask = true;
                                                    }
                                                    else
                                                    {
                                                        createTask = false;
                                                    }
                                                }
                                                
                                                system.debug(createTask);
                                                
                                                if(createTask)
                                                {
                                                    TobeInsertedTaskList = ALL_CreateTask_Helper.CreateTask(sObj, Cts, SubjectOfTask, TobeInsertedTaskList);
                                                }
                                            }                                                                             
                                        }
                                    }
                                }
                            }                               
                        }                      
                    }
                }//end of the trigger.new for loop                
            }
        } 
        
        if(closeCompletedTasks)
        {
            DS_LAO_ApprovalProcess.updateTasks(closeCompletedRecordsMap.values(), oldsObjectMap);
        }
        
        return TobeInsertedTaskList;
    }
    
    public static List<Task> CreateTask(sObject sObj, Create_Task_Settings__c Cts, String SubjectOfTask, List<Task>TobeInsertedTaskList)
    {
        system.debug(Cts); system.debug(SubjectOfTask);
        Date ActivityDate;
        
        if(cts != null && cts.Reference_Date__c != null)
        {
            if(cts.Reference_Date__c == 'Today')
            {
                ActivityDate = Date.Today();
            }
            else
            {
                ActivityDate = (Date)sObj.get(cts.Reference_Date__c);
            }
        }
        
        Integer BusinessDays;
        
        if(cts != null && cts.BusinessDays__c != null && cts.BusinessDays__c != 'Special Condition')
        {
            BusinessDays = Integer.ValueOf(cts.BusinessDays__c);
            
            ActivityDate = ActivityDate.addDays(ALL_UtilitiesDate.BusinessDaysCounter(
                ActivityDate, BusinessDays, 'Laser Holiday'));
        }
        if(cts != null && cts.BusinessDays__c == 'Special Condition')
        { 
            if(Cts.Number_of_Weeks__c != null && Cts.Week_Day__c != null && cts.Reference_Date__c != null)
            {
                ActivityDate = ALL_UtilitiesDate.CalculateWeekDay(
                    (Date)sObj.get(cts.Reference_Date__c), Integer.valueOf(Cts.Number_of_Weeks__c), Cts.Week_Day__c);               
            }
        }
        
        Task t = new Task();
        t.WhatId = sObj.Id;
        if(cts != null && cts.Who__c != null && sObj.get(cts.Who__c) != null) { t.WhoId = (ID)sObj.get(cts.Who__c); }
        t.ActivityDate = ActivityDate;
        t.Subject = SubjectOfTask;
        
        if(cts != null && ALL_UtilitiesDescribe.sObjectTypeFinder(sObj) == cts.Assignee_sObject__c)
        {
            t.OwnerId = sObj.get(cts.Assigned_to__c) !=null ? 
                (ID)sObj.get(cts.Assigned_to__c) : userInfo.getUserId();
        }
        
        TobeInsertedTaskList.add(t);
        
        return TobeInsertedTaskList;        
    } 
    
    public static boolean CompareTheValues(String IdentifierString, sObject sObj)
    {
         // for intializing the variable values in the constructor.
        ALL_CreateTask_Helper ClassInstance = new ALL_CreateTask_Helper();
        boolean ValuesMatch = null;
        System.debug('sobject is' + sobj); 
        list<string> Values = new list<string>();
        if(IdentifierString != null && IdentifierString.contains('AND'))
        {
            Values = IdentifierString.split('AND');
        }
        else 
        {
            Values.add(IdentifierString);
        }
        set<string> FieldValuesSetFromCustomSettings = new set<string>();
        set<string> FieldValuesOnCurrentRecord = new set<string>();
        
        system.debug(Values + 'sobject is' + sobj);
        
        if(Values != null && !Values.isEmpty())
        {
            for(string s: Values)
            {    
                s = s!= null?s.normalizeSpace():s;
                FieldValuesSetFromCustomSettings.add(FieldValuesMap.get(s));
                
                //system.debug(s);
                //system.debug(FieldNamesMap);
                system.debug(FieldNamesMap.get(s));
                //system.debug(sObj);
                //system.debug(sObj.get(FieldNamesMap.get(s)));
                
                if(FieldNamesMap.get(s) != null)
                {
                    if(FieldValuesMap.get(s).equalsIgnoreCase('not null') && 
                       sObj.get(FieldNamesMap.get(s)) != null)
                    {
                        FieldValuesOnCurrentRecord.add('Not Null');
                    }
                    else if(FieldValuesMap.get(s).equalsIgnoreCase('null') && 
                            string.valueOf(sObj.get(FieldNamesMap.get(s))) == null)
                    {
                        FieldValuesOnCurrentRecord.add('Null');
                    }
                    else
                    {
                        FieldValuesOnCurrentRecord.add(string.ValueOf(sObj.get(FieldNamesMap.get(s))));
                    }
                }
            }
        }
        
        system.debug('test' + FieldValuesSetFromCustomSettings);
        system.debug('test' + FieldValuesOnCurrentRecord);
        system.debug('test'+ FieldValuesOnCurrentRecord.equals(FieldValuesSetFromCustomSettings));
        
        ValuesMatch = !FieldValuesOnCurrentRecord.isEmpty() && FieldValuesOnCurrentRecord.equals(FieldValuesSetFromCustomSettings);
        
        return ValuesMatch;
    }
    
    public class ApprovalProcessResultPackage
    {
        public Approval.ProcessResult[] ApprovalProcessResults;
        public map<ID, sObject> ApprovalSubmittedRecords;
    }
    
    public static ApprovalProcessResultPackage ApprovalProcessMethod(List<sObject> newRecords, List<sObject> oldRecords)
    {  
        ALL_CreateTask_Helper.ApprovalProcessResultPackage ApprovalResultsInstance = new ALL_CreateTask_Helper.ApprovalProcessResultPackage();
        
        Map<string, list<sObject>> RecordTypeToRecords = new Map<string, list<sObject>>();
        RecordTypeToRecords = ALL_UtilitiesDescribe.RecordTypeTosObjects(newRecords);
        string currentsObjectType = ALL_UtilitiesDescribe.sObjectTypeFinder(newRecords[0]);
        Approval.ProcessResult[] ApprovalProcessResults = null;
        
        // Below query gets details of the record that was submitted for approval
        List<ProcessInstance> ProcessInstances = new list<ProcessInstance>([
            Select Id, Status, ProcessDefinitionId, TargetObjectId, CompletedDate, LastActor.Name 
            From ProcessInstance 
            Where TargetObjectId 
            IN :newRecords 
        ]);
        system.debug('process instances' + ProcessInstances);
        //map<Lao.Id, list<ProcessInstance>>
        Map<Id, list<ProcessInstance>> ProcessInstanceMap = new Map<Id, list<ProcessInstance>>();
        
        if(ProcessInstances != null && !ProcessInstances.isEmpty())
        {   
            for(ProcessInstance pi : ProcessInstances)
            { 
                list<ProcessInstance> CurrentProcessInstanceList = ProcessInstanceMap.get(pi.TargetObjectId);
                
                if(CurrentProcessInstanceList == null)
                {
                    CurrentProcessInstanceList = new list<ProcessInstance>(); 
                }
                
                CurrentProcessInstanceList.add(pi);
                ProcessInstanceMap.put(pi.TargetObjectId, CurrentProcessInstanceList); 
              
            }
        }
        system.debug('process instance map' + ProcessInstanceMap);
        map<string, list<ALL_Approval_Process__c>> SubmitApprovalSettingsListToRecordType = new map<string, list<ALL_Approval_Process__c>>();
        // get all the custom settings for Laser approval Process 
        List<ALL_Approval_Process__c> ApprovalProcessSettings = ALL_Approval_Process__c.getall().values();       
        
        for(ALL_Approval_Process__c ap: ApprovalProcessSettings)
        {
            if(ap.sObject__c == currentsObjectType)
            {      
                if(ap.Record_Type__c != null)
                { 
                    List<ALL_Approval_Process__c> tempSettingsList = SubmitApprovalSettingsListToRecordType.get(ap.Record_Type__c);
                    
                    if(tempSettingsList == null)
                    {
                        tempSettingsList = new List<ALL_Approval_Process__c>();
                    } 
                    
                    tempSettingsList.add(ap);
                    SubmitApprovalSettingsListToRecordType.put(ap.Record_Type__c, tempSettingsList);                        
                }            
            }
        }
        
        Map<ID, sObject> IdToRecordMap= new Map<ID, sObject>();
        
        if(oldRecords != null) {
            for(sObject obj: oldRecords) { IdToRecordMap.put(obj.Id, obj); }
        }
        
        list<Approval.ProcessSubmitRequest> ApprovalRequestsList = new list<Approval.ProcessSubmitRequest>();
        map<ID, sObject> ApprovalSubmittedRecords = new map<ID, sObject>();
        
        system.debug(RecordTypeToRecords);system.debug('process instance map' + processInstanceMap + processInstanceMap.keySet());
        
        if(RecordTypeToRecords != null && !RecordTypeToRecords.isEmpty())
        {
            for(string recordType: RecordTypeToRecords.keySet())
            {
                List<sObject> CurrentRecordList = RecordTypeToRecords.get(recordType);
                
                if(CurrentRecordList != null && !CurrentRecordList.isEmpty())
                {
                    for(sObject sObj: CurrentRecordList) 
                    {system.debug('process instance map' + sobj.Id);
                        sObject OldRecord = IdToRecordMap.get(sObj.Id);
                        
                        // get last/previous process instance
                        list<ProcessInstance> LaoProcesInstances = ProcessInstanceMap.get(sObj.Id);
                        boolean currentApprovalPending = false;
                        boolean justGotApproved = false;
                        
                        // Siva.Pragada@CDK.com - 9/3/2015 had to look in the loop for 'Pending'status, because 
                        // pending status ProcessInstance is not arranged in order in the list
                        system.debug(LaoProcesInstances);
                        if(LaoProcesInstances != null && !LaoProcesInstances.isEmpty())
                        {
                            for(ProcessInstance pi: LaoProcesInstances)
                            {
                                if(pi.get('Status') == 'Pending')
                                {
                                    currentApprovalPending = true;
                                }
                                if(pi.get('Status') == 'Approved')
                                {
                                    dateTime approvedTime = (dateTime)pi.get('CompletedDate');
                                    system.debug(dateTime.now().getTime() - approvedTime.getTime());
                                    if(dateTime.now().getTime() - approvedTime.getTime() < 8000)
                                    {
                                        justGotApproved = true;
                                    }                                                                        
                                }                                
                            }
                        }
                        
                        system.debug(justGotApproved);
                        system.debug(LaoProcesInstances);
                        
                        
                        Integer CurrentProcessInstance;
                        if(LaoProcesInstances != null && !LaoProcesInstances.isEmpty()) {
                            CurrentProcessInstance = LaoProcesInstances.Size()-1; }
                                                                        
                        List<ALL_Approval_Process__c> FieldValueSetForApprovalInit = SubmitApprovalSettingsListToRecordType.get(recordType);
                       
                        if(FieldValueSetForApprovalInit != null && !FieldValueSetForApprovalInit.isEmpty())
                        {
                            for(ALL_Approval_Process__c ap: FieldValueSetForApprovalInit) 
                            {
                                Boolean Matches = ALL_CreateTask_Helper.CompareTheValues(ap.identifier__c, sObj);
                                
                                system.debug(Matches);
                                
                                if(Matches)
                                {  
                                    if(ProcessInstanceMap.keySet() == null || !ProcessInstanceMap.keySet().contains(sObj.Id))
                                    {
                                        system.debug(sobj.get('Name'));
                                        Approval.ProcessSubmitRequest ApprovalInstance = new Approval.ProcessSubmitRequest();                                
                                        ApprovalInstance.setObjectId(sObj.Id);
                                        ApprovalRequestsList.add(ApprovalInstance);
                                        ApprovalSubmittedRecords.put(sObj.ID, sObj);
                                    } 
                                    else
                                    {  
                                        system.debug(sObj.get('Last_Approval_Status__c'));
                                        if (CurrentProcessInstance >= 0 && (
                                            LaoProcesInstances[CurrentProcessInstance].Status == 'Rejected' || 
                                            LaoProcesInstances[CurrentProcessInstance].Status == 'Removed' || 
                                            LaoProcesInstances[CurrentProcessInstance].Status == 'Approved') && 
                                            !justGotApproved && !currentApprovalPending)// && sObj.get('Last_Approval_Status__c') != 'Approved') //!justGotApproved
                                            //LaoProcesInstances[CurrentProcessInstance].Status != 'Pending')
                                        { 
                                            boolean fieldsChangedAndConditionsMet = false;
                                            
                                            fieldsChangedAndConditionsMet = allFieldValuesComparison(ap.Identifier__c, sObj, oldRecord);
                                            
                                            system.debug(fieldsChangedAndConditionsMet);
                                            system.debug(sObj); system.debug(oldRecord);
                                            
                                            if(fieldsChangedAndConditionsMet)
                                            { 
                                                Approval.ProcessSubmitRequest ApprovalInstance = new Approval.ProcessSubmitRequest();                                
                                                ApprovalInstance.setObjectId(sObj.Id);
                                                ApprovalRequestsList.add(ApprovalInstance);
                                                ApprovalSubmittedRecords.put(sObj.ID, sObj);
                                            }                                            
                                        }              
                                    }         
                                } 
                            } 
                        }                  
                    }
                }                
            }
            system.debug(ApprovalRequestsList); 
            if(ApprovalRequestsList != null && !ApprovalRequestsList.isEmpty())
            {
                ApprovalProcessResults = Approval.process(ApprovalRequestsList);
            }
            
            ApprovalResultsInstance.ApprovalProcessResults = ApprovalProcessResults;
            ApprovalResultsInstance.ApprovalSubmittedRecords = ApprovalSubmittedRecords;
        }  
    
        return ApprovalResultsInstance;
    }
    
    //for comparing a field value in old and new record in a trigger
    public static boolean compareField(sObject newRecord, sObject oldRecord, string field)
    {
        boolean valueSame = false;
        
        if(newRecord != null && oldRecord != null && field != null && !string.isEmpty(field))
        {
            system.debug(field);
            system.debug(newRecord.get(field));
            system.debug(oldRecord.get(field));
            system.debug(newRecord.get(field) == oldRecord.get(field));
            if(newRecord.get(field) == oldRecord.get(field))
            {
                valueSame = true;
                system.debug(valueSame);
            }
            
            system.debug(valueSame);
        }
        return valueSame;
    }
    
    public static boolean allFieldValuesComparison(string identifier, sobject newRecord, sObject oldRecord)
    {
        boolean fieldsChangedAndConditionsMet = false;
        
        List<string> FieldIdentifiers = new list<string>();
        
        if(identifier != null && !string.isEmpty(identifier) && identifier.contains('AND'))
        {
            FieldIdentifiers = identifier.Split('AND');
        }
        else if(identifier != null && !string.isEmpty(identifier) && !identifier.contains('AND'))
        {
            identifier = identifier.normalizeSpace();
            FieldIdentifiers.add(identifier);
        }
        
        system.debug(FieldIdentifiers);
        
        list<boolean> booleanList = new list<boolean>();
        
        if(FieldIdentifiers != null && !FieldIdentifiers.isEmpty())
        {
            for(string field: FieldIdentifiers)
            { 
                system.debug(FieldNamesMap);
                system.debug(field);
                field = field!= null?field.normalizeSpace():field;
                system.debug(field);
                string FieldAPIName = FieldNamesMap.get(field);
                
                system.debug(FieldAPIName);
                if(FieldAPIName != null)
                {
                    boolean fieldValue = compareField(newRecord, oldRecord, FieldAPIName);
                    system.debug(fieldValue);
                    booleanList.add(fieldValue);
                }
            } 
        }
        
        system.debug(booleanList); system.debug(newRecord);system.debug(oldRecord); 
        
        if(!booleanList.isEmpty())
        {
            for(boolean bool: booleanList)
            {
                if(bool == false)
                {
                    fieldsChangedAndConditionsMet = true;
                    break;
                }
            }
        }
        system.debug(fieldsChangedAndConditionsMet);
        return fieldsChangedAndConditionsMet;
    }
    
    // map<FormsOrder.Id, map<subjectOfTask, listOfTasks>>
    public static map<ID, map<string, set<string>>> parentToTaskMap(map<ID, sObject> oldSobjectMap)
    {
        map<ID, map<string, set<string>>> parentToTaskMap = new map<ID, map<string, set<string>>>();
        
        if(oldSobjectMap != null)
        {
            List<Task> OldTaskList;
            
            if(!oldSobjectMap.isEmpty())
            {
                OldTaskList = new List<Task>([
                    Select Id, WhatId, Subject, Status, OwnerId 
                    From Task 
                    Where WhatId IN :oldSobjectMap.keySet()                    
                ]); 
            } 
            
            if(OldTaskList == null || OldTaskList.isEmpty())
            {
                return null;
            }            
            else if(OldTaskList != null && !OldTaskList.isEmpty())
            {
                for(Task t: OldTaskList)
                {
                    ID recordID = t.whatId ;
                    
                    if(recordID != null)
                    {
                        sObject record = oldSobjectMap.get(recordID);
                        
                        if(record != null)
                        {
                            map<string, set<string>> taskMap = parentToTaskMap.get(record.ID);
                            if(taskMap == null){ taskMap = new map<string, set<string>>();}
                            set<string> taskList = taskMap.get(t.Subject);
                            if(taskList == null){ taskList = new set<string>();}
                            taskList.add(t.status);
                            taskMap.put(t.Subject, taskList);
                            parentToTaskMap.put(record.ID, taskMap);                            
                        }
                    }                
                }
            }
        }
        
        return parentToTaskMap;
    }
    
    public static map<ID, map<string, boolean>> booleanMapToCreateTask(map<ID, sObject> sObjectsNewMap)
    {
        map<ID, map<string, set<string>>> parentToTaskMap = parentToTaskMap(sObjectsNewMap);
        
        if(parentToTaskMap == null || parentToTaskMap.isEmpty()) { return null; }
        
        system.debug(parentToTaskMap);
        
        map<ID, map<string, boolean>> booleanMapToCreateTask = new map<Id,map<string, boolean>>();
        
        if(parentToTaskMap != null && !parentToTaskMap.isEmpty())
        {
            for(ID id: parentToTaskMap.keySet())
            {
                map<string, set<string>> taskMap = parentToTaskMap.get(id);
                
                if(taskMap != null)
                {
                    for(string subject: taskMap.keySet())
                    {
                        set<string> statusList = taskMap.get(subject);
                        map<string, boolean> booleanMap = booleanMapToCreateTask.get(id);
                        if(booleanMap == null){ booleanMap =  new map<string, boolean>(); }
                        
                        if(statusList != null)
                        { 
                            if(statusList.size() == 1 && statusList.contains('Completed'))
                            {
                                booleanMap.put(subject, true);
                            }
                            if(statusList.size() > 1 && statusList.contains('Completed'))
                            {
                                booleanMap.put(subject, false);
                            }
                            if(statusList.size() >= 1 && !statusList.contains('Completed'))
                            {
                                booleanMap.put(subject, false);
                            }
                            
                        }
                        else
                        {
                             booleanMap.put(subject, true);
                        }
                        
                        booleanMapToCreateTask.put(id, booleanMap);
                    }
                }
            }
        }
        
        return booleanMapToCreateTask;
    }
}