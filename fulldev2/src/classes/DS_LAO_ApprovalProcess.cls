public class DS_LAO_ApprovalProcess
{
    // Added Static boolean variable to avoid the resubmiting of the approval process due to re firing of the trigger due to field updates
    // and  workflows
    // this map stores the tasks related to each lao(in the before trigger and makes it available in after trigger)
    // so that we can update these tasks with the original lao owner(standard salesforce assigns what.owner to the task.owner).
    // we have to ovveride that standard functionality in the trigger
    public static map<ID, list<task>> LaoIdToRelatedTaskList = new map<ID, list<task>>();
    
    public static void ApprovalProcessMethod(Map<ID, Laser_Artwork_Order__c> ApprovalRecordsNewMAP, List<Laser_Artwork_Order__c> ApprovalRecordsOld)
    { 
        map<ID, Laser_Artwork_Order__c> IdToLaoMap = new map<ID, Laser_Artwork_Order__c>();
        
        if(ApprovalRecordsOld != null && !ApprovalRecordsOld.isEmpty())
        {
            for(Laser_Artwork_Order__c lao: ApprovalRecordsOld)
            {
                IdToLaoMap.put(lao.ID, lao);
            }
        }
         
        
        ALL_CreateTask_Helper.ApprovalProcessResultPackage ApprovalProcessResultsPacket = new ALL_CreateTask_Helper.ApprovalProcessResultPackage();
        Approval.ProcessResult[] ApprovalProcessResults = new list<Approval.ProcessResult>();
        map<ID, sObject> ApprovalSubmittedRecords = new map<ID, sObject>();
        
        //if(ALL_CheckRecursive.runCodeBlockOnce('isNotSubmitted'))
        //{
            ApprovalProcessResultsPacket = ALL_CreateTask_Helper.ApprovalProcessMethod(ApprovalRecordsNewMAP.values(), ApprovalRecordsOld);        
            
            ApprovalProcessResults = ApprovalProcessResultsPacket.ApprovalProcessResults;
            
            ApprovalSubmittedRecords = ApprovalProcessResultsPacket.ApprovalSubmittedRecords;
        //} 
        
        List<ProcessInstance> ProcessInstances =  new List<ProcessInstance>();
        system.debug(ApprovalSubmittedRecords.keySet());
        if(ApprovalSubmittedRecords != null && !ApprovalSubmittedRecords.isEmpty())
        {
            ProcessInstances = new list<ProcessInstance>([
                Select Id, Status, ProcessDefinitionId, TargetObjectId, CompletedDate, LastActor.Name, 
                (SELECT Id, OriginalActorId, ActorId, StepStatus, Comments FROM StepsAndWorkitems) 
                From ProcessInstance 
                Where TargetObjectId IN :ApprovalSubmittedRecords.keySet() 
                AND Status = 'Pending'
            ]);
        }
        
        system.debug(ProcessInstances);
        ProcessInstance currentProcessInstance = null;
        
        if(ProcessInstances != null && !ProcessInstances.isEmpty())
        {
            currentProcessInstance = ProcessInstances.get(0);
        }
        
        list<ProcessInstanceHistory> StepsList = new list<ProcessInstanceHistory>();
        
        if(currentProcessInstance != null)
        {
            StepsList = currentProcessInstance.getsObjects('StepsAndWorkitems');
        }
        
        system.debug(StepsList);
        
        if(StepsList != null && !StepsList.isEmpty())
        {
            for(integer i=0; i<StepsList.size(); i++)
            {
                if(StepsList[i].StepStatus != 'Pending')
                {
                    StepsList.remove(i);
                }
            } 
        }
        
        system.debug(StepsList);
        
        set<ID> userIDset = new set<ID>();
        set<ID> queueIDset = new set<ID>();
        
        if(StepsList != null && !StepsList.isEmpty())
        {
            for(ProcessInstanceHistory pih: StepsList)
            {
                if(pih.ActorId.getsObjectType().getDescribe().getKeyPrefix() == '005')
                {
                    userIDset.add(pih.ActorId);
                }
                else if(pih.ActorId.getsObjectType().getDescribe().getKeyPrefix() == '00G')
                {
                    queueIDset.add(pih.ActorId);
                }
            }
        }
        list<User> userActorList = new list<User>();
        list<Group> queueActorList = new list<Group>();
        
        if(userIDset != null && !userIDset.isEmpty())
        {
            userActorList = [Select ID, Name From User Where ID IN :userIDset];
        }
        
        if(queueIDset != null && !queueIDset.isEmpty())
        {
            queueActorList = [Select ID, Name From Group Where ID IN :queueIDset];
        }
        
        String UserName, QueueName, approver ;
        
        if(!userActorList.isEmpty()){ UserName = (string)userActorList.get(0).get('Name');} 
        if(!queueActorList.isEmpty()){ QueueName = (string)queueActorList.get(0).get('Name');}
        
        if(UserName != null && !string.isEmpty(UserName))
        {
            approver = UserName;
        }
        else
        {
            approver = QueueName;
        }
        
        list<Laser_Artwork_Order__c> UserChangedStatusLAOListToUpdate = new list<Laser_Artwork_Order__c>();
        
        //DS_LAO_ApprovalProcess.CreateQualitySnapShots(ApprovalRecordsNewMAP.values(), IdToLaoMap);
        
        //Create Tasks
        if(Trigger.isInsert || Trigger.isUpdate)
        {	System.debug('LaoIdToRelatedTaskList' + LaoIdToRelatedTaskList);
            DS_LAO_ApprovalProcess.CreateTasksForFO(ApprovalRecordsNewMAP, IdToLaoMap);            
        }
        
        
        if(ApprovalProcessResults != null && !ApprovalProcessResults.isEmpty())
        {
            for(Approval.ProcessResult apr: ApprovalProcessResults)
            {
                if(apr.isSuccess())
                {
                    // below is an option to set the value of User_Changed_Status__c field, may be here Or may be in before trigger
                    // I am assuming here would be possible to check if submission was successfull, but in before trigger isSuccess() is not known
                    // only expense here is a update DML operation.                    
                    if(ApprovalSubmittedRecords.get(apr.getEntityId()) != null)
                    {
                        UserChangedStatusLAOListToUpdate.add((Laser_Artwork_Order__c)ApprovalSubmittedRecords.get(apr.getEntityId()));
                    }
                    
                }
            }
        }           
        
        for(integer i=0; i<UserChangedStatusLAOListToUpdate.size(); i++)
        {
            laser_artwork_order__c l = new laser_artwork_order__c();               
            l = UserChangedStatusLAOListToUpdate[i].clone(true, false, true, true);
            l.Approver__c = approver;
            UserChangedStatusLAOListToUpdate.remove(i);
            UserChangedStatusLAOListToUpdate.add(l);
        }
        
        if(UserChangedStatusLAOListToUpdate != null && !UserChangedStatusLAOListToUpdate.isEmpty())
        {
            for(Laser_Artwork_Order__c lao: UserChangedStatusLAOListToUpdate)
            {               
                lao.User_Changed_Status__c = userInfo.getName();
            }
            update UserChangedStatusLAOListToUpdate;   // this updates the User_Changed_Status__c field with current user who submitted the Approval Process
        }
    }
    
    public static void CreateQualitySnapShots(List<Laser_Artwork_Order__c> newList, Map<ID, Laser_Artwork_Order__c> oldMap)
    {
        //get the sorted Quality snapshots map here
        map<Id, Lao_QualitySnapShots__c> SortedQualitySnapShotsMap = new map<Id, Lao_QualitySnapShots__c>();
        if(oldMap != null && !oldMap.isEmpty())
        {
            SortedQualitySnapShotsMap = DS_LAO_ApprovalProcess.RetrieveQualitySnapShot(oldMap.values());
        }
        
        // declare a list of LAO_QualitySnapshots__c out of the for loop       
        list<LAO_QualitySnapshots__c> AfterApprovalLAOQualitySnapshotsList = new list<LAO_QualitySnapshots__c>();
        LAO_QualitySnapshots__c QualitySnap;
        
        for(Laser_Artwork_Order__c lao: newList)
        {        
            // below check for Last_Approval_Status__c field value and create LAO quality snapshot and insert it
            if(oldMap != null && oldMap.keySet() != null && !oldMap.keySet().isEmpty())
            { 
                Laser_Artwork_Order__c oldLAO = oldMap.get(lao.ID);
                system.debug(oldLAO.Last_Approval_Status__c);
                system.debug(lao.Last_Approval_Status__c);
                //system.assertEquals(2,1);
                if(oldLAO.Last_Approval_Status__c == null && lao.Last_Approval_Status__c != null)
                {
                    Lao_QualitySnapShots__c QualitySnapShot = SortedQualitySnapShotsMap.get(lao.Id);
                    
                    QualitySnap = new LAO_QualitySnapshots__c();
                    
                    if(lao.Order_Status__c=='AWIP' && lao.Revision__c == '1' && QualitySnapShot != null) { 
                        QualitySnap.Change_Made_By__c = QualitySnapShot.Change_Made_By__c; }
                    else { 
                        QualitySnap.Change_Made_By__c = lao.User_Changed_Status__c; } 
                    
                    QualitySnap.Approval_Status__c = lao.Last_Approval_Status__c;
                    QualitySnap.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                    QualitySnap.Order_Type__c = lao.Order_Type__c;
                    QualitySnap.Order_Status__c = 
                        (lao.Last_Approval_Status__c.toLowerCase() == 'rejected' && oldLAO != null) ? oldLAO.Order_Status__c : lao.Order_Status__c;
                    QualitySnap.LAO__c = lao.Id;
                    QualitySnap.Approved_Rejected_By__c = userInfo.getName();
                    //QualitySnap.Approved_Rejected_By__c = CurrentProcessInstance.LastActor.Name; // May be this value can be obtained from ProcessInstance
                    AfterApprovalLAOQualitySnapshotsList.add(QualitySnap);
                }
            }
        }
        
        
        list<Laser_Artwork_Order__c>LaserArtWorkOrderList = new list<Laser_Artwork_Order__c>();
        // clear the values in Last_Approval_Status__c and  User_Changed_Status__c fields and add it updatelist
        
        for(Laser_Artwork_Order__c lao: newList)
        {
            Laser_Artwork_order__c ClonedLao = lao.clone(true, false, true, true);
            
            if(ClonedLao.Last_Approval_Status__c != null || ClonedLao.User_Changed_Status__c != null)
            {
                if(ClonedLao.Last_Approval_Status__c != null){ ClonedLao.Last_Approval_Status__c = null;}
                if(ClonedLao.User_Changed_Status__c != null){ ClonedLao.User_Changed_Status__c = null;}
                LaserArtWorkOrderList.add(ClonedLao);
            } 
        }
        
        // insert the quality snapshots outside the for loop
        if(AfterApprovalLAOQualitySnapshotsList != null 
           && !AfterApprovalLAOQualitySnapshotsList.isEmpty())
        { 
            insert AfterApprovalLAOQualitySnapshotsList; 
        } //one dml insert
        
        
        if(LaserArtWorkOrderList != null && !LaserArtWorkOrderList.isEmpty())
        {
            update LaserArtWorkOrderList;
        }
        
    }
    // this method gets the already exisitng quality snapshots
    public static map<Id, Lao_QualitySnapShots__c> RetrieveQualitySnapShot(list<Laser_Artwork_Order__c> LaoRecords)
    {
        
        list<Lao_QualitySnapShots__c> QualitySnapsList = new list<Lao_QualitySnapShots__c>([
            Select Id, Name, Lao__c, Approval_Status__c, Approved_Rejected_By__c, Change_Made_By__c, Order_Status__c,
            Order_Type__c, Revision__c, LastModifiedDate
            From Lao_QualitySnapShots__c 
            Where Lao__c IN :LaoRecords]);
        
        // map structure: map<Lao.Id, list<Lao_QualitySnapShots__c>>
        map<Id, list<Lao_QualitySnapShots__c>> QualitySnapsSorterMap = new map<Id, list<Lao_QualitySnapShots__c>>();
        map<Id, Lao_QualitySnapShots__c> SortedQualitySnapShotsMap = new map<Id, Lao_QualitySnapShots__c>();
        list<Lao_QualitySnapShots__c> LaoQualitySnaps;
        
        for(Laser_artwork_Order__c lao: LaoRecords)
        {
            for(Lao_QualitySnapShots__c QualitySnap: QualitySnapsList)
            {
                LaoQualitySnaps = new list<Lao_QualitySnapShots__c>();
                
                if(QualitySnap.Order_Status__c == 'Artwork to LFD Team')
                {
                    LaoQualitySnaps.add(QualitySnap);
                }                
            } 
            
            QualitySnapsSorterMap.put(lao.Id, LaoQualitySnaps);
        }
        
        list<Lao_QualitySnapShots__c> SortedList;
        SortUtility FieldSorter;
        
        for(ID id: QualitySnapsSorterMap.keySet())
        {
            SortedList = new list<Lao_QualitySnapShots__c>();            
            SortedList = QualitySnapsSorterMap.get(id);
            
            if(SortedList != null && !SortedList.isEmpty())
            {
                FieldSorter = new SortUtility(SortedList, 'LastModifiedDate');
                SortedList = FieldSorter.CustomSort();
                SortedQualitySnapShotsMap.put(SortedList.get(SortedList.size() - 1).Lao__c, SortedList.get(SortedList.size() - 1));
            }        
        }     
        return SortedQualitySnapShotsMap;
    }
    
    // Task create and update only
    public static void CreateTasksForFO(map<ID, Laser_Artwork_Order__c> ApprovalRecordsNewMap, map<ID, Laser_Artwork_Order__c> ApprovalRecordsOldMap)
    { 
        List<Task> TobeInsertedTaskList = ALL_CreateTask_Helper.CreateTasksForAnySobject(ApprovalRecordsNewMap, ApprovalRecordsOldMap);
        
        
        system.debug(TobeInsertedTaskList);
        //system.debug(TobeInsertedTaskList.size());
        system.debug('LaoIdToRelatedTaskList' + LaoIdToRelatedTaskList);
        for(Laser_Artwork_Order__c lao: ApprovalRecordsNewMap.values())
        {
            // set task owner to older owner value on lao.
            if(LaoIdToRelatedTaskList.get(lao.Id) != null && !LaoIdToRelatedTaskList.get(lao.Id).isEmpty())
            {
                for(task t: LaoIdToRelatedTaskList.get(lao.Id))
                {
                    if(t.WhatId == lao.Id)
                    {
                        system.debug( t.ownerId);
                        t.ownerId = t.ownerId;
                    }
                }
            }
        }
        
        //system.debug(TobeInsertedTaskList); system.debug(TobeInsertedTaskList.size());
        
        if(TobeInsertedTaskList != null && !TobeInsertedTaskList.isEmpty() && !system.isFuture() && !system.isBatch() && !system.isScheduled()) 
        {  
            ALL_UtilitiesData.SerializesObjectList(TobeInsertedTaskList, 'insert');
        }  
        
        // update the tasks that have the owner value change
        list<task> TaskUpdateList = new list<task>();
        
        if(LaoIdToRelatedTaskList.values() != null && !LaoIdToRelatedTaskList.values().isEmpty())
        {   
            for(list<task> tasklist: LaoIdToRelatedTaskList.values())
            {
                TaskUpdateList.addAll(tasklist);
            }           
        }
        
        if(TaskUpdateList != null && !TaskUpdateList.isEmpty())    
        {              
            ALL_UtilitiesData.SerializesObjectList(TaskUpdateList, 'update');
        }        
    } 
    
    // Method for updating fields and creating tasks
    public Static void SetOwnerFieldMethod(List<Laser_Artwork_Order__c> NewList, Map<ID, Laser_Artwork_Order__c> LaoOldMap)
    { 
        List<Forms_OwnerFieldSetting__c> LAPsettings = Forms_OwnerFieldSetting__c.getall().values();
        
        for(Laser_Artwork_Order__c lao: newList)
        {
            laser_Artwork_Order__c oldRecord = LaoOldMap != null ? LaoOldMap.get(lao.ID) : null;
            
            for(Forms_OwnerFieldSetting__c lap: LAPsettings)
            {
                boolean fieldsChangedAndConditionsMet = true; 
                
                ALL_CreateTask_Helper instance = new ALL_CreateTask_Helper();
                
                if(oldRecord != null)
                {
                    fieldsChangedAndConditionsMet = ALL_CreateTask_Helper.allFieldValuesComparison(lap.Identifier__c, lao, oldRecord);
                }
                
                string currentRecordType;
                if(lao.RecordTypeId != null)
                {
                    currentRecordType = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Laser_Artwork_Order__c', lao.RecordTypeId);
                }
                
                boolean recordTypesMatch = false;
                if(currentRecordType == lap.Record_Type__c){ recordTypesMatch = true; } system.debug(lap.Identifier__c);
                boolean Matches = false; 
                
                if(lap.Identifier__c != null)
                {
                    Matches = ALL_CreateTask_Helper.CompareTheValues(lap.Identifier__c, lao);
                }
                
                system.debug(lao);system.debug(Matches);
                system.debug(lap); system.debug(currentRecordType); system.debug(lap.Owner_to_LAS__c);
                
                if(recordTypesMatch)
                {
                    if(Matches && fieldsChangedAndConditionsMet)
                    {
                        if(lap.Owner_to_LAS__c)
                        { 
                            lao.OwnerId = Lao.LAS_Name__c!=null?lao.LAS_Name__c:userInfo.getUserId();                    
                        }
                        
                        if(lap.Owner_to_LFD__c)
                        {
                            lao.OwnerId = Lao.LFD_Name__c!=null?lao.LFD_Name__c:userInfo.getUserId();   
                        }
                        
                        if(lap.Owner_to_LIS__c)
                        {
                            lao.OwnerId = Lao.LIS_Name__c!=null?lao.LIS_Name__c:userInfo.getUserId(); 
                        }
                        
                        if(lap.Assigned_Forms_Builder__c)
                        {
                            lao.OwnerId = Lao.Assigned_Forms_Builder__c!=null?lao.Assigned_Forms_Builder__c:userInfo.getUserId(); 
                        }
                    }  
                    system.debug(lao.Is_Approved__c);
                    
                    if(lao.Is_Approved__c != null)
                    { 
                        boolean oldRecordMatch = false;
                        oldRecordMatch = ALL_CreateTask_Helper.CompareTheValues(lap.Identifier__c, oldRecord);
                       	System.debug('match' + lap.Identifier__c + oldRecord);
                        if(oldRecordMatch)
                        {
                            if(lap.Rejected_FCC__c)
                            {  
                                lao.OwnerId = Lao.FCC_Name__c!=null?lao.FCC_Name__c:userInfo.getUserId(); 
                            }
                            system.debug(oldRecordMatch);
                            
                            
                            if(lap.Rejected_LAS__c)
                            {
                                lao.OwnerId = Lao.LAS_Name__c!=null?lao.LAS_Name__c:userInfo.getUserId(); 
                            }
                            
                            if(lap.Rejected_LFD__c)
                            {
                                lao.OwnerId = Lao.LFD_Name__c!=null?lao.LFD_Name__c:userInfo.getUserId();
                            }
                           
                            system.debug(lap.Rejected_FCC__c);
                            system.debug(lap.Record_Type__c);
                            system.debug(currentRecordType);
                            system.debug(lap.Record_Type__c == currentRecordType); 
                        }
                        //lao.Order_Status__c = 'Hold-CDK';
                        //system.assertEquals(lao.Is_Approved__c, Date.today() +1);                    
                    }
                    
                }
                
                system.debug(lao.OwnerId);
            }
            
            lao.Is_Approved__c = null;
        }        
    } 
     
    public static map<string, Create_Task_Settings__c> getCreateTaskSettingsWithIdentifierAsKey()
    {
        List<Create_Task_Settings__c> CTSsettings = Create_Task_Settings__c.getAll().Values();
        map<string, Create_Task_Settings__c> CTSmap = new map<string, Create_Task_Settings__c>();
        
        for(Create_Task_Settings__c cts: CTSsettings)
        {
            CTSmap.put(cts.Identifier__c, cts);
        }
        
        return CTSmap;
    }

    public Static void updateTasks(List<sobject> NewList, Map<ID, sObject> LaoOldMap)
    {          
        Set<Id> OldLAOIdSet;
        
        if(LaoOldMap != null && !LaoOldMap.isEmpty())
        {
            OldLAOIdSet = new Set<Id>(LaoOldMap.keySet());
        }
        
        List<Forms_OwnerFieldSetting__c> LAPsettings = Forms_OwnerFieldSetting__c.getall().values();
       
        // 2014-12-11 MK Track_Follow_up__c was not needed in this query (add later if needed)
        List<Task> OldTaskList;
        System.debug('old task list' + OldTaskList + OldLAOIdSet + LaoOldMap.size());
        for(Id id : LaoOldMap.keySet()) {
            System.debug('task' + LaoOldMap.get(id)  );
        }
        if(OldLAOIdSet != null && !OldLAOIdSet.isEmpty())
        {
            OldTaskList = new List<Task>([
                Select Id, WhatId, Subject, Status, OwnerId 
                From Task 
                Where WhatId IN :OldLAOIdSet
            ]); 
        }       
        System.debug('old task list' + OldTaskList + OldLAOIdSet + LaoOldMap.size());
        list<task> TobeUpdatedTaskList = new list<task>();
        list<task> welcomeKitDeleteList = new list<task>();
       
        for(Forms_OwnerFieldSetting__c lap: LAPsettings)
        {
            for(sObject lao: newList)
            {  
                list<task> tasklistIntoMap = new list<task>();
                
                if(Trigger.isUpdate)
                {  
                    if(OldTaskList != null && !OldTaskList.isEmpty())
                    {                        
                        for(Task ta: OldTaskList)
                        { 
                            if(ta.Subject != null && ta.Subject.equalsIgnoreCase('Quote Follow-up') && ta.WhatId == lao.Id)
                            { 
                                // RQ-03605: collect those tasks which meet the criteria in RQ-03605 and delete them
                                string status = (string)lao.get('Order_Status__c');
                                
                                if(status != null && status.equalsIgnoreCase('q/s approved'))
                                { 
                                    TobeUpdatedTaskList.add(ta); 
                                }                           
                                
                            }
                            
                            if(ta.Subject != null && ta.Subject.equalsIgnoreCase('Proofs Follow-up') && ta.WhatId == lao.Id)
                            {                        
                                // RQ-03605: collect those tasks which meet the criteria in RQ-03605 and delete them
                                string status = (string)lao.get('Order_Status__c');
                                
                                if(status != null && status.equalsIgnoreCase('approved')
                                   || status.equalsIgnoreCase('awip'))
                                { 
                                       TobeUpdatedTaskList.add(ta); 
                                }                            
                            }
                            
                            if(ta.Subject != null && ta.Subject.equalsIgnoreCase('Welcome Kit Follow up') && ta.WhatId == lao.Id)
                            {
                                string status = (string)lao.get('Order_Status__c');
                                
                                if(status != null && status.equalsIgnoreCase('Forms Collected'))
                                { 
                                       welcomeKitDeleteList.add(ta); 
                                }
                            }
                            
                            if(ta.WhatId == lao.Id && ta.Status != null && ta.Status.equalsIgnoreCase('completed'))
                            {                        
                                tasklistIntoMap.add(ta);                        
                            }
                        }
                    }
                }
                
                LaoIdToRelatedTaskList.put(lao.Id, tasklistIntoMap);
            }
        }
       
        if(TobeUpdatedTaskList != null && !TobeUpdatedTaskList.isEmpty())   
        {                     
            for(task t: TobeUpdatedTaskList)
            {    
                if(t.Status != 'Completed')
                {
                    t.Status = 'Completed';                   
                }              
            }           
        }
        
        // sending tasks to future method for update
        if(TobeUpdatedTaskList != null && !TobeUpdatedTaskList.isEmpty())
        {
            ALL_UtilitiesData.SerializesobjectList(TobeUpdatedTaskList, 'update');  
        } 
        
        if(welcomeKitDeleteList != null && !welcomeKitDeleteList.isEmpty())
        {
            ALL_UtilitiesData.SerializesObjectList(welcomeKitDeleteList, 'Delete');
        }
    }
}