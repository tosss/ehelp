/* **************************************************************************************** 
***** 03/28/2017 vijay.manimaran@cdk.com Created 
*****
******************************************************************************************** */

public class EMP_Corpcard_Controller {
    public contact contactObj { get; set; }
    
    @AuraEnabled
    public static void deletePolicies() {
        List<EMP_policy__c> policies ;
        try {
            policies = [
                Select id, User_Name__c, Policy_Type__c, Acknowledgement_Status__c, Name
                From EMP_policy__c
                Where User_Name__c = :userInfo.getuserId()
                AND Policy_Type__c = 'Bank of America'
            ];
            
            delete policies;
        }
        catch(exception e)
        {
        }
    }
    
    @AuraEnabled
    public static contact contactObj(String userID)
    {
        if(userId == Null || userId ==''){
            userId = UserInfo.getUserId();
        } else {
            UserId = userID;
        }
        Contact contactObj = [
            Select
            Id, HR_Manager__c, User__c, HR_Manager__r.user__r.Email, FirstName, LastName, HR_Manager__r.Name, Name,
            BOA_Access_to_Pcard__c, BOA_Registered_T_E_Card__c,HR_Manager__r.User__r.Id,Email,
            BOA_Requested_Pcard__c, Vendor_Id__c, user__r.Contractor__c,HR_Manager__r.Email
            From Contact
            Where User__c = : UserId 
            AND AccountId = :CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c
            Limit 1
        ];
        return contactObj;
    }
    
    @AuraEnabled
    Public static list<Portal_Form__c> portalFormsList(){
        //list<Portal_Form__c> portalForms = new list<Portal_Form__c>();
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'COM Bank of America');
        contact contactObj = EMP_Corpcard_Controller.contactObj(Null);
        String queryString = 'SELECT Id, Name, RecordTypeId, CreatedDate, CreatedById, '
            +'Contact__c, BOA_Access_to_Pcard__c, BOA_Address_Line_2__c, BOA_Address_Line_3__c, BOA_Address_Line_4__c,'
            +'BOA_Beginning_Date__c, BOA_BirthDate__c, BOA_City__c, BOA_Country__c, BOA_Currency_USD_CAD__c, BOA_Date_Time_of_Increase_Request__c,'
            +'BOA_Date_of_Birth__c, BOA_End_Date__c, BOA_Increase_Justification__c, BOA_Mailing_Address__c, BOA_ManagerEmail__c, BOA_Manager_Approval__c,'
            +'BOA_Manager__c, BOA_NameOnCard__c, BOA_Phone__c, BOA_SelectedCard__c, BOA_State_Province__c, BOA_ZipCode__c, BOA_Card_Type__c,'
            +'WorkFlow__c, BOA_HR_Manager_FirstName__c, BOA_HR_Manager_LastName__c, BOA_Manager_Response_date__c, BOA_Procurement_Manager_Response_Date__c,'
            +'BOA_Rejection_Reason__c, BOA_sendEmail__c FROM Portal_Form__c'
            +' WHERE recordtypeID =: portalFormsRecordTypeID AND contact__c =: contactObj.Id';
        list<sObject> portalForms = Database.query(queryString);
        return portalForms;
    }
    
    
    @AuraEnabled
    Public static list<Portal_Form__c> pendingRequest(){
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'COM Bank of America');
        contact contactObj = EMP_Corpcard_Controller.contactObj(Null);
        list<Portal_Form__c> portalForms = 
            [
                SELECT Id, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate,
                LastReferencedDate, Contact__c, BOA_Access_to_Pcard__c, BOA_Address_Line_2__c, BOA_Address_Line_3__c, BOA_Address_Line_4__c,
                BOA_Beginning_Date__c, BOA_BirthDate__c, BOA_City__c, BOA_Country__c, BOA_Currency_USD_CAD__c, BOA_Date_Time_of_Increase_Request__c,
                BOA_Date_of_Birth__c, BOA_End_Date__c, BOA_Increase_Justification__c, BOA_Mailing_Address__c, BOA_ManagerEmail__c, BOA_Manager_Approval__c,
                BOA_Manager__c, BOA_NameOnCard__c, BOA_Phone__c, BOA_SelectedCard__c, BOA_State_Province__c, BOA_ZipCode__c, BOA_Card_Type__c,
                WorkFlow__c, BOA_HR_Manager_FirstName__c, BOA_HR_Manager_LastName__c, BOA_Manager_Response_date__c, BOA_Procurement_Manager_Response_Date__c,
                BOA_Rejection_Reason__c, BOA_sendEmail__c FROM Portal_Form__c
                WHERE recordtypeID =: portalFormsRecordTypeID AND contact__c =: contactObj.Id
            ];
        return portalForms;
    }
    
    //Check card Availabilty
    @AuraEnabled
    public static string checkCardRequested(String pageType)
    {
        contact existingRequestCheck = EMP_Corpcard_Controller.contactObj(Null);
        list<EMP_policy__c> policies = [
            Select id, User_Name__c, Policy_Type__c, Acknowledgement_Status__c, Name
            From EMP_policy__c
            WHERE User_Name__c = :userInfo.getuserId()
            AND Policy_Type__c = 'Bank of America' 
            LIMIT 50
        ];
        delete policies;
        
        if (existingRequestCheck.vendor_Id__c == NULL || existingRequestCheck.vendor_Id__c == '')
        {
            return 'failurevendor';
        }
        else if (existingRequestCheck.user__r.Contractor__c == true )
        {
            return 'failurecontractor';
        }
        else if (existingRequestCheck.BOA_Registered_T_E_Card__c == true && pageType =='TravelExpenseCard')
        {
            return 'failureTECard';
        }
        else if (existingRequestCheck.BOA_Requested_Pcard__c == true && pageType =='PCard')
        {
            return 'failurePCard';
        }
        else if (existingRequestCheck.BOA_Access_to_Pcard__c == false && pageType =='PCard')
        {
            return 'failurePCardAccess';
        }
        
        return 'success';
    }
    
    @AuraEnabled
    public static list<Portal_Form__c> employeePortalResults(String pageParam,String searchVal){
        list<Portal_Form__c> portalForms = new list<Portal_Form__c>();
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'COM Bank of America');
        Portal_Form__c portalForm = new Portal_Form__c();
        if(pageParam == 'searchEmployee'){
            portalForms = EMP_Corpcard_Controller.searchResults(searchVal);
            return portalForms;
        }else if(pageParam == 'pcardAccess')
        {
            contact contactobj = EMP_Corpcard_Controller.contactObj(searchVal);
            system.debug('***** contacatobj'+contactobj);
            String contactName = contactobj.FirstName+' '+contactobj.LastName +'-'+contactobj.Email;
            portalForms = EMP_Corpcard_Controller.searchResults(contactobj.Email);
            list<Portal_Form__c> listPortalForm = new list<Portal_Form__c>();
            if(contactobj.BOA_Access_to_Pcard__c == true){
                return null;
            }else{
                portalForm.BOA_SelectedCard__c = pageParam +' '+system.now();
                system.debug('******** contact id ******* '+contactobj.id);
                if(Test.isRunningTest()){
                }else{
                    portalForm.Contact__c = contactobj.id;
                }
                
                portalForm.BOA_Card_Type__c = 'PCard';
                portalForm.RecordTypeId = portalFormsRecordTypeID;
                portalForm.BOA_NameOnCard__c = contactobj.FirstName+' '+contactobj.LastName +'-'+contactobj.Email;
                portalForm.BOA_Employee_EMAIL__c = contactobj.Email;
                listPortalForm.add(portalForm);
                
                insert listPortalForm;
                update listPortalForm;
                
                list<Portal_Form__c> lstportalform = [ 
                    Select 
                    id,Name, BOA_NameOnCard__c 
                    FROM Portal_Form__c 
                    WHERE BOA_NameOnCard__c =: listPortalForm[0].BOA_NameOnCard__c 
                ];
                return lstportalform;
            }
        }else {
            return null;
        }
    }
    
    @AuraEnabled
    public static list<Portal_Form__c> searchResults(String searchVal){
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'COM Bank of America');
        
        list<Portal_Form__c> listPortalForm = [
            SELECT Id, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate,
            LastReferencedDate, Contact__c, BOA_Access_to_Pcard__c, BOA_Address_Line_2__c, BOA_Address_Line_3__c, BOA_Address_Line_4__c,
            BOA_Beginning_Date__c, BOA_BirthDate__c, BOA_City__c, BOA_Country__c, BOA_Currency_USD_CAD__c, BOA_Date_Time_of_Increase_Request__c,
            BOA_Date_of_Birth__c, BOA_End_Date__c, BOA_Increase_Justification__c, BOA_Mailing_Address__c, BOA_ManagerEmail__c, BOA_Manager_Approval__c,
            BOA_Manager__c, BOA_NameOnCard__c, BOA_Phone__c, BOA_SelectedCard__c, BOA_State_Province__c, BOA_ZipCode__c, BOA_Card_Type__c,BOA_Employee_EMAIL__c,
            WorkFlow__c, BOA_HR_Manager_FirstName__c, BOA_HR_Manager_LastName__c, BOA_Manager_Response_date__c, BOA_Procurement_Manager_Response_Date__c,
            BOA_Rejection_Reason__c, BOA_sendEmail__c
            FROM Portal_Form__c
            WHERE recordtypeID =: portalFormsRecordTypeID
            AND BOA_Employee_EMAIL__c =: searchVal
        ];
        
        return listPortalForm;
    }
    
    @AuraEnabled
    public static boolean cardAccess()
    {
        try {
            Contact contactObj = EMP_Corpcard_Controller.contactObj(Null);
            if (contactObj.BOA_Access_to_Pcard__c == true)
            {
                Boolean	pCardAccess = true;
                return pCardAccess;
            }
            return false;
        }
        catch(Exception e)
        {
            return false;
        }
    }
    //save method
    @AuraEnabled
    public static string Acknowledgment(string Acknowledgementval)
    {
        Contact contactObj = EMP_Corpcard_Controller.contactObj(Null);
        EMP_Policy__c policyAck = new EMP_Policy__c();
        policyAck.Acknowledgement_Status__c = true;
        policyAck.Date_of_Acknowledgement__c = system.now();
        policyAck.Employee_Contact__c = contactObj.Id;
        policyAck.Policy_Type__c = 'Bank of America';
        policyAck.User_Name__c = userInfo.getuserId();
        
        if (Acknowledgementval == 'TEPolicy')
        {
            policyAck.Name = 'Travel & Expense Policy Acknowledge';
        }
        else if (Acknowledgementval == 'PCPolicy')
        {
            policyAck.Name = 'Pcard Policy Acknowledged';
        }
        else if (Acknowledgementval == 'MEPolicy')
        {
            policyAck.Name = 'Pcard SMMP Acknowledged';
        }
        else if (Acknowledgementval == 'TCPolicy')
        {
            policyAck.Name = 'Terms and Condition Acknowledged';
        }
        try{
            insert policyAck;
            return 'success';
        }
        catch(exception ex){
            return 'failure';
        }
    }
    
    @auraEnabled
    public static List<EMP_policy__c> policyExistingCheck() {
        List<EMP_policy__c> policies = new List<EMP_policy__c> ();
        try {
            policies = [
                SELECT id, User_Name__c, Policy_Type__c, Acknowledgement_Status__c, Name
                FROM EMP_policy__c
                WHERE User_Name__c = :userInfo.getuserId() 
                AND Policy_Type__c = 'Bank of America'
                Limit 10
            ];
            return policies;
        }
        catch(exception e)
        {
            return null;
        }
    }
    
    @AuraEnabled
    public static String ApprovalReject(Portal_Form__c portalForms, String decision, string casedescription)
    {
        contact contactObj = EMP_Corpcard_Controller.contactObj(Null);
        
        // check if the logged in person is a manager Assoc Procurement	
        list<GroupMember> groupMembers = [ 
            SELECT Group.Name,UserOrGroupId
            FROM GroupMember 
            WHERE Group.Name = 'Assoc Procurement' 
            AND Group.Type = 'Queue' 
        ];
        Portal_Form__c PF = new Portal_Form__c();
        if(portalForms.contact__r.HR_Manager__c == contactObj.id)
        {
            if(decision == 'Approve'){
                decision = 'Manager - Approved';     
                PF.BOA_Manager_Response_date__c = userinfo.getFirstName() +' '+ userinfo.getLastName()+'  -  '+System.now(); 
            }else{
                decision ='Manager - Rejected';
                PF.BOA_Manager_Response_date__c = userinfo.getFirstName() +' '+ userinfo.getLastName()+'  -  '+System.now(); 
            }
        }else{
            for(GroupMember c : groupMembers){
                if(c.UserOrGroupId == userinfo.getUserId() && portalForms.BOA_Manager_Approval__c == 'Manager - Approved'){
                    if(decision == 'Approve'){
                        decision = 'Procurement - Approved'; 
                        PF.BOA_Manager_Response_date__c = userinfo.getName() +'  -  '+System.now(); 
                    }else{
                        decision ='Procurement - Rejected';
                        PF.BOA_Manager_Response_date__c = userinfo.getName() +'  -  '+System.now(); 
                    }
                }
            }
        }		
        PF.BOA_Manager_Approval__c = decision;
        PF.BOA_rejection_Reason__c =casedescription;
        PF.id = portalForms.id;
        try{
            update PF;
            return 'success';
        }
        catch(Exception ex){
            return 'failure';
        }
    }
    
    @AuraEnabled
    public static Portal_Form__c fetchPortalForm(String recordId){
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'COM Bank of America');
        Portal_Form__c portalForms = 
            [
                SELECT id, Name, RecordTypeId, Contact__c, BOA_Access_to_Pcard__c,CreatedDate,BOA_Manager_Response_date__c,BOA_Rejection_Reason__c,
                BOA_Address_Line_2__c, BOA_Address_Line_3__c, BOA_Address_Line_4__c, BOA_Beginning_Date__c, BOA_BirthDate__c,workflow__r.PRC_Approvals__c,
                workflow__r.contact__r.HR_Manager__r.Name, BOA_City__c, BOA_Country__c, BOA_Currency_USD_CAD__c, BOA_Date_Time_of_Increase_Request__c,
                BOA_Date_of_Birth__c, BOA_End_Date__c,contact__r.Email,
                BOA_Increase_Justification__c, BOA_Mailing_Address__c, BOA_NameOnCard__c, BOA_Phone__c, BOA_SelectedCard__c,
                BOA_State_Province__c, BOA_ZipCode__c, BOA_Card_Type__c,contact__r.HR_Manager__c 
                FROM Portal_Form__c
                WHERE recordtypeID =: portalFormsRecordTypeID
                AND workflow__c =: recordId
            ];
        
        
        contact contactObj = EMP_Corpcard_Controller.contactObj(Null);
        String ProcurementAccess = EMP_Corpcard_Controller.pcardEnabledAccess('pcardAccess');
        if(ProcurementAccess == 'pcardAccess_Access' || portalForms.contact__r.HR_Manager__c == contactObj.id){
            return portalForms;
        }else{
            return Null;
        }
    }
    
    
    @AuraEnabled
    public static String pcardEnabledAccess(String pageParameter){
        
        List<PermissionSetAssignment> lstcurrentUserPerSet =    [   
            SELECT Id, PermissionSet.Name,AssigneeId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :Userinfo.getUserId() 
        ];
        String user_has_permission;
        for ( PermissionSetAssignment psa : lstcurrentUserPerSet ) {
            if ( psa.PermissionSet.Name.equals('COM_Access_to_Enable_Pcard') && pageParameter == 'pcardAccess') {
                return 'pcardAccess_Access';
            } else if( psa.PermissionSet.Name.equals('COM_Access_to_Procurement_Team') && pageParameter == 'searchEmployee'){
                return 'searchEmployee_Access';
            } 
        }
        return null;
    }
    
    @AuraEnabled 
    public static String submitforApporval(Portal_Form__c portalForms, String selectedCard)
    {
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'COM Bank of America');
        Contact contactObj = EMP_Corpcard_Controller.contactObj(Null);
        user USR = [
            select
            Id, ManagerId, Email, Manager.Email, Manager.Name
            From User
            Where Id = :UserInfo.getUserId()
        ];
        
        Portal_Form__c PF = new Portal_Form__c();	
        if (contactObj.HR_Manager__c != Null || contactObj.HR_Manager__c != '')
        {
            PF.BOA_Manageremail__c = contactObj.HR_Manager__r.Email;
            PF.BOA_Manager__c = contactObj.HR_Manager__r.Name;
        }
        else
        {
            PF.BOA_Manageremail__c = USR.Manager.Email;
            PF.BOA_Manager__c = USR.Manager.Name;
        }
        if(selectedCard == 'Travel & Expense Card'){
            PF.BOA_Registered_T_E_Card__c = true;
            PF.BOA_Card_Type__c = 'Travel and Expense' ;
            PF.BOA_SelectedCard__c = selectedCard +' '+ system.now();
            
            
        }
        if(selectedCard == 'PCard'){
            PF.BOA_Registered_PCard__c = true;
            PF.BOA_Card_Type__c = 'PCard';
            PF.BOA_SelectedCard__c = selectedCard +' '+ system.now();
            
            
        }
        
        if(selectedCard=='Increase Limit on Travel or PCard'){
            PF.BOA_NameOnCard__c = Userinfo.getFirstName() +' '+Userinfo.getLastName();
            PF.BOA_Beginning_Date__c = portalForms.BOA_Beginning_Date__c;
            PF.BOA_End_Date__c = portalForms.BOA_End_Date__c;
            PF.BOA_Increase_Justification__c = portalForms.BOA_Increase_Justification__c;
            PF.BOA_Currency_USD_CAD__c = portalForms.BOA_Currency_USD_CAD__c;
            PF.BOA_Card_Type__c = portalForms.BOA_Card_Type__c;
            PF.BOA_SelectedCard__c = 'Increase' +' '+ system.now();
            
            
        }else{
            PF.BOA_NameOnCard__c = portalForms.BOA_NameOnCard__c;
            PF.BOA_SelectedCard__c = selectedCard +' '+ system.now();
            
        }
        if(selectedCard == 'pcardAccess'){
            contactObj.BOA_Access_to_Pcard__c = true;
            PF.BOA_NameOnCard__c = Userinfo.getFirstName() +' '+Userinfo.getLastName();
            PF.BOA_Card_Type__c = 'PCard';
        }
        
        string s1=string.valueof(portalForms.BOA_Phone__c);
        string s2=string.valueof(portalForms.BOA_ZipCode__c);
        PF.Contact__c = contactObj.Id;
        PF.RecordTypeID = portalFormsRecordTypeID;
        PF.OwnerId = contactObj.HR_Manager__r.User__r.Id;
        PF.BOA_Mailing_Address__c = portalForms.BOA_Mailing_Address__c;
        PF.BOA_Address_Line_2__c = portalForms.BOA_Address_Line_2__c;
        PF.BOA_Address_Line_3__c = portalForms.BOA_Address_Line_3__c;
        PF.BOA_Address_Line_4__c = portalForms.BOA_Address_Line_4__c;
        PF.BOA_City__c = portalForms.BOA_City__c;
        PF.BOA_State_Province__c = portalForms.BOA_State_Province__c;
        PF.BOA_ZipCode__c = s2;
        PF.BOA_Phone__c = s1;
        PF.BOA_Date_of_Birth__c = portalForms.BOA_Date_of_Birth__c;
        PF.BOA_Country__c = portalForms.BOA_Country__c;
        PF.BOA_Employee_EMAIL__c = contactObj.Email;
        PF.PRC_Status__c = 'Open';    
        PF.BOA_sendEmail__c = true;
        try{
            insert PF;
            update PF;
            return 'success';
        }
        catch(exception ex)
        {
            return 'failure';
        }
    }
    
    @AuraEnabled
    public static String updatePortalForm(String portalformID, string updateFlag)
    {
        system.debug('************* portalformID  '+portalformID);
        Portal_Form__c portalForms = 
            [
                SELECT Id, Name, RecordTypeId, Contact__c, BOA_Access_to_Pcard__c,CreatedDate,BOA_Manager_Approval__c,BOA_HR_Manager_LastName__c,
                BOA_HR_Manager_FirstName__c,BOA_Manager_Response_date__c,BOA_Rejection_Reason__c,Contact__r.user__c,
                BOA_Address_Line_2__c, BOA_Address_Line_3__c, BOA_Address_Line_4__c, BOA_Beginning_Date__c, BOA_BirthDate__c,workflow__r.PRC_Approvals__c,
                BOA_Procurement_Manager_Response_Date__c, workflow__r.contact__r.HR_Manager__r.Name, BOA_City__c, BOA_Country__c, BOA_Currency_USD_CAD__c,
                BOA_Date_Time_of_Increase_Request__c, BOA_Date_of_Birth__c, BOA_End_Date__c, BOA_Increase_Justification__c, BOA_Mailing_Address__c,
                BOA_NameOnCard__c, BOA_Phone__c, BOA_SelectedCard__c,BOA_State_Province__c, BOA_ZipCode__c, BOA_Card_Type__c,BOA_sendEmail__c 
                FROM Portal_Form__c
                WHERE Name =: portalformID
            ];
        
        try {
            if(updateFlag == 'sendEmail'){
                portalForms.BOA_sendEmail__c = true;
            }else if(updateFlag == 'pcardAccess'){
                portalForms.BOA_Access_to_Pcard__c = true;
            }
            update portalForms; 
            return 'success';
        }
        catch(exception ex)
        {
            return 'failure';
        }
    }
    
}