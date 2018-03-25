@RestResource(urlMapping='/ALL_SvcConnect_Service/*')

global with sharing class ALL_SvcConnect_Service 
{
    @HttpDelete
    global static void deleteContact()
    {
        RestRequest req = RestContext.request;
        String relationshipId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        //String Idy = RestContext.request.params.get('Id'); system.assertEquals(Idy, 'yola');
        List<Contact_Relationship__c> contactRelation = [Select Id From Contact_Relationship__c Where Id= :relationshipId Limit 1];
        DELETE contactRelation;
    }
    
    @HttpPost
    global static List<resultObject> createContact()// list<ALL_SvcConnect_Service.saveResult> createContact()
    {  
        RestRequest request = RestContext.request;        
        list<contact> newContacts = getContacts(request);
        //List<Contact> forUpdate = new List<Contact>();
        List<Contact> forUpsert = new List<Contact>();
        
        if(newContacts != null)
        {
            for(Contact con: newContacts)
            {
                forUpsert.add(con);
            }
        }
        
        //List<resultObject> updatedResults = !forUpdate.isEmpty() ? ALL_SvcConnect_Service.updateContact(forUpdate) : null;
        map<String, ALL_SvcConnect_Service.saveResult> results = !forUpsert.isEmpty() ? ALL_SvcConnect_Service.insertServiceConnectContacts(forUpsert) : null;
        map<string, ALL_SvcConnect_Service.saveResult> duplicateResults = new map<string, ALL_SvcConnect_Service.saveResult>();
        map<string, ALL_SvcConnect_Service.saveResult> successfulResults = new map<string, ALL_SvcConnect_Service.saveResult>();
        map<string, ALL_SvcConnect_Service.saveResult> erroredResults = new map<string, ALL_SvcConnect_Service.saveResult>();
            
        //system.assertEquals(results, new map<String, ALL_SvcConnect_Service.saveResult>());
        if(results != null)
        {
            for(String resultKey: results.keySet())
            {
                ALL_SvcConnect_Service.saveResult result = results.get(resultKey);
                
                if(result.isDuplicate == true)
                {
                    duplicateResults.put(resultKey, result);
                }
                
                if(result.isSuccess == true)
                {
                    successfulResults.put(resultKey, result); 
                }
                
                if(result.isSuccess == false && result.isDuplicate == false)
                {
                    erroredResults.put(resultKey, result);
                }
            }
        }
        
        if(!duplicateResults.isEmpty())
        {
            Set<String> accountContactIds = new Set<String>();
            
            for(String resultKey: duplicateResults.keySet())
            {
                ALL_SvcConnect_Service.saveResult duplicateResult = duplicateResults.get(resultKey);
                accountContactIds.add(String.valueOf(duplicateResult.ContactAttemptedInsert.AccountId) + 
                                      String.valueOf(duplicateResult.existingContact.ID));       
            }
            
            if(!accountContactIds.isEmpty())
            {
                list<Contact_Relationship__c> existingCrList = [
                    Select ID, Role__c, Contact__c, Account__c, Phone__c, Account_Contact_Id__c, Email_LGY__c, Migration_ID__c
                    From Contact_Relationship__c
                    Where Account_Contact_Id__c IN :accountContactIds
                ];
                
                map<String, Contact_Relationship__c> existingCrMap = new map<String, Contact_Relationship__c>();
                
                if(existingCrList != null)
                {
                    for(Contact_Relationship__c crs: existingCrList)
                    {
                        existingCrMap.put(crs.Account_contact_Id__c, crs);
                    }
                }
                
                //Set<String> setToCreateCRs = new Set<String>();
                Map<String, Contact_Relationship__c> crUpsertMap = new Map<String, Contact_Relationship__c>();
                
                
                for(String resultKey: duplicateResults.keySet())
                {
                    ALL_SvcConnect_Service.saveResult duplicateResult = duplicateResults.get(resultKey);
                    String accountContactId = String.valueOf(duplicateResult.ContactAttemptedInsert.AccountId) + 
                                      String.valueOf(duplicateResult.existingContact.ID);
                    
                    Contact_Relationship__c duplicateCr = existingCrMap.get(accountContactId); //duplicateCr can be null if there is no duplicate
                    if(duplicateCr != null){ duplicateResults.get(resultKey).message.Set(0, 'Update Successful'); }
                    Contact_Relationship__c upsertCr = ALL_SvcConnect_Service.createContactRelationship(duplicateResult, duplicateCr);
                    crUpsertMap.put(accountContactId, upsertCr);
                    
                    
                   /* if(currentCr != null)
                    {
                        results.get(resultKey).existingContactRel = ALL_SvcConnect_Service.createContactRelationship(duplicateResult);//currentCr;
                    }
                    else
                    {
                        setToCreateCRs.add(resultKey);
                    }  */                  
                }
                
                Upsert crUpsertMap.values();
                
                map<String, Contact_Relationship__c> insertedCRs = new map<String, Contact_Relationship__c>();                
                List<Contact_Relationship__c> insertCrList = new list<Contact_Relationship__c>();
                Map<String, Contact_Relationship__c> accountContactIdToCr = new Map<String, Contact_Relationship__c>();
                
                List<Contact_Relationship__c> upsertedCrList = new List<Contact_Relationship__c>([
                    Select ID, Role__c, Contact__c, Account__c, Phone__c, Account_Contact_Id__c, Email_LGY__c, Migration_ID__c
                    From Contact_Relationship__c
                    Where ID IN :crUpsertMap.values()
                ]);
                
                if(upsertedCrList != null && !upsertedCrList.isEmpty())
                {
                    for(Contact_Relationship__c crs: upsertedCrList)
                    {
                        accountContactIdToCr.put(crs.Account_Contact_Id__c, crs);
                    }
                }
                
               /* if(!setToCreateCRs.isEmpty())
                {  
                    for(String key: setToCreateCRs)
                    {
                        ALL_SvcConnect_Service.saveResult duplicateResult = duplicateResults.get(key);
                        Contact_Relationship__c newCr = ALL_SvcConnect_Service.createContactRelationship(duplicateResult);
                        
                        insertCrList.add(newCr);
                    }
                    
                    list<Database.SaveResult> crsResults = Upsert(insertCrList);
                }
                
                if(!insertCrList.isEmpty())
                {
                    insertCrList = [
                        Select ID, Account__c, Contact__c, Role__c, Phone__c, Account_Contact_Id__c, Email_LGY__c 
                        From Contact_Relationship__c
                        Where ID IN: insertCrList
                    ];
                }*/
                
                //if(!insertCrList.isEmpty())
                //{
                    //map<String, Contact_Relationship__c> newCRsMap = new map<String, Contact_Relationship__c>(); 
                    
                    //for(Contact_Relationship__c crs: insertCrList)
                    //{
                        //newCRsMap.put(crs.Account_Contact_Id__c, crs);
                    //}
                    
                    //if(!newCRsMap.isEmpty())
                    //{
                if(!accountContactIdToCr.isEmpty())
                {
                    for(String resultKey: duplicateResults.keySet())
                    {
                        ALL_SvcConnect_Service.saveResult duplicateResult = duplicateResults.get(resultKey);
                        String accountContactId = String.valueOf(duplicateResult.ContactAttemptedInsert.AccountId) + 
                            String.valueOf(duplicateResult.existingContact.ID);
                        
                        Contact_Relationship__c currentCr = accountContactIdToCr.get(accountContactId);
                        //Contact_Relationship__c currentCr = crUpsertMap.get(resultKey);
                        
                        if(currentCr != null)
                        {
                            results.get(resultKey).newContactRelationship = currentCr;
                        }                 
                    }
                }
                    //}
                //}
            }//system.assertEquals(2,1);
        }
        
        if(!successfulResults.isEmpty())
        {
            List<Contact_Relationship__c> insertCrList = new list<Contact_Relationship__c>();
            
            for(String resultKey: successfulResults.keySet())
            {
                ALL_SvcConnect_Service.saveResult successfulResult = successfulResults.get(resultKey);
                Contact_Relationship__c newCr = ALL_SvcConnect_Service.createContactRelationship(successfulResult, null);
                
                insertCrList.add(newCr);
            }
            
            list<Database.SaveResult> crsResults = Database.insert(insertCrList);
            
            insertCrList = [
                    Select ID, Account__c, Contact__c, Role__c, Phone__c, Account_Contact_Id__c, Email_LGY__c 
                    From Contact_Relationship__c
                    Where ID IN: insertCrList
            ];
           
            if(!insertCrList.isEmpty())
            {
                map<String, Contact_Relationship__c> newCRsMap = new map<String, Contact_Relationship__c>(); 
                
                for(Contact_Relationship__c crs: insertCrList)
                {
                    newCRsMap.put(crs.Account_Contact_Id__c, crs);
                }
                
                if(!newCRsMap.isEmpty())
                {
                    for(String resultKey: successfulResults.keySet())
                    {
                        ALL_SvcConnect_Service.saveResult successfulResult = successfulResults.get(resultKey);
                        String accountContactId = String.valueOf(successfulResult.ContactAttemptedInsert.AccountId) + 
                            String.valueOf(successfulResult.ContactAttemptedInsert.ID);
                        
                        Contact_Relationship__c currentCr = newCRsMap.get(accountContactId);
                        
                        if(currentCr != null)
                        {
                            results.get(resultKey).newContactRelationship = currentCr; 
                        }                 
                    }
                }
            }
        }
        
        List<resultObject> resultList = new List<resultObject>();
        
        if(results != null)
        {
            for(ALL_SvcConnect_Service.saveResult result: results.values())
            {
                resultObject newresultObject = new resultObject();
                newresultObject.message = result.message;
                 
                if(result.existingContactRel != null && result.existingContactRel.get('Id') != null)
                {
                    newresultObject.contactRelation = result.existingContactRel;
                }
                else if(result.newContactRelationship != null && result.newContactRelationship.get('Id') != null)
                {
                    newresultObject.contactRelation = result.newContactRelationship;
                }
                
                resultList.add(newresultObject);
            }
        }
        //system.assertEquals(results.values(), null);
        
        //if(updatedResults != null)
        //{
            //resultList.addAll(updatedResults);
       // }
        
        return resultList; //results.values();
    }
    
    /*global static List<resultObject> updateContact(List<Contact> contacts)
    { 
        List<Database.SaveResult> saveResults;
        Map<ID, Contact_Relationship__c> crMap;
        
        if(contacts != null)
        {
            Map<String, Contact> compositeIdToContact = new Map<String, Contact>();
            Set<ID> crIdSet = new Set<ID>();
            
            for(Contact con: contacts)
            {
                String compositeId = String.valueOf(con.AccountId) + String.valueOf(con.ID);
                compositeIdToContact.put(con.Id, con);
                crIdSet.add(con.Id);
            } 
            
            if(!crIdSet.isEmpty())
            {
                list<Contact_Relationship__c> existingCrList = [
                    Select ID, Role__c, Contact__c, Account__c, Phone__c, Account_Contact_Id__c, Email_LGY__c
                    From Contact_Relationship__c
                    Where ID IN :crIdSet
                ];
                
                if(existingCrList != null)
                {
                    
                    map<String, Contact_Relationship__c> existingCrMap = new map<String, Contact_Relationship__c>();
                    
                    for(Contact_Relationship__c crs: existingCrList)
                    {
                        existingCrMap.put(crs.ID, crs);
                    }
                    
                    if(!existingCrMap.isEmpty())
                    {
                        for(String ID: compositeIdToContact.keySet())
                        {
                            Contact con = compositeIdToContact.get(ID);
                            
                            if(existingCrMap.get(ID) != null)
                            {
                                existingCrMap.get(ID).Phone__c = Con.Phone;
                            }
                        }
                        
                        saveResults = Database.Update(existingCrMap.values(), false);
                        
                        crMap = new Map<ID, Contact_Relationship__c>([
                            Select ID, Role__c, Contact__c, Account__c, Phone__c, Account_Contact_Id__c, Email_LGY__c
                            From Contact_Relationship__c
                            Where ID IN :existingCrMap.values()
                        ]);
                    }
                    
                }
            }
        }
        
        List<resultObject> results = new List<resultObject>();
        
        if(saveResults != null)
        {
            for(Database.SaveResult sr: saveResults)
            {
                resultObject result = new resultObject();
                
                if(sr.isSuccess())
                {  
                    String crId = sr.getId();
                    result.contactRelation = crMap != null ? crMap.get(crId) : null;
                    result.message.add('Success');
                }
                else
                {
                    for(Database.Error err : sr.getErrors())
                    {
                        result.message.add(err.getMessage());
                    }
                }
                results.add(result);
            }
        }
        return results;
    }*/
    
    public static List<Contact> getContacts(RestRequest request)
    {
        String body = request.requestBody.toString();
        
        //system.assertEquals(body, null);
        //String stringObject = body;
        //Exception_Log__c newLog = new Exception_Log__c();
        //newLog.Name = string.valueof(Crypto.getRandomInteger());
        //newLog.Dml_Status_Code__c = stringObject;
        //newLog.Dml_Message__c = userInfo.getName() + '  and time is ' + String.valueOf(Datetime.now());
        //insert newlog;
        
        
        List<object> jsonList = (List<object>)JSON.deserializeUntyped(body);
        //system.assertEquals(((Map<String, object>)jsonList[0]).get('AccountId'), (object)('01233000000IgTkAAK'));
        //list<contact> newContacts = (list<Contact>)JSON.deserialize(body, list<Contact>.Class);
        Set<String> partyIds = new Set<String>();
        list<Account> accountList = new list<Account>();
        map<String, Account> accountMap = new map<String, Account>();
        
        for(object obj: jsonList)
        {
            String partyId = (String)((Map<String, object>)obj).get('PartyId');
            partyIds.add(partyId);
        }
        
        if(!partyIds.isEmpty())
        {
            accountList = [
                Select Id, Name, PartyId__c
                From Account
                Where PartyId__c IN :partyIds
            ];
        }
        
        if(!accountList.isEmpty())
        {
            for(Account acc: accountList)
            {
                accountMap.put(acc.PartyId__c, acc);
            }
        }
        
        String recordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Customer Contact');
        
        List<String> accountIds = new List<String>();
        
        for(object jObj: jsonList)
        {
            String partyId = (String)((map<String, object>)jObj).get('AccountId');
            partyId = partyId == null ? (String)((map<String, object>)jObj).get('PartyId') : partyId;
            Account acc = accountMap != null ? accountMap.get(partyId) : null;
            String actualAccId = acc != null ? acc.ID : null;
            
            ((map<String, object>)jObj).put('AccountId', actualAccId);
            ((map<String, object>)jObj).put('RecordTypeId', recordTypeId);
            
            if(actualAccId != null) { accountIds.add(actualAccId); }
        }
        
        Map<ID,ID> topAccountsMap = new Map<ID,ID>();
        
        if(!accountIds.isEmpty()) 
        {
            topAccountsMap = AccountHierarchyTools.recursivelyFetchTopParentAccountIdList(accountIds);
        }
        
        String body2 = JSON.serialize(jsonList);
        
        list<contact> newContacts = (list<Contact>)JSON.deserialize(body2, list<Contact>.Class);
        
        for(Contact con: newContacts)
        {
            if(con.AccountId != null)
            {
                Con.put( 'Dealer_Group__c', topAccountsMap.get(Con.AccountId)); 
            }
        }
        
        return newContacts;
    }
    
    global class resultObject
    {
        global Contact_Relationship__c contactRelation;
        global List<String> message;
        
        global resultObject()
        {
            contactRelation = new Contact_Relationship__c();
            message = new List<String>();
        }
    }
    
    public static Contact_Relationship__c createContactRelationship(ALL_SvcConnect_Service.saveResult duplicateResult, Contact_Relationship__c duplicateCr)
    {
        Contact existingContact = duplicateResult.existingContact;
        Contact ContactAttemptedInsert = duplicateResult.ContactAttemptedInsert;
        
        Contact_Relationship__c newCr;
        
        if(duplicateCr != null && duplicateCr.ID != null)
        {  
            newCr = new Contact_Relationship__c(ID=duplicateCr.ID);
        }
        else
        { 
            newCr = new Contact_Relationship__c();
            newCr.Account__c = ContactAttemptedInsert.AccountId;
            newCr.Contact__c = existingContact != null ? existingContact.ID : ContactAttemptedInsert.ID;
        }
        
        
        newCr.Role__c = ContactAttemptedInsert.Role__c;
        newCr.Phone__c = ContactAttemptedInsert.Phone;
        newCr.Email_LGY__c = existingContact != null ? existingContact.Email : ContactAttemptedInsert.Email;
        //newCr.Account_Contact_Id__c = null;
        //newCr.Migration_ID__c = (duplicateCr != null && duplicateCr.Migration_ID__c != null) ? duplicateCr.Migration_ID__c : null;
        
        return newCr;
    }
    
    global class saveResult
    {
        global boolean isSuccess = true;
        global boolean isDuplicate = false;
        global Contact existingContact; //existing record in salesforce database
        global Contact ContactAttemptedInsert; //record attempted to insert        
        global List<string> message; // all messages returned for insert attempt.
        global Contact_Relationship__c existingContactRel;
        global Contact_Relationship__c newContactRelationship;
        
        global saveResult()
        {
            message = new list<string>();
            existingContact = new Contact();
            ContactAttemptedInsert = new Contact();
            existingContactRel = new Contact_Relationship__c();
            newContactRelationship = new Contact_Relationship__c();
        }
    }
    
    global static map<String, ALL_SvcConnect_Service.saveResult> insertServiceConnectContacts(list<Contact> contactList)
    {   
        list<Database.SaveResult> saveResultList = Database.insert(contactList, false);
        map<String, ALL_SvcConnect_Service.saveResult> results = new map<String, ALL_SvcConnect_Service.saveResult>();  
        
        
        for(Integer i =0;i<saveResultList.size();i++)
        {  
            Database.SaveResult curSaveResult = saveResultList[i];
            ALL_SvcConnect_Service.saveResult individualResult = new ALL_SvcConnect_Service.saveResult();
            
                       
            if(curSaveResult.isSuccess() == false) 
            {
                individualResult.isSuccess = false;
                
                for (Database.Error error : curSaveResult.getErrors()) 
                {                    
                    if (error instanceof Database.DuplicateError) 
                    {
                        individualResult.isDuplicate = true;
                        
                        Database.DuplicateError duplicateError = (Database.DuplicateError)error;
                        Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                        Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                        
                        for(Datacloud.MatchResult matchResult: matchResults)
                        {
                            Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                            
                            for (Datacloud.MatchRecord matchRecord : matchRecords) 
                            {
                                individualResult.existingContact = (Contact)matchRecord.getRecord();
                                individualResult.ContactAttemptedInsert = contactList[i];
                            }  
                        }
                        
                        individualResult.message.add('Duplicate Error');
                    }
                    else
                    {
                        individualResult.message.add(error.getMessage());
                    }
                }
            }
            else
            {
                individualResult.isSuccess = true;
                individualResult.isDuplicate = false;
                individualResult.existingContact = null;
                individualResult.ContactAttemptedInsert = contactList[i];
                individualResult.message.add('Success');
            }
            
            results.put(String.valueOf(Crypto.getRandomInteger()), individualResult);
        }
        
        return results;
    }
}