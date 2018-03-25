/*------------------------------------------------------------
Author:        Vishal Bandari
Description:  Controller for SLS_CampaignLeadList Component
Test Class:    SLS_CampaignLeadList_Test
Created on:    05 March 2016
Code Coverage: 96%
------------------------------------------------------------
History
2016-03-05        vishal.bandari@cdk.com          RQ-06471: Created Class and Added Methods
------------------------------------------------------------*/
public with sharing class SLS_CampaignLeadList_Controller 
{
    
    //Returns All leads Status available for Lead Object
    @AuraEnabled
    public static List<String> getLeadStatus()
    {
        List<String> status = new List<String>();
        List<Schema.PicklistEntry> pickListEntries = Lead.Status.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pickListOption : pickListEntries)
        {
            status.add(pickListOption.getValue());
        } 
        return status;
    }
    
    //Returns Leads List with given Search Criteria on all fields and with pagianton parameters
    @AuraEnabled
    public static List<Lead> getLeads(String CampaignId, List<String> leadStatus,String SearchString,Integer pageNumber,Integer recordsLimit)
    {     
        Integer recordLimit = Integer.valueOf(recordsLimit);
        Integer offset= (Integer.valueOf(pageNumber)-1)*recordLimit;
        String status = String.join(leadStatus,'\' OR status = \'' );
        
        // 2016-03-22 matt.keefe@cdk.com - need to break out query
        return Database.Query(
            'SELECT Id, Name, Company, Phone, Email, Products_of_Interest__c, Current_Account__c, Contact__c, MSR_Notes__c, Description, Status, isConverted '+ 
            'FROM LEAD WHERE ADP_Campaign__c = :CampaignId and (status in: leadStatus) '
            +(SearchString != '' ?'and ( Name Like \'%'+SearchString+'%\' or Company Like \'%'+SearchString+'%\' or Phone Like \'%'
            +SearchString+'%\' or Email Like \'%'+SearchString+'%\' or Products_of_Interest__c includes (\''+SearchString+'\') or Status Like \'%'+SearchString+'%\' )':'')
            +' and IsConverted=false order by LastModifiedDate desc LIMIT :recordLimit offset :offset'
        );
    }
    
    //Returns record count available for Leads List with given Search Criteria on all fields and with pagianton parameters
    @AuraEnabled
    public static Integer getRecordsCount(String CampaignId, List<String> leadStatus,String SearchString)
    {     
        String status = String.join(leadStatus,'\' OR status = \'' );
        List<sobject> sobjectList =  Database.Query(
            'SELECT Id FROM LEAD WHERE ADP_Campaign__c  = :CampaignId and ( status in: leadStatus) '
            +(SearchString != '' ?'and ( Name Like \'%'+SearchString+'%\' or Company Like \'%'+SearchString+'%\' or Phone Like \'%'
            +SearchString+'%\' or Email Like \'%'+SearchString+'%\' or Products_of_Interest__c includes (\''+SearchString+'\') or Status Like \'%'+SearchString+'%\' )':'')
            +' and IsConverted=false');
        if(sobjectList.size() <= 2000)
        {
            return sobjectList.size();
        }
        return 2000;
    }
    
    
    //Mass Updates the Status of Lead Object
    @AuraEnabled
    public static List<Lead> updateStatus(String CampaignId, List<String> leadStatus,String SearchString, List<String> leadIds,String Status,Integer pageNumber,Integer recordsLimit)
    {
        List<Sobject> updatedList = new List<Sobject>();
        for(String leadId :leadIds)
        {
            Sobject leadObject = Schema.getGlobalDescribe().get('lead').newSobject();
            leadObject.put('Id',leadId );
            leadObject.put('status',Status );
            updatedList.add(leadObject);
        }
        
        update updatedList;
        
        return getLeads(CampaignId, leadStatus, SearchString,pageNumber,recordsLimit);
    }
    
    //Fetches Account Details
    @AuraEnabled
    public static Account getAccountDetails(String AccountId)
    {
        return [
            SELECT id, Name, Group__c, Group__r.Name, Site_Type__c, Site_Type__r.Name, 
            Designated_DSM__c,Designated_DSM__r.Name, DSM_DOS__c, Region__c, Key_DOS__c, Key_DOS__r.Name, Key_Rep__c, Key_Rep__r.Name 
            FROM Account 
            WHERE Id =: AccountId
        ];
    }
    
    //Fetches Contact Details
    @AuraEnabled
    public static Contact getContactDetails(String ContactId)
    {
        return [SELECT id, Name, Email, phone, Role__c FROM Contact WHERE id =: ContactId];
    }
    
    
    //Fetches Current UserInfo
    @AuraEnabled
    public static User getCurrentUser()
    {
        return [SELECT Id, Name, FirstName,LastName, Email, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];   
    }
    
    
    //Fetches VendorSystem for given Account
    @AuraEnabled
    public static String getVendorSystem(String AccountId)
    {
        System_at_Dealership__c systemAtDealer= [
            SELECT Id, Vendor__r.Name 
            FROM System_at_Dealership__c 
            WHERE Account__c =: AccountId AND System_Type__c = 'DMS' 
            LIMIT 1
        ];
        
        if(systemAtDealer != null)
        {
            return systemAtDealer.Vendor__r.Name;
        }
        return '';
    }
    
    //Fetches ISR for given Account
    @AuraEnabled
    public static String getISR(String AccountId)
    {
        Account_Team__c accountTeam= [
            SELECT Id, Team_Member__r.Name 
            FROM Account_Team__c 
            WHERE Account__c =: AccountId 
            AND Team_Role__c='Forecasting - Inside Sales Rep' 
            LIMIT 1
        ];
        
        if(accountTeam != null)
        {
            return accountTeam.Team_Member__r.Name;
        }
        return '';
    }
    
    
    //Fetches OpenActivities under given lead
    @AuraEnabled
    public static List<Task> getOpenActivities(String accountId, String leadId, String openActivityFilter)
    {
        Set<String> TASK_OPEN_STATUSES = new Set<String>{'Not Started', 'In Progress', 'Waiting on someone else', 'Deferred','Consult Date Proposed','Consult Date Confirmed' };
            Datetime now = DateTime.now();
        String userId = UserInfo.getUserId();
        List<sobject> openActivities = new List<sobject>();
        openActivities.addAll((List<sobject>)Database.query('SELECT Id,Subject,ReminderDateTime,ActivityDate,WhoId, Who.Name,  Type from Event '
                                                            +'WHERE  WhoId =: LeadId  '
                                                            +(openActivityFilter == 'my' ?' and CreatedById =\''+userId+'\'  '  :'')
                                                            +' ORDER BY LastModifiedDate desc LIMIT 7 '));
        
        openActivities.addAll((List<sobject>)Database.query('SELECT Id,Subject,ReminderDateTime,ActivityDate,WhoId, Who.Name,   Type, Priority, Status from Task '
                                                            +' WHERE  WhoId =: LeadId  and Status IN: TASK_OPEN_STATUSES '
                                                            +(openActivityFilter == 'my' ?' and CreatedById =\''+userId+'\'  '  :'')
                                                            +' ORDER BY LastModifiedDate desc LIMIT 8'));
        openActivities.sort();
        return openActivities;
    }
    
    //Fetches ActivityHistory under given lead
    @AuraEnabled
    public static List<Task> getActivityHistory(String accountId, String leadId, String activityHistoryFilter)
    {
        Set<String> TASK_OPEN_STATUSES = new Set<String>{'Not Started', 'In Progress', 'Waiting on someone else', 'Deferred','Consult Date Proposed','Consult Date Confirmed' };
        Datetime now = DateTime.now();
        String userId = UserInfo.getUserId();
        List<sobject> closedActivities =new List<sobject>();
        closedActivities.addAll((List<sobject>)Database.query('SELECT Id,Subject,ActivityDate,WhoId, Who.Name,  Type from Event '
                                                              +' WHERE WhoId =: LeadId  '
                                                              +(activityHistoryFilter == 'my' ?' and CreatedById =\''+userId+'\'  ':'')
                                                              +' ORDER BY LastModifiedDate desc LIMIT 7 '));
        
        closedActivities.addAll((List<sobject>)Database.query('SELECT Id,Subject,ActivityDate,WhoId, Who.Name,  Type, Priority, Status from Task '
                                                              +' WHERE  WhoId =: LeadId and Status NOT IN: TASK_OPEN_STATUSES '
                                                              +(activityHistoryFilter == 'my' ?' and CreatedById =\''+userId+'\'  '  :'')
                                                              +' ORDER BY LastModifiedDate desc LIMIT 8 '));
        closedActivities.sort();
        return closedActivities;
    }
    
    
    //Converts given lead to Opportunity
    @AuraEnabled
    public static List<Lead> convertLeadToOpportunity(String CampaignId, List<String> leadStatus,String SearchString, String leadId,Integer pageNumber,Integer recordsLimit)
    {
        Sobject leadObject = Schema.getGlobalDescribe().get('lead').newSobject();
        leadObject.put('Id',leadId );
        leadObject.put('status','Converted to Opportunity' );
        update leadObject;
        return getLeads(CampaignId, leadStatus, SearchString,pageNumber,recordsLimit);
    }
    
}