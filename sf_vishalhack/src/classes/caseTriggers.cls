/*
    Class does three things:
    
    1)  Updates Parent_Case_Owner__c field on Case if case has a parent.
    2)  Updates case team members based on prior owner when owner changed
    3)  Updates related list on Case_Time__c with how long each owner/queue has owned case
*/
//2016-08-05- anirudh.singh@cdk.com- Commented the code for Case_Time__c object and corrected indentation.
//CB_CaseUserManagement
public without sharing class caseTriggers
{
    public static Boolean run=true;
    
    public static GlobalSettings gs=GlobalSettings.getInstance(null);
    public static Boolean RunCustom=(!GlobalSettings.BypassCaseTriggersTrigger);
    
    public static Map<Id, User> AllUsers=new Map<Id, User>();
    
    //RQ-08446
    public static void updateCaseTerminationEmail(List<Case> caseNewLists,Map<Id,Case> caseOldMap)
    {
        system.debug('updateCaseTerminationEmail started');
        Map<Id,Contact> contactsMap = new Map<Id,Contact>();
        List<Id> contactIds = new List<Id>();
        for(Case caseObj : caseNewLists)
        {
            Case oldCase = caseObj.Id == null ? new Case() : caseOldMap.get(caseObj.Id);
            if(caseObj.ContactId != null && caseObj.ContactId != oldCase.ContactId)
            {
                contactIds.add(caseObj.ContactId);
            }
        }
        contactsMap = new Map<Id,Contact>([SELECT Id,HR_Business_Partner__c, HR_Business_Partner__r.Email FROM Contact WHERE Id IN: contactIds]);
        system.debug('retrived contacts from caseTriggers -- >'+contactsMap.values()[0].HR_Business_Partner__r.Email);
        for(Case caseObj : caseNewLists)
        {
            Case oldCase = caseObj.Id == null ? new Case() : caseOldMap.get(caseObj.Id);
            if(caseObj.ContactId != null && caseObj.ContactId != oldCase.ContactId)
            {
                caseObj.WF_CC_Email__C = contactsMap.get(caseObj.ContactId).HR_Business_Partner__r.Email;
                system.debug('HR_Business_Partner__r -- >'+caseObj.WF_CC_Email__C);
            }
        }
        system.debug('updateCaseTerminationEmail ended');
    }
    public static void caseUpdates(Map<Id, Case> tNewMap, Map<Id, Case> tOldMap)
    {
        if(RunCustom && run) 
        {
            //2013-11-07 - query all users into a map to get owner fields
            AllUsers=new Map<Id, User>([
                Select Id, UserName, Email, 
                ProfileId, Profile.Name, IsActive 
                From User 
                Where IsActive=true
            ]);
            
            //Case setup query
            Set<Id> caseIds=new Set<Id>();
            caseIds.addAll(tNewMap.keySet());
            
            Map<Id, Case> csSetup=new Map<Id, Case>([
                SELECT Id, Parent_Case_Owner__c, Owner.Id, Owner.Email, Owner.Name, 
                Parent.Owner.Id, Parent.Owner.Email, Parent.Owner.Name, Parent.Status, Status, Owner.IsActive, 
                (
                    SELECT Id, Parent_Case_Owner__c, Status 
                    FROM Cases
                ), 
                //2016-08-05- anirudh.singh@cdk.com- Commented the below query.
                //(
                //    SELECT Id, Case__c, External_ID__c, Case_Owner__c, Case_Owner_Id__c, Time_on_Case__c 
                //    FROM Case_Times__r
                //),
                (
                    SELECT Id, ParentId, MemberId 
                    FROM TeamMembers
                )
                FROM Case
                WHERE Id IN :caseIds
            ]);
                                                      
            //Get list of active owners -
            Set<Id> activeUsers=new Set<Id>();
            
            for(Case c: csSetup.values())
            {
                if(c.Owner.IsActive)
                {
                    activeUsers.add(c.OwnerId);
                }
            }
            
            if(tOldMap!=null)
            {
                List<Case> caseOldList=tOldMap.values();
                List<Id> oldUserIds=new List<Id>();
                
                for(Case c: caseOldList)
                {
                    User oldOwner=AllUsers.get(c.OwnerId);
                    
                    //If the oldOwner is a group, it would not be found in the User list, 
                    //and the variable would be null. Only add to the activeUsers list if
                    //it is both a User and Active.
                    if(oldOwner!=null && oldOwner.IsActive)
                    {
                        activeUsers.add(oldOwner.Id);
                    }
                }
            }
            
            //Copy the email from a parent down to any children
            Map<Id, Case> casesToUpdateMap=new Map<Id, Case>();
            for(Case p: tNewMap.values())
            {
                Case suc=csSetup.get(p.Id);
                
                if(p.ParentId!=null && p.Status!='Closed' && suc.Status!='Closed')
                {
                    Case cs=new Case(Id=p.Id, Parent_Case_Owner__c=suc.Parent.Owner.Email);
                    casesToUpdateMap.put(p.Id, cs);
                }
                
                if(suc.Cases!=null)
                {
                    for(Case c: csSetup.get(p.Id).Cases)
                    {
                        if(c.Status!='Closed')
                        {
                            Case cs=new Case(Id=c.Id, Parent_Case_Owner__c=suc.Owner.Email);
                            casesToUpdateMap.put(c.Id, cs);
                        }
                    }
                }
            }
            
            if(casesToUpdateMap.size()>0)
            {
                run=false;
                try
                {
                    update casesToUpdateMap.values(); 
                }
                catch(Exception e)
                {
                    //Do nothing.
                }
                run=true;
            }
            
            
            //The following logic is for updates only.
            if((tOldMap!=null && tOldMap.size()>0) || DSCB_CloneAnything.InsertFromMassCloneApp==true) 
            {
                List<CaseTeamMember> ctms=new List<CaseTeamMember>();
                
                for(Case newCase: tNewMap.values()) 
                {
                    if((newCase.Id!=null && tOldMap.containsKey(newCase.Id)) || DSCB_CloneAnything.InsertFromMassCloneApp==true) 
                    {
                        Case oldCase=tOldMap.get(newCase.Id);
                        String CTMOwnerId=null;
                        
                        if(oldCase==null) 
                        {
                            oldCase=new Case();
                            CTMOwnerId=userInfo.getUserId(); 
                        } 
                        else 
                        {
                            CTMOwnerId=oldCase.OwnerId; 
                        }
                        
                        //Check for 005, which is User record.
                        if(newCase.OwnerId!=oldCase.OwnerId && CTMOwnerId.startsWith('005')) 
                        {
                            //Loop through existing members and make sure no duplicate exists.
                            Boolean ctmExists=false;
                            
                            for (CaseTeamMember ctm: csSetup.get(newCase.Id).TeamMembers) 
                            {
                                if (ctm.MemberId==CTMOwnerId) 
                                {
                                    ctmExists=true;
                                    break;
                                }
                            }
                            
                            if (!ctmExists) 
                            {
                                // The new case owner is not the same as the old case owner; i.e. the case has changed owners
                                CaseTeamMember ctm=new CaseTeamMember();
                                ctm.ParentId=newCase.Id;
                                ctm.MemberId=CTMOwnerId;
                                ctm.TeamRoleId=gs.CASE_TEAM_ROLE_ID;
                                
                                if(activeUsers.contains(CTMOwnerId) || DSCB_CloneAnything.InsertFromMassCloneApp)
                                {
                                    if(newCase.OwnerId == userInfo.getUserId() && DSCB_CloneAnything.InsertFromMassCloneApp)
                                    {
                                        //Do nothing.
                                    }
                                    else
                                    {
                                        ctms.add(ctm);
                                    }
                                }
                            }
                        }
                    }
                }
                
                if(ctms.size()>0)
                {
                    try
                    {
                        insert ctms;
                    }
                    catch(exception e)
                    {
                        system.debug(e.getMessage());
                    }
                }
                
                //2016-08-05- anirudh.singh@cdk.com- Commented the below line.
                //Calculate case times
                //List<Case_Time__c> caseTimesToUpsert=new List<Case_Time__c>();
                
                //Find all the old users' names.
                Map<Id, SObject> idUserGroupMap=new Map<Id, SObject>();
                
                for(Case oldCase: tOldMap.values())
                {
                    idUserGroupMap.put(oldCase.OwnerId, null);
                }
                
                if(idUserGroupMap.size()>0)
                {
                    Map<Id, sObject> tempIdUserMap=new Map<Id, sObject>([SELECT Id, Name FROM User WHERE Id IN :idUserGroupMap.keySet()]);
                    idUserGroupMap.putAll(tempIdUserMap);
                    
                    Map<Id, sObject> tempIdGroupMap=new Map<Id, sObject>([SELECT Id, Name FROM Group WHERE Id IN :idUserGroupMap.keySet()]);
                    idUserGroupMap.putAll(tempIdGroupMap);
                    
                    //idUserGroupMap.putAll((Map<Id, SObject>) new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :idUserGroupMap.keySet()]));
                    //idUserGroupMap.putAll((Map<Id, SObject>) new Map<Id, Group>([SELECT Id, Name FROM Group WHERE Id IN :idUserGroupMap.keySet()]));
                }
                
                //2016-08-05- anirudh.singh@cdk.com- Commented the below code.
                //for(Case newCase: tNewMap.values()) 
                //{
                //    //Only continue if this is an update, not an insert.
                //    if(newCase.Id!=null && tOldMap.containsKey(newCase.Id))
                //    {
                //        Case oldCase=tOldMap.get(newCase.Id);
                
                //        Map<Id, Case_Time__c> ownerCTmap=new Map<Id, Case_Time__c>();
                //        for(Case_Time__c ct: csSetup.get(newCase.Id).Case_Times__r)
                //        {
                //            ownerCTmap.put(ct.Case_Owner_Id__c, ct);
                //        }
                
                //        Id hoursToUse=newCase.BusinessHoursId!=null?newCase.BusinessHoursId:gs.BIZ_HOURS_ID;
                
                //        if(oldCase!=null)
                //        {
                //            Case_Time__c ct=ownerCTmap.get(oldCase.OwnerId);
                
                //            if(ct==null)
                //            {
                //                ct=new Case_Time__c();
                //                ct.Case__c=oldCase.Id;
                //                ct.Case_Owner__c=(String)idUserGroupMap.get(oldCase.OwnerId).get('Name');
                //                ct.Case_Owner_Id__c=oldCase.OwnerId;
                //                ct.External_ID__c=oldCase.OwnerId+'_'+oldCase.Id;
                //                ct.Time_on_Case__c=0;
                //            }
                
                //            Double timeSinceLastStatus=0;
                
                //            if(oldCase.LastModifiedDate!=null)
                //            {
                //                timeSinceLastStatus=BusinessHours.diff(hoursToUse, oldCase.LastModifiedDate, System.now())/60000.0;
                //            }
                
                //            ct.Time_on_Case__c+=timeSinceLastStatus;
                //            caseTimesToUpsert.add(ct);
                //        }
                //    }
                //}
                
                //if(caseTimesToUpsert.size()>0)
                //{
                //    upsert caseTimesToUpsert External_ID__c;
                //}
            } 
        }
    }
    
    public static void CaseTriggerCases(list<Case> CaseTriggerCases, map<ID, Case> NewMap, map<ID, Case> OldMap)
    { 
        map<Id, Case> FilteredTriggerNewMap=new map<Id, Case>();
        map<Id, Case> FilteredTriggerOldMap=new map<Id, Case>();
        
        if(CaseTriggerCases!=null && !CaseTriggerCases.isEmpty())
        {
            for(Case c: CaseTriggerCases)
            {
                Case NewMapCase=NewMap!=null ? NewMap.get(c.Id) : null; 
                if(NewMapCase!=null)
                {
                    FilteredTriggerNewMap.put(c.Id, NewMapCase);
                }
                
                Case OldMapCase=OldMap!=null ? OldMap.get(c.Id) : null; 
                if(OldMapCase!=null)
                {
                    FilteredTriggerOldMap.put(c.Id, OldMapCase);
                }
            }
        }
        
       
        if(!FilteredTriggerNewMap.isEmpty()) 
        { 
            caseTriggers.caseUpdates(FilteredTriggerNewMap, FilteredTriggerOldMap); 
        }
    }
    
    /*public static void updateParentOwnerEmail(Map<Id, Case> tNewMap, Map<Id, Case> tOldMap){
        if (RunCustom && run) {
            List<Case> cases=tNewMap.values();
            // Start email carryover
            List<Case> casesWithParents=new List<Case>();
            for(Case c : cases){
                if(c.ParentId != null){
                    casesWithParents.add(c);
                }
            }
            
            
            List<Case> children=[select Id, ParentId, Subject from Case where ParentId in :cases];
            for (Case child : children) 
                parentIds.add(child.ParentId);
            
            List<Case> casesWithChildren=[SELECT c.Id, (SELECT cc.Id, cc.ParentId FROM Cases cc)
                FROM Case c
                WHERE c.Id IN :Cases];
                                                
            List<Id> parentIds=new List<Id>();
            for (Case cc : casesWithParents){
                parentIds.add(cc.ParentId);
            }
            for (Case c : casesWithChildren){
                for(Case cc : c.Cases){
                    parentIds.add(cc.ParentId);
                }
            }
                                                
            List<Case> parentCases=[SELECT Id, OwnerId
                FROM Case
                WHERE Id IN :parentIds];
                                                
            List<Id> ownerIds=new List<Id>();
            
            for (Case cc : parentCases){
                ownerIds.add(cc.OwnerId);
            }
            for (Case cc : casesWithParents){
                ownerIds.add(cc.OwnerId);
            }
            
            List<User> owners=[SELECT Id, Email, UserRoleId, Name
                FROM User
                WHERE Id IN :ownerIds];
            
            Map<Id, String> caseParentsEmailMap=new Map<Id, String>();
            Map<Id, Id> caseParentsMap=new Map<Id, Id>();
            Map<Id, Id> ownerRoleMap=new Map<Id, Id>();
            for(User u : owners){
                ownerRoleMap.put(u.Id, u.UserRoleId);
            }
            
            for(Case cc : parentCases){
                caseParentsMap.put(cc.Id, cc.OwnerId);
            }
            for(User uu : owners){
                caseParentsEmailMap.put(uu.Id, uu.Email);
            }
            
            List<Case> casesToUpdate=new List<Case>();
            for(Case cc : casesWithParents){
                system.debug('1 First Map:   '+caseParentsMap.get(cc.ParentId));
                system.debug('1 Second Map:   '+caseParentsEmailMap.get(caseParentsMap.get(cc.ParentId)));
                casesToUpdate.add(new Case(Id=cc.Id, Parent_Case_Owner__c=caseParentsEmailMap.get(caseParentsMap.get(cc.ParentId))));
            }
            for(Case c : casesWithChildren){
                for(Case cc : c.Cases){
                    system.debug('2 First Map:   '+caseParentsMap.get(cc.ParentId));
                    system.debug('2 Second Map:   '+caseParentsEmailMap.get(caseParentsMap.get(cc.ParentId)));
                    casesToUpdate.add(new Case(Id=cc.Id, Parent_Case_Owner__c=caseParentsEmailMap.get(caseParentsMap.get(cc.ParentId))));
                }
            }
            
            run=false;
            update casesToUpdate;
            run=true;
        }
    }
        
    public static void shareCase(Map<Id, Case> tNewMap, Map<Id, Case> tOldMap){
        if (RunCustom && run) {
            List<Case> casesToUpdate=new List<Case>();
            
            // Start case share
            List<CaseTeamMember> caseMembersToInsert=new List<CaseTeamMember>();
            
            if(tOldMap != null){
                CaseTeamRole ctrRole=[ SELECT Id, Name
                    FROM    CaseTeamRole
                    WHERE    Name='Case Team Member'];
                        
                List<Case> oldCases=tOldMap.values();
                Set<Id> oldOwners=new Set<Id>();
                for(Case c : oldCases){
                    oldOwners.add(c.OwnerId);
                }
                
                List<CaseTeamMember> existingCaseTeamMembers=[SELECT Id, MemberId, ParentId
                    FROM    CaseTeamMember
                    WHERE    MemberId IN :oldOwners
                    AND ParentId IN :oldCases];
                
                system.debug('CTM Size:  '+existingCaseTeamMembers.size());
                system.debug('CTM Records:  '+existingCaseTeamMembers);
                
                Map<Id, Set<Id>> existingCaseMap=new Map<Id, Set<Id>>();
                for(Id u : oldOwners){
                    Set<Id> tempSet=new Set<Id>();
                    for(CaseTeamMember ctm : existingCaseTeamMembers){
                        if (u == ctm.MemberId){
                            tempSet.add(ctm.ParentId); 
                        }
                    }
                    existingCaseMap.put(u, tempSet);
                }
                
                for (Case cc : oldCases){
                    Case caseOld=tOldMap.get(cc.Id);
                    Case caseNew=tNewMap.get(cc.Id);
                    system.debug('old owner-----------------------:  '+caseOld.OwnerId);
                    system.debug('new owner-----------------------:  '+caseNew.OwnerId);
                    if(caseOld.OwnerId != caseNew.OwnerId){
                        system.debug('debug false-------------------');
                        Set<Id> tempSet=existingCaseMap.get(caseOld.OwnerId);
                        if (tempSet.contains(cc.Id) == false){
                            system.debug('contains false--------------------');
                            String t=caseOld.OwnerId;
                            if(t.startsWith('005')){
                                CaseTeamMember ctm=new CaseTeamMember(MemberId=caseOld.OwnerId, ParentId=cc.Id, TeamRoleId=ctrRole.Id);
                                caseMembersToInsert.add(ctm);
                            }
                        }
                    }
                }
            }
            // End Case share
            
            run=false;
            if(!casesToUpdate.isEmpty()) update casesToUpdate;
            system.debug('casesToUpdate update size  '+casesToUpdate.size());
            if(caseMembersToInsert.size() > 0){
                system.debug('Case Members Insert  '+caseMembersToInsert.size());
                insert caseMembersToInsert;
            }
            run=true;
        }
    }
    
    public static void calcCaseTime(Map<Id, Case> tNewMap, Map<Id, Case> tOldMap){
        if (RunCustom && run) {
            List<Case> newCaseList=tNewMap.values();
            List<Case> oldCaseList=tOldMap.values();
            List<Case> existingCaseTimes=[SELECT Id, 
                (SELECT Id, Case__c, External_ID__c, Case_Owner__c, Time_on_Case__c
                    FROM Case_Times__r)
                    FROM    Case
                    WHERE    Id IN :oldCaseList
                    OR     Id IN :newCaseList];
                                                            
            List<Id> ownerIds=new List<Id>();
            for(Case c : newCaseList){
                ownerIds.add(c.OwnerId);
            }
            for(Case c : oldCaseList){
                ownerIds.add(c.OwnerId);
            }
            
            List<User> userList=[SELECT Id, Name FROM User WHERE Id IN :ownerIds];
            List<Group> groupList=[SELECT Id, Name FROM Group WHERE Id IN :ownerIds];
            
            Map<Id, String> ownerMap=new Map<Id, String>();
            for(User u : userList){
                ownerMap.put(u.Id, u.Name);
            }
            
            for(Group g : groupList){
                ownerMap.put(g.Id, g.Name);
            }
            
            // Map of Case ID -> User Id -> Existing Case Time Double                                        
            Map<Id, Map<String, Double>> caseTimeUserMap=new Map<Id, Map<String, Double>>();
            for(Case c : existingCaseTimes){
                Map<String, Double> tempMap=new Map<String, Double>();
                for(Case_Time__c cc : c.Case_Times__r){
                    tempMap.put(cc.Case_Owner__c, cc.Time_on_Case__c);
                }
                caseTimeUserMap.put(c.Id, tempMap);
            }
            
            List<Case_Time__c> caseTimesToUpdate=new List<Case_Time__c>();
            
            //Get the default business hours (we might need it)
            BusinessHours defaultHours=[select Id from BusinessHours where IsDefault=true];
            
            for (Case c : newCaseList){
                Case oldCase=tOldMap.get(c.Id);
                Id hoursToUse=c.BusinessHoursId!=null?c.BusinessHoursId:defaultHours.Id;
                // Div by 60k for minutes, div by 360k for hours
                Double timeSinceLastStatus=BusinessHours.diff(hoursToUse, oldCase.LastModifiedDate, System.now())/60000.0;
                
                if(oldCase.OwnerId == c.OwnerId){
                    String ExternalID=c.OwnerId+'_'+c.Id;
                    Double caseTime=caseTimeUserMap.get(c.Id).get(ownerMap.get(c.OwnerId));
                    system.debug('First Map:   '+caseTimeUserMap.get(c.Id));
                    system.debug('Second Map:  '+caseTimeUserMap.get(c.Id).get(ownerMap.get(c.OwnerId)));
                    if(caseTime == null)caseTime=0;
                    caseTime=caseTime+timeSinceLastStatus;
                    Case_Time__c ct=new Case_Time__c(Case_Owner__c=ownerMap.get(c.OwnerId), External_ID__c=ExternalID, Case__c=c.Id, Time_on_Case__c=caseTime);
                    caseTimesToUpdate.add(ct);
                } else {
                    String ExternalID=oldCase.OwnerId+'_'+c.Id;
                    Double caseTime=caseTimeUserMap.get(c.Id).get(ownerMap.get(oldCase.OwnerId));
                    if(caseTime == null)caseTime=0;
                    caseTime=caseTime+timeSinceLastStatus;
                    Case_Time__c ct=new Case_Time__c(Case_Owner__c=ownerMap.get(oldCase.OwnerId), External_ID__c=ExternalID, Case__c=c.Id, Time_on_Case__c=caseTime);
                    caseTimesToUpdate.add(ct);
                }
            }
            
            upsert caseTimesToUpdate External_ID__c;
        }
    }*/
}