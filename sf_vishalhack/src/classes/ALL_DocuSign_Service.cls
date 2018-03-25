//2016-07-06 - created - siva.pragada@cdk.com

//at the bottom same class versioned for Contact_Relationship__c

/*@RestResource(urlMapping='/ALL_DocuSign_Service/getSignerOptions')

global class ALL_DocuSign_Service 
{
    global class SignerSelections
    {
        list<contactDetail> Signer1Options; 
        list<contactDetail> Signer2Options; 
        
        global SignerSelections()
        {
            Signer1Options = new list<contactDetail>();
            Signer2Options = new list<contactDetail>();
        }
    }
    
    global class signerInputParameterPack
    {
        string accountId;
        //string AccountSignerField; coming from the query
        //string AccountContactSpecificSignerField;  coming from the query
        string groupType;
        
        //deal state input parameters
        string Deal_type; // == 'Add-on';
        string Total_One_Times; // <= 5000 
        string Total_Monthlies; // <= 300 
        string DCS; // == False
        string x3PA; // == False 
        string Network_Telephony; // == False 
        string Client_Data_Exchange_Products; // == False
    }
    
    global class InternalParameters
    {
        string TopAccountId;
        string currentAccountId;
        Account currentAccount;
        boolean hasCorporateAuthorizedSigner;
        
        //deal state input parameters
        string Deal_type; // == 'Add-on';
        string Total_One_Times; // <= 5000 
        string Total_Monthlies; // <= 300 
        string DCS; // == False
        string x3PA; // == False 
        string Network_Telephony; // == False 
        string Client_Data_Exchange_Products; // == False
        
        global InternalParameters()
        {
            currentAccount = new Account();
        }
        
    }
    
    @HttpPost
    global static SignerSelections getSignerOptions(signerInputParameterPack inputParametersPack)
    {
        ID AccountId = inputParametersPack.accountId;
        string groupType = inputParametersPack.grouptype; 
        
        //Internal parameters
        InternalParameters internalParameterInputs = new InternalParameters();
        
        Id TopAccountId = AccountHierarchyTools.TopParentAccountId(AccountId);
        internalParameterInputs.TopAccountId = TopAccountId;
        internalParameterInputs.currentAccountId = inputParametersPack.accountId;
        internalParameterInputs.currentAccount = currentAccountDetails(AccountId);
        internalParameterInputs.hasCorporateAuthorizedSigner = internalParameterInputs.currentAccount.Has_Corporate_Authorized_Signer__c;       
        
        //deal state input parameters
        internalParameterInputs.Deal_type = inputParametersPack.Deal_type; 
        internalParameterInputs.Total_One_Times = inputParametersPack.Total_One_Times; 
        internalParameterInputs.Total_Monthlies = inputParametersPack.Total_Monthlies; 
        internalParameterInputs.DCS = inputParametersPack.DCS; 
        internalParameterInputs.x3PA = inputParametersPack.x3PA;
        internalParameterInputs.Network_Telephony = inputParametersPack.Network_Telephony; 
        internalParameterInputs.Client_Data_Exchange_Products = inputParametersPack.Client_Data_Exchange_Products; 
        
        ALL_DocuSign_Service.SignerSelections options = new ALL_DocuSign_Service.SignerSelections();
        
        if(groupType == 'Digital')
        {
            list<Account> contactAccounts = getContactAccounts(internalParameterInputs);
            list<Contact> contacts = getContacts(contactAccounts);
            options.Signer1Options = AddContactSelectOption(options.Signer1Options, contacts);
        }
        else
        { 
            options.Signer1Options = SelectOptionListCollector('Signer_1_2_Signer__c', 'Contact_Specific_Signer_1__c', internalParameterInputs);
            
            if(internalParameterInputs.currentAccount.Signer_Required__c)
            {
                options.Signer2Options = SelectOptionListCollector('Signer_2_2_Signer__c', 'Contact_Specific_Signer_2__c', internalParameterInputs);
            }
        }
        
        return options;        
    } 
    
    public static Account currentAccountDetails(string accountId)
    {
        Account currentAccount = [
            Select Id, Name, Has_Corporate_Authorized_Signer__c, Contact_Specific_Signer_1__c, Contact_Specific_Signer_2__c, 
                   Signer_1_2_Signer__c, Signer_2_2_Signer__c, Signer_Required__c 
            From Account 
            Where Id = :accountId
            Limit 1
        ];
        
        return currentAccount;
    }
    
    public static Account getTopCorporateAccount(string TopAccountId)
    {  
        list<Account> TopOppAccounts = new list<Account>();
        Account topAccount = new Account();
            
        if(TopAccountId != null) 
        {
            TopOppAccounts = database.query(
                'Select Id, Name, Signer_Required__c, Contact_Specific_Signer_1__c, Contact_Specific_Signer_2__c, ' + 
                'Has_Corporate_Authorized_Signer__c, Site_Type__c, Site_Type__r.Name, Signer_1_2_Signer__c, Signer_2_2_Signer__c ' +  
                'From Account Where Id =\'' + TopAccountId + '\' limit 1'
            );
            
            if(TopOppAccounts != null && !TopOppAccounts.isEmpty()) 
            { 
                topAccount = TopOppAccounts.get(0); 
            }
        }
        
        return topAccount;
    }
    
    public static list<Account> getContactAccounts(InternalParameters internalParameterInputs)
    {
        list<Account> contactAccounts = new list<Account>();
        
        if(internalParameterInputs.currentAccount != null) 
        { 
            ContactAccounts.add(internalParameterInputs.currentAccount); 
            
            if(internalParameterInputs.hasCorporateAuthorizedSigner)
            {
                Account topOppAccount = getTopCorporateAccount(internalParameterInputs.TopAccountId);
                contactAccounts.add(topOppAccount);
            }
        }
        
        return contactAccounts;
    }
    
    public static list<Contact> getContacts(list<Account> contactAccounts)
    {
        list<string> contactAccountIds = new list<string>();
        
        if(!contactAccounts.isEmpty())
        {
            for(Account a : contactAccounts) { contactAccountIds.add(a.Id); }
        }
        
        list<string> fields = new list<string>{ 
                'AccountId', 'Account.Has_Corporate_Authorized_Signer__c', 
                'Authorized_Contract_Signer__c', 'Id', 'Name', 'Title', 'Role__c', 'Account.Name', 
                'Account.Site_Type__c', 'Additional_Client_Designated_Signer__c', 
                'DS_SLS_Required_cc__c', 'Email', 'Account.Site_Type__r.Name', 'Status__c'
        };
            
        string whereClause = ALL_UtilitiesString.ListToInclusiveCondition('where', 'AccountId', contactAccountIds);        
        whereClause += 'And Status__c = \'Active\' ' + 'And No_Longer_There__c = false';
        string fieldQuery = string.join(fields, ', ');
        string query = 'Select ' + fieldQuery + ' From Contact ' + whereClause;
        
        return (list<contact>)database.query(query);
    }
    
   
    public static list<Contact> getContactsThroughRelations(list<Contact_Relationship__c> contactRelations)
    {
        list<Contact> contacts = new list<Contact>();
        
        if(!contactRelations.isEmpty())
        {
            for(Contact_Relationship__c crs: contactRelations)
            {
                Contact currentContact = crs.Contact__r;
                if(currentContact != null){ contacts.add(currentContact); }
            }
        }
        
        return Contacts;
    }
    
    public static List<contactDetail> SelectOptionListCollector(
        String AccountSignerField, String AccountContactSpecificSignerField, InternalParameters internalParameterInputs)
    {
        // retrive and assign incomming values
        Account currentOppAccount = internalParameterInputs.currentAccount;
        string TopAccountId = internalParameterInputs.TopAccountId;
        
        List<contactDetail> MultiSelectOptions = new List<contactDetail>();
        
        
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
        
        
        // check for hierarchy top Account
        if(currentOppAccount != null)
        {
            // query Contacts
            Boolean AuthorizedContractSignerExists = false;            
            map<Id, list<contact>> ContactRelationsByAccount = new map<Id, list<contact>>();
            
            list<Account> ContactAccounts = getContactAccounts(internalParameterInputs);            
            list<contact> contactRelationsList = getContacts(ContactAccounts);
            
            for(contact crs : contactRelationsList)
            {
                //Contact currentContact = crs.Contact__r;
                //Account currentAccount = crs.Account__r;
                
                if(crs.AccountId != null) 
                { 
                    list<contact> CurrentContactRelations = ContactRelationsByAccount.get(crs.AccountId);
                    if(CurrentContactRelations == null) { CurrentContactRelations = new list<contact>(); }
                    
                    // filter Contacts
                    if(crs.Account.Has_Corporate_Authorized_Signer__c)
                    {
                        // then only add if the additional client designated signer is checked 
                        //   or if contact is coming from the top level account
                        if(crs.Additional_Client_Designated_Signer__c || (TopAccountId != null && crs.AccountId == TopAccountId))
                        {
                            CurrentContactRelations.add(crs);
                        }
                    }
                    else 
                    {
                        CurrentContactRelations.add(crs);
                    }
                    
                    ContactRelationsByAccount.put(crs.AccountId, CurrentContactRelations); 
                }
                
                // this should only be pulling the top level contacts from the Corporation (Top Parent Account) 
                if(crs.Authorized_Contract_Signer__c == true) 
                { 
                    AuthorizedContractSignerExists = true; 
                }
            }
            
            system.debug(ContactRelationsByAccount);
            
            
            system.debug(ContactAccounts);
            
            // if there are no Accounts
            if(ContactAccounts == null || ContactAccounts.isEmpty()) 
            {
                return MultiSelectOptions;
            }
            
            for(Account CurrentAccount : ContactAccounts)
            {
                object AccountSignerRole = (CurrentAccount != null) ? CurrentAccount.get(AccountSignerField) : null;
                list<contact> currentContactRelations = ContactRelationsByAccount.get(CurrentAccount.Id);
                
                system.debug(AccountSignerRole);
                system.debug(currentContactRelations);
                system.debug(CurrentAccount.Name);
                system.debug(CurrentAccount.Has_Corporate_Authorized_Signer__c);
                if (currentContactRelations != null && !currentContactRelations.isEmpty())
                {
                    if (AccountSignerRole == 'Client Authorized Signer' || 
                        (CurrentAccount.Signer_Required__c == false && CurrentAccount.Has_Corporate_Authorized_Signer__c))
                    { 
                        for(contact crs: currentContactRelations)
                        { 
                            //Contact currentContact = crs.Contact__r;
                            //Account currentAccount = crs.Account__r;
                            Boolean AddContact = false;
                            
                            //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                            if (crs.Additional_Client_Designated_Signer__c) {
                                AddContact = true; 
                            }
                            if(crs.Authorized_Contract_Signer__c == true) {
                                AddContact = true;
                            }
                            
                            system.debug(AddContact);
                            
                            if(AddContact)
                            {
                                MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, new list<Contact> { crs });
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
                        for(contact crs: currentContactRelations) 
                        { 
                            Boolean addContact = false;
                            
                            //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                            if (crs.Additional_Client_Designated_Signer__c) {
                                AddContact = true; 
                            }
                            
                            if(SpecificSignerIds.contains(crs.Id) || crs.Additional_Client_Designated_Signer__c) 
                            {
                                addContact = true;                                
                            }
                            system.debug(AddContact);
                            if(addContact)
                            {
                                MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, new list<Contact> { crs });
                            }
                        }
                    }
                    else if(AccountSignerRole == 'General Manager')
                    {
                        for(contact crs: currentContactRelations) 
                        {
                            Boolean AddContact = false;
                            
                            //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                            if (crs.Additional_Client_Designated_Signer__c) {
                                AddContact = true; 
                            }
                            
                            if(crs.Role__c != null && crs.Role__c.contains('General Manager')) {
                                AddContact = true; 
                            }
                            system.debug(AddContact);
                            if(AddContact) { 
                                MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, new list<Contact> { crs }); 
                            }
                        }
                    }
                    else if(AccountSignerRole == 'Client Authorized Signer')
                    {
                        for(contact crs: currentContactRelations) 
                        { 
                            Boolean AddContact = false;
                            
                            //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                            if (crs.Additional_Client_Designated_Signer__c) {
                                AddContact = true;
                            }
                            
                            if(crs.Authorized_Contract_Signer__c) {
                                AddContact = true;
                            }
                            system.debug(AddContact);
                            if(AddContact) { 
                                MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, new list<Contact> { crs }); 
                            }
                        }
                    }
                    else 
                    {
                        Boolean UseRoleSet2 = false;
                        if (internalParameterInputs.Deal_type == 'Add-on' && // == 'Add-on';
                            integer.valueOf(internalParameterInputs.Total_One_Times) <= 5000  &&  // <= 5000 
                            integer.valueOf(internalParameterInputs.Total_Monthlies) <= 300 && // <= 300 
                            boolean.valueOf(internalParameterInputs.DCS) == false && // == False
                            boolean.valueOf(internalParameterInputs.x3PA) == false && // == False 
                            boolean.valueOf(internalParameterInputs.Network_Telephony) == false && // == False 
                            boolean.valueOf(internalParameterInputs.Client_Data_Exchange_Products) == false) // == False)
                        {
                            UseRoleSet2 = true;
                        }
                        
                        // add all of the contacts            
                        for(contact crs: currentContactRelations) 
                        {
                            //Contact currentContact = crs.Contact__r;
                            //Account currentAccount = crs.Account__r;
                            // if no authorized contract signers exist and the Current Account is not the Corporate Account
                            if(!AuthorizedContractSignerExists || CurrentAccount.Has_Corporate_Authorized_Signer__c == true)
                            {
                                list<String> CurrentContactRoles = new list<String>();
                                
                                // if the Contact has more than one role 
                                if(crs.Role__c != null && crs.Role__c.contains(';')) {
                                    CurrentContactRoles.addAll(crs.Role__c.split(';')); }
                                else { // otherwise add the single role
                                    CurrentContactRoles.add(crs.Role__c); }
                                
                                Boolean AddContact = false;
                                for(String CurrentContactRole : CurrentContactRoles)
                                {
                                    CurrentContactRole = CurrentContactRole != null ? CurrentContactRole.trim() : ''; // trim whitespace if any
                                    
                                    if (RoleSet1.Contains(CurrentContactRole) || 
                                        (UseRoleSet2 && RoleSet2.contains(CurrentContactRole)) || 
                                        (crs.Additional_Client_Designated_Signer__c && CurrentAccount.Has_Corporate_Authorized_Signer__c)) { 
                                            AddContact = true; }
                                }
                                
                                //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                                if (crs.Additional_Client_Designated_Signer__c) {
                                    AddContact = true;
                                }
                                
                                if (AddContact) { 
                                    MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, new list<Contact> { crs });
                                }
                            }
                            // if there were authorized signers on the Account, use those
                            else
                            {
                                if(crs.Authorized_Contract_Signer__c == true) { 
                                    MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, new list<Contact> { crs });
                                }
                            }
                        }
                    } 
                }
            } // end for Account
        } // end opp.Account null check
        
        return MultiSelectOptions;
    }
    
    global class contactDetail
    {
        string Name;
        string Email;
        string ID;
    }
    
    public static list<contactDetail> AddContactSelectOption(list<contactDetail> MultiSelectOptions, list<contact> crsList)
    { 
        for(contact con: crsList)
        {
            contactDetail newDetail = new contactDetail();
            newDetail.Name = con.Name;
            newDetail.Email = con.Email;
            newDetail.ID = con.ID;
            
            MultiSelectOptions.add(newDetail);
        }
        
        return MultiSelectOptions;
    }
}*/














@RestResource(urlMapping='/ALL_DocuSign_Service/getSignerOptions')

global class ALL_DocuSign_Service 
{
    global class SignerSelections
    {
        list<contactDetail> Signer1Options; 
        list<contactDetail> Signer2Options; 
        String message = '';
        
        global SignerSelections()
        {
            Signer1Options = new list<contactDetail>();
            Signer2Options = new list<contactDetail>();
        }
    }
    
    global class signerInputParameterPack
    {
        //@TestVisible 
        global string accountId;
        
        global string OpportunityId;
        //string AccountSignerField; coming from the query
        //string AccountContactSpecificSignerField;  coming from the query
        //@TestVisible 
        global string groupType;
        
        //deal state input parameters
        //@TestVisible 
        global string Deal_type; // == 'Add-on';
        //@TestVisible 
        global string Total_One_Times; // <= 5000 
        //@TestVisible 
        global string Total_Monthlies; // <= 300 
        //@TestVisible 
        global string DCS; // == False
        //@TestVisible 
        global string x3PA; // == False 
        //@TestVisible 
        global string Network_Telephony; // == False 
        //@TestVisible 
        global string Client_Data_Exchange_Products; // == False
    }
    
    global class InternalParameters
    {
        string TopAccountId;
        string currentAccountId;
        string OpportunityId;
        Account currentAccount;
        boolean hasCorporateAuthorizedSigner;
        
        //deal state input parameters
        string Deal_type; // == 'Add-on';
        string Total_One_Times; // <= 5000 
        string Total_Monthlies; // <= 300 
        string DCS; // == False
        string x3PA; // == False 
        string Network_Telephony; // == False 
        string Client_Data_Exchange_Products; // == False
        
        global InternalParameters()
        {
            currentAccount = new Account();
        }
        
    }
    
    @HttpPost
    global static SignerSelections getSignerOptions(signerInputParameterPack inputParametersPack)
    {
        Try{
            ID AccountId = inputParametersPack.accountId;
            string groupType = inputParametersPack.grouptype;
            ID OpportunityId = inputParametersPack.opportunityId;
            boolean recorTypeIsPipeline = false;
            Opportunity currentOpportunity;
            
        if(OpportunityId != null)
        {
            currentOpportunity = [
                Select ID, Name, SLS_Buyer_Account__c, AccountId, RecordType.Name, CB_Customer_Signer__c, CB_Customer_Signer__r.Name, CB_Customer_Signer__r.Email 
                From Opportunity 
                Where ID = :OpportunityId
                Limit 1
            ];
        }

            
            if(currentOpportunity != null && currentOpportunity.RecordType.Name == 'Pipeline')
            {
                recorTypeIsPipeline = true;
            }
            
            if(currentOpportunity != null)
            {
                AccountId = currentOpportunity.AccountId;
                
                if(currentOpportunity.SLS_Buyer_Account__c != null)
                {
                    AccountId = currentOpportunity.SLS_Buyer_Account__c;
                }
            }
            
            //Internal parameters
            InternalParameters internalParameterInputs = new InternalParameters();
            
            Id TopAccountId = AccountHierarchyTools.TopParentAccountId(AccountId);
            internalParameterInputs.TopAccountId = TopAccountId;
            internalParameterInputs.currentAccountId = inputParametersPack.accountId;
            
            internalParameterInputs.currentAccount = [
                Select Id, Name, Has_Corporate_Authorized_Signer__c, Contact_Specific_Signer_1__c, Contact_Specific_Signer_2__c, 
                Signer_1_2_Signer__c, Signer_2_2_Signer__c, Signer_Required__c, Region__c 
                From Account 
                Where Id = :accountId
                Limit 1
            ];
            
            internalParameterInputs.hasCorporateAuthorizedSigner = internalParameterInputs.currentAccount.Has_Corporate_Authorized_Signer__c;
            
            //deal state input parameters
            internalParameterInputs.Deal_type = inputParametersPack.Deal_type; 
            internalParameterInputs.Total_One_Times = inputParametersPack.Total_One_Times; 
            internalParameterInputs.Total_Monthlies = inputParametersPack.Total_Monthlies; 
            internalParameterInputs.DCS = inputParametersPack.DCS; 
            internalParameterInputs.x3PA = inputParametersPack.x3PA;
            internalParameterInputs.Network_Telephony = inputParametersPack.Network_Telephony; 
            internalParameterInputs.Client_Data_Exchange_Products = inputParametersPack.Client_Data_Exchange_Products; 
            
            ALL_DocuSign_Service.SignerSelections options = new ALL_DocuSign_Service.SignerSelections(); 
            
            if(internalParameterInputs.currentAccount.Region__c == 'Division')
            {
                options.message = 'Contact options are empty for account region Division';
                Return options;
            }
            
            //RQ-08102 CPQ - Docusign WebService - Digital Sales Perspective
            if(recorTypeIsPipeline)
            {
                groupType = 'Digital';
            }
            
            if(groupType == 'Digital')
            {
                list<Account> contactAccounts = getContactAccounts(internalParameterInputs);
                list<Contact_Relationship__c> contactRelationsList = getContactRelationsOnAccounts(ContactAccounts);           
                options.Signer1Options =  AddContactSelectOption(options.Signer1Options, contactRelationsList);
                
                if(recorTypeIsPipeline)
                {
                    contactDetail customerSigner = new contactDetail();
                    customerSigner.Name = currentOpportunity.CB_Customer_Signer__r.Name;
                    customerSigner.Email = currentOpportunity.CB_Customer_Signer__r.Email;
                    customerSigner.ID = currentOpportunity.CB_Customer_Signer__c;
                    
                    options.Signer1Options.add(customerSigner);
                }
                
                options.message = 'Success';
            }
            else
            { 
                options.Signer1Options = SelectOptionListCollector('Signer_1_2_Signer__c', 'Contact_Specific_Signer_1__c', internalParameterInputs);
                options.message = 'Success';
                
                if(internalParameterInputs.currentAccount.Signer_Required__c)
                {
                    options.Signer2Options = SelectOptionListCollector('Signer_2_2_Signer__c', 'Contact_Specific_Signer_2__c', internalParameterInputs);
                }
                else
                {
                    options.message += ', but Signer2Options not required for this account';
                }
            }
            
            if(options.Signer1Options.isEmpty() && options.Signer2Options.isEmpty())
            {
                options.message = 'There are no contact options for account and the associated values';
            }
            return options; 
        }
        Catch(Exception exp)
        {
            ALL_DocuSign_Service.SignerSelections options = new ALL_DocuSign_Service.SignerSelections();
            options.message = 'Failed. Report following message to Salesforce admin/developer - ' + exp.getMessage();
            
            if(exp.getMessage() != null && exp.getMessage().containsIgnoreCase('List has no rows for assignment'))
            {
                options.message = 'The Opportunity or Account with ID you supplied cannot be found in Salesforce database';
            }
            
            return options;
        } 
    } 
   
    public static Account getTopCorporateAccount(string TopAccountId)
    {  
        list<Account> TopOppAccounts = new list<Account>();
        Account topAccount = new Account();
            
        if(TopAccountId != null) 
        {
            TopOppAccounts = database.query(
                'Select Id, Name, Signer_Required__c, Contact_Specific_Signer_1__c, Contact_Specific_Signer_2__c, ' + 
                'Has_Corporate_Authorized_Signer__c, Site_Type__c, Site_Type__r.Name, Signer_1_2_Signer__c, Signer_2_2_Signer__c ' +  
                'From Account Where Id =\'' + TopAccountId + '\' limit 1'
            );
            
            if(TopOppAccounts != null && !TopOppAccounts.isEmpty()) 
            { 
                topAccount = TopOppAccounts.get(0); 
            }
        }
        
        return topAccount;
    }
    
    public static list<Account> getContactAccounts(InternalParameters internalParameterInputs)
    {
        list<Account> contactAccounts = new list<Account>();
        
        if(internalParameterInputs.currentAccount != null) 
        { 
            ContactAccounts.add(internalParameterInputs.currentAccount); 
            
            if(internalParameterInputs.hasCorporateAuthorizedSigner)
            {
                Account topOppAccount = getTopCorporateAccount(internalParameterInputs.TopAccountId);
                contactAccounts.add(topOppAccount);
            }
        }
        
        return contactAccounts;
    }
    
    public static list<Contact_Relationship__c> getContactRelationsOnAccounts(list<Account> contactAccounts)
    {
        list<string> contactAccountIds = new list<string>();
        
        if(!contactAccounts.isEmpty())
        {
            for(Account a : contactAccounts) { contactAccountIds.add(a.Id); }
        }
        
        list<string> fieldsList = new list<string>{ 
                'Account__c', 'Account__r.Has_Corporate_Authorized_Signer__c', 'Additional_Client_Designated_Signer__c', 
                'Authorized_Contract_Signer__c', 'Role__c', 'Contact__r.Id', 'Contact__r.Name', 'Contact__r.Title', 
                'Contact__r.Role__c', 'Contact__r.AccountId', 'Contact__r.Account.Name', 'Contact__r.Account.Site_Type__r.Name', 
                'Contact__r.Account.Site_Type__c', 'Contact__r.Account.Has_Corporate_Authorized_Signer__c', 
                'Contact__r.Authorized_Contract_Signer__c', 'Contact__r.Additional_Client_Designated_Signer__c', 
                'Contact__r.DS_SLS_Required_cc__c', 'Contact__r.Email', 'Account__r.Site_Type__r.Name', 'Contact__r.Status__c'
        };
                        
        string whereClause = ALL_UtilitiesString.ListToInclusiveCondition('where', 'Account__c', contactAccountIds);
        
        whereClause += 'And Status__c = \'Active\' ' + 'And No_Longer_There__c = false';
        
        string query = ALL_SharedContact_Helper.buildContactRelationshipQuery(fieldsList, whereClause);
        
        list<Contact_Relationship__c> contactRelations =  Database.query(query);
        
        return contactRelations;
    }
        
    public static List<contactDetail> SelectOptionListCollector(
        String AccountSignerField, String AccountContactSpecificSignerField, InternalParameters internalParameterInputs)
    {
        // retrive and assign incomming values
        Account currentOppAccount = internalParameterInputs.currentAccount;
        string TopAccountId = internalParameterInputs.TopAccountId;
        
        List<contactDetail> MultiSelectOptions = new List<contactDetail>();
        
        
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
        
        
        // check for hierarchy top Account
        if(currentOppAccount != null)
        {
            // query Contacts
            Boolean AuthorizedContractSignerExists = false;            
            map<Id, list<Contact_Relationship__c>> ContactRelationsByAccount = new map<Id, list<Contact_Relationship__c>>();
            
            list<Account> ContactAccounts = getContactAccounts(internalParameterInputs);            
            list<Contact_Relationship__c> contactRelationsList = getContactRelationsOnAccounts(ContactAccounts);
            
            for(Contact_Relationship__c crs : contactRelationsList)
            {
                //Contact currentContact = crs.Contact__r;
                //Account currentAccount = crs.Account__r;
                
                if(crs.Account__c != null) 
                { 
                    list<Contact_Relationship__c> CurrentContactRelations = ContactRelationsByAccount.get(crs.Account__c);
                    if(CurrentContactRelations == null) { CurrentContactRelations = new list<Contact_Relationship__c>(); }
                    
                    // filter Contacts
                    if(crs.Account__r.Has_Corporate_Authorized_Signer__c)
                    {
                        // then only add if the additional client designated signer is checked 
                        //   or if contact is coming from the top level account
                        if(crs.Additional_Client_Designated_Signer__c || (TopAccountId != null && crs.Account__c == TopAccountId))
                        {
                            CurrentContactRelations.add(crs);
                        }
                    }
                    else 
                    {
                        CurrentContactRelations.add(crs);
                    }
                    
                    ContactRelationsByAccount.put(crs.Account__c, CurrentContactRelations); 
                }
                
                // this should only be pulling the top level contacts from the Corporation (Top Parent Account) 
                if(crs.Authorized_Contract_Signer__c == true) 
                { 
                    AuthorizedContractSignerExists = true; 
                }
            }
            
            //system.debug(ContactRelationsByAccount);
            
            
            //system.debug(ContactAccounts);
            
            // if there are no Accounts
            if(ContactAccounts == null || ContactAccounts.isEmpty()) 
            {
                return MultiSelectOptions;
            }
            
            for(Account CurrentAccount : ContactAccounts)
            {
                object AccountSignerRole = (CurrentAccount != null) ? CurrentAccount.get(AccountSignerField) : null;
                list<Contact_Relationship__c> currentContactRelations = ContactRelationsByAccount.get(CurrentAccount.Id);
                
                //system.debug(AccountSignerRole);
                //system.debug(currentContactRelations);
                //system.debug(CurrentAccount.Name);
                //system.debug(CurrentAccount.Has_Corporate_Authorized_Signer__c);
                if (currentContactRelations != null && !currentContactRelations.isEmpty())
                {
                    if (AccountSignerRole == 'Client Authorized Signer' || 
                        (CurrentAccount.Signer_Required__c == false && CurrentAccount.Has_Corporate_Authorized_Signer__c))
                    { 
                        for(Contact_Relationship__c crs: currentContactRelations)
                        { 
                            //Contact currentContact = crs.Contact__r;
                            //Account currentAccount = crs.Account__r;
                            Boolean AddContact = false;
                            
                            //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                            if (crs.Additional_Client_Designated_Signer__c) {
                                AddContact = true; 
                            }
                            if(crs.Authorized_Contract_Signer__c == true) {
                                AddContact = true;
                            }
                            
                            system.debug(AddContact);
                            
                            if(AddContact)
                            {
                                 MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, new list<Contact_Relationship__c> { crs });
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
                        for(Contact_Relationship__c crs: currentContactRelations) 
                        { 
                            Contact currentContact = crs.Contact__r;
                            //Account currentAccount = crs.Account__r;
                            Boolean addContact = false;
                            
                            //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                            if (crs.Additional_Client_Designated_Signer__c) {
                                AddContact = true; 
                            }
                            
                            if(SpecificSignerIds.contains(currentContact.Id) || crs.Additional_Client_Designated_Signer__c) 
                            {
                                addContact = true;                                
                            }
                            system.debug(AddContact);
                            if(addContact)
                            {
                                 MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, new list<Contact_Relationship__c> { crs });
                            }
                        }
                    }
                    else if(AccountSignerRole == 'General Manager')
                    {
                        for(Contact_Relationship__c crs: currentContactRelations) 
                        {
                            Contact currentContact = crs.Contact__r;
                            //Account currentAccount = crs.Account__r;
                            
                            Boolean AddContact = false;
                            
                            //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                            if (crs.Additional_Client_Designated_Signer__c) {
                                AddContact = true; 
                            }
                            
                            if(crs.Role__c != null && crs.Role__c.contains('General Manager')) {
                                AddContact = true; 
                            }
                            //system.debug(AddContact);
                            if(AddContact) { 
                                MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, new list<Contact_Relationship__c> { crs }); 
                            }
                        }
                    }
                    else if(AccountSignerRole == 'Client Authorized Signer')
                    {
                        for(Contact_Relationship__c crs: currentContactRelations) 
                        { 
                            //Contact currentContact = crs.Contact__r;
                            //Account currentAccount = crs.Account__r;
                            
                            Boolean AddContact = false;
                            
                            //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                            if (crs.Additional_Client_Designated_Signer__c) {
                                AddContact = true;
                            }
                            
                            if(crs.Authorized_Contract_Signer__c) {
                                AddContact = true;
                            }
                            //system.debug(AddContact);
                            if(AddContact) { 
                                 MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, new list<Contact_Relationship__c> { crs }); 
                            }
                        }
                    }
                    else 
                    {
                        Boolean UseRoleSet2 = false;
                        if (internalParameterInputs.Deal_type == 'Add-on' && // == 'Add-on';
                            integer.valueOf(internalParameterInputs.Total_One_Times) <= 5000  &&  // <= 5000 
                            integer.valueOf(internalParameterInputs.Total_Monthlies) <= 300 && // <= 300 
                            boolean.valueOf(internalParameterInputs.DCS) == false && // == False
                            boolean.valueOf(internalParameterInputs.x3PA) == false && // == False 
                            boolean.valueOf(internalParameterInputs.Network_Telephony) == false && // == False 
                            boolean.valueOf(internalParameterInputs.Client_Data_Exchange_Products) == false) // == False)
                        {
                            UseRoleSet2 = true;
                        }
                        
                        // add all of the contacts            
                        for(Contact_Relationship__c crs: currentContactRelations) 
                        {
                            //Contact currentContact = crs.Contact__r;
                            //Account currentAccount = crs.Account__r;
                            // if no authorized contract signers exist and the Current Account is not the Corporate Account
                            if(!AuthorizedContractSignerExists || CurrentAccount.Has_Corporate_Authorized_Signer__c == true)
                            {
                                list<String> CurrentContactRoles = new list<String>();
                                
                                // if the Contact has more than one role 
                                if(crs.Role__c != null && crs.Role__c.contains(';')) {
                                    CurrentContactRoles.addAll(crs.Role__c.split(';')); }
                                else { // otherwise add the single role
                                    CurrentContactRoles.add(crs.Role__c); }
                                
                                Boolean AddContact = false;
                                for(String CurrentContactRole : CurrentContactRoles)
                                {
                                    CurrentContactRole = CurrentContactRole != null ? CurrentContactRole.trim() : ''; // trim whitespace if any
                                    
                                    if (RoleSet1.Contains(CurrentContactRole) || 
                                        (UseRoleSet2 && RoleSet2.contains(CurrentContactRole)) || 
                                        (crs.Additional_Client_Designated_Signer__c && CurrentAccount.Has_Corporate_Authorized_Signer__c)) { 
                                            AddContact = true; }
                                }
                                
                                //2015-08-27 matt.keefe@cdk.com - added this as a hotfix at Patti's Request
                                if (crs.Additional_Client_Designated_Signer__c) {
                                    AddContact = true;
                                }
                                
                                if (AddContact) { 
                                     MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, new list<Contact_Relationship__c> { crs });
                                }
                            }
                            // if there were authorized signers on the Account, use those
                            else
                            {
                                if(crs.Authorized_Contract_Signer__c == true) { 
                                    MultiSelectOptions = AddContactSelectOption(MultiSelectOptions, new list<Contact_Relationship__c> { crs });
                                }
                            }
                        }
                    } 
                }
            } // end for Account
        } // end opp.Account null check
        
        return MultiSelectOptions;
    }
    
    global class contactDetail
    {
        string Name;
        string Email;
        string ID;
        string Title;
    }
    
    public static list<contactDetail> AddContactSelectOption(list<contactDetail> MultiSelectOptions, list<contact_Relationship__c> crsList)
    { 
        for(contact_Relationship__c crs: crsList)
        {
            contact con = crs.contact__r;
            contactDetail newDetail = new contactDetail();
            newDetail.Name = con.Name;
            newDetail.Email = con.Email;
            newDetail.ID = con.ID;
            newDetail.Title = crs.Role__c;
            
            MultiSelectOptions.add(newDetail);
        }
        
        return MultiSelectOptions;
    }
}