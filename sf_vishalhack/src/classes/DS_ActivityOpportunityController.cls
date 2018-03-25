/*---------------------------------------
09/10/15 -Venkata Shrivol - Changed the if condition for upserting new Task in 'save' method
2016-03-28   vishal.bandari@cdk.com           RQ-06471: to open page from Work My leads Page
2016-03-31   vishal.bandari@cdk.com           RQ-06471: to open page from Work My leads Page with lead Details
-----------------------------------------*/
//2016-06-27- anirudh.singh@cdk.com- Modified for RQ-07284 (Campaign Manager) Logged Activity - not tied to Account.

public class DS_ActivityOpportunityController 
{
    // variables
    
    public Task newTask;
    public Event followUpEvent;
    public Account acct;
    public Campaign_Account_Members__c campAcctMem;
    public String reminderTime; 
    public String CampaignMemberStatus;
    public Contact contact;
    public List<SelectOption> options=new List<SelectOption>(); 
    public List<SelectOption> remOptions=new List<SelectOption>(); 
    public Contact_Relationship__c contactRelationship{get;set;}
    Boolean eventCreated =false;
    String errorMessage = '';
    //2015-05-04 hemanth.kesapragada@cdk.com RQ-04227 Changed custom object to custom setting
    //Campaign_Mgmt_VF_Page_Assignment__c ProfileVFSettings = new Campaign_Mgmt_VF_Page_Assignment__c();
    Campaign_Mgmt_VF_Page_Assign__c ProfileVFSettings = new Campaign_Mgmt_VF_Page_Assign__c();
    
    public String accountId = System.currentPageReference().getParameters().get('accountId');
    public String contactId = System.currentPageReference().getParameters().get('contactId');
    public String campaignId = System.currentPageReference().getParameters().get('campaignId');
    //2016-03-31 : added by vishal.bandari@cdk.com RQ-06471 to open page from Work My leads Page with leadId
    public String leadId = System.currentPageReference().getParameters().get('leadId');
    
    
    public String retURL = System.currentPageReference().getParameters().get('retURL');
    
    public String startTime = (Datetime.now().addMinutes(60-Datetime.now().minute())).format('h:mm a');
    public String endTime = (Datetime.now().addMinutes(120-Datetime.now().minute())).format('h:mm a');
    public String linkTime = Datetime.now().format('h:mm a');
    
    public String recTypeName = '';
    public String recTypeTaskName = '';
    public Boolean RenderCobalt = false;
    public Boolean RenderDS = false;
    public Boolean showBlock = true;
    
    // -- properties
    
    //2015-05-04 hemanth.kesapragada@cdk.com RQ-04227 Changed custom object to custom setting      
    //public Campaign_Mgmt_VF_Page_Assignment__c getProfileVFSettings() { return ProfileVFSettings; }
    public Campaign_Mgmt_VF_Page_Assign__c getProfileVFSettings() { return ProfileVFSettings; }
    
    //2016-03-31 : added by vishal.bandari@cdk.com RQ-06471 to open page from Work My leads Page with leadId
    public String getleadId(){return leadId;}
    //public String getCampaignIdParam() { return campaignId; } // not needed because already accessable in VF
    public Boolean getRenderCobalt() { return RenderCobalt; }
    public Boolean getRenderDS() { return RenderDS; }
    public String getLinkTime() { return linkTime; }
    public Boolean getShowBlock() { return showBlock; }
    public String getRecTypeName(){ return recTypeName; }
    public String getRecTypeTaskName() { return recTypeTaskName; }
    
    public String getStartTime(){ return startTime; }
    public void setStartTime(String sTime){ startTime=sTime; }
    public String getEndTime(){ return endTime; }
    public void setEndTime(String eTime){ endTime=eTime; }
    public List<SelectOption> getItems() 
    {
        options=new List<SelectOption>();
        Campaign_Member_Status__c[] listOfOptions = [select Name, Default_Status__c from Campaign_Member_Status__c where Campaign__c=:campaignId order by Name DESC];
        if(listOfOptions!=null || listOfOptions.size()!=0)
        {
            options.add(new SelectOption('','--None--'));
            Integer sz = listOfOptions.size()-1;
            
            for(Integer i=sz; i>=0; i--)
            {
                options.add(new SelectOption(listOfOptions[i].Name,listOfOptions[i].Name)); 
            }
        }
        return options; 
    }
    
    public String getCampaignMemberStatus()
    { 
        System.debug('Campaign Member Status: ' + CampaignMemberStatus);
        return CampaignMemberStatus; 
    } 
    
    public void setCampaignMemberStatus(String CampaignMemberStatus)
    { 
        this.CampaignMemberStatus = CampaignMemberStatus; 
        campAcctMem.Campaign_Member_Status__c = CampaignMemberStatus;
    } 
    
    public Account getAcct() { return acct; }
    public Campaign_Account_Members__c getCampAcctMem() { return campAcctMem; }
    
    public Contact getContact() { return contact; }
    public Task getTask() { return newTask; }
    public Event getFollowUpEvent() { return followUpEvent; }  
    
    public String getReminderTime() { return '15 minutes'; }
    public void setReminderTime(String remTime) { reminderTime=remTime; }
    
    public List<SelectOption> getReminderTimes()
    {
        remOptions.add(new SelectOption('0 minutes','0 minutes'));
        remOptions.add(new SelectOption('5 minutes','5 minutes'));
        remOptions.add(new SelectOption('10 minutes','10 minutes'));
        remOptions.add(new SelectOption('15 minutes','15 minutes'));
        remOptions.add(new SelectOption('30 minutes','30 minutes'));
        remOptions.add(new SelectOption('1 hour','1 hour'));
        remOptions.add(new SelectOption('2 hours','2 hours'));
        remOptions.add(new SelectOption('3 hours','3 hours'));
        remOptions.add(new SelectOption('4 hours','4 hours'));
        remOptions.add(new SelectOption('5 hours','5 hours'));
        remOptions.add(new SelectOption('6 hours','6 hours'));
        remOptions.add(new SelectOption('7 hours','7 hours'));
        remOptions.add(new SelectOption('8 hours','8 hours'));
        remOptions.add(new SelectOption('9 hours','9 hours'));
        remOptions.add(new SelectOption('10 hours','10 hours'));
        remOptions.add(new SelectOption('11 hours','11 hours'));
        remOptions.add(new SelectOption('.5 days','.5 days'));
        remOptions.add(new SelectOption('18 hours','18 hours'));
        remOptions.add(new SelectOption('1 day','1 day'));
        remOptions.add(new SelectOption('2 days','2 days'));
        remOptions.add(new SelectOption('3 days','3 days'));
        remOptions.add(new SelectOption('4 days','4 days'));
        remOptions.add(new SelectOption('1 week','1 week'));
        remOptions.add(new SelectOption('2 weeks','2 weeks'));
        
        return remOptions;
    }
    
    // -- constructor
    
    public DS_ActivityOpportunityController()
    {
        System.debug('CAMPAIGN ID : ' +   campaignId);
        System.debug('CONTACT ID : ' +   contactId);
        
        //2016-03-31 : added by vishal.bandari@cdk.com RQ-06471 to open page from Work My leads Page with leadId
        System.debug('LEAD ID : ' +   leadId);
        
        contactRelationship = [Select id,Phone__c from contact_Relationship__c where Contact__C =: contactId and Account__c =: accountId];
        ID DefaultTaskRecordTypeID = null;
        
        // describe the Task object to get all of the available Record Types
        Schema.DescribeSObjectResult DescribeTaskResult = Task.SObjectType.getDescribe();
        List<RecordTypeInfo> TaskRecordTypeInfos = DescribeTaskResult.getRecordTypeInfos();
        
        // loop through the Task Record Types to get the default Record Type
        for(RecordTypeInfo r : TaskRecordTypeInfos)
        {
            // if the current Record Type is the default for the current User
            if(r.isDefaultRecordTypeMapping())
            {
                // save it for assigning to the new Task
                DefaultTaskRecordTypeID = r.getRecordTypeId();
                system.debug(DefaultTaskRecordTypeID);
            }
        }
        
        // set a default if no default was found previously
        if(DefaultTaskRecordTypeID == null) 
        {
            DefaultTaskRecordTypeID = [Select Id From RecordType Where sObjectType = 'Task' And Name = 'Sales Tasks' LIMIT 1].Id;
        }
        
        String userId = UserInfo.getUserId();
        
        //2016-03-31 : added by vishal.bandari@cdk.com RQ-06471 to open page from Work My leads Page with leadId
        if(leadId == null)
        {
            newTask = new Task(WhatId = campaignId, WhoId = contactId, OwnerId = userId);
        }
        else
        {
            newTask = new Task(WhoId = leadId, OwnerId = userId);
        }
        newTask.Status='Completed';
        newTask.Subject='Call';
        newTask.ActivityDate=Date.today();
        newTask.Activity_Type__c='Call';
        newTask.Type = 'Phone Call';
        newTask.RecordTypeId = DefaultTaskRecordTypeID;
        //2016-06-27- anirudh.singh@cdk.com- Added the below line for RQ-07284, as we need to link the Account from CR to the Task, but
        //the standard AccountId field on Task get populated from Contact's Standard field AccountId by default functionality, which cannot be populated using custom code.
        newTask.Primary_Account__c=accountId;
        recTypeTaskName = 'Sales Tasks';
        
        RecordType[] recType;
        
        List<ID> RecordTypeIdList = new List<ID>(); // addded 3/10/2015 SivaP
        
        // get the Profile Visualforce Settings (for checking if the Profile is Inside Sales)
        ProfileVFSettings = QueryPageAssignmentSettings();
        
        if(getIsProfileInsideSales())
        {
            RenderCobalt = false;
            RenderDS = true;
            //recType = [select Id from RecordType where Name = 'Standard Event'];
            RecordTypeIdList.add(ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Event', 'Standard Event')); // addded 3/10/2015 SivaP
            recTypeName='Standard Event';
            system.debug('here?');
        }
        else
        {
            RenderCobalt = true;
            RenderDS = false;
            //recType = [select Id from RecordType where Name = 'Digital Solutions Event'];
            RecordTypeIdList.add(ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Event', 'Digital Solutions Event')); // addded 3/10/2015 SivaP
            recTypeName='Digital Solutions Event';
            system.debug('here?');
        }
        
        followUpEvent = new Event(
            Subject='Call',
            WhatId = campaignId, 
            WhoId = contactId, 
            OwnerId = userId,
            Start_Date__c=Date.today(),
            End_Date__c=Date.today(), 
            ShowAs='Busy'
        );
        //2016-06-27- anirudh.singh@cdk.com- Added the below line for RQ-07284, as we need to link the Account from CR to the Event, but
        //the standard AccountId field on Event get populated from Contact's Standard field AccountId by default functionality, which cannot be populated using custom code.
        followUpEvent.Primary_Account__c=accountId;
        
        //2016-03-31 : added by vishal.bandari@cdk.com RQ-06471 to open page from Work My leads Page with leadId
        if(leadId != null)
        {
            followUpEvent.WhatId = null;
            followUpEvent.WhoId = leadId;
        }
        
        if(RecordTypeIdList.size() > 0)//(recType.size() > 0)
        {
            //followUpEvent.RecordTypeId=recType[0].Id;
            followUpEvent.RecordTypeId = RecordTypeIdList[0]; // addded 3/10/2015 SivaP
        }
        
        acct = [select Id, Name, BillingCity, BillingState, Phone from Account where Id=:accountId limit 1];
        contact = [select Phone, Email from Contact where Id=:contactId];
        
        //2016-03-31 : added by vishal.bandari@cdk.com RQ-06471 to open page from Work My leads Page with leadId
        if(leadId == null)
        {
            campAcctMem = [select Id, Campaign_Member_Status__c from Campaign_Account_Members__c where Account__c=:accountId and Campaign__c=:campaignId limit 1];
            CampaignMemberStatus = campAcctMem.Campaign_Member_Status__c;
        }
       
        
        showBlock = ProfileVFSettings.Display_Follow_up_Needed__c;
    }
    
    // -- methods
    
    public void flipSwitch()
    {
        showBlock = !showBlock; 
    }
    
    public Boolean getIsProfileInsideSales()
    {
        system.debug(ProfileVFSettings);
        return (ProfileVFSettings != null 
                && ProfileVFSettings.Campaign_VF_Layout__c != null 
                && ProfileVFSettings.Campaign_VF_Layout__c.toLowerCase() == 'inside sales');
    }
    
    //2015-05-04 hemanth.kesapragada@cdk.com RQ-04227 Changed custom object to custom setting (Return Type)
    //public Campaign_Mgmt_VF_Page_Assignment__c QueryPageAssignmentSettings()
    public Campaign_Mgmt_VF_Page_Assign__c QueryPageAssignmentSettings()
    {
        Profile p = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId() LIMIT 1];
        String SingleQuotesProfileName = p != null ? '\'' + p.Name + '\'' : '\'\'';
        
        //List<Campaign_Mgmt_VF_Page_Assignment__c> CampaignMgmtVFSettings = Database.query(
        List<Campaign_Mgmt_VF_Page_Assign__c> CampaignMgmtVFSettings = Database.query(
            'SELECT Id, Profile_Name__c, Campaign_VF_Layout__c, Display_Follow_up_Needed__c, Lead_Gen_Checkbox__c,  Show_Log_a_Call__c ' + 
            // 'FROM Campaign_Mgmt_VF_Page_Assignment__c ' + 
            'FROM Campaign_Mgmt_VF_Page_Assign__c ' + 
            'WHERE Profile_Name__c = ' + SingleQuotesProfileName + ' '
        );
        
        system.debug(CampaignMgmtVFSettings);
        
        if(!CampaignMgmtVFSettings.isEmpty()) 
        {
            return CampaignMgmtVFSettings[0]; 
        } 
        // return new Campaign_Mgmt_VF_Page_Assignment__c()
        return new Campaign_Mgmt_VF_Page_Assign__c();
    }
    
    public PageReference save()
    {
        if(showBlock) 
        {
            followUpEvent = modifyEvent(); 
            if(!eventCreated)
            {
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.FATAL,
                                          errorMessage));
                return ApexPages.currentPage();
            }
            if(followUpEvent.StartDateTime > followUpEvent.EndDateTime)
            {
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.FATAL,
                                          'An error occurred while saving the Follow-up Activity: Start Time cannot be later than End Time. '
                                          + 'Please enter a valid Start Time and try again.'));
                return ApexPages.currentPage();
            }
        }
        
        // 2013-10-29 MK - unnecessary if the click-to-call dialer is used
        // 2014-02-10 SP - re-added with condition
        //2015-09-10 Venkata Shrivol - Changed the below condition to True
       // if(ProfileVFSettings.Show_Log_a_Call__c == False)
       if(ProfileVFSettings.Show_Log_a_Call__c)
        {
            //try{
            upsert newTask; 
            //}catch (DmlException e) { }
        }
        
        if(showBlock)
        { 
            upsert followUpEvent;
        }
        
        //2016-03-31 : if check added by vishal.bandari@cdk.com RQ-06471 to open page from Work My leads Page with leadId
        if(leadId == null)
        {
            upsert campAcctMem;
        }
        
        
        //PageReference pr = new PageReference('/apex/listAccounts?campaignId='+campaignId+'&accountId='+accountId);
        PageReference pr = new PageReference(retURL);
        
        return pr;  
    }
    
    public PageReference cancel()
    {
        //PageReference pr = new PageReference('/apex/listAccounts?campaignId='+campaignId+'&accountId='+accountId);
        PageReference pr = new PageReference(retURL);
        return pr;  
    }
    
    public Event modifyEvent()
    {
        try
        {            
            String[] s = startTime.split(' ');
            String[] hrMin = s[0].split(':');
            String[] e = endTime.split(' ');
            String[] hrMin2 = e[0].split(':');
            Integer sHrs = null;
            Integer eHrs = null;
            
            if(s != null)
            {
                if(s[1].toLowerCase() == 'pm')
                {
                    if(hrMin[0] == '12')
                    {
                        sHrs = Integer.valueOf(hrMin[0]); 
                    }
                    else 
                    {
                        sHrs = Integer.valueOf(hrMin[0])+12; 
                    }
                }
                else
                {
                    if(hrMin[0]=='12') 
                    {
                        sHrs = Integer.valueOf(hrMin[0])+12;
                    }
                    else
                    {
                        sHrs = Integer.valueOf(hrMin[0]);
                    }
                }
            }
            
            System.debug('sHrs: '+sHrs);
            
            if(e != null)
            {
                if(e[1].toLowerCase() == 'pm')
                {
                    if(hrMin2[0] == '12') 
                    {
                        eHrs = Integer.valueOf(hrMin2[0]);
                    }
                    else 
                    {
                        eHrs = Integer.valueOf(hrMin2[0])+12; 
                    }
                }
                else
                {
                    if(hrMin2[0] == '12') 
                    {
                        eHrs = Integer.valueOf(hrMin2[0])+12; 
                    }
                    else
                    {
                        eHrs = Integer.valueOf(hrMin2[0]); 
                    }
                }
            }
                
            System.debug('eHrs: '+eHrs);
            
            System.debug('Start Date Whole:' 
                         + ' Year: ' + followUpEvent.Start_Date__c.Year()
                         + ' Month: ' + followUpEvent.Start_Date__c.Month()
                         + ' Date: ' + followUpEvent.Start_Date__c.Day()
                         + ' Hour: ' + sHrs
                         + ' Minute: ' + Integer.valueOf(hrMin[1]));
            
            System.debug('End Date Whole:' 
                         + ' Year: ' + followUpEvent.End_Date__c.Year()
                         + ' Month: ' + followUpEvent.End_Date__c.Month() 
                         + ' Date: ' + followUpEvent.End_Date__c.Day() 
                         + ' Hour: ' + eHrs 
                         + ' Minute: ' + Integer.valueOf(hrMin2[1]));
            
            if(sHrs==24)
            {
                followUpEvent.Start_Date__c=followUpEvent.Start_Date__c.addDays(-1);
                //eHrs=Integer.valueOf(hrMin2[0])+12;
                //followUpEvent.Start_Date__c=followUpEvent.Start_Date__c.addHours(12);
            }
            
            if(eHrs==24)
            {
                followUpEvent.End_Date__c=followUpEvent.End_Date__c.addDays(-1);
                //followUpEvent.End_Date__c=followUpEvent.End_Date__c.addHours(12);
            }
            
            Datetime st = Datetime.newInstance(
                followUpEvent.Start_Date__c.Year(),
                followUpEvent.Start_Date__c.Month(),
                followUpEvent.Start_Date__c.Day(),
                sHrs,
                Integer.valueOf(hrMin[1]),
                0
            );
            
            followUpEvent.StartDateTime = st;
            
            System.debug('Start Date Time: '+followUpEvent.StartDateTime);
            
            followUpEvent.EndDateTime = Datetime.newInstance(
                followUpEvent.End_Date__c.Year(),
                followUpEvent.End_Date__c.Month(),
                followUpEvent.End_Date__c.Day(),
                eHrs,
                Integer.valueOf(hrMin2[1]),
                0
            );
            
            System.debug('End Date Time: '+followUpEvent.EndDateTime);
            
            //followUpEvent.DurationInMinutes=Integer.valueOf((followUpEvent.EndDateTime.getTime()-followUpEvent.StartDateTime.getTime())/60000);
            
            System.debug('Duration In Minutes: '+followUpEvent.DurationInMinutes);
            system.debug(followUpEvent);
            if(followUpEvent.IsReminderSet)
            {
                String[] arr;
                arr = reminderTime.split(' ');
                
                if(reminderTime.indexOf('minutes') != -1) 
                {
                    st=st.addMinutes(-1*Integer.valueOf(arr[0]));
                }
                if(reminderTime.indexOf('hour') != -1)
                {
                    st=st.addHours(-1*Integer.valueOf(arr[0]));
                }
                if(reminderTime.indexOf('days') != -1)
                {
                    if(arr[0]!='.5') { st=st.addDays(-1*Integer.valueOf(arr[0])); }
                    else { st=st.addHours(-12); }
                }
                if(reminderTime.indexOf('week')!=-1)
                {
                    st=st.addDays(-1*7*Integer.valueOf(arr[0]));
                }
                
                followUpEvent.ReminderDateTime=st;
            }
            eventCreated  = true;
        }
        catch(Exception excp)
        {
            eventCreated  = false;
            errorMessage= 'Time must be in \'hh:mm am/pm\' format';
            System.debug('Exception:'+excp.getMessage());
            return null;
            
        }
        return followUpEvent; 
    }
    
    public PageReference saveAndCreateOpt()
    {
        if(showBlock) 
        { 
            modifyEvent(); 
            
            if(!eventCreated)
            {
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.FATAL,
                                          errorMessage));
                return ApexPages.currentPage();
            }
            if(followUpEvent.StartDateTime > followUpEvent.EndDateTime)
            {
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.FATAL,
                                          'An error occurred while saving the Follow-up Activity: Start Time cannot be later than End Time. '
                                          + 'Please enter a valid Start Time and try again.'));
                return ApexPages.currentPage();
            }
        }
        
        //upsert newTask; // 2013-10-29 MK - unnecessary if the click-to-call dialer is used
        
        if(showBlock)
        {
            upsert followUpEvent;
        }
        
        upsert campAcctMem;
        
        //Id opptId = [select Id from RecordType where Name='Baseline Multi-channel Opportunity'].Id;
        
        RecordType[] opptId;
        String url = '/006/e';
        Id usrId = UserInfo.getUserId();
        String profileName = [select Profile.Name from User where Id=:usrId].Profile.Name;
        
        
        // Commented out 2/23/2010 Ron Davis
        //Default_Opportunity_Type__c[] def = [select Default_Opportunity_Record_Type__c from Default_Opportunity_Type__c where Profile_Name__c=:profileName];
        //
        //if(def!=null && def.size()!=0)
        //{
        //  String recName = def[0].Default_Opportunity_Record_Type__c;
        //  opptId = [select Id from RecordType where Name=:recName];       
        //}
        //
        //if(opptId!=null && opptId.size()>0)
        //{
        //  url+='?RecordType='+opptId[0].Id;
        //}
        
        Campaign CurrentCampaign = [select Name from Campaign where Id=:campaignId];
        Account CurrentAccount = [select Name from Account where Id=:accountId];
        
        if(url=='/006/e')
        {
            url+='?opp4='+EncodingUtil.URLENCODE(CurrentAccount.Name,'UTF-8')
                +'&opp4_lkid='+EncodingUtil.URLENCODE(CurrentAccount.Id,'UTF-8')
                +'&opp17='+EncodingUtil.URLENCODE(CurrentCampaign.Name,'UTF-8')
                +'&opp17_lkid='+EncodingUtil.URLENCODE(CurrentCampaign.Id,'UTF-8')
                +'&opp3='+EncodingUtil.URLENCODE(CurrentCampaign.Name,'UTF-8')
                +'&CF00N40000001mu1G'+'_lkid='+EncodingUtil.URLENCODE(UserInfo.getUserId(),'UTF-8') // ADP Opportunity Owner
                +'&CF00N40000001mu1G='+EncodingUtil.URLENCODE(UserInfo.getFirstName(),'UTF-8')+' '+EncodingUtil.URLENCODE(UserInfo.getLastName(),'UTF-8'); // ADP Opportunity Owner
        }
        //commented out 3/11/2015 SivaP because, url is always == '/006/e'
        /*else
        {
            url+='&opp4='+EncodingUtil.URLENCODE(CurrentAccount.Name,'UTF-8')
                +'&opp4_lkid='+EncodingUtil.URLENCODE(CurrentAccount.Id,'UTF-8')
                +'&opp17='+EncodingUtil.URLENCODE(CurrentCampaign.Name,'UTF-8')
                +'&opp17_lkid='+EncodingUtil.URLENCODE(CurrentCampaign.Id,'UTF-8')
                +'&opp3='+EncodingUtil.URLENCODE(CurrentCampaign.Name,'UTF-8')
                +'&CF00N40000001mu1G'+'_lkid='+EncodingUtil.URLENCODE(UserInfo.getUserId(),'UTF-8') // ADP Opportunity Owner
                +'&CF00N40000001mu1G='+EncodingUtil.URLENCODE(UserInfo.getFirstName(),'UTF-8')+' '+EncodingUtil.URLENCODE(UserInfo.getLastName(),'UTF-8'); // ADP Opportunity Owner
        }*/
        
        //String s = EncodingUtil.URLDECODE(url, 'UTF-8');
        
        PageReference pr = new PageReference(url);
        
        //006/e?ent=Account&001R0000006hyZIIAY=Acme
        //?RecordType'+opptId
        
        return pr;  
    }
    
    public PageReference saveAndCreateLead() 
    {
        
        if (showBlock) 
        {
            modifyEvent();
            if(!eventCreated)
            {
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.FATAL,
                                          errorMessage));
                return ApexPages.currentPage();
            }
            if (followUpEvent.StartDateTime > followUpEvent.EndDateTime) 
            {
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.FATAL,
                                          'An error occurred while saving the Follow-up Activity: Start Time cannot be later than End Time. '
                                          + 'Please enter a valid Start Time and try again.'));
                return ApexPages.currentPage();
            }
        }
        
        if (showBlock)
        {
            upsert followUpEvent;
        }
        
        upsert campAcctMem;
        
        RecordType[]opptId;
        String url2 = '/00Q/e';
        Id usrId = UserInfo.getUserId();
        String profileName = [select Profile.Name from User where Id =  : usrId].Profile.Name;
        
        Campaign CurrentCampaign = [select Name from Campaign where Id =  : campaignId];
        Account CurrentAccount = [select Name from Account where Id =  : accountId];
        Contact CurrentContact = [select firstName, lastName, Name, Email, Fax from Contact where Id =  : contactId];
        
        
        
        
        if (url2 == '/00Q/e')
        {
            system.debug('501-------');
            //EncodingUtil.URLENCODE(url2,'UTF-8')
            url2 += '?CF00N40000001m0KD=' + EncodingUtil.URLENCODE(CurrentAccount.Name,'UTF-8')
                + '&CF00N40000001m0KD_lkid=' + EncodingUtil.URLENCODE(CurrentAccount.Id,'UTF-8')
                + '&lea3=' + EncodingUtil.URLENCODE(CurrentAccount.Name,'UTF-8')
                + '&lea3_lkid=' + EncodingUtil.URLENCODE(CurrentAccount.Id,'UTF-8')
                + '&CF00N40000001mrZA=' + EncodingUtil.URLENCODE(CurrentCampaign.Name,'UTF-8')
                + '&CF00N40000001mrZA_lkid=' + EncodingUtil.URLENCODE(CurrentCampaign.Id,'UTF-8')
                + (CurrentContact.Email != null ? '&lea11=' + EncodingUtil.URLENCODE(CurrentContact.Email,'UTF-8') : '')
                + '&lea11_lkid=' +  EncodingUtil.URLENCODE(CurrentContact.Id,'UTF-8')
                + (CurrentContact.Fax != null ? '&lea10=' +  EncodingUtil.URLENCODE(CurrentContact.Fax,'UTF-8') : '' )
                + '&lea10_lkid=' +  EncodingUtil.URLENCODE(CurrentContact.Id,'UTF-8')
                + '&CF00N40000001m1ds=' +  EncodingUtil.URLENCODE(CurrentContact.Name,'UTF-8')
                + '&CF00N40000001m1ds_lkid=' +  EncodingUtil.URLENCODE(CurrentContact.Id,'UTF-8')
                + (CurrentContact.firstName != null ? '&name_firstlea2=' +  EncodingUtil.URLENCODE(CurrentContact.firstName,'UTF-8') : '')
                + '&name_firstlea2_lkid=' +  EncodingUtil.URLENCODE(CurrentContact.Id,'UTF-8')
                + '&name_lastlea2=' +  EncodingUtil.URLENCODE(CurrentContact.lastName,'UTF-8')
                + '&name_lastlea2_lkid=' +  EncodingUtil.URLENCODE(CurrentContact.Id,'UTF-8');
            
        }
        //commented out 3/11/2015 SivaP because, url2 is always == '/00Q/e'
       /* else 
        {
            url2 += '&CF00N40000001m0KD=' + EncodingUtil.URLENCODE(CurrentAccount.Name,'UTF-8')
                + '&CF00N40000001m0KD_lkid=' + EncodingUtil.URLENCODE(CurrentAccount.Id,'UTF-8')
                + '&lea3=' + EncodingUtil.URLENCODE(CurrentAccount.Name,'UTF-8')
                + '&lea3_lkid=' + EncodingUtil.URLENCODE(CurrentAccount.Id,'UTF-8')
                + '&CF00N40000001mrZA=' + EncodingUtil.URLENCODE(CurrentCampaign.Name,'UTF-8')
                + '&CF00N40000001mrZA_lkid=' + EncodingUtil.URLENCODE(CurrentCampaign.Id,'UTF-8')
                + (CurrentContact.Email != null ? '&lea11=' + EncodingUtil.URLENCODE(CurrentContact.Email,'UTF-8') : '')
                + '&lea11_lkid=' + EncodingUtil.URLENCODE(CurrentContact.Id,'UTF-8')
                + (CurrentContact.Fax != null ? '&lea10=' + EncodingUtil.URLENCODE(CurrentContact.Fax,'UTF-8') : '' )
                + '&lea10_lkid=' + EncodingUtil.URLENCODE(CurrentContact.Id,'UTF-8')
                + '&CF00N40000001m1ds=' + EncodingUtil.URLENCODE(CurrentContact.Name,'UTF-8')
                + '&CF00N40000001m1ds_lkid=' + EncodingUtil.URLENCODE(CurrentContact.Id,'UTF-8')
                + (CurrentContact.firstName != null ? '&name_firstlea2=' + EncodingUtil.URLENCODE(CurrentContact.firstName,'UTF-8') : '')
                + '&name_firstlea2_lkid=' + EncodingUtil.URLENCODE(CurrentContact.Id,'UTF-8')
                + '&name_lastlea2=' + EncodingUtil.URLENCODE(CurrentContact.lastName,'UTF-8')
                + '&name_lastlea2_lkid=' + EncodingUtil.URLENCODE(CurrentContact.Id,'UTF-8');
            
        } */
        
        // String s = EncodingUtil.URLENCODE(url2,'UTF-8');
        System.debug('S-------' + url2); 
        PageReference rp = new PageReference(url2);
        
        return rp; 
        
    }   
}