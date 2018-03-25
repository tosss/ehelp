/*----------------------------------------------------------------------
* RQ-06791 BankofAmerica
* vijay.manimaran@cdk.com - created this class  
* 
* ---------------------------MODIFICATIONS-----------------------------
* 2016-09-19 Vijay.manimaran@cdk.com  Updated logic 
* 2017-01-31 vijay.manimaran@cdk.com Updated logic line 236 - 250 
------------------------------------------------------------------------*/
public class EMP_BankofAmerica_Controller {
    
    public EMP_Policy__c policyAck { get; set; }
    public contact contactObj { get; set; }
    public Boolean pCardAccess { get; set; }
    public Boolean pCardRequested { get; set; }
    public Boolean newCardRequested { get; set; }
    public static Boolean SHOWCARDS { get; set; }
    public Boolean redirectPage { get; set; }
    public case caseObj { get; set; }
    public string hiddenCardValue { get; set; }
    public string Acknowledgementval { get; Set; }
    public string addressline1 { get; set; }
    public string addressline2 { get; set; }
    public string addressline3 { get; set; }
    public string addressline4 { get; set; }
    public String birthDate { get; set; }
    public string digitsOnCard { get; set; }
    public static string NEW_TRAVELCARD = 'Travel & Expense Policy Acknowledge';
    public static string PCARD = 'Pcard Policy Acknowledged';
    public static string PCARD_INC = 'Pcard SMMP Acknowledged';
    public Integer begindatevalue { get; set; }
    public Integer beginmonthvalue { get; set; }
    public Integer beginyearvalue { get; set; }
    public Integer enddatevalue { get; set; }
    public Integer endmonthvalue { get; set; }
    public Integer endyearvalue { get; set; }
    public EMP_BankofAmerica_Controller(apexPages.StandardController cnt)
    {
        
    }
    
    public EMP_BankofAmerica_Controller()
    {
        caseObj = new case();
        ID caseRecordtype = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('case', 'Procurement');
        caseObj.RecordTypeID = caseRecordtype;
        SHOWCARDS = cardAccess();
        contact existingRequestCheck = contactObj();
        
    }
    
    @Remoteaction
    public static void deletePolicies() {
        EMP_BankofAmerica_controller BOA = new EMP_BankofAmerica_controller();
        List<EMP_policy__c> policies = BOA.policyExistingCheck();
        try {
            delete policies;
        }
        catch(exception e)
        { }
    }
    
    @Remoteaction
    public static contact contactObj()
    {
        contact contactObj = [
            Select
            Id, HR_Manager__c, User__c, HR_Manager__r.user__r.Email, FirstName, LastName, HR_Manager__r.Name, Name,
            BOA_Access_to_Pcard__c, BOA_Registered_T_E_Card__c,
            BOA_Requested_Pcard__c, Vendor_Id__c,
            user__r.Contractor__c
            From contact
            Where User__c = :UserInfo.getUserId() and AccountId = :CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c
            limit 1
        ];
        return contactObj;
    }
    
    //Check card Availabilty
    @Remoteaction
    public static string checkCardRequested(string checkCardRequestedVal)
    {
        system.debug('*** checkCardRequestedVal' +checkCardRequestedVal);
        
        contact existingRequestCheck = contactObj();
        if (existingRequestCheck.vendor_Id__c == NULL || existingRequestCheck.vendor_Id__c == '')
        {
            return 'failurevendor';
            
        }
        else if (existingRequestCheck.user__r.Contractor__c == true)
        {
            return 'failurecontractor';
        }
        
        if ((checkCardRequestedVal == 'newTravelCard' && existingRequestCheck.BOA_Registered_T_E_Card__c == True))
        {
            return 'failure';
        }
        system.debug('*** checkCardRequestedVal' +checkCardRequestedVal);
        if ((checkCardRequestedVal == 'Pcard' && existingRequestCheck.BOA_Requested_Pcard__c == True))
        {
            return 'failure';
        }
        
        
        return 'success';
    }
    
    public boolean cardAccess()
    {
        try {
            contactObj = [
                Select
                Id, HR_Manager__c, User__c, HR_Manager__r.user__r.Email, FirstName, LastName, HR_Manager__r.Name, Name,
                BOA_Access_to_Pcard__c, BOA_Registered_T_E_Card__c, BOA_Requested_Pcard__c
                From contact
                Where User__c = :UserInfo.getUserId() and AccountId = :CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c
                limit 1
            ];
            
            if (contactObj.BOA_Access_to_Pcard__c == true)
            {
                pCardAccess = true;
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
    @Remoteaction
    public static string Acknowledgment(string Acknowledgementval)
    {
        contact contactObj = [
            Select
            Id, HR_Manager__c, User__c, HR_Manager__r.user__r.Email, FirstName, LastName, HR_Manager__r.Name, Name,
            BOA_Access_to_Pcard__c, BOA_Registered_T_E_Card__c, BOA_Requested_Pcard__c
            From contact
            Where User__c = :UserInfo.getUserId() and AccountId = :CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c
        ];
        
        EMP_Policy__c policyAck = new EMP_Policy__c();
        policyAck.Acknowledgement_Status__c = true;
        policyAck.Date_of_Acknowledgement__c = system.now();
        policyAck.Employee_Contact__c = contactObj.Id;
        policyAck.Policy_Type__c = 'Bank of America';
        policyAck.User_Name__c = userInfo.getuserId();
        
        if (Acknowledgementval == 'TravelPolicy')
        {
            policyAck.Name = 'Travel & Expense Policy Acknowledge';
        }
        else if (Acknowledgementval == 'Pcards')
        {
            policyAck.Name = 'Pcard Policy Acknowledged';
        }
        else if (Acknowledgementval == 'SMMP')
        {
            policyAck.Name = 'Pcard SMMP Acknowledged';
        }
        else if (Acknowledgementval == 'Termscondition')
        {
            policyAck.Name = 'Terms and Condition Acknowledged';
        }
        insert policyAck;
        
        ApexPages.Message myMsgs = new ApexPages.Message(ApexPages.Severity.INfo, 'Thank you for the Acknowledgment');
        ApexPages.addMessage(myMsgs);
        
        return 'success';
    }
    
    
    public List<EMP_policy__c> policyExistingCheck() {
        List<EMP_policy__c> policies = new List<EMP_policy__c> ();
        try {
            policies = [
                Select id, User_Name__c, Policy_Type__c, Acknowledgement_Status__c, Name
                From EMP_policy__c
                where User_Name__c = :userInfo.getuserId() and Policy_Type__c = 'Bank of America' limit 10
            ];
            return policies;
        }
        catch(exception e)
        {
            return null;
        }
    }
    
    public List<SelectOption> getdates() {
        List<SelectOption> options = new List<SelectOption> ();
        options.add(new SelectOption('', '--Date--'));
        
        for (integer i = 01; i <= 31; i++) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }
    public List<SelectOption> getmonths() {
        
        List<SelectOption> options = new List<SelectOption> ();
        options.add(new SelectOption('', '--Month--'));
        
        for (integer i = 01; i <= 12; i++) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }
    public List<SelectOption> getbirthYears() {
        List<SelectOption> options = new List<SelectOption> ();
        options.add(new SelectOption('', '--Year--'));
        date mydate = date.newInstance(1916, 1, 1);
        
        for (integer i = mydate.year(); i <= System.Today().year() - 18; i++) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }
    
    public List<SelectOption> getYears() {
        List<SelectOption> options = new List<SelectOption> ();
        options.add(new SelectOption('', '--Year--'));
        date mydate = date.newInstance(System.Today().year(), 1, 1);
        
        for (integer i = mydate.year(); i <= System.Today().year() + 5; i++) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }
    
    @Remoteaction
    public static String ApprovalReject(String id, String Approval, string casedescription){
        try{
            case cs = new case();
            cs.BOA_Manager_Approval__c =Approval;
            cs.id = id;
            cs.Description = casedescription;
            system.debug('am here ');
            upsert cs;
            return 'success';
        }
        catch(exception ex){
            return 'failure';
        }
    }
    
    public void submitforApporval()
    {
        
        ID caseRecordtype = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('case', 'Procurement');
        contactObj = [
            Select
            Id, HR_Manager__c, User__c, HR_Manager__r.user__r.Email,
            FirstName, LastName, HR_Manager__r.Name,
            Name, HR_Manager__r.Email,
            BOA_Access_to_Pcard__c, BOA_Registered_T_E_Card__c, BOA_Requested_Pcard__c, PRC_BOA_AmexCard_PreApproved__c
            From contact
            Where User__c = :UserInfo.getUserId() and AccountId = :CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c
            limit 1
        ];

        user USR = [
            select
            Id, ManagerId, Email, Manager.Email, Manager.Name
            From User
            Where Id = :UserInfo.getUserId()
        ];
        
        caseObj.RecordTypeID = caseRecordtype;
        caseObj.status = 'open';
        caseObj.BOA_Selectedcard__c = hiddenCardValue;
        Id ManagerID;
        
        if (contactObj.HR_Manager__c != Null)
        {
            caseObj.BOA_Manageremail__c = contactObj.HR_Manager__r.Email;
            caseObj.BOA_Manager__c = contactObj.HR_Manager__r.Name;
            caseObj.OwnerId = contactObj.HR_Manager__r.User__r.Id;
        }
        else if(contactObj.HR_Manager__c == Null || contactObj.HR_Manager__c == '')
        {
            caseObj.BOA_Manageremail__c = USR.Manager.Email;
            caseObj.BOA_Manager__c = USR.Manager.Name;
            caseObj.OwnerId =  USR.ManagerID;
        }
        
        
        caseObj.ContactId = contactObj.Id;
        //caseObj.OwnerId = ManagerID;
        caseObj.BOA_Mailing_Address__c = addressline1;
        caseObj.BOA_Address_Line_2__c = addressline2;
        caseObj.BOA_Address_Line_3__c = addressline3;
        caseObj.BOA_Address_Line_4__c = addressline4;
        caseObj.BOA_Card_Type__c = digitsOnCard;
        caseObj.PRC_BOA_AmexCard_PreApproved__c = contactObj.PRC_BOA_AmexCard_PreApproved__c;
        caseObj.BOA_BirthDate__c = birthDate;
        
        List<EMP_Policy__c> policyList = policyExistingCheck();
        if (hiddenCardValue == 'newTravelCard' && policyList.size() < 2) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Kindly Acknowledge the Policies ');
            ApexPages.addMessage(myMsg);
        } else if ((hiddenCardValue == 'Pcard') && policyList.size() < 3) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Kindly Acknowledge the Policies ');
            ApexPages.addMessage(myMsg);
        }
        else
        {
            Boolean isError = false;
            
            for (EMP_Policy__c policy : policyList)
            {
                if (policy.Acknowledgement_Status__c == false && hiddenCardValue == 'newTravelCard' && policy.Name == NEW_TRAVELCARD)
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Kindly Acknowledge the Travel and Expense Policies ');
                    ApexPages.addMessage(myMsg);
                    isError = true;
                }
                else if (policy.Acknowledgement_Status__c == false && hiddenCardValue == 'Pcard')
                {
                    if (policy.Name == PCARD) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Kindly Acknowledge the Pcard Policies ');
                        ApexPages.addMessage(myMsg);
                        isError = true;
                    }
                    else
                    {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Kindly Acknowledge the Pcard Policies ');
                        ApexPages.addMessage(myMsg);
                        isError = true;
                    }
                }
                else
                {
                    
                    if (contactObj.BOA_Registered_T_E_Card__c == true && hiddenCardValue == 'newTravelCard')
                    {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ' You have already requested the Travel Expense Card');
                        ApexPages.addMessage(myMsg);
                        isError = true;
                    }
                    else if (contactObj.BOA_Requested_Pcard__c == true && hiddenCardValue == 'Pcard')
                    {
                        ApexPages.Message myMsgs = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have already requested the PCard');
                        ApexPages.addMessage(myMsgs);
                        isError = true;
                    }
                    
                }
            }
            
            if (!isError) {
                try {
                    if (hiddenCardValue == 'PcardInc')
                    {
                        caseObj.BOA_NameOnCard__c = contactObj.FirstName + '' + contactObj.LastName;
                    }
                    insert caseObj;
                    
                    if (hiddenCardValue == 'newTravelCard')
                    {
                        contactObj.BOA_Registered_T_E_Card__c = true;
                        
                    }
                    if (hiddenCardValue == 'Pcard')
                    {
                        contactObj.BOA_Requested_Pcard__c = true;
                        
                    }
                    update contactObj;
                    ApexPages.Message myMsgs = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your request has been successfully submitted.');
                    ApexPages.addMessage(myMsgs);
                }
                catch(exception e)
                {
                    system.debug('*********** exception' + e);
                    ApexPages.Message myMsgs = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to place Your Order, Please contact CorpCardAdmin@cdk.com');
                    ApexPages.addMessage(myMsgs);
                }
                
            }
        }
        
    }
}