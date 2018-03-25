// RQ-06966: Create/Edit Contact Page
// 2016-05-16 Vijay.manimaran@cdk.com  Created
// 2016-05-18 Vijay.manimaran@cdk.com  Created/Updated DuplicateCheck Method.
// 2016-05-25 Vijay.manimaran@cdk.com  Created/Updated CreateContactRelationship Method.
// 2016-05-25 Sanjay.Ghanathey@cdk.com Updated CreateContactRelationship.
// 2016-05-25 Vijay.manimaran@cdk.com  Updated DuplicateCheck Method with tempContact.
// 2016-05-25 Sanjay.Ghanathey@cdk.com Updated DuplicateCheck Method to prepopulate the values on the vf page.
// 2016-05-27 Sanjay.Ghanathey@cdk.com Updated: Updated Recordtype Picklist values based on the user profile onto Visualforcepage(ShreadContacts.vfp) 

public with Sharing class SharedContacts_Controller {
   /* Vijay Moved to ALL_SharedContacts_Controller  
    public Contact CurrentContact{get;set;}
    public Contact_Relationship__c ContactRelationship{get;set;}
    public Boolean showbuttons {get;set;}
    public Boolean isDuplicate {get;set;} 
    public Boolean isReadOnly {get;set;}
    public Boolean readMode {get;set;}    
    public ALL_SharedContact_Helper.duplicateCheckWrapper results{get;set;}
    public String recordType {get;set;}
    public String recordTypeHRId{get;set;}
    public String recordTypeCustomerId{get;set;}
    public String recordTypeDigitalId{get;set;}
    public String recordTypeTestContactId{get;set;}
    
    public SharedContacts_Controller(apexPages.StandardController controller){
        recordTypeHRId = [Select Id From RecordType Where Name =:'Internal HR Contact' Limit 1].Id;
        recordTypeCustomerId = [Select Id From RecordType Where Name =:'Customer Contact' Limit 1].Id;
        recordTypeDigitalId = [Select Id From RecordType Where Name =:'Digital Advertising Contact' Limit 1].Id;
        recordTypeTestContactId = [Select Id From RecordType Where Name =:'Test Contact' Limit 1].Id;
        
        String currentContactId='';
        CurrentContact = new Contact();     
        ContactRelationship = new Contact_Relationship__c();
        ContactRelationship = (Contact_Relationship__c)controller.getRecord();
        String accountId = apexpages.currentpage().getparameters().get('accountId');
        String readModeParam = apexpages.currentpage().getparameters().get('readMode');
        String ContactRelationshipId = apexpages.currentpage().getparameters().get('CRId');
        String isEditParam = apexpages.currentpage().getparameters().get('isEdit');
        String changedRecordTypeId = apexpages.currentpage().getparameters().get('recordId');
        String isCancel = apexpages.currentpage().getparameters().get('isCancel');
        //2016-06-24 - siva.pragada@cdk.com - added for RQ-06835 - LMA RFP - LMA President Addition/Maintenance
        String Role = apexpages.currentpage().getparameters().get('Role__c');
        
        if(isEditParam != Null)
        {            
            showbuttons = False;
            isDuplicate = True;
        }
        else{
            showbuttons = True;
        }
        
        if(readModeParam != Null){
            readMode = True;
        }
        
        if(accountId != Null || accountId != ''){
            ContactRelationship.Account__c = accountId;
        }
        
         //2016-06-24 - siva.pragada@cdk.com - added for RQ-06835 - LMA RFP - LMA President Addition/Maintenance
        if(Role != null || Role != '')
        {
            ContactRelationship.Role__c = Role;
        }
        
        //condition is used to land on the edit page. CRID and AccountID must be used as paramter.Cancel logic is on else.
        if(ContactRelationshipId != Null && accountId != Null){
            ContactRelationship = [
                Select Account__c,Role__c,Contact__c,Phone__c,Authorized_Contract_Signer__c,
                Authorized_Signer_e_Store_Only__c, Additional_Client_Designated_Signer__c,
                DS_SLS_Required_CC__c,No_Longer_There__c,Status__c,Extension__c,Fax__c,
                CSI_Last_Filled_Out_Date__c
                From Contact_Relationship__c 
                Where Id=:ContactRelationshipId
                Limit 1
            ];            
            
            // 2016-06-14 matt.keefe@cdk.com - commented Dealer_Group_Name_DNU__c, not needed code (keep in Shared Contacts change set)
            if(isCancel == Null || !isCancel.equalsIgnoreCase('true'))
            {
                CurrentContact = [
                    Select Id, IsDeleted, MasterRecordId, accountId, LastName, FirstName, Salutation, Name, Recordtype.Name,
                    RecordTypeId, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherLatitude, 
                    OtherLongitude, OtherAddress, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
                    MailingLatitude, MailingLongitude, MailingAddress, Phone, Fax, MobilePhone, HomePhone, OtherPhone, AssistantPhone,
                    ReportsToId, Email, Title, Department, AssistantName, LeadSource, Birthdate, Description, OwnerId, HasOptedOutOfEmail, 
                    HasOptedOutOfFax, DoNotCall, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
                    LastActivityDate, LastCURequestDate, LastCUUpdateDate, LastViewedDate, LastReferencedDate, EmailBouncedReason, 
                    EmailBouncedDate, IsEmailBounced, PhotoUrl, Jigsaw, JigsawContactId, Department__c, Title_Comments__c, County__c, 
                    Primary_Contact__c, Do_Not_Solicit__c, Do_Not_Fax__c, No_Longer_There__c, Title__c, Small_Id__c, SLX_ContactId__c, 
                    Authorized_Contract_Signer__c, External_accountId__c, External_SystemId__c, Primary_Procare_Contact__c, Decision_Maker__c, 
                    Website_Dev__c, Campaign_Contact__c, Other_Email__c, LDP__c, LDP_Reason_Code__c, VIP__c, Personal_Email__c, 
                    Role__c, Account_Designated_DSM_EMail__c, Account_Name_Text__c, Account_Number__c, Advertising__c, Cobalt_ConsolIdation_Id__c,
                    Dealix__c, Economic_Buyer__c, Extension__c, External_Id__c, Full_Name__c, Group_Member__c, LDP_Brand__c, LDP_Level__c, MIddle_Initial__c, 
                    OS_Contact_Id__c, Preferred_Contact_Time__c, Reason_Code__c, Relationship__c, Sales_Notes__c, Send_ROI_Report__c, Status__c, VFP_Checkbox__c, 
                    Authorized_Signer_e_Store_Only__c, WebId__c, Websites__c, Total_Policies_To_Approve__c, Total_Policies__c, DS_SLS_Required_CC__c, Vendor_Company__c, 
                    pi__campaign__c, Business_Site__c, Region_Business_Site__c, HR_Last_Date_Worked__c, HR_Term_Date__c, LMA_Divison__c, //Dealer_Group_Name_DNU__c,
                    Language_Preference__c, VIP_Reason_Code__c, User__c, Vendor_Id__c, Migration_Id__c, XCOM_member__c, HR_Manager__c, 
                    HR_Business_Unit__c, HR_Location__c, HR_Title__c, HR_Status__c, DSM__c, OEM__c, Survey_Sent__c, ResponseDate__c, CSIOptOut__c,
                    Additional_Client_Designated_Signer__c, CSI_Last_Filled_Out_Date__c, Most_Recent_CSI_Sent_Date__c, Most_Recent_CSI_Sent_Date1__c, 
                    Associates_Last_Date_Time__c, Associates_Last_Termination_Date_Time__c, Manual_Policy_Addition__c, FY16_US_Acknowledgement__c,
                    Employee_Id__c, HR_Hire_Date__c, HR_Rehire_Date__c, pi__comments__c, pi__conversion_date__c, pi__conversion_object_name__c,
                    pi__conversion_object_type__c, pi__created_date__c, pi__first_activity__c, pi__first_search_term__c, pi__first_search_type__c, 
                    pi__first_touch_url__c, pi__grade__c, pi__last_activity__c, pi__notes__c, pi__pardot_hard_bounced__c, pi__score__c, pi__url__c,
                    pi__utm_campaign__c, pi__utm_content__c, pi__utm_medium__c, pi__utm_source__c, pi__utm_term__c, HR_Business_Partner__c,
                    HR_Work_Country_Code__c, Count_of_Active_Contact_Relationsips__c, Dealer_Group__c
                    From Contact 
                    Where Id=:ContactRelationship.Contact__c 
                    Limit 1
                ];    
            }
            else
            {
                Contact contactObject = [
                    Select Id, IsDeleted, MasterRecordId, accountId, LastName, FirstName, Salutation, Name, Recordtype.Name,
                    RecordTypeId, Email 
                    From Contact
                    Where Id=:ContactRelationship.Contact__c 
                    Limit 1
                ];
                
                CurrentContact.FirstName = contactObject.FirstName;
                CurrentContact.LastName = contactObject.LastName;
                CurrentContact.Email = contactObject.Email;
            }
            //This is set when record type is changed From View Contact Page
            if(changedRecordTypeId != Null)
            {
                if(recordTypeHRId.containsIgnoreCase(changedRecordTypeId)){
                    recordType = recordTypeHRId;                       
                }
                else if(recordTypeCustomerId.containsIgnoreCase(changedRecordTypeId))
                {
                    recordType = recordTypeCustomerId;                     
                }
                else if(recordTypeDigitalId.containsIgnoreCase(changedRecordTypeId))
                {
                    recordType = recordTypeDigitalId;                     
                }   
                else if(recordTypeTestContactId.containsIgnoreCase(changedRecordTypeId))
                {
                    recordType = recordTypeTestContactId;                     
                }  
            }
            else
            {
                recordType = CurrentContact.RecordTypeId;                
            }            
        }       
    }
    
    public void DuplicateCheck(){
        String tempEmail = String.ValueOf(CurrentContact.Email);
        
        if(tempEmail != null )
        {
            if( (recordType != recordTypeHRId && recordType != recordTypeTestContactId) && 
               tempEmail.containsIgnoreCase('@cdk.com') )
            {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.Error,'Only Internal HR can create contact with email cdk.com'));    
            }
            else
            {
                DuplicateChecks();
            }
        }
        else
        {
            DuplicateChecks();
        }
    }
    
    public void DuplicateChecks()
    {
        isDuplicate = False;       //This variable is used for showing alert msgs on page - can be removed if Mode=Read param working
        isReadOnly = True;         //This variable is used to toggle read only areas on page
        
        String returnedContactId = '';
        String accountContactIds = '';
        
        CurrentContact.RecordTypeId = recordType;
        
        // 2016-06-16 matt.keefe@cdk.com - add Account to Contact for inserting Dealer Group
        CurrentContact.AccountId = ContactRelationship.Account__c;
        
        Map<String, ALL_SharedContact_Helper.duplicateCheckWrapper>  insertContactMap 
            = ALL_SharedContact_Helper.InsertContact(CurrentContact,ContactRelationship.Role__c,Null,'');
        
        ALL_SharedContact_Helper.duplicateCheckWrapper results = insertContactMap.get('Contact');
        try{
            
            if(results != Null){
                system.debug('$$ '+results);
                
                isDuplicate = (results.insertedRecordIds==Null || results.insertedRecordIds.isEmpty());  
                
                if(isDuplicate){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Contact and Contact Relationship currently exists.'));
                }
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'New Contact Created.'));
                }
                
                if(results.existingRecordIdToNewRecordMap.size() >0)
                {
                    for(Id contactIds : results.existingRecordIdToNewRecordMap.keySet())
                    {
                        sObject obj = results.existingRecordIdToNewRecordMap.get(contactIds);
                        returnedContactId = contactIds;
                    }
                }
                else // this is to get the newly created contact Id - using returnedContactId
                {
                    for(Id contactIds : results.insertedRecordIds){
                        returnedContactId = contactIds;
                    } 
                }
                
                Contact tempContact = [
                    Select
                    accountId,Id,FirstName,LastName,Name,HR_Manager__c,HR_Title__c,RecordtypeId,Email,Total_Policies__c,
                    Total_Policies_To_Approve__c,Manual_Policy_Addition__c,FY16_US_Acknowledgement__c,
                    County__c,HR_Location__c,HR_Business_Unit__c,HR_Status__c,HR_Rehire_Date__c,HR_Hire_Date__c,HR_Last_Date_Worked__c,
                    HR_Term_Date__c,Employee_Id__c,User__c,Vip__c,VIP_Reason_Code__c,Vendor_Id__c,MIddle_Initial__c,Extension__c,
                    MobilePhone,Title,HomePhone,XCOM_member__c,Dealer_Group__c,Title_Comments__c,Vendor_Company__c,Do_Not_Solicit__c,
                    Do_Not_Fax__c,HasOptedOutOfEmail,Personal_Email__c,Language_Preference__c,CSI_Last_Filled_Out_Date__c,
                    HR_Work_Country_Code__c,Associates_Last_Termination_Date_Time__c,HR_Business_Partner__c,OwnerId,CreatedById,LastModifiedById
                    From Contact
                    Where Id=:returnedContactId 
                    Limit 1
                ];
                
                CurrentContact = tempContact; 
                recordType = tempContact.RecordtypeId;                
                CurrentContact.Status__c = 'Active';
                
                if(tempContact.accountId == Null){
                    tempContact.accountId = ContactRelationship.Account__c;
                    update tempContact;
                }              
                
                CurrentContact.put('accountId',tempContact.accountId);   
            }
            
            if(returnedContactId != Null && returnedContactId.length()>0)
            {            
                Boolean isContactRelationshipExists = True;
                Contact_Relationship__c tempContactRelationship;
                accountContactIds = String.ValueOf(ContactRelationship.Account__c) + String.ValueOf(returnedContactId);
                CurrentContact.Id = returnedContactId;
                
                try
                {
                    tempContactRelationship =[
                        Select 
                        Id, Account__c, Role__c, Status__c 
                        From Contact_Relationship__c 
                        Where Account_Contact_Id__c =: accountContactIds
                        Limit 1
                    ];  
                }
                catch(Exception e)
                {
                    //CR does not exits but contact might exist
                    isContactRelationshipExists = False;
                    System.debug('Exception:'+e.getMessage());
                }
                
                if(tempContactRelationship!=Null && isContactRelationshipExists)
                {
                    ContactRelationship.Id = tempContactRelationship.Id;
                    ContactRelationship.Account__c = tempContactRelationship.Account__c;
                    ContactRelationship.Status__c = 'Active';
                    update ContactRelationship;
                }
                CurrentContact.put('CRId',ContactRelationship.Id);   
            }
            
        }
        catch(Exception e){
            System.debug('Exception:'+e.getMessage());
        }
        
        PageReference PageRef = ApexPages.currentPage();
        PageRef.getParameters().put('Id',ContactRelationship.Id);
        showbuttons = False;
        readMode=False;   
    }    
    
    public PageReference EditPage()
    {
        showbuttons = False;
        readMode = False;
        isReadOnly = True;
        PageReference PageRef = new PageReference('/apex/sharedContactsPage?CRId=' +ContactRelationship.Id+ '&accountId=' +ContactRelationship.Account__c);
        PageRef.getParameters().put('isEdit','True');  
        PageRef.setRedirect(True);
        return PageRef;
    }
    
    public PageReference Cancel(){
        PageReference PageRef = new PageReference('/apex/sharedContactsPage?AccountId='+ ContactRelationship.Account__c +'&CRId='+ ContactRelationship.Id);        
        PageRef.setRedirect(True);
        return PageRef;
    }
    
    public PageReference CreateContactRelationship(){  
        showbuttons = True;
        readMode = True; 
        
        if(isDuplicate){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Existing Contact and Contact relationship Updated Successfully.'));
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'New Contact and Contact relationship Updated Successfully.'));
        }
        
        String returnedContactId = '';
        Boolean isContactRelationshipExist = True;
        Contact_Relationship__c tempContactRelationship;
        
        try{
            String accountContactIds = String.ValueOf(ContactRelationship.Account__c) + String.ValueOf(CurrentContact.Id);
            tempContactRelationship =[Select Id From Contact_Relationship__c Where Account_Contact_Id__c =: accountContactIds Limit 1];  
            update CurrentContact;
            
        }
        catch(Exception e){
            isContactRelationshipExist = False;
            System.debug('Exception:'+e.getMessage());
            ApexPages.addMessages(e);
        }
        
        if(isContactRelationshipExist)
        {
            ContactRelationship.Id=tempContactRelationship.Id;
            update ContactRelationship;
        }
        else
        {
            //mapping required contact field if needed
            ContactRelationship.Contact__c = CurrentContact.Id;
            insert ContactRelationship;
        }
        
        // Dave's request to redirect to default view page
        PageReference PageRef = new PageReference('/'+CurrentContact.Id);
        showbuttons = True;
        PageRef.setRedirect(True); 
        return PageRef;
    }
    
    //getRecordTypes is used to prepopulate the picklist values in the visualforcepage
    public List<SelectOption> getRecordTypes() {
        List<RecordType> recordTypeList = [
            Select 
            Id,Name,SobjectType 
            From RecordType 
            Where SobjectType = 'Contact' And isactive = true
        ];
        List<SelectOption> options = new List<SelectOption>();         
        Schema.SObjectType sObjectType = Contact.SObjectType;
        List<RecordTypeInfo> recordTypeInfoList = sObjectType.getDescribe().getRecordTypeInfos();    
        if (recordTypeInfoList.size() > 1) {
            for (RecordTypeInfo recordTypeInfo : recordTypeInfoList) {
                if (recordTypeInfo.isAvailable()          
                    && !String.valueOf(recordTypeInfo.getRecordTypeId()).endsWith('AAA'))
                    for(Recordtype record : recordTypeList){ 
                        if(recordTypeInfo.getName().equalsIgnoreCase(record.Name)){
                            options.add(new SelectOption(record.Id, record.Name));  
                        }            
                    }                
            }
        }    
        else{
            for(Recordtype record : recordTypeList){ 
                if(recordTypeInfoList[0].getName().equalsIgnoreCase(record.Name)){
                    options.add(new SelectOption(record.Id, record.Name));  
                }            
            }             
        }             
        return options;
    }
    */
}