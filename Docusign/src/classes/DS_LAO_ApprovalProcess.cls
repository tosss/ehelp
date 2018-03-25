public class DS_LAO_ApprovalProcess
{
    // Added Static boolean variable to avoid the resubmiting of the approval process due to re firing of the trigger due to field updates
    // and  workflows
    
    public static boolean isSubmitted = false;
    
    // this map stores the tasks related to each lao(in the before trigger and makes it available in after trigger)
    // so that we can update these tasks with the original lao owner(standard salesforce assigns what.owner to the task.owner).
    // we have to ovveride that standard functionality in the trigger
    public static map<ID, list<task>> LaoIdToRelatedTaskList = new map<ID, list<task>>();
    
    public static void ApprovalProcessMethod(List<Laser_Artwork_Order__c> ApprovalRecordsNew, List<Laser_Artwork_Order__c> ApprovalRecordsOld)
    {
        // Below query gets details of the record that was submitted for approval
        List<ProcessInstance> ProcessInstances = new list<ProcessInstance>([
            Select Id, Status, ProcessDefinitionId, TargetObjectId, CompletedDate, LastActor.Name 
            From ProcessInstance 
            Where TargetObjectId 
            IN :ApprovalRecordsNew 
        ]);

        //map<Lao.Id, list<ProcessInstance>>
        Map<Id, list<ProcessInstance>> ProcessInstanceMap = new Map<Id, list<ProcessInstance>>();

        for(ProcessInstance pi : processInstances)
        {
            list<ProcessInstance> CurrentProcessInstanceList = ProcessInstanceMap.get(pi.TargetObjectId);

            if(CurrentProcessInstanceList == null)
            {
                CurrentProcessInstanceList = new list<ProcessInstance>(); 
            }

            CurrentProcessInstanceList.add(pi);
            ProcessInstanceMap.put(pi.TargetObjectId, CurrentProcessInstanceList); 
        }

        // get all the custom settings for Laser approval Process 
        List<Laser_Approval_Process__c> LAPsettings = Laser_Approval_Process__c.getall().values();
        List<List<String>> SubmitApprovalFieldListList = new List<List<String>>(); 
        
        for(Laser_Approval_Process__c lap: LAPsettings)
        {
            List<String> SAFieldSet = new List<String>();
            
            if(lap.Submit_Approval__c == true)
            {
                SAFieldSet.add(lap.Order_Type__c); SAFieldSet.add(lap.Order_Status__c);
                SubmitApprovalFieldListList.add(SAFieldSet); 
            }
        }
        
        Map<String, Laser_Artwork_Order__c> IdToLaoMap= new Map<String, Laser_Artwork_Order__c>();
        
        if(ApprovalRecordsOld != null) {
            for(Laser_Artwork_Order__c lao: ApprovalRecordsOld) { IdToLaoMap.put(lao.Id, Lao); }
        }
        
        //DS_LAO_ApprovalProcess InstanceClass = new DS_LAO_ApprovalProcess();
        
        // below lines are moved out of the for loop from line 145 and 146 to avoid hitting SOQL governor limits
        Date ActivityDate = Date.today();
        Date TaskDueDate = ActivityDate.addDays(ALL_UtilitiesDate.BusinessDaysCounter(date.today(), 3, 'Laser Holiday'));
        
        // declare a list of LAO_QualitySnapshots__c out of the for loop       
        list<LAO_QualitySnapshots__c> AfterApprovalLAOQualitySnapshotsList = new list<LAO_QualitySnapshots__c>();
        LAO_QualitySnapshots__c QualitySnap;
        list<Laser_Artwork_Order__c>LaserArtWorkOrderList = new list<Laser_Artwork_Order__c>();
        list<Approval.ProcessSubmitRequest> ApprovalRequestsList = new list<Approval.ProcessSubmitRequest>();
        map<ID, Laser_Artwork_Order__c> ApprovalSubmittedLaos = new map<ID, Laser_Artwork_Order__c>();
        
        //get the sorted Quality snapshots map here
        map<Id, Lao_QualitySnapShots__c> SortedQualitySnapShotsMap = new map<Id, Lao_QualitySnapShots__c>();
        if(ApprovalRecordsOld != null && !ApprovalRecordsOld.isEmpty())
        {
            SortedQualitySnapShotsMap = DS_LAO_ApprovalProcess.QulaitySnapShotRetriever(ApprovalRecordsOld);
        }
        List<Task> TobeInsertedTaskList = new List<Task>();
        for(Laser_Artwork_Order__c lao: ApprovalRecordsNew)
        {
            Laser_Artwork_Order__c CurrentLAO = IdToLaoMap.get(lao.Id);
            
            // get last/previous process instance
            list<ProcessInstance> LaoProcesInstances = ProcessInstanceMap.get(lao.Id);
            
            system.debug(LaoProcesInstances);
            
            Integer CurrentProcessInstance = -1;
            if(LaoProcesInstances != null && !LaoProcesInstances.isEmpty()) {
                CurrentProcessInstance = LaoProcesInstances.Size()-1; }
            
            List<String> RekFieldSet = new List<String>();    
            
            RekFieldSet.add(lao.Order_Type__c);
            RekFieldSet.add(lao.Order_Status__c);          

            for(List<String> s: SubmitApprovalFieldListList)
            {
                if(RekFieldSet.equals(s))
                {  
                    if(ProcessInstanceMap.keySet() == null || !ProcessInstanceMap.keySet().contains(lao.Id))
                    {  
                        //InstanceClass.ApprovalProcessMethod(lao);
                        Approval.ProcessSubmitRequest ApprovalInstance = new Approval.ProcessSubmitRequest();                                
                        ApprovalInstance.setObjectId(lao.Id);
                        ApprovalRequestsList.add(ApprovalInstance);
                        ApprovalSubmittedLaos.put(lao.ID, lao);
                    } 
                    else
                    {  system.debug(CurrentProcessInstance);
                        // resubmit logic for rejected/removed/approved where not pending
                        if (CurrentProcessInstance >= 0 && (
                            LaoProcesInstances[CurrentProcessInstance].Status == 'Rejected' || 
                            LaoProcesInstances[CurrentProcessInstance].Status == 'Removed' || 
                            LaoProcesInstances[CurrentProcessInstance].Status == 'Approved') && 
                            LaoProcesInstances[CurrentProcessInstance].Status != 'Pending')
                        {
                            if ((CurrentLAO.Order_Type__c != lao.Order_Type__c && CurrentLAO.Order_Status__c != lao.Order_Status__c) || 
                                (CurrentLAO.Order_Type__c != lao.Order_Type__c && CurrentLAO.Order_Status__c == lao.Order_Status__c) || 
                                (CurrentLAO.Order_Type__c == lao.Order_Type__c && CurrentLAO.Order_Status__c != lao.Order_Status__c))
                            { 
                                //InstanceClass.ApprovalProcessMethod(lao); // ERROR 83
                                Approval.ProcessSubmitRequest ApprovalInstance = new Approval.ProcessSubmitRequest();                                
                                ApprovalInstance.setObjectId(lao.Id);
                                ApprovalRequestsList.add(ApprovalInstance);
                                ApprovalSubmittedLaos.put(lao.ID, lao);
                            }
                        }              
                    } // end else contains lao.Id          
                } // end if required field set
            } // end for 
            
            system.debug(ApprovalRequestsList);
                        
            List<List<String>> CreateQuoteTask = new List<List<String>>();
            List<List<String>> CreateProofsTask = new List<List<String>>();
            
            for(Laser_Approval_Process__c lap: LAPsettings)
            {
                //List of status pairs from custom settings that are for creating a task with subject 'Quote Follow Up'
                
                List<String> QuoteTask = new List<String>();
                
                if(lap.TaskQuote_FollowUp__c == true)
                {
                    QuoteTask.add(lap.Order_Type__c); QuoteTask.add(lap.Order_Status__c);
                    CreateQuoteTask.add(QuoteTask);
                }
                
                //List of status pairs from custom settings that are for creating a task with subject 'Proofs Follow Up'
                
                List<String> ProofsTask = new List<String>();
                
                if(lap.TaskProofs_FollowUp__c == true)
                {
                    ProofsTask.add(lap.Order_Type__c); ProofsTask.add(lap.Order_Status__c);
                    CreateProofsTask.add(ProofsTask);
                }     
            }
            
            // below lines are moved out of this for loop to save from SOQL 101 error hit
            //Date ActivityDate = Date.today();
            //Date TaskDueDate = ActivityDate.addDays(ALL_UtilitiesDate.BusinessDaysCounter(date.today(), 3, 'Laser Holiday'));
            
            system.debug(CreateQuoteTask);
            system.debug(CreateProofsTask);
            
            if(Trigger.isInsert)
            {
                for(List<String> s: CreateQuoteTask)
                {
                    if(RekFieldSet.equals(s))
                    {
                        Task t = new Task();
                        t.WhatId = lao.Id;
                        if(lao.Contact__c != null) { t.WhoId = lao.Contact__c; }
                        t.ActivityDate = TaskDueDate;
                        t.Subject = 'Quote Follow-up';
                        t.OwnerId = lao.LAS_Name__c!=null ? lao.LAS_Name__c : userInfo.getUserId();
                        TobeInsertedTaskList.add(t);
                        //Insert t;
                    }                
                }   
                
                for(List<String> s: CreateProofsTask)
                {
                    if(RekFieldSet.equals(s))
                    {
                        Task t = new Task();
                        t.WhatId = lao.Id; 
                        if(lao.Contact__c != null) { t.WhoId = lao.Contact__c; }
                        t.ActivityDate = TaskDueDate;                        
                        t.Subject = 'Proofs Follow-up';
                        t.OwnerId = lao.LAS_Name__c!=null?lao.LAS_Name__c:userInfo.getUserId();
                        TobeInsertedTaskList.add(t);
                        //insert t; 
                    }
                }
            }          
            
            // below check for Last_Approval_Status__c field value and create LAO quality snapshot and insert it
            if(IdToLaoMap.keySet() != null && !IdToLaoMap.keySet().isEmpty())
            { 
                if(CurrentLAO.Last_Approval_Status__c == null && lao.Last_Approval_Status__c != null)
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
                        (lao.Last_Approval_Status__c.toLowerCase() == 'rejected' && CurrentLAO != null) ? CurrentLAO.Order_Status__c : lao.Order_Status__c;
                    QualitySnap.LAO__c = lao.Id;
                    QualitySnap.Approved_Rejected_By__c = userInfo.getName();
                    //QualitySnap.Approved_Rejected_By__c = CurrentProcessInstance.LastActor.Name; // May be this value can be obtained from ProcessInstance
                    AfterApprovalLAOQualitySnapshotsList.add(QualitySnap);
                }
            }
            
            // clear the values in Last_Approval_Status__c and  User_Changed_Status__c fields and add it updatelist
            Laser_Artwork_order__c ClonedLao = lao.clone(true, false, true, true);
            
            if(ClonedLao.Last_Approval_Status__c != null || ClonedLao.User_Changed_Status__c != null)
            {
                if(ClonedLao.Last_Approval_Status__c != null){ ClonedLao.Last_Approval_Status__c = null;}
                if(ClonedLao.User_Changed_Status__c != null){ ClonedLao.User_Changed_Status__c = null;}
                LaserArtWorkOrderList.add(ClonedLao);
            }
            
            system.debug(LaoIdToRelatedTaskList.get(lao.Id));
            
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
        }//end of the trigger.new for loop
        
        //sending tasks to future method for inserting tasks
        DS_LAO_ApprovalProcess.SerializeObjects(TobeInsertedTaskList, 'insert');
        
        // update the tasks that have the owner value change
        list<task> TaskUpdateList = new list<task>();
        
        if(LaoIdToRelatedTaskList.values() != null && !LaoIdToRelatedTaskList.values().isEmpty())
        {   
            for(list<task> tasklist: LaoIdToRelatedTaskList.values())
            {
                TaskUpdateList.addAll(tasklist);
            }           
        }
        system.debug(TaskUpdateList); system.debug(System.isFuture());
            
        DS_LAO_ApprovalProcess.SerializeObjects(TaskUpdateList, 'update');
            
        list<Laser_Artwork_Order__c> UserChangedStatusLAOListToUpdate = new list<Laser_Artwork_Order__c>();
        Approval.ProcessResult[] ApprovalProcessResults = null;
        try 
        { 
            if(ApprovalRequestsList != null && !ApprovalRequestsList.isEmpty())
            {
                ApprovalProcessResults = Approval.process(ApprovalRequestsList);
            }// discuss with Gaurav to determine if this may be needed// , true);
            
        }
        catch (system.DMLException e) 
        { 
            for (Integer i = 0; i < e.getNumDml(); i++) 
            {                
                e.setMessage((e.getDmlMessage(i))); 
            }
            //e.setMessage(e.getDmlMessage(0));
            
            for(sobject l: trigger.new)
            {   
                if(e.getMessage().toLowerCase().contains('manager_not_defined'))
                {
                    //l.addError(e.getDmlMessage(0));
                    l.addError('LAS Name has to be selected for approval process');
                }
                else{
                    l.addError(e.getMessage());
                }
            }
            System.debug('Exception Is ' + e.getMessage());
        }
        
        system.debug(ApprovalProcessResults);
        
        Set<ID> ApprovalSubmittedLaoIds = new set<ID>();
        if(ApprovalProcessResults != null && !ApprovalProcessResults.isEmpty())
        {
            for(Approval.ProcessResult apr: ApprovalProcessResults)
            {
                if(apr.isSuccess())
                {
                    // below is an option to set the value of User_Changed_Status__c field, may be here Or may be in before trigger
                    // I am assuming here would be possible to check if submission was successfull, but in before trigger isSuccess() is not known
                    // only expense here is a update DML operation.                    
                    if(ApprovalSubmittedLaos.get(apr.getEntityId()) != null)
                    {
                        ApprovalSubmittedLaoIds.add(apr.getEntityId());
                        UserChangedStatusLAOListToUpdate.add(ApprovalSubmittedLaos.get(apr.getEntityId()));
                    }
                    
                }
            }
        }
        system.debug(UserChangedStatusLAOListToUpdate);
        
        for(integer i=0; i<UserChangedStatusLAOListToUpdate.size(); i++)
        {
            laser_artwork_order__c l = new laser_artwork_order__c();
            // this clone method only works because of runonce() on the trigger preventing recurrence
            l = UserChangedStatusLAOListToUpdate[i].clone(true, false, true, true); 
            UserChangedStatusLAOListToUpdate.remove(i);
            UserChangedStatusLAOListToUpdate.add(l);
        } 
        
        system.debug(UserChangedStatusLAOListToUpdate);
        system.debug(UserChangedStatusLAOListToUpdate.size());
               
        if(UserChangedStatusLAOListToUpdate != null && !UserChangedStatusLAOListToUpdate.isEmpty())
        {
            for(Laser_Artwork_Order__c lao: UserChangedStatusLAOListToUpdate)
            {               
                lao.User_Changed_Status__c = userInfo.getName();
            }
            update UserChangedStatusLAOListToUpdate;   // this updates the User_Changed_Status__c field with current user who submitted the Approval Process
        }
        
        system.debug(AfterApprovalLAOQualitySnapshotsList);
        
        // insert the quality snapshots outside the for loop
        if(AfterApprovalLAOQualitySnapshotsList != null 
           && !AfterApprovalLAOQualitySnapshotsList.isEmpty())
        { 
            insert AfterApprovalLAOQualitySnapshotsList; 
        } //one dml insert
        
        system.debug(ApprovalSubmittedLaoIds);        
        
        system.debug(LaserArtWorkOrderList);
        
        if(LaserArtWorkOrderList != null && !LaserArtWorkOrderList.isEmpty())
        {
            update LaserArtWorkOrderList;
        }           
       
    }    
   
    // Method for updating fields and creating tasks
    public Static void SetOwnerFieldMethod(List<Laser_Artwork_Order__c> NewList, List<Laser_Artwork_Order__c> OldList)
    {       
        Map<Id, Laser_Artwork_Order__c> LaoOldMap = new Map<Id, Laser_Artwork_Order__c>();
        Set<Id> OldLAOIdSet = new Set<Id>();
        
        if(OldList != null){For(Laser_Artwork_Order__c lao: OldList){ LaoOldMap.put(lao.Id, lao); OldLAOIdSet.add(lao.Id);}}
        
        List<Laser_Approval_Process__c> LAPsettings = Laser_Approval_Process__c.getall().values();
        
        system.debug(OldList);
        system.debug(trigger.isUpdate);
        
        // Make lists of lists for collecting data from custom settings
        List<List<String>> LASFieldListList = new List<List<String>>();
        List<List<String>> LFDFieldListList = new List<List<String>>();
        List<List<String>> LASOwnerUpdateOnTrigger = new List<List<String>>();
        List<List<String>> LFDOwnerUpdateOnTrigger = new List<List<String>>();
        List<List<String>> LISOwnerUpdateOnTrigger = new List<List<String>>();
        List<List<String>> CreateQuoteTask = new List<List<String>>();
        List<List<String>> CreateProofsTask = new List<List<String>>();
        List<String> RekFieldSet = new List<String>();
        
        for(Laser_Approval_Process__c lap: LAPsettings)
        {
            // List of status pairs from custom settings that are for updating owner field with LAS name
            List<String> LASOwnerUpdate = new List<String>();
            
            if(lap.Owner_to_LAS__c == True)
            {
                LASOwnerUpdate.add(lap.Order_Type__c); LASOwnerUpdate.add(lap.Order_Status__c);
                LASOwnerUpdateOnTrigger.add(LASOwnerUpdate); 
            }
            
            //List of status pairs from custom settings that are for updating owner field with LFD name 
            List<String> LFDOwnerUpdate = new List<String>();
            
            if(lap.Owner_to_LFD__c == True)
            {
                LFDOwnerUpdate.add(lap.Order_Type__c); LFDOwnerUpdate.add(lap.Order_Status__c);
                LFDOwnerUpdateOnTrigger.add(LFDOwnerUpdate);
            }
            
            // List of status pairs from custom settings that are for updating owner field with LIS name
            List<String> LISOwnerUpdate = new List<String>();
            
            if(lap.Owner_to_LIS__c == true)
            {
                LISOwnerUpdate.add(lap.Order_Type__c); LISOwnerUpdate.add(lap.Order_Status__c);
                LISOwnerUpdateOnTrigger.add(LISOwnerUpdate);
            }  
            
            // List of status pairs from custom settings that are for updating owner field with LAS name when the approval process is rejected
            List<String> LASFieldSet = new List<String>();
            
            if(lap.Rejected_LAS__c == true)
            {
                LASFieldSet.add(lap.Order_Type__c); LASFieldSet.add(lap.Order_Status__c);
                LASFieldListList.add(LASFieldSet); 
            }
            
            // List of status pairs from custom settings that are for updating owner field with LFD name when the approval process is rejected
            List<String> LFDFieldSet = new List<String>();
            
            if(lap.Rejected_LFD__c == true)
            {
                LFDFieldSet.add(lap.Order_Type__c); LFDFieldSet.add(lap.Order_Status__c);
                LFDFieldListList.add(LFDFieldSet);
            }
            
            // List of status pairs from custom settings that are for creating a task with subject 'Quote Follow Up'
            List<String> QuoteTask = new List<String>();
            
            if(lap.TaskQuote_FollowUp__c == true)
            {
                QuoteTask.add(lap.Order_Type__c); QuoteTask.add(lap.Order_Status__c);
                CreateQuoteTask.add(QuoteTask);
            }
            
            // List of status pairs from custom settings that are for creating a task with subject 'Proofs Follow Up'
            List<String> ProofsTask = new List<String>();
            
            if(lap.TaskProofs_FollowUp__c == true)
            {
                ProofsTask.add(lap.Order_Type__c); ProofsTask.add(lap.Order_Status__c);
                CreateProofsTask.add(ProofsTask);
            }     
        }
        
        // 2014-12-11 MK Track_Follow_up__c was not needed in this query (add later if needed)
        List<Task> OldTaskList = new List<Task>([Select Id, WhatId, Subject, Status, OwnerId From Task Where WhatId IN :OldLAOIdSet]);        
        
        system.debug(OldTaskList);
        system.debug(OldLAOIdSet);
        
        for(Laser_Artwork_Order__c lao: NewList)
        {    
            
            RekFieldSet.add(lao.Order_Type__c);
            RekFieldSet.add(lao.Order_Status__c);
            
            System.debug('RekFieldSet---'+RekFieldSet);                                 
        }
        
        // moved below two lines out of the for loop from 398 and 399. because, BusinessDaysCounter method has SOQL query that is causing SOQL governor limit hit
        Date ActivityDate = Date.today();
        Date TaskDueDate = ActivityDate.addDays(ALL_UtilitiesDate.BusinessDaysCounter(date.today(), 3, 'Laser Holiday'));
        // RQ-03605 declare a task list to delete it at the end as per the request RQ-03605
        list<task> TobeUpdatedTaskList = new list<task>();
        list<task> TobeInsertedTaskList = new list<task>();
        
        // set the owner field and create tasks when the trigger fires not related to approval process
        for(Laser_Artwork_order__c lao: NewList)
        {
            for(List<String> s: LASOwnerUpdateOnTrigger)
            {
                if(RekFieldSet.equals(s))
                {                        
                    System.debug(RekFieldSet.equals(s));  
                    System.debug(lao.OwnerId);
                    System.debug(Lao.LAS_Name__c);
                    
                    lao.OwnerId = Lao.LAS_Name__c!=null?lao.LAS_Name__c:userInfo.getUserId();                   
                }                
            }
            
            for(List<String> s: LFDOwnerUpdateOnTrigger)
            {
                if(RekFieldSet.equals(s))
                {                        
                    System.debug(RekFieldSet.equals(s));  
                    System.debug(lao.OwnerId);
                    System.debug(Lao.LFD_Name__c);
                    
                    lao.OwnerId = Lao.LFD_Name__c!=null?lao.LFD_Name__c:userInfo.getUserId();                   
                }                
            }
            
            System.debug('RekFieldSet---'+RekFieldSet);
            System.debug(LISOwnerUpdateOnTrigger.size());
            System.debug(LISOwnerUpdateOnTrigger);
            
            for(List<String> s: LISOwnerUpdateOnTrigger)
            {
                
                if(RekFieldSet.equals(s))
                {                        
                    System.debug(RekFieldSet.equals(s));  
                    System.debug(lao.OwnerId);
                    System.debug(Lao.LIS_Name__c);
                    
                    lao.OwnerId = Lao.LIS_Name__c!=null?lao.LIS_Name__c:userInfo.getUserId();                   
                }                
            }
            
            // set the owner field when the approval is rejected
            if(lao.Is_Approved__c != null)
            {
                System.debug('is Approved---'+lao.Is_Approved__c);
                for(List<String> s: LASFieldListList)
                {
                    if(RekFieldSet.equals(s))
                    {                        
                        System.debug(RekFieldSet.equals(s));  
                        System.debug(lao.OwnerId);
                        System.debug(Lao.LAS_Name__c);
                        
                        lao.OwnerId = Lao.LAS_Name__c!=null?lao.LAS_Name__c:userInfo.getUserId();                   
                    }                
                }
                
                for(List<String> s: LFDFieldListList)
                {
                    if(RekFieldSet.equals(s))
                    {                       
                        System.debug(RekFieldSet.equals(s));
                        System.debug(lao.OwnerId);
                        System.debug(Lao.LFD_Name__c);
                        
                        lao.OwnerId = Lao.LFD_Name__c!=null?lao.LFD_Name__c:userInfo.getUserId();
                    }                
                }
                
                lao.Is_Approved__c = null;
                lao.Order_Status__c = 'Hold-ADP';
            }
            
            // create a task and assign it to the corresponding user on the LAO record.
            
            DS_LAO_ApprovalProcess ClassInstance = new DS_LAO_ApprovalProcess();
            System.debug('CreateQuoteTask---'+CreateQuoteTask);
            System.debug('RekFieldSet---'+RekFieldSet);
            
            if(Trigger.isUpdate)
            {                 
                Set<String> QuoteSubjectSet = new Set<String>();
                Set<String> QuoteStatusSet = new Set<String>();
                Set<String> ProofSubjectSet = new Set<String>();
                Set<String> ProofStatusSet = new Set<String>();
                
                if(OldTaskList != null && !OldTaskList.isEmpty())
                {
                    for(Task ta: OldTaskList)
                    {
                        
                        if(ta.Subject == 'Quote Follow-up' && ta.WhatId == lao.Id)
                        {                        
                            QuoteSubjectSet.add(ta.Subject);
                            QuoteStatusSet.add(ta.Status);
                            
                            system.debug(lao.Order_Status__c);
                            
                            // RQ-03605: collect those tasks which meet the criteria in RQ-03605 and delete them
                            if(lao.Order_Status__c.toLowerCase() == 'q/s approved'){ 
                                TobeUpdatedTaskList.add(ta); }                           
                            
                        }
                        
                        if(ta.Subject == 'Proofs Follow-up' && ta.WhatId == lao.Id)
                        {
                            ProofSubjectSet.add(ta.Subject);
                            ProofStatusSet.add(ta.Status);
                            system.debug('here once');
                            // RQ-03605: collect those tasks which meet the criteria in RQ-03605 and delete them
                            if(lao.Order_Status__c.toLowerCase() == 'approved'
                               || lao.Order_Status__c.toLowerCase() == 'awip'){ 
                                   TobeUpdatedTaskList.add(ta); }                            
                        }                    
                    }
                }
                
                if(QuoteStatusSet.contains('Completed') && QuoteStatusSet.size() > 1){ QuoteStatusSet.remove('Completed'); }
                if(ProofStatusSet.contains('Completed') && ProofStatusSet.size() > 1){ ProofStatusSet.remove('Completed'); }
                
                System.debug(quoteSubjectSet);
                System.debug(quoteStatusSet);
                System.debug(ProofSubjectSet);
                System.debug(ProofStatusSet);                
                
                if ((LaoOldMap.get(lao.Id).Order_Type__c != lao.Order_Type__c && LaoOldMap.get(lao.Id).Order_Status__c != lao.Order_Status__c) || 
                    (LaoOldMap.get(lao.Id).Order_Type__c != lao.Order_Type__c && LaoOldMap.get(lao.Id).Order_Status__c == lao.Order_Status__c) || 
                    (LaoOldMap.get(lao.Id).Order_Type__c == lao.Order_Type__c && LaoOldMap.get(lao.Id).Order_Status__c != lao.Order_Status__c))                   
                {
                    if(QuoteStatusSet.contains('Completed') || QuoteStatusSet.isEmpty())
                    {
                        for(List<String> s: CreateQuoteTask)
                        {
                            if(RekFieldSet.equals(s))
                            {   
                                System.debug(RekFieldSet.equals(s));
                                
                                Task t = new Task();
                                t.WhatId = lao.Id;
                                if(lao.Contact__c != null) { t.WhoId = lao.Contact__c; }
                                t.ActivityDate = TaskDueDate;
                                t.Subject = 'Quote Follow-up';
                                t.OwnerId = Lao.LAS_Name__c != null ? lao.LAS_Name__c : userInfo.getUserId();
                                
                                //Insert t; moved to future method to prevent recursive trigger
                                TobeInsertedTaskList.add(t);      
                            }                
                        } 
                    }
                    
                    if(ProofStatusSet.contains('Completed') || ProofStatusSet.isEmpty())
                    {
                        for(List<String> s: CreateProofsTask)
                        {
                            if(RekFieldSet.equals(s))
                            {
                                System.debug(RekFieldSet.equals(s));
                                Task t = new Task();
                                t.WhatId = lao.Id;
                                if(lao.Contact__c != null) { t.WhoId = lao.Contact__c; }
                                t.ActivityDate = TaskDueDate;
                                t.Subject = 'Proofs Follow-up';
                                t.OwnerId = Lao.LAS_Name__c!=null?lao.LAS_Name__c:userInfo.getUserId();
                                
                                //Insert t; 
                                TobeInsertedTaskList.add(t);                          
                            }                
                        }
                    }                    
                }                
                
                list<task> tasklistIntoMap = new list<task>();
                
                for(task t: OldTaskList)
                {                    
                    if(t.WhatId == lao.Id && t.Status.toLowerCase() != 'completed')
                    {                        
                        tasklistIntoMap.add(t);                        
                    }
                }                
                LaoIdToRelatedTaskList.put(lao.Id, tasklistIntoMap);
            }             
        }
        
        boolean OkayToUpdateTasks = false;
        
        if(TobeUpdatedTaskList != null && !TobeUpdatedTaskList.isEmpty())   
        {                     
            for(task t: TobeUpdatedTaskList)
            {    
                if(t.Status != 'Completed')
                {
                    t.Status = 'Completed';
                    OkayToUpdateTasks = true;
                }              
            }           
        }
        
        // sending tasks to future method for update
        DS_LAO_ApprovalProcess.SerializeObjects(TobeUpdatedTaskList, 'update');
        
        //sending tasks to future method for inserting tasks
        DS_LAO_ApprovalProcess.SerializeObjects(TobeInsertedTaskList, 'insert');               
    } 
    
    public static map<Id, Lao_QualitySnapShots__c> QulaitySnapShotRetriever(list<Laser_Artwork_Order__c> LaoRecords)
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
    
    // This is to update the Task records. moved from the Approval Process Method to avoid the Recursive trigger 
    
    
    public static void SerializeObjects(List<sObject> TobeInsertedsObjectList, string dMlOperation)
    {
        List<sObject> oldList; map<Id, sObject> oldMap; map<Id, sObject> newMap;
        DS_EncapsulationHelperClass TobeInsertedSobjectEncapsule = new DS_EncapsulationHelperClass(
            TobeInsertedsObjectList, oldList, oldMap, newMap);
        
        string SerializedsObjectsToInsert = JSON.Serialize(TobeInsertedSobjectEncapsule);
        
        if(!System.isBatch() && !System.isFuture() && !System.isScheduled() && 
           TobeInsertedsObjectList != null && !TobeInsertedsObjectList.isEmpty()) 
        {
            DS_LAO_ApprovalProcess.FutureUpdateORinsertsObjects(SerializedsObjectsToInsert, dMlOperation);
        }
    }
    
    @future
    public static void FutureUpdateORinsertsObjects(String Serialized, string dMLOperation)
    {
        DS_EncapsulationHelperClass Unserialized = null;      
        
        Unserialized = (DS_EncapsulationHelperClass)JSON.deserialize(serialized, DS_EncapsulationHelperClass.class);
        List<sObject> sObjectListToInsertORUpdate = Unserialized.newSObjectList;        
        
        if(sObjectListToInsertORUpdate != null && !sObjectListToInsertORUpdate.isEmpty())   
        {  
            if(dMLOperation.equalsIgnoreCase('insert')){ Insert sObjectListToInsertORUpdate; } 
            if(dMLOperation.equalsIgnoreCase('update')){ Update sObjectListToInsertORUpdate; }
        }            
    }
}