//2016-05-12 -anirudh.singh@cdk.com, venkata.shrivol@cdk.com- Created this class for RQ-06986
//2016-05-26- anirudh.singh@cdk.com- Added a new parameter for fax as the insertContact method of ALL_SharedContact_Helper has been modified.
//2016-07-20 - sanjay.ghanathey@cdk.com - Added logic for LMA RFP Mini contact Page
//2017-02-03 - ragashalini.koka@cdk.com - Made changes for RQ-08334
global class ALL_NewContactDialog_Controller
{
    //public static ALL_NewContact_Wrapper fetchAllAttributes{get; set;}
    public Contact contactRecord{get; set;}
    public String subProjectId{get; set;}
    public SubProject__c subProject{get; set;}
    public List<SubProjectSite__c> siteList{get; set;}
    //public Id accountId{get; set;}
    public Boolean enableProjectRole{get; set;}
    public Decimal numberOfSites{get; set;}
    //public String text{get; set;}
    
    global ALL_NewContactDialog_Controller()
    {
        //system.debug('-------enableProjectRole-----'+enableProjectRole);
        subProjectId='';
        subProject=new SubProject__c();
        Id subProjectIdOne=ApexPages.currentPage().getParameters().get('id');
        Id subProjectIdTwo=ApexPages.currentPage().getParameters().get('subProject');
        
        if(subProjectIdOne!=Null || subProjectIdTwo!=Null)
        {
            siteList=[
                SELECT Account__r.Name, Account__c 
                FROM SubProjectSite__c
                WHERE SubProject__c IN (:subProjectIdOne, :subProjectIdTwo)
            ];
            subProjectId=subProjectIdOne;
            numberOfSites=siteList.size();
        }
    }
    
    public Map<String, String> getRelationshipRoles()
    {
        return fetchPicklistOptions('Contact', 'Role__c');
    }
    
    public Map<String, String> getProjectRoles()
    {
        return fetchPicklistOptions('SubProject_Client_Contact__c', 'Role__c');
    }
    
    public static Map<String, String> fetchPicklistOptions(String objectAPIName, String fieldAPIName)
    {
        system.debug('Start fetchPicklistOptions---->');
        Map<String, String> picklistOptionsMap=new Map<String, String>();
        
        Schema.DescribeSObjectResult describeResult=Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        Schema.DescribeFieldResult fieldResult=describeResult.Fields.getMap().get(fieldAPIName).getDescribe();
        
        for(Schema.PicklistEntry picklistValue: fieldResult.getPicklistValues()) 
        {
            picklistOptionsMap.put(picklistValue.getLabel(), picklistValue.getValue()); 
        }
        
        system.debug('End fetchPicklistOptions---->');
        return picklistOptionsMap;
    }
    
    public Map<String, String> getAccountMap()
    {
        system.debug('Start getAccountMap---->');
        /* List<Account> accountsList=new List<Account>();
        accountsList=[
        SELECT Id, Name
        FROM Account
        WHERE Id IN :fetchAllAttributes.accountList
        ];
        
        Map<String, String> accountMap=new Map<String, String>();
        
        for(Account accountRecord: accountsList) 
        {
        accountMap.put(accountRecord.Name, accountRecord.Id); 
        }*/
        
        Map<String, String> accountMap=new Map<String, String>();
        if(siteList!=Null && siteList.size()>0)
        {
            for(SubProjectSite__c site:siteList)
            {
                if(site.Account__c!=Null)
                {
                    if(site.Account__r.Name!=Null)
                    {
                        accountMap.put(site.Account__r.Name, site.Account__c);
                    }
                }
            }
        }
        
        //07-20-2016 sanjay.ghanathey@cdk.com //For LMA RFP Mini contact Page
        if(accountMap == null || accountMap.isEmpty())
        {
            Id LMAId =ApexPages.currentPage().getParameters().get('id');
            try{
                LMA_RFP__c LmaRfp = [select id,LMA__c,LMA__r.Name from LMA_RFP__c where id=:LMAId Limit 1];
                if(LmaRfp != null){
                    accountMap.put(LmaRfp.LMA__r.Name, LmaRfp.LMA__c);
                }
            }
            catch(Exception e){
                
            }
        }
        system.debug('End getAccountMap---->');
        return accountMap;
    }
    
    @RemoteAction
    global static Response createNewContact(String firstName, String lastName, String accountId, String role, String projectRole, String email, 
                                            String phone, String mobilePh, Boolean displayProjectRole, String subProjectId, String inputCall)
    {
        system.debug('Start createNewContact---->');
        if(inputCall == 'campaign')
        {
            accountId=getAccountIdFromCampaign(accountId);
        }
        
        system.debug('End createNewContact---->');
        return contactInsertionHelper(firstName, lastName,accountId, role,projectRole, email, 
                                      phone, mobilePh, displayProjectRole,  subProjectId);
    }
    
    global static String getAccountIdFromCampaign(string campaignMemberId)
    {
        system.debug('Start getAccountIdFromCampaign---->');
        String accountId='';
        
        if(!campaignMemberId.startsWith('001'))
        { 
            List<Campaign_Account_Members__c> CAMs=[
                SELECT Id, Name, Account__c 
                FROM Campaign_Account_Members__c 
                WHERE Id=:campaignMemberId
            ];
            
            system.debug(CAMs);
            if(!CAMs.IsEmpty()) 
            {
                accountId=CAMs[0].Account__c; 
            } 
        }
        
        system.debug('End getAccountIdFromCampaign---->');
        return accountId;
    }
    
    private static Id fetchContactRecordTypeId()
    {
        system.debug('Start fetchContactRecordTypeId---->');
        Id contactRecordTypeId=Null;
        
        try
        {
            contactRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Customer Contact');
        }
        catch(Exception ex) 
        { 
            List<RecordType> contactRecordTypes=[
                SELECT Id 
                FROM RecordType 
                WHERE sObjectType='Contact' 
                AND DeveloperName LIKE '%Customer%' 
                LIMIT 1
            ];
            
            if(contactRecordTypes!=Null && !contactRecordTypes.isEmpty())
            {
                contactRecordTypeId=contactRecordTypes.get(0).Id;
            }
        }
        
        system.debug('End fetchContactRecordTypeId---->'+contactRecordTypeId);
        return contactRecordTypeId;
    }
    
    //2017-02-03 - ragashalini.koka@cdk.com - Added parameter mobilePh for RQ-08334
    webService static String AddContactAndClientContact(String FirstName, String LastName, String accountId, 
                                                        String contactRole, string projectRole, String Email, 
                                                        String Phone, String mobilePh, boolean insertSPCC,string SubProjectId)
    {
        system.debug('Start AddContactAndClientContact---->'+SubProjectId);
        Response resp=contactInsertionHelper(FirstName, LastName,  accountId,  contactRole,  projectRole, 
                                             Email, Phone, mobilePh, insertSPCC,  SubProjectId);
        
        string jsonResponse=JSON.serialize(resp);
        
        system.debug('End AddContactAndClientContact---->'+SubProjectId);
        return jsonResponse;
    }
     //2017-02-03 - ragashalini.koka@cdk.com - Added parameter mobilePh for RQ-08334
    public static Response contactInsertionHelper(String FirstName, String LastName, String accountId, 
                                                  String role, string projectRole, String Email, 
                                                  String Phone, String mobilePh, boolean insertSPCC,string SubProjectId)
    {
        system.debug('Start createNewContact---->');
        system.debug('accountId---->'+accountId);
        Response response=new Response();
        response.success=false;
        
        Id contactRecordTypeId=fetchContactRecordTypeId();
        
        try
        {
            Contact contactRecord=new Contact();
            contactRecord.FirstName=firstName;
            contactRecord.LastName=lastName;
            contactRecord.AccountId=accountId;
            //Role field will be removed from Contact object.
            //contactRecord.Role__c=role;
            contactRecord.Email=email;
            contactRecord.Phone=phone;
            contactRecord.MobilePhone=mobilePh;
            if(contactRecordTypeId!=Null)
            {
                contactRecord.RecordTypeId=contactRecordTypeId;
            }
            //Inserting Contact Record.
            //Map<String, ALL_SharedContact_Helper.DuplicateCheckWrapper> resultMap=ALL_SharedContact_Helper.insertContactAndRelationship(contactRecord);
            //ALL_SharedContact_Helper.DuplicateCheckWrapper contactRelationshipResult=resultMap.get('Contact Relationship');
            //Contact_
            system.debug('contactRecord---->'+contactRecord);
            //2016-05-26- anirudh.singh@cdk.com- Added a new parameter for fax as the insertContact method of ALL_SharedContact_Helper has been modified.
            Map<string, ALL_SharedContact_Helper.duplicateCheckWrapper> resultMap=ALL_SharedContact_Helper.insertContact(contactRecord, role, phone, '');
            ALL_SharedContact_Helper.duplicateCheckWrapper insertionResultOnContact=resultMap.get('Contact');
            ALL_SharedContact_Helper.duplicateCheckWrapper insertionResultOnCRT=resultMap.get('Contact_Relationship');
            
           system.debug('insertionResultOnContact---->'+insertionResultOnContact);
            system.debug('insertionResultOnCRT---->'+insertionResultOnCRT);
            if(insertionResultOnContact.insertedRecordIds.isEmpty() && insertionResultOnCRT.insertedRecordIds.isEmpty())
            {
                if(insertionResultOnCRT.errorMsg == 'Duplicate Error')
                {
                    string duplicateIDString = '';
                    for(Id duplicateId:insertionResultOnContact.existingRecordIdToNewRecordMap.keySet())
                    {
                        duplicateIDString = duplicateId;
                    }
                    response.message='A Contact to this selected Account already exists. Please pick a different Account'+' <a href=\''+URL.getSalesforceBaseUrl().toExternalForm()+'/'+duplicateIDString+'\' target=\'_blank\'>Duplicate Contact</a>';
                }
                else if(insertionResultOnContact.insertedRecordIds.isEmpty())
                {
                    response.message=insertionResultOnContact.errorMsg + ' Please Contact administrator for Help!';
                }
                else
                {
                    response.message=insertionResultOnCRT.errorMsg + ' Please Contact administrator for Help!';
                }
                
            } 
            else
            {
                if(insertSPCC==true)
                {
                    Response thisResponse=insertSubProjectClientContact(projectRole, insertionResultOnContact, contactRecord, subProjectId);
                    return thisResponse;
                }
                else
                {
                    response.success=true;
                	response.message='Success';
                }                
            }
        }
        catch(Exception ex)
        {
            response.message=ex.getMessage(); 
        }
        
        system.debug('End createNewContact---->'+response);
        return response;
    }
    
    private static Response insertSubProjectClientContact(String projectRole, ALL_SharedContact_Helper.duplicateCheckWrapper insertionResultOnContact, 
                                                          Contact contactRecord, String subProjectId)
    {
        system.debug('Start insertSubProjectClientContact---->');
        //system.debug('----contactRecord--------'+contactRecord);
        //system.debug('---subProjectId---'+subProjectId);
        
        Response response=new Response();
        
        SubProject_Client_Contact__c subProjClientContactRecord=new SubProject_Client_Contact__c();
        subProjClientContactRecord.SubProject__c=subProjectId;
        subProjClientContactRecord.Role__c=projectRole;
        if(!insertionResultOnContact.insertedRecordIds.isEmpty())
        {
            subProjClientContactRecord.Client_Contact__c=contactRecord.Id;  
            subProjClientContactRecord.Phone__c = contactRecord.Phone;
        }
        else
        {
            Set<Id> duplicateContactIds=insertionResultOnContact.existingRecordIdToNewRecordMap.keySet();
            Map<Id,Contact> contactMap=new Map<Id,Contact>([SELECT Id, Phone FROM Contact WHERE Id IN :duplicateContactIds]);
            system.debug('duplicateContactIds---->'+duplicateContactIds);
            for(Id duplicateContactId: duplicateContactIds)
            {
                subProjClientContactRecord.Client_Contact__c=duplicateContactId;
                subProjClientContactRecord.Phone__c = contactMap.containsKey(duplicateContactId) ? contactMap.get(duplicateContactId).Phone : null; 
            }
        }
        try
        {
            //system.debug('subProjClientContactRecord---->'+subProjClientContactRecord);
            insert subProjClientContactRecord;
            response.Message='Success';
            response.Success=true; 
        }
        catch(Exception ex)
        {
            response.Message=ex.getMessage();
            response.Success=false;   
        }
        
        system.debug('End insertSubProjectClientContact---->');
        return response;
    }
    
    global class Response
    {
        global Boolean Success{get; set;}
        global String Message{get; set;}
    }
}