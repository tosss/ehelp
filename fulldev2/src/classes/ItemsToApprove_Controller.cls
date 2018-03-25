global class ItemsToApprove_Controller
{
    //Author     : Vishal Bandari
    //Date       : 6th Jan, 2015
    //Description: This controller is used for the ItemsToApprove Visualforce page.
    
    public   String showMessage{get;set;}
    public   Boolean renderTable{get;set;}
    public  String selectedOption{get;set;}
    
    
    public ItemsToApprove_Controller()
    {        
        selectedOption = 'my';
        rerenderTable();
    }
    
    public PageReference rerenderTable()
    {
        renderTable = true;
        showMessage = '';
        try
        {   
            List<ProcessInstance> processInstanceList;
            if(selectedOption=='my')
            {
                //Fetching All possible Approval Assigned to Current User
                processInstanceList = [SELECT Id, TargetObjectId, CreatedDate, LastActorId, (select id, ActorId, OriginalActorId  from Steps Order By CreatedDate Asc Limit 1 ),(select id, ActorId from WorkItems where ActorId=:UserInfo.getUserId())  from ProcessInstance where CompletedDate = null Order By CreatedDate Desc ];
            }
            else 
            {
                processInstanceList = [SELECT Id, TargetObjectId, CreatedDate, LastActorId, (select id, ActorId, OriginalActorId  from Steps Order By CreatedDate Asc Limit 1 ),(select id, ActorId from WorkItems )  from ProcessInstance where CompletedDate = null Order By CreatedDate Desc ];   
            }
            if(processInstanceList.size()!=0)
            {  
                
                //All the Users Required for querying their details                
                List<Id> RequiredUserIds = new List<Id>();
                List<Id> RequiredGroupIds = new List<Id>();
                for(ProcessInstance p:processInstanceList)
                {
                    if(p.WorkItems.size()!=0)
                    {
                        List<ProcessInstanceWorkItem> pWorkItem = p.WorkItems;
                        for(ProcessInstanceWorkItem pwi: pWorkItem)
                        {
                            if(String.Valueof(pwi.ActorId).startswith('005'))
                            {
                                RequiredUserIds.add(pwi.ActorId); 
                            }
                            else
                            {
                                RequiredGroupIds.add(pwi.ActorId);
                            }
                        }
                    }
                    if(p.Steps.size()!=0)
                    {
                        ProcessInstanceStep pStep = p.Steps;
                        RequiredUserIds.add(pStep.ActorId);
                        RequiredUserIds.add(pStep.OriginalActorId);
                        RequiredUserIds.add(p.LastActorId);
                    }
                }
                List<group> requiredGroupList = [select id,name from group where id=:RequiredGroupIds];
                List<user> requiredUserList = [select id, FirstName, LastName from user where id =:RequiredUserIds ];
                
                //Map that maps User Id with Name
                Map<id,String> userIdToNameMap = new Map<id,String>();
                for(User u:requiredUserList)
                {
                    userIdToNameMap.put(u.id, u.LastName+','+u.FirstName);
                }
                
                
                
                Map<id,String> groupIdtoNameMap = new Map<id,String>();
                for(Group g: requiredGroupList)
                {
                    groupIdtoNameMap.put(g.id,g.name);
                }
                
                //Map that maps sobject Id to sobjectType and sobjectName
                Map<id,Map<String,String>> idToTypeandNameMap = new Map<id,Map<String,String>>();
                
                //Map that maps sobjectType and all its relevant Targetobjects to be Approved and assigned to current user
                Map<Schema.SobjectType,List<Id>> NametoTargetObjectsList = new Map<Schema.SobjectType,List<String>>();
                
                for(ProcessInstance p :processInstanceList)
                {
                    Schema.SobjectType objType = p.TargetObjectId.getSobjectType();
                    if(!String.valueOf(objType).contains('__') || String.valueOf(objType).endsWith('__c'))
                    {
                        if(!NametoTargetObjectsList.containsKey(objType))
                        {
                            NametoTargetObjectsList.put(objType,new List<Id>());
                        }
                        NametoTargetObjectsList.get(objType).add(p.TargetObjectId);
                    }
                }
                //Querying to get the Sobject Name from Sobject Map and adding values to 'idToTypeandNameMap'
                for(Schema.SobjectType SobType:NametoTargetObjectsList.keySet())
                {
                    List<String> typeIds = new List<string>();
                    typeIds= NametoTargetObjectsList.get(SobType);
                    List<Sobject> nameofRecord = DataBase.Query('SELECT Id, Name from '+SobType+' where id In: typeIds');
                    for(Sobject s: nameofRecord)
                    {
                        idToTypeandNameMap.put(s.id,new Map<String,String>());
                        idToTypeandNameMap.get(s.id).put(String.Valueof(s.get('name')),SobType.getDescribe().getLabel()); 
                    }
                }  
                ItemsToApproveList = new List<ProcessDetails>();
                //Adding each Approval Record to datatable with coressponding columns
                for(ProcessInstance pInstance:processInstanceList)
                {
                    if(pInstance.Steps != null)
                    {                        
                        ProcessDetails processDetail =  new ProcessDetails();
                        
                        if(pInstance.Steps.size()!=0)
                        {
                            ProcessInstanceStep pStep = pInstance.Steps;
                            processDetail.MostRecentApprover = userIdToNameMap.get(pstep.OriginalActorId);
                            processDetail.MostRecentApproverId = pstep.OriginalActorId; 
                            processDetail.DateSubmitted = String.Valueof(DateTime.valueOf(pInstance.CreatedDate).format('MM/dd/YYYY hh:mm a'));
                        }
                        if(idToTypeandNameMap.containsKey(pInstance.TargetObjectId))
                        {
                            processDetail.RelatedToId = String.valueof(pInstance.TargetObjectId);
                            processDetail.RelatedTo = String.Valueof(idToTypeandNameMap.get(pInstance.TargetObjectId).keySet()).remove('{').remove('}');
                            processDetail.Type= String.Valueof(idToTypeandNameMap.get(pInstance.TargetObjectId).get(processDetail.RelatedTo));
                        }
                        if(pInstance.WorkItems.size()!=0)
                        {
                            List<ProcessInstanceWorkItem> pWorkItem = pInstance.WorkItems;
                            for(ProcessInstanceWorkItem pwi:pWorkItem)
                            {
                                ProcessDetails processDetailCopy = new ProcessDetails();
                                processDetailCopy = processDetail.clone();
                                if(String.valueOf(pwi.ActorId).startswith('005'))
                                { 
                                    if(pwi.ActorId == UserInfo.getUserId())
                                    {
                                        processDetailCopy.ReassignApproveurl = pwi.id;
                                        processDetailCopy.AssignedToId =  pwi.ActorId; 
                                        processDetailCopy.AssignedTo = userIdToNameMap.get(pwi.ActorId);
                                        ItemsToApproveList.add(processDetailCopy);
                                    }
                                }
                                else
                                {
                                        processDetailCopy.ReassignApproveurl =  null;
                                        processDetailCopy.AssignedToId =  pwi.ActorId; 
                                        processDetailCopy.AssignedTo = groupIdToNameMap.get(pwi.ActorId); 
                                        ItemsToApproveList.add(processDetailCopy);
                                }
                            } 
                        }
                        
                    }
                }
            }
            
            if(ItemsToApproveList.size()==0)
            {
                renderTable = false;
                showMessage = 'No records to display';
            }
            else
            {
                renderTable = true;
            }
        }
        catch(Exception e)
        {
            renderTable = false;
            showMessage = 'No records to display';
            System.debug('Exception: ' +e.getMessage()+' At '+e.getLineNumber());
        }
        return null;
    } 
    
    public  List<ProcessDetails> ItemsToApproveList{get;set;}
    public Class ProcessDetails
    {
        public String AssignedTo{get; set;}
        public String AssignedToId{get;set;}
        public String RelatedTo{get; set;}
        public String RelatedToId{get;set;}
        public String Type{get; set;}
        public String MostRecentApprover{get; set;}
        public String MostRecentApproverId{get; set;}
        public String DateSubmitted {get; set;}
        public String ReassignApproveUrl{get;set;}
    }
}