global class EMP_HRInvoluntaryController 
{ 
    public string AccountName {get;set;}
    public Contact Associate {get;set;}
    public Date myDate{get;set;}
    public boolean hidepage{get;set;}
    
    public EMP_HRInvoluntaryController()
    {
        Account CDKGlobalAccount = [
            Select Id, Name 
            From Account
            Where Id = :CustomSettings__c.getInstance().CDK_Global_Account_Id__c
        ];
       Profile objPro = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
      
           Page_Component__c pagecomp = [select id, name, VFPageName__c,Component_Order__c,Class_Tag__c,Main_Content__c, Component_Type__c,Chatter_Group__c  
                from Page_Component__c where name ='EMP_HRInvoluntaryTermination'];
               List<CollaborationGroupMember> members = [Select MemberId 
                          From CollaborationGroupMember 
                          where CollaborationGroupId = :pagecomp.Chatter_Group__c and MemberId =: userinfo.getUserId()
                          ];
        if(members.size()==0){ ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Sorry you dont have access'));
              hidepage= true; }

        AccountName = CDKGlobalAccount.Name;
        
        Associate = new Contact();
        
    }
    
    @RemoteAction
    global static List<Contact> SearchContacts (String SearchTerm) 
    {
        List<sObject> SearchList = null;
        
        if(SearchTerm != null && SearchTerm.length() > 0)
        { 
            string SOSLSearchTerm = '*' + SearchTerm + '*';
            
            List<List<sObject>> SoslSearchList = [
                FIND :SOSLSearchTerm 
                IN ALL FIELDS
                RETURNING Contact (
                    Id, Name
                    //, HR_Title__c, HR_Manager__r.Name, HR_Manager__c, Vendor_Id__c
                    Where AccountId = :CustomSettings__c.getInstance().CDK_Global_Account_Id__c 
                 //   And No_Longer_There__c = false
                 //   And Status__c != 'Inactive'
                    Order By Name
                )
                Limit 200
            ];
            
            if(SoslSearchList != null)
            {
                SearchList = (SoslSearchList[0] != null ? SoslSearchList[0] : null); 
            }
        }
        else
        {
            SearchList = [
                Select Id, Name
                //, HR_Title__c, HR_Manager__r.Name, HR_Manager__c, Vendor_Id__c 
                From Contact
                Where AccountId = :CustomSettings__c.getInstance().CDK_Global_Account_Id__c
             //   And No_Longer_There__c = false
              //  And Status__c != 'Inactive'
                Order By Name
                Limit 200
            ];
        }
        
        return SearchList;
    }
    
    @RemoteAction
    global static EMP_HRInvoluntaryController.result submitForm(
        Id ContactId, String SelectedDate, String Hours, String Min, String AMPM)
    {
        system.debug('In Submit Form');
        
        // calculate a date 2 weeks in the future
        Date TwoWeeksFuture = Date.today();
        TwoWeeksFuture=TwoWeeksFuture.addDays(14);
        
         if(SelectedDate == null){
            return new EMP_HRInvoluntaryController.result(
                false, 'Please Enter Associates Last Worked Date. '
            );  
        }
        
        Date dt = Date.parse(SelectedDate);
        
        if(dt < date.Today() || dt >= TwoWeeksFuture){
            return new EMP_HRInvoluntaryController.result(
                false, 'Last Date Worked cannot be in the past nor can it be the more than 2 Weeks in the future. '
            );  
        }
        
        if(ContactId == null){
            return new EMP_HRInvoluntaryController.result(
                false, 'Please Select a Contact. '
            );
        }
        
        Contact HRTermContact = new Contact();
        Case HRTermCase = new Case();
        
        try
        {
            HRTermCase.AccountId = CustomSettings__c.getInstance().CDK_Global_Account_Id__c;
            HRTermCase.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'HR');
            HRTermCase.Status = 'Open';
            HRTermCase.Priority = 'High';
            HRTermCase.Origin = 'Associate Portal';
            HRTermCase.Subject = 'Involuntary Termination';
            insert HRTermCase;
            
            HRTermContact = [
                Select Id, Name 
                From Contact
                Where ID = :ContactId
                Limit 1
            ];
            
            HRTermCase.Status ='Closed';
            HRTermCase.ContactId = HRTermContact.Id; 
            
            if(dt != null)
            {
              //  HRTermContact.Associates_Last_Date_Time__c = dt;
               // HRTermContact.Associates_Last_Termination_Date_Time__c = EMP_HRInvoluntaryController.formatDate(dt, Hours, Min, AMPM);
                HRTermCase.Subject += ' ' + EMP_HRInvoluntaryController.formatDate(dt, Hours, Min, AMPM);
            }
            
            update HRTermContact;
            update HRTermCase;
        }
        catch(Exception e) 
        {
            return new EMP_HRInvoluntaryController.result(
                false, e.getMessage()
            );
        }
            
        return new EMP_HRInvoluntaryController.result(
            true, 
            'Successfully logged an HR Case for "' + HRTermContact.Name + 
            //'" and set Associates Last Worked Date Time to "' + HRTermContact.Associates_Last_Termination_Date_Time__c + '". ',
            HRTermCase.Id
        );
    }
    
    global class result
    {
        public result() { success=false; message='An unexpected error occurred'; }
        public result(boolean s) { success=s; }
        public result(boolean s, string m) { success=s; message=m; }
        public result(boolean s, string m, string cid) { success=s; message=m; caseid=cid; }
        
        public boolean success {get;set;}
        public string message {get;set;}
        public string caseid {get;set;}
    }
    
    public static string formatDate(Date d, String h, String m, String ap)
    {        
        string formattedDateTime = d.format();
        
        if(h == '00')
        {
            formattedDateTime += ' 12:' + m + ' ' + 'AM'; 
        }
        else if(h != null)
        {
            formattedDateTime += ' ' + h + ':' + m + ' ' + ap; 
        }
        
        return formattedDateTime;
    }
    
    public PageReference doCancel(){
        pageReference page = new pageReference('/apex/EMP_AssociatePortalPage?page=EMP_HRInvoluntaryPage');
        page.setRedirect(true);
        return page;
    }
    
}