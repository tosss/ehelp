//2015-01-06- vishal.bandari@cdk.com- Created this class for ItemsToApprove Visualforce page.
//2016-06-14 matt.keefe@cdk.com - updated formatting and added comments.
//2016-06-14 anirudh.singh@cdk.com- Refactored the class and corrected naming conventions.
global class ItemsToApprove_Controller
{
    public String showMessage{get; set;}
    public Boolean renderTable{get; set;}
    public String selectedOption{get; set;}
    public List<ProcessDetails> ItemsToApproveList{get; set;}
    
    public ItemsToApprove_Controller()
    {
        system.debug('Start ItemsToApprove_Controller---->');
        selectedOption='my';
        rerenderTable();
        system.debug('End ItemsToApprove_Controller---->');
    }
    
    public PageReference rerenderTable()
    {
        system.debug('Start rerenderTable---->');
        renderTable=true;
        showMessage='';
        ItemsToApproveList=new List<ProcessDetails>();
        
        try
        {   
            List<ProcessInstance> processInstanceList=fetchProcessInstanceList(selectedOption);
            
            if(processInstanceList.size()!=0)
            {
                Map<Id, String> userIdToNameMap=new Map<Id, String>();
                Map<Id, String> groupIdToNameMap=new Map<Id, String>();
                
                populateGroupAndUserMap(processInstanceList, userIdToNameMap, groupIdToNameMap);
                
                Map<Schema.SobjectType, List<Id>> nametoTargetObjectsMap=fetchNametoTargetObjectsMap(processInstanceList);
                
                Map<Id, Map<String, String>> idToTypeandNameMap=fetchIdToTypeandNameMap(nametoTargetObjectsMap);
                
                ItemsToApproveList=fetchItemsToApproveList(processInstanceList, userIdToNameMap, groupIdToNameMap, idToTypeandNameMap);
            }
            
            if(ItemsToApproveList.size()==0)
            {
                renderTable=false;
                showMessage='No records to display';
            }
            else
            {
                renderTable=true;
            }
        }
        catch(Exception ex)
        {
            renderTable=false;
            showMessage='No records to display';
            System.debug('Exception: ' +ex.getMessage()+' At '+ex.getLineNumber());
        }
        
        system.debug('End rerenderTable---->');
        return Null;
    }
    
    private static List<ProcessInstance> fetchProcessInstanceList(String selectedOption)
    {
        system.debug('Start fetchProcessInstanceList---->');
        List<ProcessInstance> processInstanceList=new List<ProcessInstance>();
        String queryString='SELECT Id, TargetObjectId, CreatedDate, LastActorId,'
            +' (SELECT Id, ActorId, OriginalActorId FROM Steps ORDER BY CreatedDate ASC LIMIT 1),'
            +' (SELECT Id, ActorId FROM WorkItems';
        
        if(selectedOption=='my')
        {
            //Fetching All possible Approval Assigned to Current User
            queryString+=' WHERE ActorId=\''+UserInfo.getUserId()+'\'';
        }
        queryString+=') FROM ProcessInstance';
        
        //2016-06-22- anirudh.singh@cdk.com- Included this IF Block, as in Test Class, the Process Instance get Completed as soon as they are submitted.
        if(!Test.isRunningTest())
        {
            queryString+=' WHERE CompletedDate=null';
        }
        queryString+=' ORDER BY CreatedDate DESC';
        
        processInstanceList=Database.query(queryString);
        
        system.debug('End fetchProcessInstanceList---->');
        return processInstanceList;
    }
    
    private static void populateGroupAndUserMap(List<ProcessInstance> processInstanceList, Map<Id, String> userIdToNameMap, Map<Id, String> groupIdToNameMap)
    {
        system.debug('Start populateGroupAndUserMap---->');
        
        List<Id> requiredUserIds=new List<Id>();
        List<Id> requiredGroupIds=new List<Id>();
        
        List<User> requiredUserList=new List<User>();
        List<Group> requiredGroupList=new List<Group>();
        
        for(ProcessInstance processInstanceRecord: processInstanceList)
        {
            if(processInstanceRecord.WorkItems.size()!=0)
            {
                List<ProcessInstanceWorkItem> processWorkItemsList=processInstanceRecord.WorkItems;
                
                for(ProcessInstanceWorkItem processWorkItemRecord: processWorkItemsList)
                {
                    if(String.valueOf(processWorkItemRecord.ActorId).startswith('005'))
                    {
                        requiredUserIds.add(processWorkItemRecord.ActorId);
                    }
                    else
                    {
                        requiredGroupIds.add(processWorkItemRecord.ActorId);
                    }
                }
            }
            
            if(processInstanceRecord.Steps.size()!=0)
            {
                ProcessInstanceStep processInstanceStep=processInstanceRecord.Steps;
                requiredUserIds.add(processInstanceStep.ActorId);
                requiredUserIds.add(processInstanceStep.OriginalActorId);
                requiredUserIds.add(processInstanceRecord.LastActorId);
            }
        }
        
        requiredUserList=[SELECT Id, FirstName, LastName FROM User WHERE Id=:requiredUserIds];
        requiredGroupList=[SELECT Id, Name FROM Group WHERE Id=:requiredGroupIds];
        
        for(User userRecord: requiredUserList)
        {
            userIdToNameMap.put(userRecord.Id, userRecord.LastName+','+userRecord.FirstName);
        }
        
        for(Group groupRecord: requiredGroupList)
        {
            groupIdtoNameMap.put(groupRecord.Id, groupRecord.Name);
        }
        
        system.debug('End populateGroupAndUserMap---->');
    }
    
    private static Map<Schema.SobjectType, List<Id>> fetchNametoTargetObjectsMap(List<ProcessInstance> processInstanceList)
    {
        system.debug('Start fetchNametoTargetObjectsMap---->');
        
        //Map that maps sobjectType and all its relevant Targetobjects to be Approved and assigned to current user.
        Map<Schema.SobjectType, List<Id>> nametoTargetObjectsMap=new Map<Schema.SobjectType, List<Id>>();
        
        for(ProcessInstance processInstanceRecord: processInstanceList)
        {
            Schema.SobjectType objType=processInstanceRecord.TargetObjectId.getSobjectType();
            
            if(!String.valueOf(objType).contains('__') || String.valueOf(objType).endsWith('__c'))
            {
                if(!nametoTargetObjectsMap.containsKey(objType))
                {
                    nametoTargetObjectsMap.put(objType, new List<Id>());
                }
                
                nametoTargetObjectsMap.get(objType).add(processInstanceRecord.TargetObjectId);
            }
        }
        
        system.debug('End fetchNametoTargetObjectsMap---->');
        return nametoTargetObjectsMap;
    }
    
    private static Map<Id, Map<String, String>> fetchIdToTypeandNameMap(Map<Schema.SobjectType, List<Id>> nametoTargetObjectsMap)
    {
        system.debug('Start fetchIdToTypeandNameMap---->');
        
        //Map that maps sobject Id to sobjectType and sobjectName.
        Map<Id, Map<String, String>> idToTypeandNameMap=new Map<Id, Map<String, String>>();
        
        //Querying to get the Sobject Name from Sobject Map and adding values to 'idToTypeandNameMap'
        for(Schema.SobjectType sObjectType: nametoTargetObjectsMap.keySet())
        {
            List<String> typeIds=new List<string>();
            typeIds=nametoTargetObjectsMap.get(sObjectType);
            
            List<sObject> sObjectList=DataBase.Query('SELECT Id, Name FROM '+sObjectType+' WHERE Id IN: typeIds');
            
            for(sObject sObjectRecord: sObjectList)
            {
                idToTypeandNameMap.put(sObjectRecord.Id, new Map<String,String>());
                idToTypeandNameMap.get(sObjectRecord.Id).put(String.Valueof(sObjectRecord.get('name')), sObjectType.getDescribe().getLabel()); 
            }
        }
        
        system.debug('End fetchIdToTypeandNameMap---->');
        return idToTypeandNameMap;
    }
    
    private static List<ProcessDetails> fetchItemsToApproveList(List<ProcessInstance> processInstanceList, Map<Id, String> userIdToNameMap, 
                                                                Map<Id, String> groupIdToNameMap, Map<Id, Map<String, String>> idToTypeandNameMap)
    {
        system.debug('Start populateItemsToApproveList---->');
        List<ProcessDetails> recordsToApproveList=new List<ProcessDetails>();
        
        //Adding each Approval Record to datatable with coressponding columns
        for(ProcessInstance processInstanceRecord: processInstanceList)
        {
            if(processInstanceRecord.Steps!=Null)
            {                        
                ProcessDetails processDetail=new ProcessDetails();
                
                if(processInstanceRecord.Steps.size()!=0)
                {
                    ProcessInstanceStep processInstanceStep=processInstanceRecord.Steps;
                    processDetail.MostRecentApprover=userIdToNameMap.get(processInstanceStep.OriginalActorId);
                    processDetail.MostRecentApproverId=processInstanceStep.OriginalActorId; 
                    processDetail.DateSubmitted=String.Valueof(DateTime.valueOf(processInstanceRecord.CreatedDate).format('MM/dd/YYYY hh:mm a'));
                }
                
                if(idToTypeandNameMap.containsKey(processInstanceRecord.TargetObjectId))
                {
                    processDetail.RelatedToId=String.valueof(processInstanceRecord.TargetObjectId);
                    processDetail.RelatedTo=String.Valueof(idToTypeandNameMap.get(processInstanceRecord.TargetObjectId).keySet()).remove('{').remove('}');
                    processDetail.Type= String.Valueof(idToTypeandNameMap.get(processInstanceRecord.TargetObjectId).get(processDetail.RelatedTo));
                }
                
                if(processInstanceRecord.WorkItems.size()!=0)
                {
                    List<ProcessInstanceWorkItem> processWorkItemsList=processInstanceRecord.WorkItems;
                    
                    for(ProcessInstanceWorkItem processWorkItemRecord: processWorkItemsList)
                    {
                        ProcessDetails processDetailCopy=new ProcessDetails();
                        processDetailCopy=processDetail.clone();
                        
                        if(String.valueOf(processWorkItemRecord.ActorId).startswith('005'))
                        { 
                            if(processWorkItemRecord.ActorId == UserInfo.getUserId())
                            {
                                processDetailCopy.ReassignApproveurl=processWorkItemRecord.Id;
                                processDetailCopy.AssignedToId=processWorkItemRecord.ActorId; 
                                processDetailCopy.AssignedTo=userIdToNameMap.get(processWorkItemRecord.ActorId);
                                recordsToApproveList.add(processDetailCopy);
                            }
                        }
                        else
                        {
                            processDetailCopy.ReassignApproveurl=null;
                            processDetailCopy.AssignedToId=processWorkItemRecord.ActorId; 
                            processDetailCopy.AssignedTo=groupIdToNameMap.get(processWorkItemRecord.ActorId); 
                            recordsToApproveList.add(processDetailCopy);
                        }
                    } 
                }
                
            }
        }
        
        system.debug('End populateItemsToApproveList---->');
        return recordsToApproveList;
    }
    
    public Class ProcessDetails
    {
        public String AssignedTo{get; set;}
        public String AssignedToId{get; set;}
        public String RelatedTo{get; set;}
        public String RelatedToId{get; set;}
        public String Type{get; set;}
        public String MostRecentApprover{get; set;}
        public String MostRecentApproverId{get; set;}
        public String DateSubmitted {get; set;}
        public String ReassignApproveUrl{get; set;}
    }
}