/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Handler for IMP_PostFeedToAsignee trigger that posts feed regarding the project activity assigned
             to the assigned cdk user's
             and sets them as followers of the project and subproject if still not following
Test Class:
History
09/23/14    Kimiko Roberto      Created
10/02/14    Rey Austral         Change the url in msgBodyForContact
11/13/14    Samuel Oberes       used the format method for startDate and endDate in lieu of the first 10 chars of the string value of the date
11/14/14    Samuel Oberes       added ERR_MSG_NO_START_DATE_ASSIGNED and ERR_MSG_NO_END_DATE_ASSIGNED to allow for re-use.
05/12/15    Samuel Oberes       Refactored: instead of 2, calls to IMP_Project_Utility.retrieveEntitySubscription were merged to 1 to lessen SOQL query count
------------------------------------------------------------*/
public class IMP_PostFeedToAsignee_Handler
{


    //public static void postToChatterFeed(List<sObject> sObjectList, Map<Id, sObject> oldSObjectList, Set<Id> subPrjId)
    //{
        
    //    List<FeedItem> feedToPostList = new List<FeedItem>();
    //    //get subproject to be followed through the passed subproject object; this will be used for creation of followers for the subproject and project
    //    List<SubProject__c> subProjectIdList = IMP_Project_Utility.retrieveSubProjectsBySet(IMP_Project_Utility.QUERY_NAME_ID, null, subPrjId);
    //    //List<SubProject__c> subProjectIdList = [SELECT Id, SubProject_Name__c, Project__c, Project__r.Name FROM SubProject__c WHERE Id IN: subPrjId];
        
    //    SubProject__c subProjectId = subProjectIdList.get(0);
    //    List<EntitySubscription> newFollowerList = new List<EntitySubscription>();
    //    Set<EntitySubscription> newFollowersSet = new Set<EntitySubscription>();
        
    //    //get list of followers from the query of subprojects; this will be used if the asignee is already following the project or subproject
    //    //List<EntitySubscription> checkFollowers = IMP_Project_Utility.retrieveEntitySubscription(subProjectId.Id, null, null);
        
    //    //List<EntitySubscription> checkFollowers = [SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId = : subProjectId.Id];
    //    //List<EntitySubscription> checkFollowersPrj = IMP_Project_Utility.retrieveEntitySubscription(subProjectId.Project__c, null, null);
        
    //    //List<EntitySubscription> checkFollowersPrj = [SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId = : subProjectId.Project__c];
    //    //String followerIds = '';
    //    //String followerIdsPrj = '';
        
    //    Set<String> projectAndSubprojectFollowersSet = new Set<String>();

    //    List<EntitySubscription> subscriptions = IMP_Project_Utility.retrieveEntitySubscription(null, new Set<Id> { subProjectId.Id, subProjectId.Project__c }, null);
    //    for (EntitySubscription es : subscriptions)
    //    {
    //        projectAndSubprojectFollowersSet.add(es.ParentId + '|' + es.SubscriberId);
    //    }

    //    //for(EntitySubscription followers : checkFollowers)
    //    //{
    //    //    if(!checkFollowers.isEmpty())
    //    //    {
    //    //        followerIds = followerIds + followers.SubscriberId;
    //    //    }
    //    //}
        
    //    //for(EntitySubscription followers : checkFollowersPrj )
    //    //{
    //    //    if(!checkFollowersPrj.isEmpty())
    //    //    {
    //    //        followerIdsPrj = followerIdsPrj + followers.SubscriberId;
    //    //    }
    //    //}

    //    //iterate from Project activities by using passed project activity object for posting to the users and making them followers of the related project and subproject
    //    for(sObject prj : sObjectList)
    //    {
    //        sObject oldPrj;
    //        if(oldSObjectList != null)
    //        {
    //            oldPrj = oldSObjectList.get(prj.Id);
    //        }
    //        /*
    //        //run only when cdk asignee is updated to a different value and is not equall to null
    //        if(prj.CDK_Assignee__c != oldPrj.CDK_Assignee__c && prj.CDK_Assignee__c != null)
    //        {
    //            String tmpStart = '';
    //            String startDate = '';
    //            String tmpEnd = '';
    //            String endDate = '';
    //            //handler if there are no dates assigned
    //            if(prj.Planned_Start_Date__c == null)
    //            {
    //                startDate = IMP_String_Utility.ERR_MSG_NO_START_DATE_ASSIGNED;
    //            }
    //            else
    //            {
    //                startDate = prj.Planned_Start_Date__c.format();
    //            }
                
    //            if(prj.Planned_End_Date__c == null)
    //            {
    //                endDate = IMP_String_Utility.ERR_MSG_NO_END_DATE_ASSIGNED;
    //            }
    //            else
    //            {
    //                endDate = prj.Planned_End_Date__c.format();
    //            }
    //            //create msg body for the post by getting the project activity description, cdk asignee, start and end dates and subproject's name and url; this will be the message posted to the asignee nad subproject feed
                
    //            //String url = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/';
    //            //String url = '';
    //            String msgBodyForContact = 'Project Activity: ' + prj.Description__c + ' has been assigned to you.\n' + 'SubProject: '+ subProjectId.SubProject_Name__c + ' - ' + url + subProjectId.Id + '\nProject: '+ subProjectId.Project__r.Name + ' - ' + url + subProjectId.Project__c +'\nPlanned Start Date: ' + startDate  + '\nPlanned End Date: ' + endDate;
    //            String msgBodyForSubProject = 'Project Activity: ' + prj.Description__c + ' has been assigned to ' + prj.CDK_Assignee__r.Name + '\nPlanned Start Date: ' + startDate + '\nPlanned End Date: ' + endDate;
                
    //            //add feed items to be posted after the body is created ; two feeds are going to be posted; for the asignee and the subproject
    //            FeedItem newFeedforContact = new FeedItem(ParentId = prj.CDK_Assignee__c, Body = msgBodyForContact);
    //            feedToPostList.add(newFeedforContact);
    //            FeedItem newFeedforSubProject = new FeedItem(ParentId = subProjectId.Id, Body = msgBodyForSubProject);
    //            feedToPostList.add(newFeedforSubProject);
                
                
    //            if(!followerIds.contains(prj.CDK_Assignee__c))
    //            {
    //                EntitySubscription newFollower = new EntitySubscription(ParentId = subProjectId.Id, SubscriberId = prj.CDK_Assignee__c);
    //                if(!newFollowersSet.contains(newFollower))
    //                {
    //                    //add the assignee if still not following subproject
    //                    newFollowersSet.add(newFollower);
    //                }
    //            }
                
    //            //check if already following project
    //            if(!followerIdsPrj.contains(prj.CDK_Assignee__c))
    //            {
    //                EntitySubscription newFollowerPrj = new EntitySubscription(ParentId = subProjectId.Project__c, SubscriberId = prj.CDK_Assignee__c);
    //                if(!newFollowersSet.contains(newFollowerPrj))
    //                {
    //                    //add the asignee if still not following project
    //                    newFollowersSet.add(newFollowerPrj);
    //                }
    //            }
    //        }
    //        */
    //        String tmpStart = '';
    //        String startDate = '';
    //        String tmpEnd = '';
    //        String endDate = '';
    //        String msgBodyForContact = '';
            
    //        if(oldPrj != null && (Id)prj.get('CDK_Assignee__c') != (Id)oldPrj.get('CDK_Assignee__c') && (Id)prj.get('CDK_Assignee__c') != null)
    //        {
    //            system.Debug('**oldPrj: '+oldPrj);
    //            system.Debug('**(Id)prj.get(CDK_Assignee__c): '+(Id)prj.get('CDK_Assignee__c'));
    //            system.Debug('**(Id)oldPrj.get(CDK_Assignee__c): '+(Id)oldPrj.get('CDK_Assignee__c'));
    //            //handler if there are no dates assigned
    //            if((Date)prj.get('Planned_Start_Date__c') == null)
    //            {
    //                startDate = IMP_String_Utility.ERR_MSG_NO_START_DATE_ASSIGNED;
    //            }
    //            else
    //            {
    //                //startDate = prj.Planned_Start_Date__c.format();
    //                //startDate = prj.Planned_Start_Date__c;
    //                Date tmpStartDate = (Date)prj.get('Planned_Start_Date__c');
    //                tmpStartDate.format();
    //                startDate = string.ValueOf(tmpStartDate);
    //            }
                
    //            if((Date)prj.get('Planned_End_Date__c') == null)
    //            {
    //                endDate = IMP_String_Utility.ERR_MSG_NO_END_DATE_ASSIGNED;
    //            }
    //            else
    //            {
    //                //endDate = prj.Planned_End_Date__c.format();
    //                //endDate = prj.Planned_End_Date__c;
    //                Date tmpEndDate = (Date)prj.get('Planned_End_Date__c');
    //                tmpEndDate.format();
    //                endDate = string.ValueOf(tmpEndDate);
    //            }
    //            //remove the url; instead add an instruction to review my project task tab
    //            //String geturl = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/';
    //            //String url = '';
                
                
    //            if(prj.getSobjectType() == Schema.Project_Activity__c.getSObjectType())
    //            {
    //                msgBodyForContact = 'Project Activity: ' + (String)prj.get('Description__c') + ' has been assigned to you.\n' +
    //                'SubProject: '+ subProjectId.SubProject_Name__c + 
    //                '\nProject: '+ subProjectId.Project__r.Name + 
    //                '\nPlanned Start Date: ' + startDate  +
    //                '\nPlanned End Date: ' + endDate;
    //            }
    //            else if(prj.getSobjectType() == Schema.Project_Task__c.getSObjectType())
    //            {
    //                if((String)prj.get('Description__c') == null || (String)prj.get('Description__c') == '')
    //                {
    //                    msgBodyForContact = 'Project Task: A Task has been assigned to you.\n' +
    //                    'SubProject: '+ subProjectId.SubProject_Name__c +
    //                    '\nProject: '+ subProjectId.Project__r.Name +
    //                    '\nPlanned Start Date: ' + startDate  +
    //                    '\nPlanned End Date: ' + endDate +
    //                    '\nYou can check the My Project Tasks tab to see the assigned task.';
    //                }
    //                else
    //                {
    //                    msgBodyForContact = 'Project Task: ' + (String)prj.get('Description__c') + ' has been assigned to you.\n' + 
    //                    'SubProject: '+ subProjectId.SubProject_Name__c +
    //                    '\nProject: '+ subProjectId.Project__r.Name + 
    //                    '\nPlanned Start Date: ' + startDate  + 
    //                    '\nPlanned End Date: ' + endDate + 
    //                    '\nYou can check the My Project Tasks tab to see the assigned task.';
    //                }
                    
                     
    //            }
    //            //add feed items to be posted after the body is created ;
    //            FeedItem newFeedforContact = new FeedItem(ParentId = (Id)prj.get('CDK_Assignee__c'), Body = msgBodyForContact);
    //            feedToPostList.add(newFeedforContact); 

    //            //if(!followerIds.contains((Id)prj.get('CDK_Assignee__c')))
    //            //{
    //            //    EntitySubscription newFollower = new EntitySubscription(ParentId = subProjectId.Id, SubscriberId = (Id)prj.get('CDK_Assignee__c'));
    //            //    if(!newFollowersSet.contains(newFollower))
    //            //    {
    //            //        //add the assignee if still not following subproject
    //            //        newFollowersSet.add(newFollower);
    //            //    }
    //            //}

    //            if (!projectAndSubprojectFollowersSet.contains( (Id)prj.get('SubProject_ID__c') + '|' + (Id)prj.get('CDK_Assignee__c') ))
    //            {
    //                EntitySubscription subprojectFollower = new EntitySubscription(ParentId = (Id)prj.get('SubProject_ID__c'), SubscriberId = (Id)prj.get('CDK_Assignee__c'));
    //                if(!newFollowersSet.contains(subprojectFollower))
    //                {
    //                    //add the assignee if still not following subproject
    //                    newFollowersSet.add(subprojectFollower);
    //                }
    //            }
                
    //            ////check if already following project
    //            //if(!followerIdsPrj.contains((Id)prj.get('CDK_Assignee__c')))
    //            //{
    //            //    EntitySubscription newFollowerPrj = new EntitySubscription(ParentId = subProjectId.Project__c, SubscriberId = (Id)prj.get('CDK_Assignee__c'));
    //            //    if(!newFollowersSet.contains(newFollowerPrj))
    //            //    {
    //            //        //add the asignee if still not following project
    //            //        newFollowersSet.add(newFollowerPrj);
    //            //    }
    //            //}

    //            if (!projectAndSubprojectFollowersSet.contains( (Id)prj.get('Project_ID__c') + '|' + (Id)prj.get('CDK_Assignee__c') ))
    //            {
    //                EntitySubscription projectFollower = new EntitySubscription(ParentId = (Id)prj.get('Project_ID__c'), SubscriberId = (Id)prj.get('CDK_Assignee__c'));
    //                if(!newFollowersSet.contains(projectFollower))
    //                {
    //                    //add the asignee if still not following project
    //                    newFollowersSet.add(projectFollower);
    //                }
    //            }

    //        }
    //        else if((Id)prj.get('CDK_Assignee__c') != null && oldPrj == null)
    //        {
    //            //handler if there are no dates assigned
    //            if((Date)prj.get('Planned_Start_Date__c') == null)
    //            {
    //                startDate = IMP_String_Utility.ERR_MSG_NO_START_DATE_ASSIGNED;
    //            }
    //            else
    //            {
    //                //startDate = prj.Planned_Start_Date__c.format();
    //                //startDate = prj.Planned_Start_Date__c;
    //                Date tmpStartDate = (Date)prj.get('Planned_Start_Date__c');
    //                tmpStartDate.format();
    //                startDate = string.ValueOf(tmpStartDate);
    //            }
                
    //            if((Date)prj.get('Planned_End_Date__c') == null)
    //            {
    //                endDate = IMP_String_Utility.ERR_MSG_NO_END_DATE_ASSIGNED;
    //            }
    //            else
    //            {
    //                //endDate = prj.Planned_End_Date__c.format();
    //                //endDate = prj.Planned_End_Date__c;
    //                Date tmpEndDate = (Date)prj.get('Planned_End_Date__c');
    //                tmpEndDate.format();
    //                endDate = string.ValueOf(tmpEndDate);
    //            }
    //            //remove the url; instead add an instruction to review my project task tab
    //            //String geturl = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/';
    //            //String url = '';
                
                
    //            if(prj.getSobjectType() == Schema.Project_Activity__c.getSObjectType())
    //            {
    //                msgBodyForContact = 'Project Activity: ' + (String)prj.get('Description__c') + ' has been assigned to you.\n' +
    //                'SubProject: '+ subProjectId.SubProject_Name__c + 
    //                '\nProject: '+ subProjectId.Project__r.Name + 
    //                '\nPlanned Start Date: ' + startDate  +
    //                '\nPlanned End Date: ' + endDate;
    //            }
    //            else if(prj.getSobjectType() == Schema.Project_Task__c.getSObjectType())
    //            {
    //                if((String)prj.get('Description__c') == null || (String)prj.get('Description__c') == '')
    //                {
    //                    msgBodyForContact = 'Project Task: A Task has been assigned to you.\n' +
    //                    'SubProject: '+ subProjectId.SubProject_Name__c +
    //                    '\nProject: '+ subProjectId.Project__r.Name +
    //                    '\nPlanned Start Date: ' + startDate  +
    //                    '\nPlanned End Date: ' + endDate +
    //                    '\nYou can check the My Project Tasks tab to see the assigned task.';
    //                }
    //                else
    //                {
    //                    msgBodyForContact = 'Project Task: ' + (String)prj.get('Description__c') + ' has been assigned to you.\n' + 
    //                    'SubProject: '+ subProjectId.SubProject_Name__c +
    //                    '\nProject: '+ subProjectId.Project__r.Name + 
    //                    '\nPlanned Start Date: ' + startDate  + 
    //                    '\nPlanned End Date: ' + endDate + 
    //                    '\nYou can check the My Project Tasks tab to see the assigned task.';
    //                }
                    
                     
    //            }
    //            //add feed items to be posted after the body is created ;
    //            FeedItem newFeedforContact = new FeedItem(ParentId = (Id)prj.get('CDK_Assignee__c'), Body = msgBodyForContact);
    //            feedToPostList.add(newFeedforContact); 

    //            //if(!followerIds.contains((Id)prj.get('CDK_Assignee__c')))
    //            //{
    //            //    EntitySubscription newFollower = new EntitySubscription(ParentId = subProjectId.Id, SubscriberId = (Id)prj.get('CDK_Assignee__c'));
    //            //    if(!newFollowersSet.contains(newFollower))
    //            //    {
    //            //        //add the assignee if still not following subproject
    //            //        newFollowersSet.add(newFollower);
    //            //    }
    //            //}

    //            if (!projectAndSubprojectFollowersSet.contains( (Id)prj.get('SubProject_ID__c') + '|' + (Id)prj.get('CDK_Assignee__c') ))
    //            {
    //                EntitySubscription subprojectFollower = new EntitySubscription(ParentId = (Id)prj.get('SubProject_ID__c'), SubscriberId = (Id)prj.get('CDK_Assignee__c'));
    //                if(!newFollowersSet.contains(subprojectFollower))
    //                {
    //                    //add the assignee if still not following subproject
    //                    newFollowersSet.add(subprojectFollower);
    //                }
    //            }
                
    //            ////check if already following project
    //            //if(!followerIdsPrj.contains((Id)prj.get('CDK_Assignee__c')))
    //            //{
    //            //    EntitySubscription newFollowerPrj = new EntitySubscription(ParentId = subProjectId.Project__c, SubscriberId = (Id)prj.get('CDK_Assignee__c'));
    //            //    if(!newFollowersSet.contains(newFollowerPrj))
    //            //    {
    //            //        //add the asignee if still not following project
    //            //        newFollowersSet.add(newFollowerPrj);
    //            //    }
    //            //}

    //            if (!projectAndSubprojectFollowersSet.contains( (Id)prj.get('Project_ID__c') + '|' + (Id)prj.get('CDK_Assignee__c') ))
    //            {
    //                EntitySubscription projectFollower = new EntitySubscription(ParentId = (Id)prj.get('Project_ID__c'), SubscriberId = (Id)prj.get('CDK_Assignee__c'));
    //                if(!newFollowersSet.contains(projectFollower))
    //                {
    //                    //add the asignee if still not following project
    //                    newFollowersSet.add(projectFollower);
    //                }
    //            }
                
    //        }
            
    //        if(prj.getSobjectType() == Schema.Project_Task__c.getSObjectType())
    //        {
    //            if((Boolean)prj.get('NotifyWhenComplete__c') && (String)prj.get('Status__c') == 'Complete')
    //            {   
    //                String msgBodyForContactTaskComplete = '';
    //                //'The upstream task' + prj.Description__c + 'has been completed, and downstream may begin.'
    //                //posting to proj/subproj removed, while posting to the asignee will retain.
    //                if((String)prj.get('Description__c') == null || (String)prj.get('Description__c') == '')
    //                {
    //                    msgBodyForContactTaskComplete = 'The upstream task has been completed, and downstream may begin.\n'+
    //                    'SubProject: '+ subProjectId.SubProject_Name__c +       
    //                    '\nProject: '+ subProjectId.Project__r.Name +       
    //                    '\nMilestone: '+ (String)prj.getSobject('Project_Activity__r').getSobject('Milestone__r').get('Description__c')+
    //                    '\nActivity: '+ (String)prj.getSobject('Project_Activity__r').get('Description__c')+
    //                    '\nTask: Task';
    //                }
    //                else
    //                {
    //                    msgBodyForContactTaskComplete = 'The upstream task ' + (String)prj.get('Description__c') + ' has been completed, and downstream may begin.\n'+
    //                    'SubProject: '+ subProjectId.SubProject_Name__c +
    //                    '\nProject: '+ subProjectId.Project__r.Name +
    //                    '\nMilestone: '+ (String)prj.getSobject('Project_Activity__r').getSobject('Milestone__r').get('Description__c')+
    //                    '\nActivity: '+ (String)prj.getSobject('Project_Activity__r').get('Description__c')+
    //                    '\nTask: '+ (String)prj.get('Description__c');
                        
                        
    //                }
                    
                    
    //                //add feed items to be posted after the body is created ; 
    //                FeedItem newFeedforContact = new FeedItem(ParentId = subProjectId.Id, Body = msgBodyForContactTaskComplete);
    //                feedToPostList.add(newFeedforContact);
    //            }
    //        }

            
    //    }
        
        
    //    if(!feedToPostList.isEmpty())
    //    {
    //        //post feed to asignees
    //        insert feedToPostList;
            
    //    }
        
    //    if(!newFollowersSet.isEmpty())
    //    {
    //        //insert asignees as new followers to the project and subproject
    //        for(EntitySubscription follower : newFollowersSet)
    //        {
    //            newFollowerList.add(follower);
    //        }
    //        if(!newFollowerList.isEmpty())
    //        {
    //            insert newFollowerList;
    //        }
            
    //    }
        
    //}
    
}