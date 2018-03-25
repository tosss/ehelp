//2016-04-01- anirudh.singh@cdk.com- Created this controller for SLS_ActivityOpportunity lightning component for Request RQ-06734.
public class SLS_ActivityOpportunity_Controller
{
    @AuraEnabled
    public static RecordsWrapper fetchRecords(Id leadId, Id accountId, Id contactId)
    {
        system.debug('Start fetchRecords---->'+leadId+'-'+accountId+'-'+contactId);
        Id userId=UserInfo.getUserId();
        Account accountRecord=[SELECT Id, Name, BillingCity, BillingState, Phone FROM Account WHERE Id=:accountId];
        Contact contactRecord=[SELECT Phone, Email FROM Contact WHERE Id=:contactId];
        
        RecordsWrapper recWrapper=new RecordsWrapper();
        recWrapper.accountRecord=accountRecord;
        recWrapper.contactRecord=contactRecord;
        //Processing for Event Record.
        createNewEventRecord(recWrapper, leadId, userId);
        //Processing for Task Record.
        createNewTaskRecord(recWrapper, leadId, userId);
        
        system.debug('End fetchRecords---->');
        return recWrapper;
    }
    
    //Creating new Task Record.
    private static void createNewTaskRecord(RecordsWrapper recWrapper, Id leadId, Id userId)
    {
        system.debug('Start createNewTaskRecord---->');
        Task newTask=new Task();
        Id defaultTaskRecordTypeId=Null;
        String taskRecordTypeName='';
        
        //Describe the Task object to get all of the available Record Types.
        Schema.DescribeSObjectResult describeTaskResult=Task.SObjectType.getDescribe();
        List<RecordTypeInfo> taskRecordTypeInfosList=describeTaskResult.getRecordTypeInfos();
        
        //Loop through the Task Record Types to get the default Record Type.
        for(RecordTypeInfo recordTypeInfoRef: taskRecordTypeInfosList)
        {
            //If the current Record Type is the default for the current User.
            if(recordTypeInfoRef.isDefaultRecordTypeMapping())
            {
                //Save it for assigning to the new Task.
                defaultTaskRecordTypeId=recordTypeInfoRef.getRecordTypeId();
                taskRecordTypeName=recordTypeInfoRef.getName();
                break;
            }
        }
        
        //Set a default if no default was found.
        if(defaultTaskRecordTypeId==Null) 
        {
            defaultTaskRecordTypeId=[SELECT Id FROM RecordType WHERE sObjectType='Task' AND Name='Baseline Task' LIMIT 1].Id;
            taskRecordTypeName='Baseline Task';
        }
        newTask.WhoId=leadId;
        newTask.OwnerId=userId;
        newTask.Status='Completed';
        newTask.Subject='Call';
        newTask.ActivityDate=date.today();
        newTask.Activity_Type__c='Call';
        newTask.Type='Phone Call';
        newTask.RecordTypeId=defaultTaskRecordTypeId;
        
        //Populating values on recWrapper.
        recWrapper.newTask=newTask;
        recWrapper.taskRecordTypeName=taskRecordTypeName;
        //recWrapper.taskSubjectOptionsMap=fetchPicklistOptionsMap(Task.Subject.getDescribe().getPicklistValues());
        
        if(recWrapper.renderForCobalt)
        {
            Map<String, String> taskTypeMap=new Map<String, String>();
            taskTypeMap.put('--None--', '');
            //taskTypeMap.putAll(fetchPicklistOptionsMap(Task.Type.getDescribe().getPicklistValues()));
            recWrapper.taskTypeMap=taskTypeMap;
        }
        
        system.debug('End createNewTaskRecord---->');
    }
    
    //Creating new Event Record.
    private static void createNewEventRecord(RecordsWrapper recWrapper, Id leadId, Id userId)
    {
        system.debug('Start createNewEventRecord---->');
        Event newEvent=new Event();
        String eventRecordTypeName='';
        Boolean renderForCobalt=false;
        Boolean renderForDS=false;
        Boolean showEventSection=true;
        Campaign_Mgmt_VF_Page_Assign__c pageAssignmentForUserProfile=fetchPageAssignmentSettings();
        List<Id> eventRecordTypeIdList=new List<Id>();
        Map<String, String> eventTypeMap=new Map<String, String>();
        
        if(pageAssignmentForUserProfile!=Null && pageAssignmentForUserProfile.Campaign_VF_Layout__c!=Null 
           && pageAssignmentForUserProfile.Campaign_VF_Layout__c.toLowerCase()=='inside sales')
        {
            renderForCobalt=false;
            renderForDS=true;
            eventRecordTypeIdList.add(ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Event', 'Standard Event'));
            eventRecordTypeName='Standard Event';
            showEventSection=pageAssignmentForUserProfile.Display_Follow_up_Needed__c;
        }
        else
        {
            renderForCobalt=true;
            renderForDS=false;
            eventRecordTypeIdList.add(ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Event', 'Digital Solutions Event'));
            eventRecordTypeName='Digital Solutions Event';
            
            //Fetch Event Type Map.
            eventTypeMap.put('--None--', '');
            //eventTypeMap.putAll(fetchPicklistOptionsMap(Event.Type.getDescribe().getPicklistValues()));
        }
        
        newEvent.WhoId=leadId;
        newEvent.Subject='Call';
        newEvent.OwnerId=userId;
        newEvent.StartDateTime=Datetime.now().addMinutes(60-Datetime.now().minute());
        newEvent.EndDateTime=Datetime.now().addMinutes(120-Datetime.now().minute());
        newEvent.IsReminderSet=false;
        newEvent.IsAllDayEvent=false;
        newEvent.IsPrivate=false;
        newEvent.ShowAs='Busy';
        if(eventRecordTypeIdList.size()>0)
        {
            newEvent.RecordTypeId=eventRecordTypeIdList[0];
        }
        
        Map<String, String> eventShowAsMap=new Map<String, String>();
        eventShowAsMap.put('--None--', '');
        //eventShowAsMap.putAll(fetchPicklistOptionsMap(Event.ShowAs.getDescribe().getPicklistValues()));
        
        //Populating values on recWrapper.
        recWrapper.newEvent=newEvent;
        recWrapper.eventRecordTypeName=eventRecordTypeName;
        recWrapper.renderForCobalt=renderForCobalt;
        recWrapper.renderForDS=renderForDS;
        //recWrapper.eventSubjectOptionsMap=fetchPicklistOptionsMap(Event.Subject.getDescribe().getPicklistValues());
        recWrapper.showCompletedActivitySection=pageAssignmentForUserProfile.Show_Log_a_Call__c;
        recWrapper.showEventSection=showEventSection;
        recWrapper.eventShowAsMap=eventShowAsMap;
        recWrapper.reminderTimesMap=fetchReminderTimesMap();
        recWrapper.eventTypeMap=eventTypeMap;
        
        system.debug('End createNewEventRecord---->');
    }
    
    private static Campaign_Mgmt_VF_Page_Assign__c fetchPageAssignmentSettings()
    {
        system.debug('Start fetchPageAssignmentSettings---->');
        
        Profile currentUserProfile=[
            SELECT Name 
            FROM Profile 
            WHERE Id=:UserInfo.getProfileId() 
            LIMIT 1
        ];
        
        String profileName=currentUserProfile!=Null ? ('\''+currentUserProfile.Name+'\'') : ('\'\'');
        
        List<Campaign_Mgmt_VF_Page_Assign__c> campaignMgmtVFSettingsList=Database.query(
            'SELECT Id, Profile_Name__c, Campaign_VF_Layout__c, Display_Follow_up_Needed__c, Lead_Gen_Checkbox__c, Show_Log_a_Call__c '
            +'FROM Campaign_Mgmt_VF_Page_Assign__c '
            +'WHERE Profile_Name__c='+profileName+' '
        );
        
        if(!campaignMgmtVFSettingsList.isEmpty()) 
        {
            return campaignMgmtVFSettingsList[0]; 
        } 
        
        system.debug('End fetchPageAssignmentSettings---->');
        return new Campaign_Mgmt_VF_Page_Assign__c(); 
    }
    
    /*private static Map<String, String> fetchPicklistOptionsMap(List<Schema.PicklistEntry> picklistValuesList)
    {
        system.debug('Start fetchPicklistOptionsMap---->');
        Map<String, String> picklistOptionsMap=new Map<String, String>();
        
        for(Schema.PicklistEntry pickListOption: picklistValuesList)
        {
            if(pickListOption.isActive())
            {
                picklistOptionsMap.put(pickListOption.getLabel(), pickListOption.getValue());
            }
        } 
        
        system.debug('End fetchPicklistOptionsMap---->');
        return picklistOptionsMap;
    }*/
    
    private static Map<String, String> fetchReminderTimesMap()
    {
        system.debug('Start fetchReminderTimesMap---->');
        Map<String, String> reminderTimesMap=new Map<String, String>();
        reminderTimesMap.put('0 minutes', '0 minutes');
        reminderTimesMap.put('5 minutes', '5 minutes');
        reminderTimesMap.put('10 minutes', '10 minutes');
        reminderTimesMap.put('15 minutes', '15 minutes');
        reminderTimesMap.put('30 minutes', '30 minutes');
        reminderTimesMap.put('1 hour', '1 hour');
        reminderTimesMap.put('2 hours', '2 hours');
        reminderTimesMap.put('3 hours', '3 hours');
        reminderTimesMap.put('4 hours', '4 hours');
        reminderTimesMap.put('5 hours', '5 hours');
        reminderTimesMap.put('6 hours', '6 hours');
        reminderTimesMap.put('7 hours', '7 hours');
        reminderTimesMap.put('8 hours', '8 hours');
        reminderTimesMap.put('9 hours', '9 hours');
        reminderTimesMap.put('10 hours', '10 hours');
        reminderTimesMap.put('11 hours', '11 hours');
        reminderTimesMap.put('0.5 days', '0.5 days');
        reminderTimesMap.put('18 hours', '18 hours');
        reminderTimesMap.put('1 day', '1 day');
        reminderTimesMap.put('2 days', '2 days');
        reminderTimesMap.put('3 days', '3 days');
        reminderTimesMap.put('4 days', '4 days');
        reminderTimesMap.put('1 week', '1 week');
        reminderTimesMap.put('2 weeks', '2 weeks');
        
        system.debug('End fetchReminderTimesMap---->');
        return reminderTimesMap;
    }
    
    @AuraEnabled
    public static String saveDetails(String recWrapperWithChanges)
    {
        system.debug('Start saveDetails---->');
        RecordsWrapper recWrapper=(RecordsWrapper)JSON.deserialize(recWrapperWithChanges, RecordsWrapper.class);
        Event newEvent;
        
        Campaign_Mgmt_VF_Page_Assign__c pageAssignmentForUserProfile=fetchPageAssignmentSettings();
        if(pageAssignmentForUserProfile.Show_Log_a_Call__c)
        {
            insert recWrapper.newTask;
        }
        
        if(recWrapper.showEventSection)
        {
            system.debug('Create Event---->');
            newEvent=modifyEvent(recWrapper);
            insert newEvent;
        }
        
        system.debug('End saveDetails---->');
        return 'Success';
    }
    
    private static Event modifyEvent(RecordsWrapper recWrapper)
    {
        system.debug('Start modifyEvent---->');
        Event newEvent=new Event();
        newEvent=recWrapper.newEvent;
        
        if(recWrapper.newEvent.IsReminderSet)
        {
        	List<String> tempStringList=recWrapper.selectedReminderTime.split(' ');
            
            if(recWrapper.selectedReminderTime.indexOf('minutes')!=-1) 
            {
                newEvent.ReminderDateTime=newEvent.StartDateTime.addMinutes(-1*Integer.valueOf(tempStringList[0]));
            }
            if(recWrapper.selectedReminderTime.indexOf('hour')!=-1)
            {
                newEvent.ReminderDateTime=newEvent.StartDateTime.addHours(-1*Integer.valueOf(tempStringList[0]));
            }
            if(recWrapper.selectedReminderTime.indexOf('day')!=-1)
            {
                if(tempStringList[0]!='0.5')
                {
                    newEvent.ReminderDateTime=newEvent.StartDateTime.addDays(-1*Integer.valueOf(tempStringList[0]));
                }
                else
                {
                    newEvent.ReminderDateTime=newEvent.StartDateTime.addHours(-12);
                }
            }
            if(recWrapper.selectedReminderTime.indexOf('week')!=-1)
            {
                newEvent.ReminderDateTime=newEvent.StartDateTime.addDays(-1*7*Integer.valueOf(tempStringList[0]));
            }
        }
        
        system.debug('End modifyEvent---->');
        return newEvent;
    }
    
    public class RecordsWrapper
    {
        @AuraEnabled
        public Account accountRecord{get; set;}
        
        @AuraEnabled
        public Contact contactRecord{get; set;}
        
        @AuraEnabled
        public Task newTask{get; set;}
        
        @AuraEnabled
        public String taskRecordTypeName{get; set;}
        
        @AuraEnabled
        public Map<String, String> taskSubjectOptionsMap{get; set;}
        
        @AuraEnabled
        public Map<String, String> taskTypeMap{get; set;}
        
        @AuraEnabled
        public Event newEvent{get; set;}
        
        @AuraEnabled
        public String eventRecordTypeName{get; set;}
        
        @AuraEnabled
        public Boolean renderForCobalt{get; set;}
        
        @AuraEnabled
        public Boolean renderForDS{get; set;}
        
        @AuraEnabled
        public Map<String, String> eventSubjectOptionsMap{get; set;}
        
        @AuraEnabled
        public Map<String, String> eventTypeMap{get; set;}
        
        @AuraEnabled
        public Map<String, String> eventShowAsMap{get; set;}
        
        @AuraEnabled
        public Map<String, String> reminderTimesMap{get; set;}
        
        @AuraEnabled
        public String selectedReminderTime{get; set;}
        
        @AuraEnabled
        public Boolean showEventSection{get; set;}
        
        @AuraEnabled
        public Boolean showCompletedActivitySection{get; set;}
    }
}