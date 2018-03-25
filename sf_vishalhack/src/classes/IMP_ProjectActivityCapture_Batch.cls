/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Batch implementation of ProjectActivity Capture Process
Test Class: 
History
09/24/14    Michael Lasala      Created
10/07/14    Michael Lasala      Added processing of records inside execute (previously in handler class), Added Database.Stateful to preserve global variables for finish processing
10/07/14    Michael Lasala      Added posting to Subproject chatter feed with mentioned SubProject Project Manager and Project Milestone and Project Activity error details on finish
03/31/15    Samuel Oberes       Replaced project activity references to project task
04/14/15    Samuel Oberes       Changed the query to be more selectable
04/20/15    Samuel Oberes       Fixed the error wherein the feed won't get posted whenever the project manager ID is not supplied
------------------------------------------------------------*/
global class IMP_ProjectActivityCapture_Batch implements Database.Batchable<sObject>, Database.Stateful
{
    //Used for dynamic handling for the handler calss
    global String recordTypeName;
    
    global Map<Id, Id> subProjectPMMap {get;set;}
    global Map<Id, String> subProjectNameMap {get;set;}
    global Map<Id, Map<Id, String>> milestoneMap {get;set;}
    global Map<Id, String> laoMap {get;set;}
    global Map<Id, List<String>> milestoneActivityMap {get;set;}
    
    global IMP_ProjectActivityCapture_Batch()
    {
        recordTypeName = '';
        subProjectPMMap = new Map<Id, Id>();
        subProjectNameMap = new Map<Id, String>();
        milestoneMap = new Map<Id, Map<Id, String>>();
        laoMap = new Map<Id, String>();
        milestoneActivityMap = new Map<Id, List<String>>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext info)
    { 
        String query = '';
        //Retrieve SubProjects where Status != Closed
        if(Test.isRunningtest())
        {
            //Limit records if executing test
            //query = ('SELECT Id FROM SubProject__c WHERE SubProject_Status__c != \'Closed\' Order By CreatedDate desc Limit 50');
            query = ('SELECT SubProject_ID__c FROM Project_Task__C WHERE Project_Activity__r.Milestone__r.Status__c != \'Closed\' AND External_Activity_Name__c != null AND Actual_End_Date__c = null ORDER BY CreatedDate desc Limit 50');
        } 
        else 
        {
            //query = ('SELECT Id FROM SubProject__c WHERE SubProject_Status__c != \'Closed\'');
            query = ('SELECT SubProject_ID__c FROM Project_Task__c WHERE Project_Activity__r.Milestone__r.Status__c != \'Closed\' AND External_Activity_Name__c != null AND Actual_End_Date__c = null');
        }

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, List<sObject> scope)
    { 
        Set<Id> subProjectSet = new Set<Id>();

        for(Sobject o: scope)
        {
            subProjectSet.add((Id)o.get('SubProject_ID__c'));
        }
        
        //Process records
        IMP_ProjectActivityCapture_Handler captureHandler = new IMP_ProjectActivityCapture_Handler();
        List<Project_Task__c> projectTasksForUpdate = captureHandler.IMP_ProjectActivityCapture_Handler(recordTypeName, subProjectSet);
        System.debug('$$$ projectTasksForUpdate: ' + projectTasksForUpdate.size());
        
        if(!projectTasksForUpdate.isEmpty())
        {
            //Used for getting Project Activity data 
            Integer i = 0;
            
            //Update activities, boolean parameter set to false so success records will update
            List<Database.SaveResult> dsrs = Database.Update(projectTasksForUpdate, false);
            
            for(Database.SaveResult dsr : dsrs)
            {
                //Iterate over failure records
                if(!dsr.isSuccess())
                {
                    //Key: Project Milestone Id, Value: Project Milestone Description
                    //Used for naming parent Project Milestone of processed Project Activities
                    Map<Id, String> tempMap = new Map<Id, String>();
                    tempMap.put(projectTasksForUpdate[i].Project_Activity__r.Milestone__c, projectTasksForUpdate[i].Project_Activity__r.Milestone__r.Description__c);
                    
                    //Key: SubProject Id, Value: SubProject Project Manager User Id
                    //Used for setting Chatter subjectId and mention (mentionSegmentInput.Id)
                    subProjectPMMap.put(projectTasksForUpdate[i].SubProject_ID__c, projectTasksForUpdate[i].Project_Activity__r.Milestone__r.SubProject__r.Project_Manager__c);
                    
                    //Key: SubProject Id, Value: SubProject Name
                    //Used for setting SubProject hyperlink on Chatter post
                    subProjectNameMap.put(projectTasksForUpdate[i].SubProject_ID__c, projectTasksForUpdate[i].Project_Activity__r.Milestone__r.SubProject__r.Name);
                    
                    //Key: SubProject Id, Value: Project Milestone map
                    //Used for identifying which Project Milestone belongs to which SubProject
                    if(milestoneMap.containsKey(projectTasksForUpdate[i].SubProject_ID__c))
                    {                        
                        milestoneMap.get(projectTasksForUpdate[i].SubProject_ID__c).put(projectTasksForUpdate[i].Project_Activity__r.Milestone__c, projectTasksForUpdate[i].Project_Activity__r.Milestone__r.Description__c);
                    } 
                    else 
                    {
                        milestoneMap.put(projectTasksForUpdate[i].SubProject_ID__c, tempMap);
                    }
                    
                    //Key: Milestone Id, Value: External System Name
                    //Used for identifying which Project Milestone External System Name belongs to which Project Milestone Id
                    laoMap.put(projectTasksForUpdate[i].Project_Activity__r.Milestone__c, projectTasksForUpdate[i].Project_Activity__r.Milestone__r.External_System_Name__c);
                    
                    //Construct string which consists of the Task Description along with it's error message
                    String taskDescriptionError = String.valueOf(projectTasksForUpdate[i].Description__c+' - '+dsr.getErrors()[0].getMessage());
                    
                    //Key: Project Milestone Id, Value: List<String> Project Activity + error message
                    //Used for identifying which Project Activity belongs to which Project Milestone
                    if(milestoneActivityMap.containsKey(projectTasksForUpdate[i].Project_Activity__r.Milestone__c))
                    {                        
                        milestoneActivityMap.get(projectTasksForUpdate[i].Project_Activity__r.Milestone__c).add(taskDescriptionError);
                    } 
                    else 
                    {
                        List<String> tempList = new List<String>();
                        tempList.add(taskDescriptionError);
                        milestoneActivityMap.put(projectTasksForUpdate[i].Project_Activity__r.Milestone__c, tempList);
                    }
                }
                i++;
            }
            
            System.debug('$$$ subProjectPMMap: ' + subProjectPMMap.keySet() + ', ' + subProjectPMMap.values());
            System.debug('$$$ milestoneMap: ' + milestoneMap.keySet() + ', ' + milestoneMap.values());
            System.debug('$$$ milestoneActivityMap: ' + milestoneActivityMap.keySet() + ', ' + milestoneActivityMap.values());
        }
    }     
    
    global void finish(Database.batchableContext info)
    {
        if(!subProjectPMMap.keySet().isEmpty())
        {
            //For bulk posting of Chatter feeds
            List<ConnectApi.BatchInput> batchInputList = new List<ConnectApi.BatchInput>();
            
            String baseURL = System.Url.getSalesforceBaseURL().toExternalForm();
            System.debug('$$$ baseURL: '+baseURL);
            
            //Iterate over each SubProject
            for(Id subProjectId: subProjectPMMap.keySet())
            {
                //Instantiate ConnectApi.FeedItemInput for posting on Chatter
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                //Assign SubProject Project Manager User Id for mention
                if (subProjectPMMap.get(subProjectId) != null) {
                    mentionSegmentInput.id = subProjectPMMap.get(subProjectId);
                    messageBodyInput.messageSegments.add(mentionSegmentInput);
                    System.debug('$$$ Project Manager: '+subProjectPMMap.get(subProjectId));
                }
                
                //Construct plain text to be included in the post
                String chatterPostText = '';
                chatterPostText = ' Activity Detail Capture Job Failure in '+subProjectNameMap.get(subProjectId)+': '+baseURL+'/'+subProjectId+'\n';
                
                //Iterate over parent Project Milestones of failed Project Activities 
                for(Id milestoneId: milestoneMap.get(subProjectId).keySet())
                {
                    
                    //Add Description for identification
                    chatterPostText += '\n Milestone: '+milestoneMap.get(subProjectId).get(milestoneId)+'\n';
                    System.debug('$$$ Project Milestone: '+milestoneMap.get(subProjectId).get(milestoneId));
                    
                    //Add External Id
                    chatterPostText += 'External ID: '+laoMap.get(milestoneId)+'\n';
                    System.debug('$$$ External Id: '+laoMap.get(milestoneId));
                    
                    chatterPostText += '\n Project Activity:';
                    
                    //Count for number of Project Activities involved
                    Integer count = 0;
                    
                    //Iterate over failed Project Activities
                    for(String activityString: milestoneActivityMap.get(milestoneId))
                    {
                        count++;
                        
                        //Add Description + error message
                        chatterPostText += '\n'+count+'. '+activityString;
                    }
                    System.debug('$$$: Activity: '+milestoneActivityMap.get(milestoneId));
                    
                    //Add line breaks if there are multiple Project Milestones
                    if(milestoneMap.get(subProjectId).keySet().size()>1)
                    {
                        chatterPostText += '\n';
                    }
                }
                System.debug('$$$: chatterPostText: '+chatterPostText);
                
                //Assign plain text value
                textSegmentInput.text = chatterPostText;
                messageBodyInput.messageSegments.add(textSegmentInput);
                
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                
                //Assign ParentId
                feedItemInput.subjectId = subProjectId;
                
                //Used for bulk posting of ConnectApi.FeedItemInput
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                batchInputList.add(batchInput);
            }
            
            //Post Chatter feeds
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputList);
            System.debug('$$$ batchInputList: '+batchInputList.size());
        }
    }
}