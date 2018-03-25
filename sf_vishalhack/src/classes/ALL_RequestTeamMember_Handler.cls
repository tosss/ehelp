/*.......................................................................................................................
. Author		:	lalitha.adduru@cdk.com                     
. Description	:	Handler class for All_RequestTeamMembers-    
.               	Trigger on Request_Team_Member__c           
. Date			:	July 2015 
. Note			:	Tried using a set to store the to-be updated requests ( especially during bulk operations ). Despite 
.					that, it threw a duplicate Id exception. Turns out that, as we are dealing with instances of 
.					Request__c, two instances pointing to the same object will still be two differet instances in memory,
.					therefore we can end up having two entries of the same request in the set. So it should only be a map
.					and we can do operations using Map.values().
.........................................................................................................................*/                     

public class ALL_RequestTeamMember_Handler {
    
    /*...........................................................................    
    . Harcoded String Constants to compare the role which the User belongs to.	
    . The Values assigned should be the values in the Picklist Role__c			
    . on Request_Team_Member__c								                   	
    . .........................................................................*/
    Static final string SFDEV = 'SF Developer';
    Static final string EXTDEV = 'External Developer';
    Static final string SFCONFADMIN = 'SF Config Admin';
    Static final string RELMANAGER = 'Release Manager';
    Static final string TECHREVIEWER = 'Technical Reviewer';
    Static final string BUSINESSANALYST = 'Business Analyst';
    Static final string QATESTER = 'QA Tester';
    Static final string PROJECTMANAGER = 'Project Manager';
    
    // Delimiter to separate User Names 
    Static final string DELIMITER = ', ';
    
    // Error message to show, when a duplicate Request Team Member is about to be added
    Static final string DUPLICATERECORD = 'This Request Team Member has already been added';
    
    /*....................................................................... 
    . Author		: 	lalitha.adduru@cdk.com                            	
    . Description	:	This method takes a list of RequestTeamMembers and 	
    . 					returns a map of corresponding Request__c fields            	
    . Arguments		:	List of Request Team Member records	
    .					In this case, it's trigger.new or trigger.old
    .......................................................................*/
    public Map<Id,Request__c> getRequestMap( List<Request_Team_Member__c> rtmList )
    {
        List<Id> reqIds = new List<Id>();
        
        // add all Request__c from Request_Team_Member__c list , into a list
        for(Request_Team_Member__c rtm : rtmList)
        {
            reqIds.add(rtm.Request__c);
        }

        String RequestQuery = 'select Id, Business_Analysts__c, SF_Developers__c, SF_Config_Admins__c, Project_Managers__c, External_Developers__c,QA_Testers__c, All_Request_Team_Members__c, Release_Managers__c,Technical_Reviewers__c,( ' + 
            ' SELECT id, User__c, Request__c, Role__c FROM Request_Team_Members__r ' +
            ') ' + 
            'from Request__c ' + 
            'where Id in :reqIds ';
        
        // fetch the required details of the requests using soql
        Map<Id, Request__c> reqMap = new Map<Id, Request__c>((List<Request__c>)Database.query(RequestQuery));
        
        return reqMap;
    }
    
    /*....................................................................... 
    . Author		: 	lalitha.adduru@cdk.com                            	
    . Description	:	This method takes a list of RequestTeamMembers and 	
    . 					returns a map of corresponding User__c fields            	
    . Arguments		:	List of Request Team Member records					
    .......................................................................*/
    public Map<Id,User> getUserMap( List<Request_Team_Member__c> rtmList )
    {
        List<Id> userIds = new List<Id>();
        for(Request_Team_Member__c rtm : rtmList)
        {
            userIds.add(rtm.User__C);
        }
        Map<Id,User> userMap = new Map<Id, User>([
            select Id, Name 
            from User 
            where Id in :userIds
        ]);
        return userMap;
    }
    
    /*....................................................................... 
    . Author		: 	lalitha.adduru@cdk.com                            	
    . Description	:	This method takes a list of Request__c and 	
    . 					returns a map of corresponding Request_Team_Member__c
    .					list.
    . Arguments		:	List of Request Team Member records					
    .......................................................................*/
    public Map<Id,List<Request_Team_Member__c>> getReqToReqTeamMembersMap(List<Request__c> requestList)
    {
        Map<Id, List<Request_Team_Member__c>> ReqToReqTeamMembersMap = new Map<id, List<Request_Team_Member__c>>();
        for(Request__c req : requestList)
        {
            List<Request_Team_Member__c> rttms = new List<Request_Team_Member__c>();
            rttms = req.getSobjects('Request_Team_Members__r');
            reqToReqTeamMembersMap.put(req.id,rttms);
        }
        return ReqToReqTeamMembersMap;
        
    }
    
    /*....................................................................... 
    . Author		: 	lalitha.adduru@cdk.com                            	
    . Description	:	This method is used to find if a request team member
    .					is already present on a Request.
    . Arguments		:	A request team member record and a map of request to
    .					its corresponding list of requestTeamMembers.
    .......................................................................*/
    public boolean isAlreadyPresent(Request_Team_Member__c rtmToCheck, Map< id, List<Request_Team_Member__c> > ReqToReqTeamMembersMap)
    {
        boolean isAlreadyPresent = false;
        List<Request_Team_Member__c> rtmList = new List<Request_Team_Member__c>();
        rtmList = ReqToReqTeamMembersMap.get(rtmToCheck.Request__c);
        if(rtmList != null)
        {
            for(Request_Team_Member__c rtm : rtmList )
            {
                if(rtmToCheck.id != rtm.id && rtmToCheck.Role__c == rtm.Role__c && rtmToCheck.User__c == rtm.User__c)
                {
                    isAlreadyPresent = true;
                }
            }
        }
        return isAlreadyPresent;
    }
    
    /*................................................................................................ 
	. Author		: 	lalitha.adduru@cdk.com                            	
	. Description	:	This method is executed after an insert operation on Request_Team_Member__c.
	.					It includes updating corresponding requests by adding/removing relevant users  
	.					to/from their respective groups.
	. Arguments		:	List of Request Team Member records	( in this case, it's trigger.new )				
	.................................................................................................*/
    public Void updateRequestsAfterInsert( List<Request_Team_Member__c> rtms_current )
    {
        List<Request__c> requestListToUpdate = new List<Request__c>(); // To store the list of to-be updated Requests
        Map<Id, Request__c> requestsToUpdateMap = new Map<Id, Request__c>(); //To prevent the duplicacy error.	
        
        Map<Id, Request__c> newReqMap = getRequestMap(rtms_current); // Map to store request details from trigger.new
        Map<Id,User> newUserMap = getUserMap(rtms_current); // Map to store user details from trigger.new
        
        // Map to store request --> request team member list 
        Map<Id,List<Request_Team_Member__c>> ReqToReqTeamMembersMap = new Map<Id,List<Request_Team_Member__c>>();
        ReqToReqTeamMembersMap = getReqToReqTeamMembersMap(newReqMap.values());
        
        // For each User__c in new Request_Team_Member__c, add that User to the corresponding role in Request__c
        for(Request_Team_member__c rtm: rtms_current)
        {
            // check if it's already present on the request record
            if(!isAlreadyPresent(rtm, ReqToReqTeamMembersMap))
            {
                requestListToUpdate.add( addUserTo_A_RoleInRequest( rtm, newReqMap.get( rtm.Request__c ), newUserMap.get( rtm.User__c ) ) );
            }
            else
            {
                rtm.AddError(DUPLICATERECORD);            
            }
        }
        if(requestListToUpdate != null && requestListToUpdate.size() > 0)
        {
            requestsToUpdateMap.putAll( requestListToUpdate ); // put all the values from list into a map to avoid duplicate Id errors
            try
            {
                update requestsToUpdateMap.values();
            }
            catch(Exception ex)
            {
                ex.getMessage();
            }
        }
    }
    
    /*................................................................................................ 
    . Author		: 	lalitha.adduru@cdk.com                            	
    . Description	:	This method is executed after an Delete operation on Request_Team_Member__c.
    .					It includes updating corresponding requests by removing relevant users  
    .					from their respective groups.
    . Arguments		:	List of Request Team Member records	( In this case, it's trigger.old )				
    .................................................................................................*/
    public Void updateRequestsafterDelete( List<Request_Team_Member__c> rtms_old )
    {
        List<Request__c> requestListToUpdate = new List<Request__c>();
        Map<Id, Request__c> requestsToUpdateMap = new Map<Id, Request__c>();
        
        Map<Id, Request__c> oldreqMap = getRequestMap(rtms_old); // Map to store request details from rtms_old
        Map<Id,User> oldUserMap = getUserMap(rtms_old); // Map to store user details from rtms_old
        
        // removing users from their paticular roles from corresponding requests
        for(Request_team_Member__c rtm : rtms_old)
        {
            requestListToUpdate.add( removeUserFrom_A_RoleInRequest( rtm,oldreqmap.get( rtm.Request__c ),oldusermap.get( rtm.User__c ) ) );
        }
        
        // add all values from set to a List to call update
        requestsToUpdateMap.putAll(requestListToUpdate);
        try
        {
            update requestsToUpdateMap.values();
        }
        catch(Exception ex)
        {
            ex.getMessage();
        }
    }
    
    /*................................................................................................ 
    . Author		: 	lalitha.adduru@cdk.com                            	
    . Description	:	This method is executed after an Update operation on Request_Team_Member__c.
    .					It includes updating corresponding requests by adding/removing relevant users  
    .					to/from their respective groups.
    . Arguments		:	List of Request Team Member records	
    .					In this case, it's trigger.oldMap, trigger.new, in that order.
    .................................................................................................*/
    public Void UpdateRequestsAfterUpdate( Map<Id, Request_Team_Member__c> rtms_oldMap, List<Request_Team_Member__C> rtms_new )
    {
        List<Request__c> requestListToUpdate = new List<Request__c>();
        Map<Id, Request__c> requestsToUpdateMap = new Map<Id, Request__c>();
        
        Map<Id, Request__c> newReqMap = getRequestMap(rtms_new); // Map to store request details from trigger.new
        Map<Id,User> newUserMap = getUserMap(rtms_new); // Map to store user details from trigger.new
        Map<Id, Request__c> oldreqMap = getRequestMap(rtms_oldMap.values()); // Map to store request details from trigger.new
        Map<Id,User> oldUserMap = getUserMap(rtms_oldMap.values()); // Map to store user details from trigger.new
        
        // Map to store request --> request team member list
        Map<Id,List<Request_Team_Member__c>> oldReqToReqTeamMembersMap = new Map<Id,List<Request_Team_Member__c>>();
        oldReqToReqTeamMembersMap = getReqToReqTeamMembersMap(oldreqMap.values());
        
        // Map to store request --> request team member list ( this is used when the request field is getting updated)
        Map<Id,List<Request_Team_Member__c>> newReqToReqTeamMembersMap = new Map<Id,List<Request_Team_Member__c>>();
        newReqToReqTeamMembersMap = getReqToReqTeamMembersMap(newreqMap.values());
        
        List<Request_team_Member__c> rtms = rtms_new;
        Request__c req_new = new Request__c();
        
        for(Request_team_Member__c rtm : rtms)
        { 
            // if request is getting updated, check if the new request team member is already present in the updated request record
            if(rtm.Request__c != rtms_oldmap.get(rtm.Id).Request__c)
            {
                if(!isAlreadyPresent(rtm,newReqToReqTeamMembersMap ))
                {
                    // if only request is getting updated
                    if(rtm.Request__c != rtms_oldmap.get(rtm.Id).Request__c && rtm.Role__c == rtms_oldmap.get(rtm.Id).Role__c && newUserMap.get(rtm.user__c) == oldUserMap.get(rtms_oldmap.get(rtm.Id).user__c ))
                    {
                        requestListToUpdate.add(addUserTo_A_RoleInRequest(rtm,newReqMap.get(rtm.Request__c),newUserMap.get(rtm.User__c)));
                        requestListToUpdate.add(removeUserFrom_A_RoleInRequest(rtm,oldReqMap.get(rtms_oldmap.get(rtm.Id).Request__c),newUserMap.get(rtm.User__c)));
                    }
                    
                    // if role and request are getting updated 
                    else if(rtm.Role__c != rtms_oldmap.get(rtm.Id).Role__c && rtm.Request__c != rtms_oldmap.get(rtm.Id).Request__c && newUserMap.get(rtm.user__c) == oldUserMap.get(rtms_oldmap.get(rtm.Id).user__c))
                    {	
                        requestListToUpdate.add(addUserTo_A_RoleInRequest(rtm,newReqMap.get(rtm.Request__c),newUserMap.get(rtm.User__c)));
                        requestListToUpdate.add(removeUserFrom_A_RoleInRequest(rtms_oldmap.get(rtm.Id),oldReqMap.get(rtms_oldmap.get(rtm.Id).Request__c),newUserMap.get(rtm.User__c)));
                    }
                    
                    // if user and request or all three are getting updated 
                    else if(newUserMap.get(rtm.user__c) != oldUserMap.get(rtms_oldmap.get(rtm.Id).user__c) && rtm.Request__c != rtms_oldmap.get(rtm.Id).Request__c)
                    {
                        requestListToUpdate.add(addUserTo_A_RoleInRequest(rtm,newReqMap.get(rtm.Request__c),newUserMap.get(rtm.User__c)));
                        requestListToUpdate.add(removeUserFrom_A_RoleInRequest(rtms_oldmap.get(rtm.Id),oldReqMap.get(rtms_oldmap.get(rtm.Id).Request__c),oldUserMap.get(rtms_oldmap.get(rtm.Id).user__c)));                
                    }
                }
                else
                {
                    rtm.addError(DUPLICATERECORD);
                }
            }
            else
            {
                // if request is not getting updated, it's enough to check for duplicates on the same request
                if(!isAlreadyPresent(rtm,oldReqToReqTeamMembersMap))                
                {
                    //request details from trigger.new
                    req_new = newReqMap.get(rtm.Request__c);
                    
                    // If only role is getting updated
                    if(rtm.Role__c != rtms_oldmap.get(rtm.Id).Role__c && newUserMap.get(rtm.user__c) == oldUserMap.get(rtms_oldmap.get(rtm.Id).user__c) && rtm.Request__c == rtms_oldmap.get(rtm.Id).Request__c)
                    {
                        req_new = addUserTo_A_RoleInRequest(rtm,req_new,newUserMap.get(rtm.user__c));
                        req_new = removeUserFrom_A_RoleInRequest(rtms_oldmap.get(rtm.Id),newReqMap.get(rtm.Request__c),newUserMap.get(rtm.user__c));                
                        requestListToUpdate.add(req_new);
                    }            
                    
                    // if only user is getting updated 
                    else if(newUserMap.get(rtm.user__c) != oldUserMap.get(rtms_oldmap.get(rtm.Id).user__c) && rtm.Role__c == rtms_oldmap.get(rtm.Id).Role__c && rtm.Request__c == rtms_oldmap.get(rtm.Id).Request__c)
                    {
                        req_new = addUserTo_A_RoleInRequest(rtm,req_new,newUserMap.get(rtm.User__c));
                        req_new = removeUserFrom_A_RoleInRequest(rtms_oldmap.get(rtm.Id),req_new,oldUserMap.get(rtms_oldmap.get(rtm.Id).user__c));              
                        requestListToUpdate.add(req_new);
                    }                  
                    
                    // if role and user are getting updated
                    else if(rtm.Role__c != rtms_oldmap.get(rtm.Id).Role__c && newUserMap.get(rtm.user__c) != oldUserMap.get(rtms_oldmap.get(rtm.Id).user__c) && rtm.Request__c == rtms_oldmap.get(rtm.Id).Request__c)
                    {
                        req_new = addUserTo_A_RoleInRequest(rtm,req_new,newusermap.get(rtm.user__c));
                        req_new = removeUserFrom_A_RoleInRequest(rtms_oldmap.get(rtm.Id),req_new,oldusermap.get(rtms_oldmap.get(rtm.Id).user__c));
                        requestListToUpdate.add(req_new);
                    } 
                }
                else
                {
                    rtm.AddError(DUPLICATERECORD);
                }
            }
        }
        
        if(requestListToUpdate != null && requestListToUpdate.size() > 0)
        {
            requestsToUpdateMap.putAll( requestListToUpdate ); // put all the values from list into a map to avoid duplicate Id errors
            try
            {
                update requestsToUpdateMap.values();
            }
            catch(Exception ex)
            {
                ex.getMessage();
            }
        }
    }
    
    
    /*.................................................................................................. 
    . Author		: 	lalitha.adduru@cdk.com                            	
    . Description	:	This method is called from updateRequestsAfterInsert and UpdateRequestsAfterUpdate
    .					methods.
    .					It includes adding relevant users to their respective groups.
    . Arguments		:	A request team member, its corresponding request and user	
    ....................................................................................................*/
    public Request__c addUserTo_A_RoleInRequest( Request_Team_Member__c rtm, Request__c req, User usr )
    {
        // full Name of user to be added
        String fullName; fullName = usr != null ? usr.Name : null;
        string memberRole; memberRole = rtm != null ? rtm.Role__c : null;
        
        List<String> usersToBeAdded = new List<String>();
        usersToBeAdded.add(fullName);
        
        if(memberRole == SFDEV)
        {            
            usersToBeAdded.add(req.SF_Developers__c);
            req.SF_Developers__c = ALL_UtilitiesString.ListToDelimitedString(usersToBeAdded, DELIMITER);
            system.debug('added sf dev -- >'+req.SF_Developers__c);
            
        }
        else if(memberRole == BUSINESSANALYST)
        { 
            usersToBeAdded.add(req.Business_Analysts__c);
            req.Business_Analysts__c = ALL_UtilitiesString.ListToDelimitedString(usersToBeAdded, DELIMITER);
            system.debug('added BA  -- >'+req.Business_Analysts__c);            
        }
        else if(memberRole == PROJECTMANAGER)
        { 
            usersToBeAdded.add(req.Project_Managers__c);
            req.Project_Managers__c = ALL_UtilitiesString.ListToDelimitedString(usersToBeAdded, DELIMITER);
            system.debug('added Project Manager  -- >'+req.Project_Managers__c);            
        }
        else if(memberRole == SFCONFADMIN)
        {
            usersToBeAdded.add(req.SF_Config_Admins__c);
            req.SF_Config_Admins__c = ALL_UtilitiesString.ListToDelimitedString(usersToBeAdded, DELIMITER );
            system.debug('added Config Admin  -- >'+req.SF_Config_Admins__c);
        }
        else if(memberRole == QATESTER)
        {
            //usersToBeAdded.add(string.valueOf(req.get(rdf.QA_Testers_API_Name__c)));
            //req.put(rdf.QA_Testers_API_Name__c, ALL_UtilitiesString.ListToDelimitedString(usersToBeAdded, DELIMITER ));
            usersToBeAdded.add(req.QA_Testers__c);
            req.QA_Testers__c = ALL_UtilitiesString.ListToDelimitedString(usersToBeAdded, DELIMITER );
            system.debug('added QA Tester  -- >'+string.valueOf(req.QA_Testers__c));
        }
        else if(memberRole == EXTDEV)
        {
            usersToBeAdded.add(req.External_Developers__c);
            req.External_Developers__c = ALL_UtilitiesString.ListToDelimitedString(usersToBeAdded, DELIMITER);
            system.debug('add ext dev -- > '+req.External_Developers__c);
        }
        else if(memberRole == RELMANAGER)
        {
            usersToBeAdded.add(req.Release_Managers__c);
            req.Release_Managers__c = ALL_UtilitiesString.ListToDelimitedString(usersToBeAdded, DELIMITER);
            system.debug('add rel man -- > '+req.Release_Managers__c);
        }
        else if(memberRole == TECHREVIEWER)
        {
            //usersToBeAdded.add(string.valueOf(req.get(rdf.Technical_Reviewers_Field_API_Name__c)));
            //req.put(rdf.Technical_Reviewers_Field_API_Name__c, ALL_UtilitiesString.ListToDelimitedString(usersToBeAdded, DELIMITER ));
            usersToBeAdded.add(req.Technical_Reviewers__c);
            req.Technical_Reviewers__c = ALL_UtilitiesString.ListToDelimitedString(usersToBeAdded, DELIMITER);
            system.debug('add code reviewer -- > '+req.Technical_Reviewers__c );
        }
        req = updateAllRequestTeamMembersInRequest( req );
        return req; 
    }
    
    
    /*................................................................................................... 
    . Author		: 	lalitha.adduru@cdk.com                            	
    . Description	:	This method is called from updateRequestsAfterDelete and updateRequestsAfterUpdate
    .					methods.
    . Arguments		:	A request team member, its corresponding request and user	
    ....................................................................................................*/
    public Request__c removeUserFrom_A_RoleInRequest( Request_Team_Member__c rtm, Request__c req, User usr )
    {
        // different possibilities for a particular user name to be present in any role field in request
        List<String> stringsToBeRemoved = new List<String>();
        stringsToBeRemoved.add(DELIMITER + usr.Name); 
        stringsToBeRemoved.add(usr.Name + DELIMITER);  
        stringsToBeRemoved.add(usr.Name); 
        
        string memberRole; memberRole = rtm != null ? rtm.Role__c : null;
        
        if(memberRole == SFDEV)
        { 
            req.sf_developers__c = ALL_UtilitiesString.removeListOfStringsFromString(req.Sf_developers__c, stringsToBeRemoved, DELIMITER);
            system.debug('after removing sf dev -- >'+req.SF_Developers__c);
        }
        else if(memberRole == BUSINESSANALYST)
        {
            req.Business_Analysts__c = ALL_UtilitiesString.removeListOfStringsFromString(req.Business_Analysts__c, stringsToBeRemoved, DELIMITER);                
            system.debug('after removing BA  -- >'+req.Business_Analysts__c);
        }
        else if(memberRole == PROJECTMANAGER)
        {
            req.Project_Managers__c = ALL_UtilitiesString.removeListOfStringsFromString(req.Project_Managers__c, stringsToBeRemoved, DELIMITER);                
            system.debug('after removing Project Manager  -- >'+req.Project_Managers__c);
        }
        else if(memberRole == SFCONFADMIN)
        {
            req.SF_Config_Admins__c = ALL_UtilitiesString.removeListOfStringsFromString(req.SF_Config_Admins__c, stringsToBeRemoved, DELIMITER);
            system.debug('after removing Config Admin  -- >'+req.SF_Config_Admins__c);
        }
        else if(memberRole == EXTDEV)
        {
            req.External_Developers__c = ALL_UtilitiesString.removeListOfStringsFromString(req.External_Developers__c, stringsToBeRemoved, DELIMITER);
            system.debug('after removing ext dev -- > '+req.External_Developers__c);
        }
        else if(memberRole == RELMANAGER)
        {
            req.Release_Managers__c = ALL_UtilitiesString.removeListOfStringsFromString(req.Release_Managers__c, stringsToBeRemoved, DELIMITER);
            system.debug('after removing rel man -- > '+req.Release_Managers__c);
        }
        else if(memberRole == QATESTER)
        {
            //Request_Dereference_Fields__c rdf = Request_Dereference_Fields__c.getOrgDefaults();
            //req.put(rdf.QA_Testers_API_Name__c, ALL_UtilitiesString.removeListOfStringsFromString(string.valueOf(req.get(rdf.QA_Testers_API_Name__c)), stringsToBeRemoved));
            req.QA_Testers__c = ALL_UtilitiesString.removeListOfStringsFromString(req.QA_Testers__c, stringsToBeRemoved, DELIMITER);
            system.debug('added QA Tester  -- >'+string.valueOf(req.QA_Testers__c));
        }
        else if(memberRole == TECHREVIEWER)
        {
            //Request_Dereference_Fields__c rdf = Request_Dereference_Fields__c.getOrgDefaults();
            //req.put(rdf.Technical_Reviewers_Field_API_Name__c, ALL_UtilitiesString.removeListOfStringsFromString(string.valueOf(req.get(rdf.Technical_Reviewers_Field_API_Name__c)), stringsToBeRemoved));
            req.Technical_Reviewers__c = ALL_UtilitiesString.removeListOfStringsFromString(req.Technical_Reviewers__c, stringsToBeRemoved, DELIMITER);
            system.debug('after removing code reviewer -- > '+string.valueOf(req.Technical_Reviewers__c));
        }
        req = updateAllRequestTeamMembersInRequest( req );
        return req;
    }
    
    /*....................................................................... 
    . Author		: 	lalitha.adduru@cdk.com                            	
    . Description	:	This method takes a Request__c record and 	
    . 					modifies All_Request_Team_Members__c field. It is 
    .					called from removeUserFrom_A_RoleInRequest and
    .					addUserTo_A_RoleInRequest after modifying the role 
    .					fields.
    . Arguments		:	Request__c 					
    .......................................................................*/
    public Request__c updateAllRequestTeamMembersInRequest( Request__c request )
    {   
        // List of all request team members
        List<String> stringsToBeConcatenated = new List<String>();
        stringsToBeConcatenated.add( request.External_Developers__c );
        stringsToBeConcatenated.add( request.SF_Developers__c );
        stringsToBeConcatenated.add( request.Business_Analysts__c );
        stringsToBeConcatenated.add( request.Release_Managers__c );
        stringsToBeConcatenated.add( request.Technical_Reviewers__c );
        stringsToBeConcatenated.add( request.SF_Config_Admins__c );
        stringsToBeConcatenated.add( request.QA_Testers__c );
        stringsToBeConcatenated.add( request.Project_Managers__c );
        
        /* Concatenated string of all RequestTeamMembers ( May contain duplicate User Names
		since a User can be assigned multiple roles in the same request ) */
        String allTeamMembers = ALL_UtilitiesString.ListToDelimitedString( stringsToBeConcatenated, DELIMITER );
        
        // removing all duplicate User Names
        allTeamMembers = ALL_UtilitiesString.removeDuplicatesFromDelimitedString( allTeamMembers, DELIMITER );
        
        // setting the All_Request_Team_Members__c field to the final string
        request.All_Request_Team_Members__c = allTeamMembers;
        
        return request;
    }
}