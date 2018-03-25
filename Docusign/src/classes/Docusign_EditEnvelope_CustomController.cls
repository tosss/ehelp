public class Docusign_EditEnvelope_CustomController 
{
    public static String attachmentsMapJSON{get;set;}
    private static Id objectId;
    public static dsfs__DocuSign_Envelope__c envelopeObj{get;set;}
    public  String exisitngDocs{get;set;}
    public List<dsfs__DocuSign_Envelope_Document__c> exisitngDocsList{get;set;}
    public List<dsfs__DocuSign_Envelope_Recipient__c> exisitngRcpList{get;set;}
    public static Deal_State__c dsObj{get;set;}
    public static Opportunity opp{get;set;}
    public static Map<String,Account> accountMap{get;set;}
    public static List<String> signerRoles{get;set;}
    public static String newContact{get;set;}
    public static String rcpNew{get;set;}
    public static List<Contact> Signer_1_Options {get; set;}
    public static List<Contact> Signer_2_Options {get; set;}
    public static String languageTempltesJson{get;set;}
    public static Map<String, Docusign_Language_Email_Template__c> languageTempltes{get;set;}
    public static ErrorHandling error{get;set;}
    
    public Docusign_EditEnvelope_CustomController()
    {
        
        newContact = Json.serialize(new Contact());
        rcpNew = JSON.serialize(new dsfs__DocuSign_Envelope_Recipient__c());
        objectId = ApexPages.currentPage().getParameters().get('Id');
        languageTempltes = Docusign_Language_Email_Template__c.getAll();
        languageTempltesJson = Json.serialize(languageTempltes);
        try
        {
            dsObj  = [select id, opportunity__r.name, opportunity__c,account__c, name, deal_type__c, Alternate_DocuSign_Account__c, french_wording__c  from Deal_State__c where id =: objectId];
            
            List<Account> account = [select id,name, Signer_Required__c from account where name =: dsobj.account__c or name=: dsobj.Alternate_DocuSign_Account__c];
            
            opp = [Select Id, Name, ADP_Opportunity_Owner__c, ADP_Opportunity_Owner__r.Name, ADP_Opportunity_Owner__r.Email, 
                   ADP_Opportunity_Owner__r.FirstName, ADP_Opportunity_Owner__r.LastName, Client_Signer_1__c, Client_Signer_2__c, 
                   AccountId, Account.Name, Client_Signer_1_Sign_in_Person_Override__c,
                   Account.Region__c, Account.Signer_1_2_Signer__c, Account.Signer_2_2_Signer__c, 
                   Account.Contact_Specific_Signer_1__c, Account.Contact_Specific_Signer_2__c, 
                   Account.Signer_Required__c, Account.Has_Corporate_Authorized_Signer__c, 
                   (Select Id, Name, Docusign_Envelope_Status__c, Client_1_Sign_In_Person__c, Client_2_Sign_In_Person__c,
                    French_Wording__c, Deal_Type__c, Shared_System_Addendum__c From Deal_State__r)
                   From Opportunity 
                   Where Id = : dsobj.opportunity__c];
            accountMap = new Map<String,Account>();
            for(Account acc: account)
            {
                accountMap.put(acc.Name,acc);
            }
            Signer_1_Options = SelectOptionListCollector( 'Signer_1_2_Signer__c', 'Contact_Specific_Signer_1__c');
            Signer_2_Options = SelectOptionListCollector( 'Signer_2_2_Signer__c', 'Contact_Specific_Signer_2__c');
            init(objectId);
        }
        catch(Exception e)
        {
            
            if(e.getLineNumber() == 31)
            {
                error =  new ErrorHandling('Error','No Deal State Record Found');
            }
            else if(e.getLineNumber() == 33)
            {
                error =  new ErrorHandling('Error','No Account Found');
            }
            else if(e.getLineNumber() == 35)
            {
                error =  new ErrorHandling('Error','No Opportunity Found');
            }
            else 
            {
                error =  new ErrorHandling('Error','Unknown Error');
            }
            system.debug('Exception e:'+e.getMessage()+' at '+e.getLineNumber());
        }
        
    }
    
    public static List<Contact> SelectOptionListCollector(String AccountSignerField, String AccountContactSpecificSignerField)
    {
        List<Contact> MultiSelectOptions = new List<Contact>();
        
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
    
    @RemoteAction
    public static void saveRecipient(String rcp)
    {
        dsfs__DocuSign_Envelope_Recipient__c rcpObj =  (dsfs__DocuSign_Envelope_Recipient__c)JSON.deserialize(rcp, dsfs__DocuSign_Envelope_Recipient__c.class);
        update rcpObj;
    }
    @RemoteAction
    public static String addRecipients(String rcp)
    {
        Map<String,dsfs__DocuSign_Envelope_Recipient__c> rcpObj = (Map<String,dsfs__DocuSign_Envelope_Recipient__c>)(Json.deserialize(rcp, Map<String,dsfs__DocuSign_Envelope_Recipient__c>.class));
        insert rcpObj.values();
        return JSON.serialize(rcpObj);
    }
    @RemoteAction
    public static String getRecipient(String rcpId)
    {
        dsfs__DocuSign_Envelope_Recipient__c rcp = new dsfs__DocuSign_Envelope_Recipient__c();
        rcp =[Select id, dsfs__SignInPersonName__c,dsfs__SignInPersonEmail__c ,dsfs__DSER_ContactID__r.Email,dsfs__DSER_ContactID__r.Name,dsfs__DSER_LeadID__r.Email,dsfs__Access_Code__c,dsfs__Recipient_Note_Long__c,
              dsfs__Recipient_Email__c,dsfs__DSER_LeadID__r.Name, dsfs__DSER_UserID__r.Email,dsfs__DSER_UserID__r.Name,dsfs__Routing_Order__c, dsfs__DocuSign_Signature_Name__c,                                                                                                                            dsfs__DocuSign_EnvelopeID__c, 
              dsfs__DocuSign_Recipient_Role__c,dsfs__Salesforce_Recipient_Type__c, dsfs__DocuSign_Signer_Type__c from dsfs__DocuSign_Envelope_Recipient__c
              Where Id=: rcpId
             ];
        String jsonRcp = Json.serialize(rcp);
        return jsonRcp;
    }
    @RemoteAction
    public static void deleteRecipient(String Ids)
    {
        List<String> idsList = Ids.split(',');
        List<dsfs__DocuSign_Envelope_Recipient__c> rcpList = [select id from dsfs__DocuSign_Envelope_Recipient__c where Id in: idsList];
        delete rcpList;
    }
    public void getEnvelope()
    {
        try
        {
            String objectIdInstance = ApexPages.currentPage().getParameters().get('Id');
            envelopeObj = [Select id,	dsfs__DocuSign_Email_Subject__c, dsfs__DocuSign_Email_Message__c from dsfs__DocuSign_Envelope__c where dsfs__Source_Object__c =: objectIdInstance  order by createddate desc limit 1];
            Map<Id, dsfs__DocuSign_Envelope_Document__c> exisitngDocsMap = new Map<Id, dsfs__DocuSign_Envelope_Document__c>(
                [Select Id, dsfs__Attachment_Name__c, dsfs__Document_Order__c ,	dsfs__Attachment_ID__c, 	
                 dsfs__Document_ID__c, dsfs__Document_Name__c, dsfs__SFDocument_Type__c, 
                 dsfs__External_Document_Id__c, dsfs__Validation_Message__c, 	dsfs__DocuSign_EnvelopeID__c
                 from dsfs__DocuSign_Envelope_Document__c where dsfs__DocuSign_EnvelopeID__c =: envelopeObj.Id order by dsfs__Document_Order__c]);
            exisitngDocsList = exisitngDocsMap.values();
            Map<Id,dsfs__DocuSign_Envelope_Recipient__c> exisitngRcpMap = new Map<Id,dsfs__DocuSign_Envelope_Recipient__c>([Select id,dsfs__SignInPersonEmail__c , dsfs__SignInPersonName__c,dsfs__DSER_ContactID__r.Email,dsfs__DSER_ContactID__r.Name,dsfs__DSER_LeadID__r.Email,
                                                                                                                            dsfs__Recipient_Email__c,dsfs__DSER_LeadID__r.Name, dsfs__DSER_UserID__r.Email,dsfs__DSER_UserID__r.Name,dsfs__Routing_Order__c, dsfs__DocuSign_Signature_Name__c,                                                                                                                            dsfs__DocuSign_EnvelopeID__c, 
                                                                                                                            dsfs__DocuSign_Recipient_Role__c,dsfs__Salesforce_Recipient_Type__c, dsfs__DocuSign_Signer_Type__c from dsfs__DocuSign_Envelope_Recipient__c
                                                                                                                            Where dsfs__DocuSign_EnvelopeID__c =: envelopeObj.Id  order by dsfs__Routing_Order__c
                                                                                                                           ]);
            exisitngRcpList = exisitngRcpMap.values();
            exisitngDocs = JSON.serialize(exisitngDocsList); 
        }
        catch(Exception e)
        {
            
        }
        
        if(envelopeObj==null)
        {
            envelopeObj = new dsfs__DocuSign_Envelope__c();
            envelopeObj.dsfs__DocuSign_Email_Subject__c = 'Documents for your DocuSign Signature';
            envelopeObj.dsfs__DocuSign_Email_Message__c = 'I am sending you this request for your electronic signature, please review and electronically sign by following the link below.';
            //insert envelopeObj;
        }
    }
    
    @RemoteAction 
    public static String insertNewContact(String newContactParam)
    {
        Contact c = (Contact)Json.deserialize(newContactParam,Contact.class);
        String success = '400';
        try
        {
            insert c;
            success = '200';
        }
        catch(Exception  e)
        {
            return e.getMessage();
        }
        return success;
    }
    
    @RemoteAction 
    public static String init(Id objectIdParam)
    {
        Map<String,Map<String,List<Sobject>>> attachmentsMap = new Map<String,Map<String,List<Sobject>>>();
        
        Map<String,List<Sobject>> individualSources = new Map<String,List<Sobject>>();
        individualSources.put('all',[select id, name, BodyLength from Attachment where parentId=:objectIdParam]);
        attachmentsMap.put('Attachments',individualSources);
        individualSources = new Map<String,List<Sobject>>();
        List<Document> allDocs = [select id, name,BodyLength, folderId from Document];
        Map<Id,List<sobject>> folderToDocMap = new Map<Id,List<sobject>>();
        for(Document doc : allDocs)
        {
            if(!folderToDocMap.keySet().contains(doc.folderId))
            {
                folderToDocMap.put(doc.folderId,new List<sobject>());
            }
            List<sobject> docs= folderToDocMap.get(doc.folderId);
            docs.add(doc);
            folderToDocMap.put(doc.folderId,docs);
        }
        Map<Id,Folder> allFolders = new Map<Id,Folder>([select id, name from Folder order by name desc]);
        for(Id folderId:allFolders.keySet())
        {
            String Name =allFolders.get(folderId).Name;
            Name = Name==null?'':Name;
            if(folderToDocMap.keySet().contains(folderId))
            {
                individualSources.put(folderId+Name,folderToDocMap.get(folderId));
            }
            else
            {
                individualSources.put(folderId+Name,null);
            }
        }
        individualSources.put(UserInfo.getUserId()+'My Personal Documents',folderToDocMap.get(UserInfo.getUserId()));
        attachmentsMap.put('Documents',individualSources);
        individualSources = new Map<String,List<Sobject>>();
        List<ContentWorkspace> libraries = [select id, name from ContentWorkspace order by name desc];
        Map<Id,ContentDocument> documents = new Map<Id,ContentDocument>([select id, Title, ParentId, ContentSize from ContentDocument]);
        List<ContentVersion> contver = [select id, Title, ContentSize, ContentDocumentId from ContentVersion where ContentDocumentId In: documents.keySet() order by createddate desc];
        Map<Id,ContentVersion> docToVersion = new Map<Id,ContentVersion>();
        for(ContentVersion cv : contver)
        {
            if(!docToVersion.keySet().contains(cv.ContentDocumentId))
            {
                docToVersion.put(cv.ContentDocumentId, cv);
            }
        }
        Map<Id,List<sobject>> libToDocument = new Map<Id,List<Sobject>>();
        for(ContentDocument cd : documents.values())
        {
            if(!libToDocument.keySet().contains(cd.parentId))
            {
                libToDocument.put(cd.parentId,new List<Sobject>());
            }
            List<sobject> docsList = libToDocument.get(cd.parentId);
            docsList.add(docToVersion.get(cd.Id));
            libToDocument.put(cd.parentId,docsList);
        }
        for(ContentWorkspace cw : libraries)
        {
            individualSources.put(cw.Id+cw.Name,libToDocument.get(cw.Id));
        }
        attachmentsMap.put('Libraries',individualSources);
        List<sobject> feeds = [select id,title, ContentSize from feeditem where parentId=:objectId];
        individualSources = new Map<String,List<Sobject>>();
        individualSources.put('all',feeds);
        attachmentsMap.put('Feed Attachments',individualSources);
        attachmentsMapJSON = JSON.serialize(attachmentsMap);
        return attachmentsMapJSON;
    }
    public static list<Contact> AddContactSelectOption(list<Contact> MultiSelectOptions, Contact c)
    {
        sObject ContactAccount = c.getSObject('Account');
        sObject ContactAccountSiteType = ContactAccount != null ? ContactAccount.getSObject('Site_Type__r') : null;
        string AccountSiteTypeName = ContactAccountSiteType != null ? ' (' + ContactAccountSiteType.get('Name') + ')' : '';
        
        string ContactDisplayName = c.Name;
        if(c.Role__c != null) { ContactDisplayName += ', ' + c.Role__c; }
        if(AccountSiteTypeName != null) { ContactDisplayName += AccountSiteTypeName; }
        
        MultiSelectOptions.add(c);
        
        return MultiSelectOptions;
    }
    
    @RemoteAction 
    public static void saveRcpOrder(String rcpOrderMap)
    {
        Map<Id,Integer> rcpOrder = (Map<Id,Integer>)Json.deserialize(rcpOrderMap, Map<Id,Integer>.class);
        Map<Id, dsfs__DocuSign_Envelope_Recipient__c> rcpMap = new Map<Id,dsfs__DocuSign_Envelope_Recipient__c>([select id,dsfs__Routing_Order__c from dsfs__DocuSign_Envelope_Recipient__c where id in: rcpOrder.keySet()]);
        for(Id rcp : rcpOrder.keySet())
        {
            rcpMap.get(rcp).dsfs__Routing_Order__c = rcpOrder.get(rcp);
        }
        update rcpMap.values();
    }
    public static void getRecipientInfo()
    {
        Map<String,Docusign_Recipient__c> rcpSigners = Docusign_Recipient__c.getAll();
        signerRoles = new List<String>();
        for(Docusign_Recipient__c rcpSigner: rcpSigners.values())
        {
            signerRoles.add(rcpSigner.Signer_Role__c);
        }
    }
    @RemoteAction 
    public static String getOptions(String objectName,String searchString)
    {
        searchString = '%'+searchString+'%';
        return JSON.serialize(DataBase.query('select id,name '+(objectName.toLowerCase()=='account'?'':',email ')+' from '+objectName+' where name like \''+searchString+'\' '+(objectName.toLowerCase()=='account'?'':' or email like  \''+searchString+'\' ') ));
    }
    @RemoteAction
    public static String addAttachments(String parentId, String attachmentList,String order)
    {
        List<dsfs__DocuSign_Envelope_Document__c> env = new List<dsfs__DocuSign_Envelope_Document__c>();
        List<sobject> envMap = (List<sobject>)JSOn.deserialize(attachmentList, List<sobject>.class);
        Map<Id,Integer> orderMap = (Map<Id,Integer>)Json.deserialize(order,Map<Id,Integer>.class);
        for(Sobject s: envMap)
        {
            dsfs__DocuSign_Envelope_Document__c envObj = new dsfs__DocuSign_Envelope_Document__c();
            envObj.dsfs__Attachment_ID__c = (Id)s.get('Id');
            String objType = String.valueOf(s.getSObjectType());
            envObj.dsfs__SFDocument_Type__c = objType;
            String nameField = (objType == 'Attachment'|| objType == 'Document'?'Name':'Title');
            envObj.dsfs__Document_Name__c = String.valueOf(s.get(nameField));
            envObj.dsfs__Document_Order__c = orderMap.get(envObj.dsfs__Attachment_ID__c);
            envObj.dsfs__DocuSign_EnvelopeID__c = parentId;
            env.add(envObj);
        }
        insert env;   
        Map<String,String> attachmentToIdMap = new Map<String,String>();
        for(dsfs__DocuSign_Envelope_Document__c envObj: env)
        {
            attachmentToIdMap.put(envObj.dsfs__Attachment_ID__c, envObj.Id);
        }
        return JSON.serialize(attachmentToIdMap);
    }
    @RemoteAction
    public static void updateAttachments(String parentId,String order)
    {
        Map<Id,Integer> orderMap = (Map<Id,Integer>)Json.deserialize(order,Map<Id,Integer>.class);
        List<dsfs__DocuSign_Envelope_Document__c> allDocs = [Select id, dsfs__Document_Order__c, dsfs__Attachment_ID__c from dsfs__DocuSign_Envelope_Document__c where dsfs__DocuSign_EnvelopeID__c =: parentId];
        for(dsfs__DocuSign_Envelope_Document__c doc: allDocs)
        {
            doc.dsfs__Document_Order__c = orderMap.get(doc.dsfs__Attachment_ID__c);
        }
        update allDocs;
    }
    @RemoteAction
    public static void deleteAttachments(String parentId,List<Id> deleteIds)
    {
        List<dsfs__DocuSign_Envelope_Document__c> allDocs = [Select id, dsfs__Document_Order__c, dsfs__DocuSign_EnvelopeID__c from dsfs__DocuSign_Envelope_Document__c where dsfs__DocuSign_EnvelopeID__c =: parentId and dsfs__Attachment_ID__c IN: deleteIds];
        delete allDocs;
    }
    public Class ErrorHandling
    {
        public String message{get;set;}
        public String category{get;set;}
        public String errorClass{get;set;}
        public String Icon{get;set;}
        public ErrorHandling(String category, String Message)
        {
            if(category == 'Error')
            {
                Icon= 'fa-times-circle-o';
                errorClass= 'danger';
            }
            else if(category == 'Warning')
            {
                Icon= 'fa-exclamation-circle';
                errorClass= 'warning';
            }
            else if(category == 'Info')
            {
                Icon= 'fa-info-circle';
                errorClass= 'info';
            }
            this.message = Message;
            this.category = category;
        }
    }
}