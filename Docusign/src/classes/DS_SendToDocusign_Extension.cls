// 2015-6-11 siva.pragada@cdk.com added two methods getAllContacts() and getTheContact() remote actions





global class DS_SendToDocusign_Extension 
{
    public Boolean DisplaySigner2 {get; set;}
    public Boolean SignInPerson1 {get; set;}
    public Boolean SignInPerson2 {get; set;}
    public String Signer_1_Email {get; set;}
    public String Signer_2_Email {get; set;}
    public String Signer1EmailUpdate {get; set;}
    public String Signer2EmailUpdate {get; set;}
    public String SelectedListSigner1 {get; set;}
    public String SelectedListSigner2 {get; set;}
    public String SubjectInputValue {get; set;}
    public String EmailBody {get; set;}
    public Boolean FrenchWording {get; set;}
    public Boolean BuySellatBuyer {get; set;} 
    public Deal_State__c dealStateObject {get;set;}
    public Boolean buySellAtBuyerCheckBox {get; set;}
    public Account CurrentAccount{get; set;}
    public Deal_State__c DealState {get; set;}    
    public Boolean ErrorOnPage {get; set;}
    public Opportunity opp;
    public static Opportunity QueriedOpp {get; set;}
    public Boolean Is_2_Signer_Required {get;set;}
    
    public List<SelectOption> Signer_1_Options {get; set;}
    public List<SelectOption> Signer_2_Options {get; set;}
    public List<SelectOption> AllCcContacts {get; set;} // rename to AllCcContacts
    public Boolean SharedSystemAddendum {get; set;} 
            
    public static Opportunity QueryOpportunity(Id OpportunityId)
    {
        // query opportunity
        Opportunity QueriedOpportunity = new Opportunity();
        
        if (OpportunityId != null) 
        {
            list<Opportunity> Opportunities = [
                Select Id, Name, ADP_Opportunity_Owner__c, ADP_Opportunity_Owner__r.Name, ADP_Opportunity_Owner__r.Email, 
                       ADP_Opportunity_Owner__r.FirstName, ADP_Opportunity_Owner__r.LastName, Client_Signer_1__c, Client_Signer_2__c, 
                       AccountId, Account.Name, Client_Signer_1_Sign_in_Person_Override__c,
                       Account.Region__c, Account.Signer_1_2_Signer__c, Account.Signer_2_2_Signer__c, 
                       Account.Contact_Specific_Signer_1__c, Account.Contact_Specific_Signer_2__c, 
                       Account.Signer_Required__c, Account.Has_Corporate_Authorized_Signer__c, 
                       (Select Id, Name, Docusign_Envelope_Status__c, Client_1_Sign_In_Person__c, Client_2_Sign_In_Person__c,
                               French_Wording__c, Deal_Type__c, Shared_System_Addendum__c From Deal_State__r)
                From Opportunity 
                Where Id = :OpportunityId
            ];
            
            if(Opportunities != null && !Opportunities.isEmpty()) { QueriedOpportunity = Opportunities.get(0); }
        }
        
        return QueriedOpportunity;
    }
    
    //sanjay.ghanathey@cdk.com 07-Jan-2015 
    //To fetch Signers when account is changed
    public void changeAccount()
    {
        try
        {
            List<Account> ChangedAccount = [
                select Id, Name, 
                    Region__c, Signer_Required__c, Contact_Specific_Signer_1__c, Contact_Specific_Signer_2__c, 
                    Signer_1_2_Signer__c, Signer_2_2_Signer__c, Has_Corporate_Authorized_Signer__c 
                from Account 
                where Id = :dealStateObject.Alternate_DocuSign_Account__c 
                limit 1
            ];
            
            if(ChangedAccount != null && !ChangedAccount.isEmpty()) { CurrentAccount = ChangedAccount.get(0); }
            
            Id opportunityId = Apexpages.currentPage().getParameters().get('Id');
            QueriedOpp = DS_SendToDocusign_Extension.QueryOpportunity(OpportunityId);
            
            QueriedOpp.put('AccountId',CurrentAccount.Id);
            QueriedOpp.putSObject('Account',CurrentAccount);
            
            system.debug(QueriedOpp);
            
            
            Signer_1_Options = DS_SendToDocusign_Extension.SelectOptionListCollector(QueriedOpp, 'Signer_1_2_Signer__c', 'Contact_Specific_Signer_1__c');
            Signer_2_Options = DS_SendToDocusign_Extension.SelectOptionListCollector(QueriedOpp, 'Signer_2_2_Signer__c', 'Contact_Specific_Signer_2__c');
            
            //Check to disable/enable second Signer
            if(CurrentAccount.Signer_Required__c)
            {
                Is_2_Signer_Required = true;
            }
            else
            {
                Is_2_Signer_Required = false;
            }
        }
        catch(Exception e)
        {
            System.debug('Exception:'+e.getMessage());
        }
    }
    
    // Initialize the constructor and the some required variables    
    public DS_SendToDocusign_Extension(ApexPages.StandardController OpportunityController)
    {   
        // default to displaying the signer 2 fields
        DisplaySigner2 = true;       
        this.opp = (Opportunity) OpportunityController.getRecord();
        if(this.opp.Client_Signer_1_Sign_in_Person_Override__c!=null)
        {
            this.opp.Client_Signer_1_Sign_in_Person_Override__c = null;
        }
        
        if(this.opp.Client_Signer_2_Sign_in_Person_Override__c!=null)
        {
            this.opp.Client_Signer_2_Sign_in_Person_Override__c = null;
        }
        
        
        //Msg = null;
        dealStateObject = new Deal_State__c();
        
        // pre-populate a text value in the subject field of the visualforce page
        Id opportunityId = Apexpages.currentPage().getParameters().get('Id');
        QueriedOpp = DS_SendToDocusign_Extension.QueryOpportunity(OpportunityId);
        CurrentAccount = QueriedOpp.Account;
        
        
        system.debug(QueriedOpp);
        if(QueriedOpp != null)
        {
            Signer_1_Options = DS_SendToDocusign_Extension.SelectOptionListCollector(QueriedOpp, 'Signer_1_2_Signer__c', 'Contact_Specific_Signer_1__c');
            Signer_2_Options = DS_SendToDocusign_Extension.SelectOptionListCollector(QueriedOpp, 'Signer_2_2_Signer__c', 'Contact_Specific_Signer_2__c');
            
            SubjectInputValue = ''; 
            string EmailBodyTemplate = '{1}'; 
            
            if(QueriedOpp.Account != null)
            { 
                system.debug(QueriedOpp.Account);
                
                CurrentAccount = QueriedOpp.Account;
                Is_2_Signer_Required = CurrentAccount.Signer_Required__c;
                
                if(QueriedOpp != null &&
                   CurrentAccount != null &&
                   CurrentAccount.Has_Corporate_Authorized_Signer__c && 
                   !CurrentAccount.Signer_Required__c)
                {
                    // get the Account at the top of the hierarchy
                    Id TopAccountId = AccountHierarchyTools.TopParentAccountId(QueriedOpp.AccountId);
                    
                    CurrentAccount = [
                        Select Id, Name, Signer_2_2_Signer__c, Signer_Required__c 
                        From Account 
                        Where Id = :TopAccountId
                    ];
                }
                
                if (CurrentAccount.Signer_2_2_Signer__c == null || 
                    CurrentAccount.Signer_Required__c == false) 
                {
                    DisplaySigner2 = false; 
                }
                
                if(QueriedOpp.Account != null) { 
                    SubjectInputValue += QueriedOpp.Account.Name + ' '; }
                
                if(QueriedOpp.Account != null && QueriedOpp.ADP_Opportunity_Owner__c != null) {
                    SubjectInputValue += '(' + QueriedOpp.Account.Region__c + ', ' + QueriedOpp.ADP_Opportunity_Owner__r.Name + ')'; }
            }
            
            DealState = null;
            list<Deal_State__c> DealStates = QueriedOpp.getSObjects('Deal_State__r');
            
            if(DealStates != null && !DealStates.isEmpty()) 
            { 
                DealState = DealStates.get(0); 
            }
            
            FrenchWording = false;
            if(DealState != null) 
            {
                FrenchWording = DealState.French_Wording__c;
                SharedSystemAddendum = DealState.Shared_System_Addendum__c; // Shared_System_Addendum__c needs to be created in Training
            }
            
            if(!FrenchWording)
            {
                SubjectInputValue += ' Contract for e-signature'; 
                
                EmailBodyTemplate = 'You are receiving this contract for your electronic signature. \r\n\r\n'
                    + 'Please click on the "View Documents" link below to begin signing. \r\n\r\nThanks! \r\n';
            }
            else
            {
                SubjectInputValue += ' Contrat pour signature ?lectronique'; 
                
                EmailBodyTemplate = 'Vous recevez ce contrat pour votre signature ?lectronique. \r\n\r\n'
                    + 'S\'il vous pla?t cliquer sur le lien ?View Documents? ci-dessous pour commencer signature. \r\n\r\nMerci! \r\n';
            }
            
            EmailBodyTemplate += UserInfo.getName() + ' (' + UserInfo.getUserEmail() + ')';
            
            EmailBody = EmailBodyTemplate;
        }
        
        //ContactsOnAccount = DS_SendToDocusign_Extension.getAllContacts(CurrentAccount.ID);
        AllCcContacts = DS_SendToDocusign_Extension.getAllContacts(CurrentAccount);        
    }
    
    @RemoteAction
    global static List<SelectOption> getAllContacts(/*String CurrentAccountID*/ Account CurrentAccount)
    {
        
        List<SelectOption> AllCcContacts = new List<SelectOption>();
        AllCcContacts.add(new SelectOption('', '--None--'));
        If(/*CurrentAccountID*/ CurrentAccount != null)
        {
            Account AccountWithContacts = [
                Select Id, Name, (Select Id, Name, FirstName, LastName, Status__c, Email, DS_SLS_Required_cc__c From Contacts) 
                From Account 
                Where Id = /*:CurrentAccountID*/ :CurrentAccount.ID 
                Limit 1];
            
            List<Contact> AccountContacts = AccountWithContacts.getSobjects('Contacts');
            
            if(AccountContacts != null && !AccountContacts.isEmpty())
            {
                for(Contact c: AccountContacts)
                {
                    if(c.Status__c == 'Active')
                    {
                        AllCcContacts.add(new SelectOption(c.Id, c.name));                        
                    }
                }
            }
        }       
        return AllCcContacts;
    }
    
    // global class pass into the remote action method    
    global Class AllFieldVariables  
    {
        // variables those are in the pack that is comming into controller from javascript
        global String selectedListSigner1 {get;set;}
        global String selectedListSigner2 {get;set;}        
        global String Signer_1_Email {get;set;}
        global String Signer_2_Email {get;set;}
        global Boolean Signer1EmailUpdate {get; set;}
        global Boolean Signer2EmailUpdate {get; set;} 
        global String HiddenId {get; set;}
        global String OverrideSignerId1 {get; set;}
        global String OverrideSignerId2 {get; set;}
        global string SharedSystemSellerTitle {get; set;}
        global string SharedSystemSellerFirstName {get; set;}
        global string SharedSystemSellerLastName {get; set;}
        global string SharedSystemSeller2Title {get; set;}
        global string SharedSystemSeller2FirstName {get; set;}
        global string SharedSystemSeller2LastName {get; set;}
        
        // variables those are both comming in and going out of controller
        global String EmailBody {get; set;} 
        global String Subject {get; set;}
        global Boolean SignInPerson1 {get;set;}
        global Boolean SignInPerson2 {get;set;}
        
        // variables that are in the pack those are going back to javascript
        global String DealStateId {get; set;}
        global String ApexMessages {get; set;}
        global Boolean CreditCheck {get; set;}
        global Contact SignerContact1 {get; set;}
        global Contact SignerContact2 {get; set;}
        global Docusign_Recipient__c SignerContact3 {get; set;}
        global Docusign_Recipient__c SignerContact4 {get; set;}
        global Docusign_Recipient__c SignerContact5 {get; set;}
        global Docusign_Recipient__c SignerContact6 {get; set;}  
        global Docusign_Recipient__c SignerContact7 {get; set;}
        global Docusign_Recipient__c SignerContact8 {get; set;}
        global Docusign_Recipient__c SignerContact8_2 {get; set;}
        
        global String ADPOpportunityOwnerEmail {get;set;}
        global String ADPOpportunityOwnerLastName {get;set;}
        global String ADPOpportunityOwnerFirstName {get;set;}
    }
    
    @RemoteAction // pass in Fieldpack; return FieldPack
    public static AllFieldVariables UpdateDocusignFields(AllFieldVariables FieldPack) 
    {
        // Instantiate the class to gather all the Url building components as we go down 
        AllFieldVariables UrlVariablePack = new AllFieldVariables(); 
        Opportunity UpdatableOpp = new Opportunity();
        try
        {
            if(FieldPack.OverrideSignerId1!=null)
            {
                User userObject = new User();
                
                if(FieldPack.OverrideSignerId1 != null) {
                    
                    List<User> users = [
                        Select Id, Name, Email, FirstName, LastName 
                        From User 
                        Where Id = :FieldPack.OverrideSignerId1 
                        limit 1
                    ];
                    
                    if(users != null && !users.isEmpty()) {
                        userObject = users.get(0); 
                    }
                }
                UrlVariablePack.selectedListSigner1 = userObject.Name;
                UrlVariablePack.Signer_1_Email = userObject.Email;
            }
            
            if(FieldPack.OverrideSignerId2!=null)
            {
                User userObject = new User();
                
                if(FieldPack.OverrideSignerId2 != null) {
                    
                    List<User> users = [
                        Select Id, Name, Email, FirstName, LastName 
                        From User 
                        Where Id = :FieldPack.OverrideSignerId2 
                        limit 1
                    ];
                    
                    if(users != null && !users.isEmpty()) {
                        userObject = users.get(0); 
                    }
                }
                UrlVariablePack.selectedListSigner2 = userObject.Name;
                UrlVariablePack.Signer_2_Email = userObject.Email;
            }
            
            Id HiddenOppId = FieldPack.HiddenId;            
            
            // perform second layer of validation            
            UrlVariablePack.ApexMessages = DS_SendToDocusign_Extension.Validate(HiddenOppId);
            System.debug(UrlVariablePack.ApexMessages);
            
            if(UrlVariablePack.ApexMessages != null) { return UrlVariablePack; }
            
            Deal_State__c Ds = new Deal_State__c();
            
            List<Deal_State__c> DealStates = [
                Select Id, Name, Docusign_Envelope_Status__c, Opportunity__c, Client_Signer_1_Role__c, 
                Client_Signer_2_Role__c, CA_Approver_Email__c, Credit_Check__c, Client_Signer_1__c, Client_Signer_2__c
                From Deal_State__c
                Where Opportunity__c = :HiddenOppId
            ];
            
            if(DealStates != null && !DealStates.isEmpty()) { Ds = DealStates.get(0); }            
            
            UpdatableOpp = DS_SendToDocusign_Extension.QueryOpportunity(HiddenOppId);
            System.debug(UpdatableOpp);
            
            if(UpdatableOpp != null && UpdatableOpp.ADP_Opportunity_Owner__r != null) 
            {
                UrlVariablePack.ADPOpportunityOwnerEmail = UpdatableOpp.ADP_Opportunity_Owner__r.Email;
                UrlVariablePack.ADPOpportunityOwnerFirstName = UpdatableOpp.ADP_Opportunity_Owner__r.FirstName;
                UrlVariablePack.ADPOpportunityOwnerLastName = UpdatableOpp.ADP_Opportunity_Owner__r.LastName;
            }
            
            // query the selected contacts
            Contact Signer1Contact = null;             
            Contact Signer2Contact = null;
            
            if(FieldPack.selectedListSigner1 != null 
               && !String.isEmpty(FieldPack.selectedListSigner1))
            {
                List<Contact> Signer1Contacts = [
                    Select Id, FirstName, LastName, Name, Role__c, Email, DS_SLS_Required_cc__c 
                    From Contact 
                    Where Id = :FieldPack.selectedListSigner1
                ];
                
                if(Signer1Contacts != null && !Signer1Contacts.isEmpty()) { 
                    Signer1Contact = Signer1Contacts.get(0); 
                }
            }
            
            if(FieldPack.selectedListSigner2 != null 
               && !String.isEmpty(FieldPack.selectedListSigner2))
            {
                List<Contact> Signer2Contacts = [
                    Select Id, FirstName, LastName, Name, Role__c, Email, DS_SLS_Required_cc__c
                    From Contact 
                    Where Id = :FieldPack.selectedListSigner2
                ];
                if(Signer2Contacts != null && !Signer2Contacts.isEmpty()) { Signer2Contact = Signer2Contacts.get(0); }           
            }
            
            // update opportunity
            if(FieldPack.selectedListSigner1 != null && !String.isEmpty(FieldPack.selectedListSigner1))
            {
                UpdatableOpp.Client_Signer_1__c = FieldPack.selectedListSigner1;
            }
            
            if(FieldPack.selectedListSigner2 != null && !String.isEmpty(FieldPack.selectedListSigner2)) {
                UpdatableOpp.Client_Signer_2__c = FieldPack.selectedListSigner2; } 
            else
            {
                UpdatableOpp.Client_Signer_2__c = null;
            }
            
            //sanjay.ghanathey@cdk.com 17-feb-2015 Update Overridden User in Opp
            if(FieldPack.OverrideSignerId1!=null &&  FieldPack.OverrideSignerId1 != '000000000000000')
            {
                UpdatableOpp.Client_Signer_1_Sign_in_Person_Override__c = FieldPack.OverrideSignerId1;
            }
            else                    
            {
                UpdatableOpp.Client_Signer_1_Sign_in_Person_Override__c = null;
            }
            
            if(FieldPack.OverrideSignerId2!=null &&  FieldPack.OverrideSignerId2 != '000000000000000')
            {
                UpdatableOpp.Client_Signer_2_Sign_in_Person_Override__c = FieldPack.OverrideSignerId2;
            }
            else
            {
                UpdatableOpp.Client_Signer_2_Sign_in_Person_Override__c = null;
            }
            
            update UpdatableOpp; 
            
            
            // update deal state
            if(Ds != null)
            {
                if(FieldPack.SignInPerson1 == True){ Ds.Signer1_Sign_on_Paper__c = True; }
                if(FieldPack.SignInPerson2 == True){ Ds.Signer2_Sign_on_Paper__c = True; }
                if(FieldPack.SharedSystemSellerTitle != null){ Ds.Shared_System_Signer_Title__c = FieldPack.SharedSystemSellerTitle;}
                if(FieldPack.SharedSystemSeller2Title != null){ Ds.Shared_System_Signer2_Title__c = FieldPack.SharedSystemSeller2Title;}
                
                
                if(FieldPack.SharedSystemSellerFirstName != null && 
                   FieldPack.SharedSystemSellerLastName != null)
                { 
                    Ds.Shared_System_Signer_Name__c = FieldPack.SharedSystemSellerFirstName + FieldPack.SharedSystemSellerLastName;
                }
                
                if(FieldPack.SharedSystemSeller2FirstName != null && 
                   FieldPack.SharedSystemSeller2LastName != null)
                { 
                    Ds.Shared_System_Signer2_Name__c = FieldPack.SharedSystemSeller2FirstName + FieldPack.SharedSystemSeller2LastName;
                }
                
                if(Signer1Contact != null)
                {
                    Ds.Client_Signer_1_Role__c = Signer1Contact.Role__c;
                    //Ds.Client_Signer_1__c = Signer1Contact.Name; // For RQ-04781
                }
                if(Signer2Contact != null)
                {
                    Ds.Client_Signer_2_Role__c = Signer2Contact.Role__c;
                    //Ds.Client_Signer_2__c = Signer2Contact.Name;  // For RQ-04781
                }
                update Ds;
            }
            
            // update contacts email fields
            list<Contact> ContactsToUpdate = new list<Contact>();
            if(FieldPack.Signer1EmailUpdate == True){ Signer1Contact.Email = FieldPack.Signer_1_Email; ContactsToUpdate.add(Signer1Contact); }
            if(FieldPack.Signer2EmailUpdate == True){ Signer2Contact.Email = FieldPack.Signer_2_Email; ContactsToUpdate.add(Signer2Contact); }
            if(!ContactsToUpdate.isEmpty()) { update ContactsToUpdate; }
            
            // Set all the component variables below to return them in the javascript callback function for building DocuSign Url
            UrlVariablePack.EmailBody = FieldPack.EmailBody;  // set EmailBody and Subject to the UrlVariablePack to return at the end 
            UrlVariablePack.Subject = FieldPack.Subject;      // and make it available in the JavaScript           
            UrlVariablePack.DealStateId = Ds.Id;              // set the Deal State Id for JavaScript      
            UrlVariablePack.CreditCheck = Ds.Credit_Check__c; // set the Credit Check boolean for JavaScript
            UrlVariablePack.SignerContact1 = Signer1Contact;  // set contact fields for JavaScript
            UrlVariablePack.SignerContact2 = Signer2Contact;
            UrlvariablePack.SignInPerson1 = FieldPack.SignInPerson1;
            UrlvariablePack.SignInPerson2 = FieldPack.SignInPerson2;
            
            // get all custom settings to send those to javascript in callback function for sending through url to docusign
            Map<String, Docusign_Recipient__c> SignersFromCustomsettings = Docusign_Recipient__c.getAll();
            
            // get and set the Signercontact values
            
            
            UrlvariablePack.SignerContact3 = null;
            if(SignersFromCustomsettings.get('SCS') != null) {
                UrlvariablePack.SignerContact3 = SignersFromCustomsettings.get('SCS'); }
            
            UrlvariablePack.SignerContact4 = null;
            if(Ds.CA_Approver_Email__c != null) { 
                UrlvariablePack.SignerContact4 = SignersFromCustomsettings.get('CA');
                UrlvariablePack.SignerContact4.Email__c = Ds.CA_Approver_Email__c;
            }
            
            UrlvariablePack.SignerContact7 = null;
            if(SignersFromCustomsettings.get('BlockingUser') != null) {
                UrlvariablePack.SignerContact7 = SignersFromCustomsettings.get('BlockingUser'); }
            
            UrlvariablePack.SignerContact5 = null;
            if(SignersFromCustomsettings.get('Legal Counter Signer') != null) {
                UrlvariablePack.SignerContact5 = SignersFromCustomsettings.get('Legal Counter Signer'); }
            
            UrlvariablePack.SignerContact6 = null;
            if(SignersFromCustomsettings.get('CRA Signer') != null) {
                UrlvariablePack.SignerContact6 = SignersFromCustomsettings.get('CRA Signer'); }
            
            UrlvariablePack.SignerContact8 = null;
            if(SignersFromCustomsettings.get('Shared System Seller') != null) {
                UrlvariablePack.SignerContact8 = SignersFromCustomsettings.get('Shared System Seller'); }
            
            UrlvariablePack.SignerContact8_2 = null;
            if(SignersFromCustomsettings.get('Shared System Seller2') != null) {
                UrlvariablePack.SignerContact8_2 = SignersFromCustomsettings.get('Shared System Seller2'); }
            
            
            
            System.debug(UrlVariablePack);                                 
            System.debug('entered');
            System.debug(FieldPack);
        }
        catch(Exception e) 
        { 
            UrlVariablePack.ApexMessages = e.getMessage(); system.debug(e.getLineNumber()); 
        }
        finally
        {
            // set the ApexMessages value if the  selectedListSigner1 is null i.e if the user did not select a value for the
            // Signer 1 contact in the visualforce page                
            
            // if(FieldPack.OverrideSignerId1==null ||  FieldPack.OverrideSignerId1 == '000000000000000')
            // {
            if (FieldPack.selectedListSigner1 == null || 
                String.isEmpty(FieldPack.selectedListSigner1))
            {
                UrlVariablePack.ApexMessages = 'Please select Signer 1 Contact. Cannot be left blank';
            }                             
            // } 
            if(UpdatableOpp.Account.Signer_Required__c)
            {
                if(FieldPack.selectedListSigner2 == null || 
                   String.isEmpty(FieldPack.selectedListSigner2))
                {
                    UrlVariablePack.ApexMessages = 'If you are missing either Signer 1 or Signer 2 or both, Please select values';
                }
            }               
        }                        
        return UrlVariablePack;
    }
    
    // method for collecting the picklist values
    public static List<SelectOption> SelectOptionListCollector(Opportunity opp, String AccountSignerField, String AccountContactSpecificSignerField)
    {
        List<SelectOption> MultiSelectOptions = new List<SelectOption>();
        
        Set<String> RoleSet1 = new Set<String>();
        Set<String> RoleSet2 = new Set<String>();
        
        Id TopLevelAccountId = null;
        
        // get the custom settings for the contact roles (Role__c)
        Map<String, DocuSign_Contact_Roles__c> ContactRolesSettings = DocuSign_Contact_Roles__c.getAll();
        
        for(String ContactRoleName : ContactRolesSettings.keySet())
        {
            if(ContactRolesSettings.get(ContactRoleName).RoleSet1__c == True){ RoleSet1.add(ContactRoleName); }
            if(ContactRolesSettings.get(ContactRoleName).RoleSet2__c == True){ RoleSet2.add(ContactRoleName); }          
        }
        
        system.debug(RoleSet1);
        system.debug(RoleSet2);
        system.debug(opp);
        system.debug(AccountSignerField);
        system.debug(AccountContactSpecificSignerField);
        system.debug(opp.Account.Has_Corporate_Authorized_Signer__c);
        
        MultiSelectOptions.add(new SelectOption('', '--None--'));  
                
        list<Account> ContactAccounts = new list<Account>(); // change to a map designating whether or not top account contacts
        if(opp != null && opp.Account != null) { ContactAccounts.add(opp.Account); }
        
        // check for hierarchy top Account
        if(opp != null)
        {
            if(opp.Account.Has_Corporate_Authorized_Signer__c)
            {
                // get the Account at the top of the hierarchy
                Id TopAccountId = AccountHierarchyTools.TopParentAccountId(opp.AccountId);
                
                system.debug(TopAccountId);
                
                if(TopAccountId != null) 
                {
                    list<Account> TopOppAccounts = new list<Account>();
                    
                    TopOppAccounts = database.query(
                        'Select Id, Name, Signer_Required__c, Contact_Specific_Signer_1__c, Contact_Specific_Signer_2__c, ' + 
                            'Has_Corporate_Authorized_Signer__c, Site_Type__c, Site_Type__r.Name, ' + AccountSignerField + ' ' + 
                        'From Account Where Id =\'' + TopAccountId + '\' limit 1'
                    );
                    
                    if(TopOppAccounts != null && !TopOppAccounts.isEmpty()) { 
                        ContactAccounts.add(TopOppAccounts.get(0)); TopLevelAccountId = TopOppAccounts.get(0).Id; }
                }
            }
            
            system.debug(ContactAccounts);
            
            // query Contacts
            Boolean AuthorizedContractSignerExists = false;
            map<Id, list<Contact>> ContactsByAccount = new map<Id, list<Contact>>();
            if(ContactAccounts != null && !ContactAccounts.isEmpty()) 
            {
                list<Id> ContactAccountIds = new list<Id>();
                for(Account a : ContactAccounts) { ContactAccountIds.add(a.Id); }
                
                list<Contact> Contacts = database.query(
                    'Select Id, Name, Title, Role__c, AccountId, Account.Name, ' + 
                        'Account.Site_Type__r.Name, Account.Site_Type__c, Account.Has_Corporate_Authorized_Signer__c, ' +    
                        'Authorized_Contract_Signer__c, Additional_Client_Designated_Signer__c, DS_SLS_Required_cc__c, Email ' +
                    'From Contact ' +
                    'Where (AccountId IN :ContactAccountIds) ' +
                    'And Status__c = \'Active\' ' +
                    'And No_Longer_There__c = false'
                ); 
                
                system.debug(Contacts);
                
                for(Contact c : Contacts)
                {
                    if(c.AccountId != null) 
                    { 
                        list<Contact> CurrentContacts = ContactsByAccount.get(c.AccountId);
                        if(CurrentContacts == null) { CurrentContacts = new list<Contact>(); }
                        
                        // filter Contacts
                        if(c.Account.Has_Corporate_Authorized_Signer__c)
                        {
                            // then only add if the additional client designated signer is checked 
                            //   or if contact is coming from the top level account
                            if(c.Additional_Client_Designated_Signer__c || (TopLevelAccountId != null && c.AccountId == TopLevelAccountId))
                            {
                                CurrentContacts.add(c);
                            }
                        }
                        else 
                        {
                            CurrentContacts.add(c);
                        }
                        
                        ContactsByAccount.put(c.AccountId, CurrentContacts); 
                    }
                    
                    // this should only be pulling the top level contacts from the Corporation (Top Parent Account) 
                    if(c.Authorized_Contract_Signer__c == true) 
                    { 
                        AuthorizedContractSignerExists = true; 
                    }
                }
                
                system.debug(ContactsByAccount);
            }
            
            system.debug(ContactAccounts);
            
            // if there are no Accounts
            if(ContactAccounts == null || ContactAccounts.isEmpty()) 
            {
                return MultiSelectOptions;
            }
            
            for(Account CurrentAccount : ContactAccounts)
            {
                object AccountSignerRole = (CurrentAccount != null) ? CurrentAccount.get(AccountSignerField) : null;
                list<Contact> Contacts = ContactsByAccount.get(CurrentAccount.Id);
                
                system.debug(AccountSignerRole);
                system.debug(Contacts);
                system.debug(CurrentAccount.Name);
                system.debug(CurrentAccount.Has_Corporate_Authorized_Signer__c);
                if (Contacts != null && !Contacts.isEmpty())
                {
                    if (AccountSignerRole == 'Client Authorized Signer' || 
                        (CurrentAccount.Signer_Required__c == false && CurrentAccount.Has_Corporate_Authorized_Signer__c))
                    { 
                        for(Contact c : Contacts)
                        { 
                            Boolean AddContact = false;
                            
                            //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                            if (c.Additional_Client_Designated_Signer__c) {
                            	AddContact = true; 
                            }
                            if(c.Authorized_Contract_Signer__c == true) {
                                AddContact = true;
                            }
                            
                            system.debug(AddContact);
                            
                            if(AddContact)
                            {
                                 MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, c);
                            }
                        }
                    }
                    else if(AccountSignerRole == 'Contact Specific Signer') 
                    {
                        // collect the specific Contact for Account.Contact_Specific_Signer_1__c
                        Set<Id> SpecificSignerIds = new Set<Id>();
                        if(CurrentAccount != null) 
                        {
                            object SignerId = CurrentAccount.get(AccountContactSpecificSignerField);
                            
                            if(SignerId != null) { 
                                SpecificSignerIds.add( (Id)SignerId ); }
                        }
                        
                        // add an option for the contact that is selected 
                        for(Contact c : Contacts) 
                        { 
                            Boolean addContact = false;
                            
                            //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                            if (c.Additional_Client_Designated_Signer__c) {
                            	AddContact = true; 
                            }
                            
                            if(SpecificSignerIds.contains(c.Id) || c.Additional_Client_Designated_Signer__c) 
                            {
                                addContact = true;                                
                            }
                            system.debug(AddContact);
                            if(addContact)
                            {
                                MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, c);
                            }
                        }
                    }
                    else if(AccountSignerRole == 'General Manager')
                    {
                        for(Contact c : Contacts) 
                        {
                            Boolean AddContact = false;
                            
                            //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                            if (c.Additional_Client_Designated_Signer__c) {
                            	AddContact = true; 
                            }
                            
                            if(c.Role__c != null && c.Role__c.contains('General Manager')) {
                                AddContact = true; 
                            }
                            system.debug(AddContact);
                            if(AddContact) { 
                                MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, c); 
                            }
                        }
                    }
                    else if(AccountSignerRole == 'Client Authorized Signer')
                    {
                        for(Contact c : Contacts) 
                        { 
                            Boolean AddContact = false;
                            
                            //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                            if (c.Additional_Client_Designated_Signer__c) {
                            	AddContact = true;
                            }
                            
                            if(c.Authorized_Contract_Signer__c) {
                                AddContact = true;
                            }
                            system.debug(AddContact);
                            if(AddContact) { 
                                MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, c); 
                            }
                        }
                    }
                    else 
                    {
                        // query the deal state related to the current opportunity
                        List<Deal_State__c> DealStateList =  new List<Deal_State__c>([
                            Select Id, Name, Deal_type__c, Total_One_Times__c, Total_Monthlies__c, DCS__c, x3PA__c, Network_Telephony__c, 
                            Client_Data_Exchange_Products__c, Opportunity__c
                            From Deal_State__c 
                            Where Opportunity__c = :opp.Id
                        ]);
                        
                        Boolean UseRoleSet2 = false;
                        for(Deal_State__c ds : DealStateList)
                        {
                            if (ds.Deal_type__c == 'Add-on' && 
                                ds.Total_One_Times__c <= 5000 && 
                                ds.Total_Monthlies__c <= 300 && 
                                ds.DCS__c == False && 
                                ds.x3PA__c == False && 
                                ds.Network_Telephony__c == False && 
                                ds.Client_Data_Exchange_Products__c == False)
                            {
                                UseRoleSet2 = true;
                            }
                        }
                        
                        // add all of the contacts            
                        for(Contact c : Contacts) 
                        {
                            // if no authorized contract signers exist and the Current Account is not the Corporate Account
                            if(!AuthorizedContractSignerExists || CurrentAccount.Has_Corporate_Authorized_Signer__c == true)
                            {
                                list<String> CurrentContactRoles = new list<String>();
                                
                                // if the Contact has more than one role 
                                if(c.Role__c != null && c.Role__c.contains(';')) {
                                    CurrentContactRoles.addAll(c.Role__c.split(';')); }
                                else { // otherwise add the single role
                                    CurrentContactRoles.add(c.Role__c); }
                                
                                Boolean AddContact = false;
                                for(String CurrentContactRole : CurrentContactRoles)
                                {
                                    CurrentContactRole = CurrentContactRole != null ? CurrentContactRole.trim() : ''; // trim whitespace if any
                                    
                                    if (RoleSet1.Contains(CurrentContactRole) || 
                                        (UseRoleSet2 && RoleSet2.contains(CurrentContactRole)) || 
                                        (c.Additional_Client_Designated_Signer__c && CurrentAccount.Has_Corporate_Authorized_Signer__c)) { 
                                        AddContact = true; }
                                }
                                
                                //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                                if (c.Additional_Client_Designated_Signer__c) {
                                    AddContact = true;
                                }
                                
                                if (AddContact) { 
                                    MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, c);
                                }
                            }
                            // if there were authorized signers on the Account, use those
                            else
                            {
                                if(c.Authorized_Contract_Signer__c == true) { 
                                    MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, c);
                                }
                            }
                        }
                    } // end else (AccountSignerRole check)
                    
                    // add any additional signers
                    //for(Contact c : Contacts) 
                    //{  
                    //    if(c.Additional_Client_Designated_Signer__c)
                    //    {
                    //        MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, c);
                    //    }
                    //}
                }
            } // end for Account
        } // end opp.Account null check
        
        return MultiSelectOptions;
    }
    
    global class EmailTextVariables{
        global Contact SelectedContact {get; set;}
        global object UserinfoName {get; set;}
        global object UserinfoEmail {get; set;}
    }
    
    @RemoteAction
    public static EmailTextVariables SelectContact(Id ContactId)
    {
        EmailTextVariables EmailTextVariablesInstance = new EmailTextVariables();
        
        if(ContactId != null) {
            
            list<Contact> Contacts = [
                Select Id, Name, Email, Role__c, Phone, FirstName, LastName, DS_SLS_Required_cc__c
                From Contact Where Id = :ContactId 
                limit 1
            ];
            
            if(Contacts != null && !Contacts.isEmpty()) {
                EmailTextVariablesInstance.SelectedContact = Contacts.get(0); 
            }
        }
        
        EmailTextVariablesInstance.UserinfoName = UserInfo.getName();
        EmailTextVariablesInstance.UserinfoEmail = UserInfo.getUserEmail();
        
        return EmailTextVariablesInstance;
    }  
    
    public static list<SelectOption> AddContactSelectOption(list<SelectOption> MultiSelectOptions, Contact c)
    {
        sObject ContactAccount = c.getSObject('Account');
        sObject ContactAccountSiteType = ContactAccount != null ? ContactAccount.getSObject('Site_Type__r') : null;
        string AccountSiteTypeName = ContactAccountSiteType != null ? ' (' + ContactAccountSiteType.get('Name') + ')' : '';
        
        string ContactDisplayName = c.Name;
        if(c.Role__c != null) { ContactDisplayName += ', ' + c.Role__c; }
        if(AccountSiteTypeName != null) { ContactDisplayName += AccountSiteTypeName; }
        
        MultiSelectOptions.add(new SelectOption(c.Id, ContactDisplayName));
        
        return MultiSelectOptions;
    }
    
    @RemoteAction
    public static String Validate(Id CurrentOppId)
    {
        String Message = null;
        
        Deal_State__c Ds = null;
        list<Deal_State__c> DealStates = [
            Select Id, Name, Docusign_Envelope_Status__c, Opportunity__c, Opportunity__r.AccountId, Opportunity__r.Account.Region__c,
            (Select Id, dsfs__Sent_Date_Time__c, dsfs__Completed_Date_Time__c From DocuSign_Status__r)
            From Deal_State__c            
            Where Opportunity__c = :CurrentOppId
        ];     
        
        if(DealStates != null && !DealStates.isEmpty()) { Ds = DealStates.get(0); }
        
        if(Ds == null)
        {
            Message = 'The associated Deal State record could not be found. To Send to DocuSign, a Deal State record must be linked to the Opportunity. ';          
        }
        else
        {
            Boolean SentStatus = false;
            Boolean DeliveredStatus = false;
            Boolean CompletedStatus = false;
            
            list<dsfs__DocuSign_Status__c> DocuSignStatuses = Ds.getSObjects('DocuSign_Status__r');
            
            if(DocuSignStatuses != null && !DocuSignStatuses.isEmpty())
            {
                for(dsfs__DocuSign_Status__c DocuSignStatus : DocuSignStatuses)
                {
                    if(DocuSignStatus.dsfs__Sent_Date_Time__c != null) { SentStatus = true; }
                    // check delivered status?
                    if(DocuSignStatus.dsfs__Completed_Date_Time__c != null) { CompletedStatus = true; }
                }
            }
            
            if (Ds.Docusign_Envelope_Status__c == 'Sent' || 
                Ds.Docusign_Envelope_Status__c == 'Delivered' || 
                Ds.Docusign_Envelope_Status__c == 'Completed')
            { 
                Message = 'The envelope status on Deal State shows it has already been ' + '\''  + Ds.Docusign_Envelope_Status__c + '\''; 
            }                         
        }
        
        List<Attachment> Attachments = new List<Attachment>(); 
        
        if(Ds != null)
        { 
            Attachments = [Select Id, Name, ParentId From Attachment Where ParentId = :Ds.Id]; 
        }
        
        if(Attachments == null || Attachments.isEmpty()) 
        {      
            Message = 'The Deal State record does not have attachments. To Send to DocuSign, please add an attachment to the Deal State record.';            
        }   
        
        
        return Message;
    }
    
    //sanjay.ghanathey@cdk.com 03-Dec-2014 To Update return URL in DealState
    @RemoteAction 
    global static void UpdateDocusignReturnURL(Id oppId, String returnURL, Boolean Is_Client_1_Sign_In_Person) 
    {
        Deal_State__c dealState = [
            select Docusign_Create_Envelope_URL__c 
            from Deal_State__c 
            where Opportunity__c=:oppId LIMIT 1
        ];
        
        dealState.Docusign_Create_Envelope_URL__c = returnURL;
        
        if(Is_Client_1_Sign_In_Person!=null)
        {
            dealState.Client_1_Sign_In_Person__c = Is_Client_1_Sign_In_Person;
        }
        
        upsert dealState;
    }
    
    @RemoteAction
    public static User SelectUser(Id userId)
    {        
        User userObject = new User();
        
        if(userId != null) {
            
            List<User> users = [Select Id, Name, Email, FirstName, LastName From User Where Id = :userId limit 1];
            
            if(users != null && !users.isEmpty()) {
                userObject = users.get(0); 
            }
        }
        
        return userObject;
    } 
    
    @RemoteAction
    global static List<User> searchForUsers(string SearchTerm) 
    {       
        List<User> SearchList = new List<User> ();
        
        if (SearchTerm != null) {            
            
            if (SearchTerm.length() > 0) 
            {
                String SearchQuery = 'FIND \'' + SearchTerm + '\' IN ALL FIELDS RETURNING User (Id, Email, FirstName, LastName, Name)';                
                List < List<User>> SoslSearchList = search.query(SearchQuery);
                
                if (SoslSearchList != null) {
                    SearchList = (SoslSearchList[0] != null ? SoslSearchList[0] : null);
                }
            }             
        }
        system.debug(SearchList);
        return SearchList;
    }
    
    @RemoteAction
    global static Contact getTheContact(Id ContactId)
    {
        Contact c = null;
        if(ContactId != null)
        {
            c = [
                Select Id, Name, FirstName, LastName, Email, DS_SLS_Required_cc__c 
                From Contact 
                Where Id = :ContactId 
                Limit 1
            ];
        }
        return c;
    }
    
    @RemoteAction
    global static list<Contact> getAllRequiredCcsIntoJavascript(ID currentAccountID, ID dealStateAccountID)
    {
        Id TopAccountId = AccountHierarchyTools.TopParentAccountId(currentAccountID);
        list<contact> requiredCcContacts = new list<Contact>();
        set<ID> accountIDset = new set<ID>(); 
        
        if(TopAccountId != null)
        {
            accountIDset.add(TopAccountId);
        }
        
        if(currentAccountID != null)
        {
            accountIDset.add(currentAccountID);
        }
       
        if(accountIDset != null && !accountIDset.isEmpty())
        {
            requiredCcContacts = [
                Select Id, Name, FirstName, LastName, Email, DS_SLS_Required_cc__c, AccountID 
                From Contact 
                Where AccountID IN :accountIDset 
                AND DS_SLS_Required_cc__c = true
            ];
        } 
        system.debug(requiredCcContacts);
        return requiredCcContacts;
    }
}