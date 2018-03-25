/*
---Entire Code runs in three different functions for three different Scenarios

--->1. updateEnvelope(EnvelopeId, Contract#) - Automatic Updating Envelope with Contract numbers and Deleting Blocking User1
--->2. manualUpdateEnvelope(EnvelopeId, Contract#) - Manual update for the docusign Contract number using Exception Contract# Push Field filled
--->3. addEnvelopeRecipients(EnvelopeId) - Adding new Recipients NewCA, Blocking User2 if none of the above cases aren't

4/23/2015 - Venkata Shrivol - Commented out the SOBO User email query; I recommend to either use a particular user always rather than sender
                              or don't use one. 

*/


public with sharing class DS_CallDocusignAPI_Handler {
    
    public DS_CallDocusignAPI_Handler() { }
    
    public static string loginURL = CustomSettings__c.getOrgDefaults().DocusignBaseURL__c;
    
    public static void prepareForUpdate(list<Deal_State__c> dsList)
    {
        Set<id> dsIds = new Set<Id>();
        for(Deal_State__c dState : dsList)
        {
            dsIds.add(dState.id);   
        }
        
        list<Deal_State__c> dealStateList = [ 
            Select Id, Contract_Number_s__c, Exception_Contract_Push__c, 
            ( Select Id, dsfs__DocuSign_Envelope_ID__c from DocuSign_Status__r order by createdDate desc limit  1 ) 
            from Deal_State__c where id IN :dsIds
        ];
        
        for(Deal_State__c ds: dealStateList)
        {
            dsfs__DocuSign_Status__c  docuStatus = ds.DocuSign_Status__r;
            
            if(ds.Exception_Contract_Push__c == null && ds.Contract_Number_s__c!= null)
            {
                updateEnvelope(docuStatus.dsfs__DocuSign_Envelope_ID__c, ds.Contract_Number_s__c);
            } 
            else if(ds.Exception_Contract_Push__c != null && ds.Contract_Number_s__c!= null ) 
            {
                manualUpdateEnvelope(docuStatus.dsfs__DocuSign_Envelope_ID__c, ds.Contract_Number_s__c); 
            }
            else 
            {
                addEnvelopeRecipients(docuStatus.dsfs__DocuSign_Envelope_ID__c);
            } 
        }   
    }

    @future (callout=true)
    public static void updateEnvelope(String envelopeID, String ContractNumber)
    {
        RecipientResponse RecipientResponseDeserialized = new RecipientResponse();
        RecipientTabResponse RecipientTabResponseDeserialized = new RecipientTabResponse();
        LoginResponse LoginResponseDeserialized = new LoginResponse();
        Map<String, Docusign_Recipient__c> docusignRecipientMap = Docusign_Recipient__c.getAll();
         
        
        string rResponse = '{}';
        string rLoginInformationResponse = '{}';
        string recipientIdwithContractTab;
        string recipientIdForBlockingRecipient;
        string rTabResponse = '{}';
        string rSetRecipientResponse = '{}';
        string rSetTabForRecipientResponse = '{}';
        string rTabRecipientDeleteResponse = '{}';
        string rBlockingRecipientDeleteResponse = '{}';
        string contractTabRoleName = docusignRecipientMap.get('Legal Counter Signer').Signer_Role__c; //'Signer5' 
        string blockingTabRoleName = docusignRecipientMap.get('BlockingUser').Signer_Role__c; //'Signer7'
        //string soboEmail= ''; // sobo - Send On Behalf Of Functionality of Docusign. 
        
        //string test='';
        
        
        try
        {
            // Getting the SenderEmail of the document who can be used as SOBO user of Docusign 
           /* list<dsfs__DocuSign_Status__c> soboEmails = [
                Select dsfs__Sender_Email__c 
                from dsfs__DocuSign_Status__c 
                where dsfs__DocuSign_Envelope_ID__c = :envelopeID 
                limit 1 
            ];
            
            // sobo - sent on behalf of
            soboEmail = soboEmails.size() > 0 ? soboEmails[0].dsfs__Sender_Email__c : '';
            system.debug(soboEmail);*/
            
            // Call to get login Information baseURL to add it in authentication header
            rLoginInformationResponse = getLoginInformation(loginURL);
            
            LoginResponseDeserialized =parseLoginResponse(rLoginInformationResponse);
            system.debug('---------------------------'+LoginResponseDeserialized);
            
            //Call to get envelope recipients
            rResponse = getEnvelopeRecipients(envelopeID, LoginResponseDeserialized); 
            system.debug(rResponse); 
            
            // rResponse is a JSON string
            RecipientResponseDeserialized = parseRecipentResponse(rResponse);  
            system.debug(RecipientResponseDeserialized);
            
            recipientIdwithContractTab = getTabRecipientId(RecipientResponseDeserialized, contractTabRoleName);
            system.debug(recipientIdwithContractTab);
            
            //Call to get recipient tab
            rTabResponse = getRecipientTab(envelopeID, recipientIdwithContractTab, LoginResponseDeserialized);
            system.debug(rTabResponse);
            
            // rTabResponse is a JSON string
            RecipientTabResponseDeserialized = parseRecipientTabResponse(rTabResponse); 
            system.debug(RecipientTabResponseDeserialized);
                        
                     
            //Call to modify tab for legal recipient 
            rSetTabForRecipientResponse = modifyTabwithContractNum(envelopeID, RecipientTabResponseDeserialized, 
                ContractNumber, recipientIdwithContractTab, LoginResponseDeserialized);
            system.debug(rSetTabForRecipientResponse);
            
            
            
            //Call to delete blocking user 
            recipientIdForBlockingRecipient = getTabRecipientId(RecipientResponseDeserialized, blockingTabRoleName);
            rBlockingRecipientDeleteResponse = deleteRecipient(envelopeID, recipientIdForBlockingRecipient, LoginResponseDeserialized);
            system.debug(rBlockingRecipientDeleteResponse);
        }
        catch(Exception ex) { system.debug(ex); }           
    }
    
    
     @future (callout=true)
    public static void addEnvelopeRecipients(String envelopeID)
    {
        RecipientResponse RecipientResponseDeserialized = new RecipientResponse();
        LoginResponse LoginResponseDeserialized = new LoginResponse();
        
        string rLoginInformationResponse = '{}';
        string rResponse = '{}';
        string recipientIdForBlockingRecipient;
        string rTabResponse = '{}';
        string rSetRecipientResponse ='{}';
        string setBlockingUser2Response = '{}';
        string rSetCARecipientResponse= '{}';
        string rBlockingRecipientDeleteResponse = '{}';
        string roleName ='Signer4';
        string blockingTabRoleName = 'Signer7';
        //string soboEmail= '';

        
        try
        {
            // Getting the SenderEmail of the document who can be used as SOBO user of Docusign 
            /*list<dsfs__DocuSign_Status__c> soboEmails = [Select dsfs__Sender_Email__c from dsfs__DocuSign_Status__c where dsfs__DocuSign_Envelope_ID__c = :envelopeID limit 1 ];
            soboEmail = soboEmails.size() > 0 ? soboEmails[0].dsfs__Sender_Email__c : '';
            system.debug(soboEmail);
            /*for(dsfs__DocuSign_Status__c dStatus: soboEmails){
                soboEmail = dStatus.dsfs__Sender_Email__c;
                system.debug(soboEmail);
            } */
            
            // Call to get login Information baseURL to add it in authentication header
            rLoginInformationResponse = getLoginInformation(loginURL);
            
            LoginResponseDeserialized =parseLoginResponse(rLoginInformationResponse);
            system.debug('---------------------------'+LoginResponseDeserialized);
            
            //Call to get envelope recipients
            rResponse = getEnvelopeRecipients(envelopeID, LoginResponseDeserialized); // function Defined below
            system.debug(rResponse); //2nd response in debug log
            
            RecipientResponseDeserialized = parseRecipentResponse(rResponse); 
            system.debug(RecipientResponseDeserialized);
            
            //Call to add recipient with new id
            rSetCARecipientResponse = setRecipientsNewCAandBU2(envelopeID,RecipientResponseDeserialized, LoginResponseDeserialized);
            system.debug(rSetCARecipientResponse);
            
            // Call to add recipient for Blocking User 2
            //setBlockingUser2Response = setBlockingUser2(envelopeID, soboEmail, LoginResponseDeserialized);
            //system.debug(setBlockingUser2Response);
            
            
            //Call to delete blocking user 
            recipientIdForBlockingRecipient = getTabRecipientId(RecipientResponseDeserialized, blockingTabRoleName);
            rBlockingRecipientDeleteResponse = deleteRecipient(envelopeID, recipientIdForBlockingRecipient, LoginResponseDeserialized);
            system.debug(rBlockingRecipientDeleteResponse);
            
        }
        catch(Exception ex) { system.debug(ex); }           
    }
    
    @future (callout=true)
    public static void manualUpdateEnvelope(String envelopeID, String ContractNumber)
    {
        RecipientResponse RecipientResponseDeserialized = new RecipientResponse();
        RecipientTabResponse RecipientTabResponseDeserialized = new RecipientTabResponse();
        LoginResponse LoginResponseDeserialized = new LoginResponse();
        
        string rResponse = '{}';
        string rLoginInformationResponse = '{}';
        string recipientIdwithContractTab;
        string recipientIdForBlockingRecipient2;
        string recipientIdForNewCA;
        string rTabResponse = '{}';
        string rSetRecipientResponse = '{}';
        string rSetTabForRecipientResponse = '{}';
        string rTabRecipientDeleteResponse = '{}';
        string rBlockingRecipient2DeleteResponse = '{}';
        string rNewCADeleteResponse = '{}';
        string rBlockingRecipient2RoleName = 'Signer9';
        string contractTabRoleName = 'Signer5';
        string newCARecipientId = '8';
        
        //string soboEmail= '';

        
        try
        {
            // Getting the SenderEmail of the document who can be used as SOBO user of Docusign 
            /*list<dsfs__DocuSign_Status__c> soboEmails = [Select dsfs__Sender_Email__c from dsfs__DocuSign_Status__c where dsfs__DocuSign_Envelope_ID__c = :envelopeID limit 1 ];
            soboEmail = soboEmails.size() > 0 ? soboEmails[0].dsfs__Sender_Email__c : '';
            system.debug(soboEmail);*/
            
            // Call to get login Information baseURL to add it in authentication header
            rLoginInformationResponse = getLoginInformation(loginURL);
            
            LoginResponseDeserialized =parseLoginResponse(rLoginInformationResponse);
            system.debug('---------------------------'+LoginResponseDeserialized);
            
            //Call to get envelope recipients
            rResponse = getEnvelopeRecipients(envelopeID, LoginResponseDeserialized); // function Defined below
            system.debug(rResponse); //2nd response in debug log
            
            RecipientResponseDeserialized = parseRecipentResponse(rResponse); // Function defined below 
            system.debug(RecipientResponseDeserialized);
            
            recipientIdwithContractTab = getTabRecipientId(RecipientResponseDeserialized, contractTabRoleName);
            system.debug(recipientIdwithContractTab);
            
            //Call to get recipient tab
            rTabResponse = getRecipientTab(envelopeID, recipientIdwithContractTab, LoginResponseDeserialized);
            system.debug(rTabResponse);
            
            RecipientTabResponseDeserialized = parseRecipientTabResponse(rTabResponse);
            system.debug(RecipientTabResponseDeserialized);

            //Call to add tab to new recipient with new id
            
            rSetTabForRecipientResponse = modifyTabwithContractNum(envelopeID,RecipientTabResponseDeserialized,ContractNumber, recipientIdwithContractTab, LoginResponseDeserialized);
            system.debug(rSetTabForRecipientResponse);
            
            
            //Call to delete NewCAApproverCheck 
            //recipientIdForBlockingRecipient2 = getTabRecipientId(RecipientResponseDeserialized, rBlockingRecipient2RoleName);
            // Calling the same function used above but with different RecipientGuid;
            rNewCADeleteResponse = deleteRecipient(envelopeID, newCARecipientId, LoginResponseDeserialized); 
            system.debug(rNewCADeleteResponse);
            
            //Call to delete blocking user2 
            recipientIdForBlockingRecipient2 = getTabRecipientId(RecipientResponseDeserialized, rBlockingRecipient2RoleName);
            // Calling the same function used above but with different RecipientGuid;
            rBlockingRecipient2DeleteResponse = deleteRecipient(envelopeID, recipientIdForBlockingRecipient2, LoginResponseDeserialized); 
            system.debug(rBlockingRecipient2DeleteResponse);
        }
        
        catch(Exception ex) { system.debug(ex); }           
    }
     public static string getTabRecipientId(RecipientResponse rResponse, String roleName)
    {
        string recipientTabID = 'Not Found';
        
        try
        {
            List<Signer> mySigners = rResponse.signers;
            for(Signer mySigner : mySigners)
            {
                if(mySigner.roleName==roleName )
                {
                    //rContractTabID = mySigner.recipientIdGuid;
                    recipientTabID = mySigner.recipientId;
                }
                
            }  
            system.debug(recipientTabID);          
        }
        catch(Exception ex) { system.debug(ex); }
        
        return recipientTabID;
    }
    
    public static string getLoginInformation(string baseLoginURL) 
    {
        string DSEndpoint=baseLoginURL;  //'https://demo.docusign.net/restapi/v2/';
        string response = '{}';  
        
        try
        {
            
             
            
            //DocusignAPI_Users__c dUser = getApiUser();
            DocusignAPI_Users__c dUser = DocusignAPI_Users__c.getValues('Docusign API User');
            string DSUserId = dUser.UserId__c;
            system.debug('=======================================>'+DSUserId );
            string DSPassword = dUser.Password__c;
            system.debug('=======================================>'+DSPassword );
            string DSAccountID = dUser.AccountId__c;
            system.debug('=======================================>'+ DSAccountID);
            string DSIntegratorKey = dUser.IntegratorKey__c;
            system.debug('=======================================>'+ DSIntegratorKey);
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(DSEndpoint +'login_information/?api_password=true');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-DocuSign-Authentication', '<DocuSignCredentials><Username>'+DSUserId+'</Username><Password>'+DSPassword+'</Password><IntegratorKey>'+DSIntegratorKey+'</IntegratorKey></DocuSignCredentials>');                                
            request.setHeader('Accept', 'application/json');    
            request.setTimeout(120000);
            
            system.debug(request.getHeader('X-DocuSign-Authentication'));
            
            HttpResponse myResponse = (new Http()).send(request);
            
            system.debug(myResponse.getBody());
            
            if(myResponse.getStatusCode().format()=='200')
            {       
                response = myResponse.getBody();
                system.debug(response);
            }
        }
        catch(Exception ex)
        {
            system.debug(ex);
        }
        
        return response;
    }
    
    public static string getEnvelopeRecipients(string envelopeID, LoginResponse rLoginResponse) 
    {
        string DSEndpoint='';//baseURL; //'https://demo.docusign.net/restapi/v2/';
        string response = '{}'; 
        string DSUserId = '';
        string DSPassword = '';
    
        try
        {
            List<LoginAccount> myAccounts = rLoginResponse.loginAccounts;
            for (LoginAccount myAccount: myAccounts){
                
                DSEndpoint = myAccount.baseUrl;
                DSUserId = myAccount.userId;
            }
            DSPassword = rLoginResponse.apiPassword;
            system.debug('=======================================>'+DSUserId );
            system.debug('=======================================>'+DSPassword );
            
            DocusignAPI_Users__c dUser = DocusignAPI_Users__c.getValues('Docusign API User');
            string DSIntegratorKey = dUser.IntegratorKey__c;
            system.debug('=======================================>'+ DSIntegratorKey);
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(DSEndpoint +'/envelopes/'+envelopeID+'/recipients');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-DocuSign-Authentication', '<DocuSignCredentials><Username>'+DSUserId+'</Username><Password>'+DSPassword+'</Password><IntegratorKey>'+DSIntegratorKey+'</IntegratorKey></DocuSignCredentials>');                                
            request.setHeader('Accept', 'application/json');    
            request.setTimeout(120000);
            
            system.debug(request.getHeader('X-DocuSign-Authentication'));
            
            HttpResponse myResponse = (new Http()).send(request);
            
            system.debug(myResponse.getBody());
            
            if(myResponse.getStatusCode().format()=='200')
            {       
                response = myResponse.getBody();
                system.debug(response);
            }
        }
        catch(Exception ex)
        {
            system.debug(ex);
        }
        
        return response;
    }
    
    public static string getRecipientTab(string envelopeID, string recipientId, LoginResponse rLoginResponse)
    {
        string response = '{}';
        string DSEndpoint ='';
        string DSUserId='';
        string DSPassword='';
        /*string DSEndpoint = baseURL;   //'https://demo.docusign.net/restapi/v2/';
        string DSUserId = 'f90e0642-0e4a-440e-bce7-a2caa48fde98';
        string DSPassword = '/IbBuG/bzIfvbyJzJnRb3gI82Nk=';
        string DSAccountID = '2aafa2b1-2c3b-46e0-b11c-3162c3ae5681';
        string DSIntegratorKey = 'ADPF-9ea456ac-2ee7-4552-9648-6c43465400cd'; */
        
        
        try
        {
            List<LoginAccount> myAccounts = rLoginResponse.loginAccounts;
            for (LoginAccount myAccount: myAccounts){
                
                DSEndpoint = myAccount.baseUrl;
                DSUserId = myAccount.userId;
            }
            DSPassword = rLoginResponse.apiPassword;
            system.debug('=======================================>'+DSUserId );
            system.debug('=======================================>'+DSPassword );
            
            DocusignAPI_Users__c dUser = DocusignAPI_Users__c.getValues('Docusign API User');
            string DSIntegratorKey = dUser.IntegratorKey__c;
            system.debug('=======================================>'+ DSIntegratorKey);
        
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(DSEndpoint + '/envelopes/'+envelopeID+'/recipients/'+recipientId+'/tabs/');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-DocuSign-Authentication', '<DocuSignCredentials><Username>'+DSUserId+'</Username><Password>'+DSPassword+'</Password><IntegratorKey>'+DSIntegratorKey+'</IntegratorKey></DocuSignCredentials>');                                
            request.setHeader('Accept', 'application/json');    
            request.setTimeout(120000);
            
            system.debug(request.getHeader('X-DocuSign-Authentication'));
            
            HttpResponse myResponse = (new Http()).send(request);
            
            system.debug(myResponse.getBody());
            
            if(myResponse.getStatusCode().format()=='200')
            {       
                response = myResponse.getBody();
                system.debug(response);
            }
        }
        catch(Exception ex) { system.debug(ex); }
        
        return response;
    }
    
    
   
   
    
    public static string modifyTabwithContractNum(string envelopeID, RecipientTabResponse rTabResponse, 
        String addContractNumber, string recipientId, LoginResponse rLoginResponse)
    {
        string response = '{}';
        string DSEndpoint ='';
        string DSUserId='';
        string DSPassword='';
        /*string DSEndpoint = baseURL;   //'https://demo.docusign.net/restapi/v2/';
        string DSUserId = 'f90e0642-0e4a-440e-bce7-a2caa48fde98';
        string DSPassword = '/IbBuG/bzIfvbyJzJnRb3gI82Nk=';
        string DSAccountID = '2aafa2b1-2c3b-46e0-b11c-3162c3ae5681';
        string DSIntegratorKey = 'ADPF-9ea456ac-2ee7-4552-9648-6c43465400cd'; */
        
        try
        {
            
            //DocusignAPI_Users__c dUser = getApiUser();
             List<LoginAccount> myAccounts = rLoginResponse.loginAccounts;
            for (LoginAccount myAccount: myAccounts){
                
                DSEndpoint = myAccount.baseUrl;
                DSUserId = myAccount.userId;
            }
            DSPassword = rLoginResponse.apiPassword;
            system.debug('=======================================>'+DSUserId );
            system.debug('=======================================>'+DSPassword );
            
            DocusignAPI_Users__c dUser = DocusignAPI_Users__c.getValues('Docusign API User');
            string DSIntegratorKey = dUser.IntegratorKey__c;
            system.debug('=======================================>'+ DSIntegratorKey);
            
            List<TextTabs> myTextTabToAdd = new List<TextTabs>();
            List<TextTabs> myTextTabs = rTabResponse.textTabs;
            
            system.debug('------------------myTextTabs----------------' + myTextTabs );
            for(TextTabs myTextTab : myTextTabs)
            {
                if(myTextTab.tabLabel == 'Contract Number(s)_5')
                {
                    myTextTabToAdd.add(myTextTab);
                    system.debug('*****************************1**************************************'+myTextTabToAdd );    
                }
            }
          
            string myBody = '{"textTabs": [';
            for(TextTabs myContractTab : myTextTabToAdd)
            {
                if(myContractTab.tabLabel == 'Contract Number(s)_5')
                {
                    system.debug('---------------myContractTab-------------------'+myContractTab);
                    myBody += '{"tabId": "'+myContractTab.tabId+'","value": "'+addContractNumber+'"},';
                }
            }
            //myBody += myBody2.subString(0,myBody2.length()-1);
            myBody = myBody.removeEnd(',');
            
             myBody += ']}';
            
            
            system.debug('===========================================>'+myBody);
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(DSEndpoint + '/envelopes/'+envelopeID+'/recipients/'+recipientId+'/tabs');
            request.setMethod('PUT');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-DocuSign-Authentication', '<DocuSignCredentials><Username>'+DSUserId+'</Username><Password>'+DSPassword+'</Password><IntegratorKey>'+DSIntegratorKey+'</IntegratorKey></DocuSignCredentials>');                             
            request.setHeader('Accept', 'application/json');    
            request.setTimeout(120000);
            request.setBody(myBody);
            
            system.debug(request.getHeader('X-DocuSign-Authentication'));
            
            
            HttpResponse myResponse = (new Http()).send(request);
            
            system.debug(myResponse.getBody());
            
            if(myResponse.getStatusCode().format()=='201')
            {       
                response = myResponse.getBody();
                system.debug(response);
                
            }
            
        }
        catch(Exception ex) { system.debug(ex); }
        
        return response;
    }
    
    public static string deleteRecipient(string envelopeID, string recipientId, LoginResponse rLoginResponse)
    {
        string response = '{}';
        string DSEndpoint ='';
        string DSUserId='';
        string DSPassword='';
        /*string DSEndpoint = baseURL;   //'https://demo.docusign.net/restapi/v2/';
        string DSUserId = 'f90e0642-0e4a-440e-bce7-a2caa48fde98';
        string DSPassword = '/IbBuG/bzIfvbyJzJnRb3gI82Nk=';
        string DSAccountID = '2aafa2b1-2c3b-46e0-b11c-3162c3ae5681';
        string DSIntegratorKey = 'ADPF-9ea456ac-2ee7-4552-9648-6c43465400cd'; */
        
       
        try
        {
              List<LoginAccount> myAccounts = rLoginResponse.loginAccounts;
            for (LoginAccount myAccount: myAccounts){
                
                DSEndpoint = myAccount.baseUrl;
                DSUserId = myAccount.userId;
            }
            DSPassword = rLoginResponse.apiPassword;
            system.debug('=======================================>'+DSUserId );
            system.debug('=======================================>'+DSPassword );
            
            DocusignAPI_Users__c dUser = DocusignAPI_Users__c.getValues('Docusign API User');
            string DSIntegratorKey = dUser.IntegratorKey__c;
            system.debug('=======================================>'+ DSIntegratorKey);
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(DSEndpoint + '/envelopes/'+envelopeID+'/recipients/'+recipientId);
            request.setMethod('DELETE');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-DocuSign-Authentication', '<DocuSignCredentials><Username>'+DSUserId+'</Username><Password>'+DSPassword+'</Password><IntegratorKey>'+DSIntegratorKey+'</IntegratorKey></DocuSignCredentials>');                             
            request.setHeader('Accept', 'application/json');    
            request.setTimeout(120000);
            
            system.debug(request.getHeader('X-DocuSign-Authentication'));
            
            HttpResponse myResponse = (new Http()).send(request);
            
            system.debug(myResponse.getBody());
            
            if(myResponse.getStatusCode().format()=='200')
            {       
                response = myResponse.getBody();
                system.debug(response);
            }
        }
        catch(Exception ex) { system.debug(ex); }
        
        return response;
    } 
    
     public static string setRecipientsNewCAandBU2(string envelopeID, RecipientResponse rResponse, LoginResponse rLoginResponse)
    {
        string response = '{}';
        string DSEndpoint ='';
        string DSUserId='';
        string DSPassword='';
        
        /*string DSUserId = 'venkata.shrivol@cdk.com';//'f90e0642-0e4a-440e-bce7-a2caa48fde98';
        string DSPassword = 'samrat18';//'/IbBuG/bzIfvbyJzJnRb3gI82Nk=';
        string DSAccountID = '2aafa2b1-2c3b-46e0-b11c-3162c3ae5681';
        string DSIntegratorKey = 'ADPF-9ea456ac-2ee7-4552-9648-6c43465400cd'; 
        string DSEndpoint = 'https://demo.docusign.net/restapi/v2/accounts/'+DSAccountID+'';//baseURL;   //'https://demo.docusign.net/restapi/v2/';*/
        
        try
        {
             List<LoginAccount> myAccounts = rLoginResponse.loginAccounts;
            for (LoginAccount myAccount: myAccounts){
                
                DSEndpoint = myAccount.baseUrl;
                DSUserId = myAccount.userId;
            }
            DSPassword = rLoginResponse.apiPassword;
            system.debug('=======================================>'+DSUserId );
            system.debug('=======================================>'+DSPassword );
            
            DocusignAPI_Users__c dUser = DocusignAPI_Users__c.getValues('Docusign API User');
            string DSIntegratorKey = dUser.IntegratorKey__c;
            system.debug('=======================================>'+ DSIntegratorKey);
            
            Signer mySignerToAdd = new Signer();
            
            List<Signer> mySigners = rResponse.signers;
            for(Signer mySigner : mySigners)
            {
                if(mySigner.roleName == 'Signer4') // Signer4 is CA in DocuSign config
                {
                    mySignerToAdd = mySigner;
                }
                 
            }
            system.debug('-------------------CA-----mySignerToAdd------------------------------'+mySignerToAdd);
            String myBody;
            myBody = '{"signers": [{"signInEachLocation": "false","name": "'+mySignerToAdd.name +' Check","email": "'+mySignerToAdd.email+'","recipientId": "8","requireIdLookup": "false","routingOrder": "16","roleName": "'+mySignerToAdd.roleName+'Added1"}, {"signInEachLocation": "false","name": "BlockingUser2","email": "noreply@cdk.com","recipientId": "9","requireIdLookup": "false","routingOrder": "17","roleName": "Signer9"}]}';
            
            //myBody = '{"signers": [{"signInEachLocation": "false","name": "Check","email": "venkata.shrivol@cdk.com","recipientId": "8","requireIdLookup": "false","routingOrder": "16","roleName": "Added1"}]}';
            HttpRequest request = new HttpRequest();
            request.setEndpoint(DSEndpoint + '/envelopes/'+envelopeID+'/recipients/');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-DocuSign-Authentication', '<DocuSignCredentials><Username>'+DSUserId+'</Username><Password>'+DSPassword+'</Password><IntegratorKey>'+DSIntegratorKey+'</IntegratorKey></DocuSignCredentials>');                             
            request.setHeader('Accept', 'application/json');    
            request.setTimeout(120000);
            request.setBody(myBody);
            
            system.debug(request.getHeader('X-DocuSign-Authentication'));
            
            HttpResponse myResponse = (new Http()).send(request);
            
            system.debug(myResponse.getBody());
            
            if(myResponse.getStatusCode().format()=='201')
            {       
                response = myResponse.getBody();
                //system.debug(response);
            }
        }
        catch(Exception ex) { system.debug(ex); }
        
        return response;
    }
    
    /*public static string setBlockingUser2(string envelopeID, string soboUser, LoginResponse rLoginResponse)
    {
        string response = '{}';
        string DSEndpoint ='';
        string DSUserId='';
        string DSPassword='';
        /*string DSEndpoint = baseURL;   //'https://demo.docusign.net/restapi/v2/';
        string DSUserId = 'f90e0642-0e4a-440e-bce7-a2caa48fde98';
        string DSPassword = '/IbBuG/bzIfvbyJzJnRb3gI82Nk=';
        string DSAccountID = '2aafa2b1-2c3b-46e0-b11c-3162c3ae5681';
        string DSIntegratorKey = 'ADPF-9ea456ac-2ee7-4552-9648-6c43465400cd'; 
        
        try
        {
            List<LoginAccount> myAccounts = rLoginResponse.loginAccounts;
            for (LoginAccount myAccount: myAccounts){
                
                DSEndpoint = myAccount.baseUrl;
                DSUserId = myAccount.userId;
            }
            DSPassword = rLoginResponse.apiPassword;
            system.debug('=======================================>'+DSUserId );
            system.debug('=======================================>'+DSPassword );
            
            DocusignAPI_Users__c dUser = DocusignAPI_Users__c.getValues('Docusign API User');
            string DSIntegratorKey = dUser.IntegratorKey__c;
            system.debug('=======================================>'+ DSIntegratorKey);
            
            String myBody;
            myBody = '{"signers": [{"signInEachLocation": "false","name": "BlockingUser2","email": "dstestdocusign@gmail.com","recipientId": "9","requireIdLookup": "false","routingOrder": "17","roleName": "Signer9"}]}';
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(DSEndpoint + '/envelopes/'+envelopeID+'/recipients/');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-DocuSign-Authentication', '<DocuSignCredentials><Username>'+DSUserId+'</Username><Password>'+DSPassword+'</Password><SendOnBehalfOf>'+soboUser+'</SendOnBehalfOf><IntegratorKey>'+DSIntegratorKey+'</IntegratorKey></DocuSignCredentials>');                             
            request.setHeader('Accept', 'application/json');    
            request.setTimeout(120000);
            request.setBody(myBody);
            
            system.debug(request.getHeader('X-DocuSign-Authentication'));
            
            HttpResponse myResponse = (new Http()).send(request);
            
            system.debug(myResponse.getBody());
            
            if(myResponse.getStatusCode().format()=='201')
            {       
                response = myResponse.getBody();
                system.debug(response);
            }
        }
        catch(Exception ex) { system.debug(ex); }
        
        return response;
    } */
    
    public class RecipientTabResponse 
    {
        public List<TextTabs> textTabs;
        //public List<SignHereTabs> signHereTabs; 
        //public List<DateSignedTabs> dateSignedTabs;
        //public List<FullNameTabs> fullNameTabs;
        /*

        {
            "textTabs": [
                
                    {
                      "mergeFieldXml": "<mergefieldconfig configversion=\"1.0\" service=\"salesforce\"><mergefield><writeenabled>false</writeenabled>
                                        <sendercanedit>false</sendercanedit><queryfrom><obj><type>Deal_State__c</type><name>Deal_State__c</name>
                                        <field><fieldtype>textarea</fieldtype><name>Contract_Number_s__c</name></field><id>a45M0000000ElBzIAK</id>
                                        </obj></queryfrom></mergefield></mergefieldconfig>",
                      "name": "Contract Number(s)",
                      "value": "",
                      "required": "false",
                      "locked": "true",
                      "concealValueOnDocument": "false",
                      "disableAutoSize": "false",
                      "tabLabel": "Contract Number(s)_5",
                      "documentId": "1",
                      "recipientId": "5",
                      "pageNumber": "19",
                      "xPosition": "200",
                      "yPosition": "74",
                      "tabId": "e159cee2-f7e9-4115-ad57-e82dd666a15d"
                    }
             ]
        }

        */
    }
    
    public static RecipientResponse parseRecipentResponse(String json) {
        return (RecipientResponse) System.JSON.deserialize(json, RecipientResponse.class);
    }
    
    public static RecipientTabResponse parseRecipientTabResponse(String json) {
        return (RecipientTabResponse) System.JSON.deserialize(json, RecipientTabResponse.class);
    }
    
    public static LoginResponse parseLoginResponse(String json) {
        return (LoginResponse) System.JSON.deserialize(json, LoginResponse.class);
    }
    
    // JSON wrapper classes to deserialize into (see above methods)
    public class Signer
    {
        public string name;
        public string email;
        public string recipientId;
        public string recipientIdGuid;
        public string requireIdLookup;
        public string userId;
        public string routingOrder;
        public string roleName;
        public string status;
        public string signedDateTime;
        public string deliveredDateTime;
        public string templateLocked;
        public string templateRequired;
    }
    
    public class RecipientResponse
    {
        public List<Signer> signers;
        public List<Signer> agents;
        public List<Signer> editors;
        public List<Signer> intermediaries;
        public List<Signer> carbonCopies;
        public List<Signer> certifiedDeliveries;
        public List<Signer> inPersonSigners;
        public String recipientCount;
        public String currentRoutingOrder;
        
     
    }
    
    public class LoginAccount
    {
        public string name;
        public string accountId;
        public string baseUrl;
        public string isDefault;
        public string userName;
        public string userId;
        public string email;
    }
    
    public class LoginResponse
    {
        public List<LoginAccount> loginAccounts; 
        public String apiPassword;
    }
    
    public class TextTabs {
        public Integer height;
        public String validationPattern;
        public String validationMessage;
        public String shared;
        public String requireInitialOnSharedChange;
        public String name;
        public String value;
        public Integer width;
        public String required;
        public String locked;
        public String concealValueOnDocument;
        public String disableAutoSize;
        public String tabLabel;
        public String documentId;
        public String recipientId;
        public String pageNumber;
        public String xPosition;
        public String yPosition;
        public String tabId;
    }
    
    
}