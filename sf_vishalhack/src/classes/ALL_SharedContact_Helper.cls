// 2016-05-09 Matt.Keefe@CDK.com, Venkata.Shrivol@CDK.com, Siva.Pragada@CDK.com - Created
// 2016-05-12 -siva.pragada@cdk.com - overloaded buildContactRelationshipQuery();
//2016-05-26- anirudh.singh@cdk.com- Added Fax__c field in the insertContact method to populate it on Contact Relationship instead of Contact.
public class ALL_SharedContact_Helper 
{
    // --   Constants   --------------------------------------------------
    
    public static final string[] CONTACT_DEFAULT_FIELDS = new list<string>{ 'Id', 'Name' };
    public static final string[] CONTACT_RELATIONSHIP_DEFAULT_FIELDS = new list<string>{ 'Id', 'Name', 'Contact__r'};
    
    public static final string DUPLICATE_ERROR_MESSAGE = 
        'ERROR!! A similar contact already exists (email and name must be unique). ' +
        'You may be inserting a DUPLICATE CONTACT.';
    
    // -- Query Methods - facade -----------------------------------------
    
    // query using dot notation (through field set on Contact Relationship)
    // select Id, Name, Contact__r.Id, Contact__r.Name from Contact_Relationship__c where :whereClause
    public static map<Id, Contact_Relationship__c> queryContactRelationshipAndContact(string whereClause)
    {
        return queryContactRelationships(whereClause, 'InternalHRContact');
    }
    
    // query using sub-query (starting at Contact)
    // select Id, Name, (select Id, Name From Contact_Relationship__r) from Contact where :whereClause
    public static map<Id, Contact> queryContactsAndContactRelationships(string whereClause)
    {
        return queryContacts(whereClause, 'InternalHRContact', 'InternalHRContact');
    }
    
    // -- query helper methods -------------------------------------------
    
    // queries both Contact Relationship and Contact fields based on Contact Relationship Field Set
    public static map<Id, Contact_Relationship__c> queryContactRelationships(string whereClause, string FieldSetName)
    {
        string query = buildContactRelationshipQuery(whereClause, FieldSetName);
        system.debug('Query------------------------>'+query);
        return new map<Id, Contact_Relationship__c>((List<Contact_Relationship__c>)Database.query(query));
    }
    
    // build query for Contact Relationships (and Contacts through field set relationship fields, dot notation)
    public static string buildContactRelationshipQuery(string whereClause, string FieldSetName)
    {
        list<string> fields = getFieldAPINames('Contact_Relationship__c', FieldSetName, CONTACT_RELATIONSHIP_DEFAULT_FIELDS);        
        return buildContactRelationshipQuery(fields, whereClause);
    }
    
    public static string buildContactRelationshipQuery(list<string> fields, string whereClause)
    {
        string fieldQuery = string.join(fields, ', ');
        string query = 'Select ' + fieldQuery + ' From Contact_Relationship__c ' + whereClause;
        return query;
    }
    
    public static map<Id, Contact> queryContacts(
        string whereClause, string ContactFieldSet, string ContactRelationshipFieldSet)
    {
        list<string> contactRelFields = getFieldAPINames(
            'Contact_Relationship__c', ContactRelationshipFieldSet, CONTACT_RELATIONSHIP_DEFAULT_FIELDS);
        
        list<string> contactFields = getFieldAPINames(
            'Contact', ContactFieldSet, CONTACT_DEFAULT_FIELDS);
        
        string q = constructQueryWithRelationships(contactFields, contactRelFields);
        q += ' ' + whereClause;
        system.debug('Query------------------------>'+q);
        return new map<Id, Contact>((List<Contact>)Database.query(q));
    }
    
    public static list<string> getFieldAPINames(string sObjectType, string FieldSetName, list<string> defaultFields)
    {
        // note: we can add fields for Contact as subchildren
        list<Schema.FieldSetMember> ContactRelationshipFields = getAllFieldSetMembers(sObjectType, FieldSetName);
        
        list<string> fields = new list<string>();
        
        if(ContactRelationshipFields == null || ContactRelationshipFields.isEmpty())
        {
            fields.addAll( defaultFields );
        }
        else
        {
            for(Schema.FieldSetMember fsm : ContactRelationshipFields) 
            {
                fields.add(fsm.getFieldPath());
            }
        }
        
        return fields;
    }
    
   
    public static list<Schema.FieldSetMember> getAllFieldSetMembers(string sObjectType, string fieldSetName)
    {
        Schema.DescribeSObjectResult sObjectResult = ALL_UtilitiesDescribe.getDescribeInfoForsObject(sObjectType);
        Map<String, Schema.FieldSet> FsMap = sObjectResult.fieldSets.getMap();
        Schema.FieldSet fieldSet = FsMap.get(fieldSetName);
        list<Schema.FieldSetMember> fieldSetMemberList = fieldSet!=null ? fieldSet.getFields() : null;
               
        return fieldSetMemberList;
    }
    
    public static string constructQueryWithRelationships(
        list<string> contactFields, list<string> relationshipFields)
    {
        string queryStringContact = constructBasicQuery('Contact', contactFields); 
        string queryStringRelation = constructBasicQuery('Contact_Relationships__r', relationshipFields);
        
        queryStringRelation = ' (' + queryStringRelation + ') ';
        
        integer index = queryStringContact.IndexOf('FROM');
        queryStringContact = queryStringContact.subString(0,index-1);
        queryStringContact += ',';
        queryStringContact += queryStringRelation;
        queryStringContact += ' FROM ' + 'Contact';
        
        return queryStringContact;
    }
    
    public static string constructBasicQuery(string sObjectType, list<string> fields) 
    {
        if(fields == null) { fields = new list<string>(); }
        fields.add('Id'); // always add the Id
        
        string queryString = 'SELECT ' + string.join(fields, ', ');
        queryString += ' FROM ' + sObjectType;
        
        return queryString;
    }
    
    // -- Insertion Methods --------------------------------------------------
    
    // to be used for inserting Contacts or Contact Relationships (or both, call twice separately)
    public static duplicateCheckWrapper insertDuplicateCheck(list<sObject> recordsToBeInserted)
    { 
        // 2016-06-16 - vishal.bandari@cdk.com - Setting Dealer_Group field on Contact Records
        List<Id> accountIds = new List<Id>();
        for(sObject currentRecord : recordsToBeInserted)
        {
            // 2016-06-16 matt.keefe@cdk.com, vishal.bandari@cdk.com - added type check
            if(currentRecord.getSObjectType() == Schema.Contact.getSObjectType())
            {
                if(currentRecord.get('AccountId') != null) {
                    accountIds.add( (Id)currentRecord.get('AccountId') ); }
            }
        }
        system.debug('---accountIds--'+accountIds);
        
        // 2016-06-16 matt.keefe@cdk.com, vishal.bandari@cdk.com - added type check and dealer group setting
        if(!accountIds.isEmpty()) 
        {
            Map<Id,Id> TopAccountsMap = AccountHierarchyTools.recursivelyFetchTopParentAccountIdList(accountIds);
            system.debug('TopAccountsMap---------'+TopAccountsMap);
            for(sObject currentRecord : recordsToBeInserted)
            {
                if(currentRecord.getSObjectType() == Schema.Contact.getSObjectType())
                {
                    if(currentRecord.get('AccountId') != null) {
                        currentRecord.put( 'Dealer_Group__c', TopAccountsMap.get((Id)currentRecord.get('AccountId')) ); }
                }
            }
        }
        
        duplicateCheckWrapper result = new duplicateCheckWrapper();
        
        list<Database.SaveResult> saveResultList = Database.insert(recordsToBeInserted, false);
        
        //2016-05-26- anirudh.singh@cdk.com- Added this variable for handling multiple error messages for the same record.
        String errMessage='';
        
        for(Integer i =0;i<saveResultList.size();i++)
        {  
            if(!saveResultList[i].isSuccess()) 
            {
                for (Database.Error error : saveResultList[i].getErrors()) 
                {
                    system.debug(error);
                    system.debug('DuplicateError? '+ (error instanceof Database.DuplicateError));
                    
                    if (error instanceof Database.DuplicateError) 
                    {
                        Database.DuplicateError duplicateError = (Database.DuplicateError)error;
                        Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                        Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                        
                        for(Datacloud.MatchResult matchResult:duplicateResult.getMatchResults())
                        {
                            Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                            
                            for (Datacloud.MatchRecord matchRecord : matchRecords) 
                            {
                                result.existingRecordIdToNewRecordMap.put(
                                    (ID)matchRecord.getRecord().get('Id'), recordsToBeInserted[i]
                                );
                            }
                        }
                        // This String value dependency in ALL_NewContactDialog_Controller.contactInsertionHelper
                        //2016-05-26- anirudh.singh@cdk.com- Commented the below line and using errMessage.
                        //result.errorMsg='Duplicate Error';
                        errMessage='Duplicate Error';
                    }
                    else
                    {
                        //2016-05-26- anirudh.singh@cdk.com- Commented the below line and added a line to handle multiple error messages for the same record.
                        //result.errorMsg=error.getMessage();
                    	errMessage+=((errMessage!='' && !errMessage.contains(error.getMessage()))? ', ' : '')+error.getMessage();
                    }
                }
                //2016-05-26- anirudh.singh@cdk.com- Added this line.
                result.errorMsg=errMessage;
            }
            else
            {
                result.insertedRecordIds.add(saveResultList[i].getId());
            }
        }
        return result;
    }
    
    //2016-05-19   -venkata.shrivol@cdk.com -used this method to insert only Single Contact from a dialog box
    public static map<string, duplicateCheckWrapper>  insertContact(Contact conTobeInserted, string contactRole, string Phone, String faxFieldValue)
    {
        system.debug('------insertContact-----------Start-');
        list<Contact_Relationship__c> conRelationshipsToBeInserted = new list<Contact_Relationship__c>();
        map<string, duplicateCheckWrapper> mapToReturn = new map<String, duplicateCheckWrapper>();
        
        //2016-06-16 - vishal.bandari@cdk.com - Setting Dealer_Group field on Contact Record
        if(conToBeInserted != null && conToBeInserted.AccountId != null) {
            conTobeInserted.Dealer_Group__c = AccountHierarchyTools.recursivelyFetchTopParentAccountId(conTobeInserted.AccountId);
        }
        
        duplicateCheckWrapper result1  = insertDuplicateCheck(new list<Contact>{conTobeInserted});
        mapToReturn.put('Contact', result1);
        
        if(!result1.insertedRecordIds.isEmpty())
        {
            set<Id> recordIdsToQuery = result1.insertedRecordIds;
            list<Contact> InsertedContacts = Database.Query('Select AccountId, Id from Contact where Id IN :recordIdsToQuery');
            for(sObject sObj:InsertedContacts)
            {
                if(sObj.get('AccountId') !=null)
                {
                    Contact_Relationship__c crt = new Contact_Relationship__c();
                    crt.Account__c = (Id)sObj.get('AccountId');
                    crt.Contact__c= (Id)sObj.get('Id');
                    crt.Phone__c = Phone;
                    crt.Role__c = contactRole;
                    //2016-05-26- anirudh.singh@cdk.com- Added Fax__c field to populate it on Contact Relationship instead of Contact.
                    crt.Fax__c = faxFieldValue;
                    conRelationshipsToBeInserted.add(crt);	
                }
            }
        }
        else
        {
            for(Id contactId:result1.existingRecordIdToNewRecordMap.keySet())
            {
                Contact_Relationship__c crt = new Contact_Relationship__c();
                crt.Account__c = (ID)result1.existingRecordIdToNewRecordMap.get(contactId).get('AccountId');
                crt.Contact__c= contactId;
                crt.Phone__c = Phone;
                crt.Role__c = contactRole;
                //2016-05-26- anirudh.singh@cdk.com- Added Fax__c field to populate it on Contact Relationship instead of Contact.
                crt.Fax__c = faxFieldValue;
                conRelationshipsToBeInserted.add(crt);	
            }
        }
        duplicateCheckWrapper result2 = insertDuplicateCheck(conRelationshipsToBeInserted);
        mapToReturn.put('Contact_Relationship', result2);
        system.debug('------insertContact-----------End-');
        return mapToReturn;
    }
   
    
    public class duplicateCheckWrapper
    {
        public map<Id, sObject> existingRecordIdToNewRecordMap;
        public set<Id> insertedRecordIds;
        
        //used this string to get the error message on new Contact dialog box
        //not really used for bulk insertion of contacts.
        public string errorMsg;
        public duplicateCheckWrapper()
        {
            insertedRecordIds = new set<Id>();
            existingRecordIdToNewRecordMap = new map<Id, sObject>();
        }
    }
}