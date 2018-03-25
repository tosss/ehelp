@isTest
private class DS_CallDocusignAPIHandler_Test
 {
 	static list<Deal_State__c> dsList;
 	static Deal_State__c dealState1;
 	static Deal_State__c dealState2;
 	static Deal_State__c dealState3;
 	
 	static void automaticUpdateTest()
 	{
 		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        
        /*****************For Automatic update process***************/
        multimock.setStaticResource('https://demo.docusign.net/restapi/v2/login_information/?api_password=true','DS_DocusignloginInfoTest_JSON');
        multimock.setStaticResource('https://demo.docusign.net/restapi/v2/accounts/657858/envelopes/ed43d798-9c1e-47e0-9d30-162aec79a079/recipients','DS_DocusignRecipientsTest_JSON'); 
        multimock.setStaticResource('https://demo.docusign.net/restapi/v2/accounts/657858/envelopes/ed43d798-9c1e-47e0-9d30-162aec79a079/recipients/5/tabs/','DS_DocusignRecipientTabsTest_JSON');  
        multimock.setStaticResource('https://demo.docusign.net/restapi/v2/accounts/657858/envelopes/ed43d798-9c1e-47e0-9d30-162aec79a079/recipients/5/tabs','DS_DocusignAddNewTabTest_JSON');
        multimock.setStaticResource('https://demo.docusign.net/restapi/v2/accounts/657858/envelopes/ed43d798-9c1e-47e0-9d30-162aec79a079/recipients/7','DS_DocusignDelRecipientTest_JSON');
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, multimock);
        
 	}
	
	static void addRecipientTest()
	{
 		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        
         /*****************For Adding Recipients**********************/
        multimock.setStaticResource('https://demo.docusign.net/restapi/v2/login_information/?api_password=true','DS_DocusignloginInfoTest_JSON');
        //multimock.setStaticResource('https://demo.docusign.net/restapi/v2/accounts/657858/envelopes/ed43d798-9c1e-47e0-9d30-162aec79a079/recipients','DS_DocusignRecipientsTest_JSON');
        //multimock.setStaticResource('https://demo.docusign.net/restapi/v2/accounts/657858/envelopes/ed43d798-9c1e-47e0-9d30-162aec79a079/recipients','DS_DocusignAddNewCATest_JSON');
        multimock.setStaticResource('https://demo.docusign.net/restapi/v2/accounts/657858/envelopes/ed43d798-9c1e-47e0-9d30-162aec79a079/recipients','DS_DocusignAddB2RecipientTest_JSON');
        multimock.setStaticResource('https://demo.docusign.net/restapi/v2/accounts/657858/envelopes/ed43d798-9c1e-47e0-9d30-162aec79a079/recipients/7','DS_DocusignDelRecipientTest_JSON');
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, multimock);
        
 	}
	
	static void manualUpdateTest()
	{
 		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        
        /****************For Manual Update Process******************/
        multimock.setStaticResource('https://demo.docusign.net/restapi/v2/login_information/?api_password=true','DS_DocusignloginInfoTest_JSON');
        multimock.setStaticResource('https://demo.docusign.net/restapi/v2/accounts/657858/envelopes/ed43d798-9c1e-47e0-9d30-162aec79a079/recipients','DS_DocusignRecipientsTest_JSON');
        //multimock.setStaticResource('https://demo.docusign.net/restapi/v2/accounts/657858/envelopes/ed43d798-9c1e-47e0-9d30-162aec79a079/recipients','DS_DocusignAddNewRecipientTest_JSON');
        multimock.setStaticResource('https://demo.docusign.net/restapi/v2/accounts/657858/envelopes/ed43d798-9c1e-47e0-9d30-162aec79a079/recipients/5/tabs','DS_DocusignAddNewTabTest_JSON');
        multimock.setStaticResource('https://demo.docusign.net/restapi/v2/accounts/657858/envelopes/ed43d798-9c1e-47e0-9d30-162aec79a079/recipients/8','DS_DocusignDelRecipientTest_JSON');
        multimock.setStaticResource('https://demo.docusign.net/restapi/v2/accounts/657858/envelopes/ed43d798-9c1e-47e0-9d30-162aec79a079/recipients/9','DS_DocusignDelRecipientTest_JSON');
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, multimock);
        
 	}
	static void prepareTestData()
	
	{
		dealState1 = new Deal_State__c();
        dealState1.Contract_Number_s__c = '12345';
        insert dealState1;
        
        dsfs__DocuSign_Status__c docuSign = new dsfs__DocuSign_Status__c();
        docuSign.Deal_State__c = dealState1.id;
        docuSign.dsfs__DocuSign_Envelope_ID__c = 'ed43d798-9c1e-47e0-9d30-162aec79a079';
        insert docuSign;
        
        list<Docusign_Recipient__c> dRecLst = new list<Docusign_Recipient__c>();
        Docusign_Recipient__c testRecipient = new Docusign_Recipient__c();
        testRecipient.Name = 'Legal Counter Signer';
        testRecipient.Signer_Role__c = 'Signer5';
        dRecLst.add(testRecipient);
        
        Docusign_Recipient__c testRecipient2 = new Docusign_Recipient__c();
        testRecipient2.Name = 'BlockingUser';
        testRecipient2.Signer_Role__c = 'Signer7';
        dRecLst.add(testRecipient2);
        insert dRecLst;
        
        Map<String, Docusign_Recipient__c> docusignRecipientMap = Docusign_Recipient__c.getAll();
        
        
        dealState2 = new Deal_State__c();
        dealState2.Main_Site_Zip__c = '100020';
        insert dealState2;
        
        dsfs__DocuSign_Status__c docuSign2 = new dsfs__DocuSign_Status__c();
        docuSign2.Deal_State__c = dealState2.id;
        docuSign2.dsfs__DocuSign_Envelope_ID__c = 'ed43d798-9c1e-47e0-9d30-162aec79a079';
        insert docuSign2;
        
        
        dealState3 = new Deal_State__c();
        dealState3.Contract_Number_s__c = '089080';
        dealState3.Exception_Contract_Push__c = 'CA';
        insert dealState3;
        
        dsfs__DocuSign_Status__c docuSign3 = new dsfs__DocuSign_Status__c();
        docuSign3.Deal_State__c = dealState3.id;
        docuSign3.dsfs__DocuSign_Envelope_ID__c = 'ed43d798-9c1e-47e0-9d30-162aec79a079';
        insert docuSign3;
        
        
        DocusignAPI_Users__c docuUser = new DocusignAPI_Users__c();
        docuUser.Name = 'Docusign API User';
        docuUser.AccountId__c = '2aafa2b1-2c3b-46e0-b11c-3162c3ae5681';
        docuUser.IntegratorKey__c = 'ADPF-9ea456ac-2ee7-4552-9648-6c43465400cd';
        docuUser.Password__c = 'docusign123';
        docuUser.UserId__c ='642d72a0-6134-49aa-997e-4f13c57c4e04';
        insert docuUser;
        
        CustomSettings__c customSettings = new CustomSettings__c();
		customSettings.DocusignBaseURL__c = 'https://demo.docusign.net/restapi/v2/';
		insert customSettings;
	
	}
    
    static testMethod void testHttpCallout1() 
    {
        automaticUpdateTest();
        prepareTestData();
        dsList = new list<Deal_State__c>();
        dsList.add(dealState1); 
        dsList.add(dealState3);
        
        Test.startTest();
        DS_CallDocusignAPI_Handler dsdocusignapi = new DS_CallDocusignAPI_Handler();
        DS_CallDocusignAPI_Handler.TextTabs dst = new DS_CallDocusignAPI_Handler.TextTabs();
        DS_CallDocusignAPI_Handler.prepareForUpdate(dsList); 
        
       Test.stopTest();
    }
	 static testMethod void testHttpCallout2() 
    {
        addRecipientTest();
        prepareTestData();
        dsList = new list<Deal_State__c>();
        dsList.add(dealState2);
        dsList.add(dealState3);
        
        Test.startTest();
        DS_CallDocusignAPI_Handler dsdocusignapi = new DS_CallDocusignAPI_Handler();
        DS_CallDocusignAPI_Handler.TextTabs dst = new DS_CallDocusignAPI_Handler.TextTabs();
        DS_CallDocusignAPI_Handler.LoginAccount dsl = new DS_CallDocusignAPI_Handler.LoginAccount();
        DS_CallDocusignAPI_Handler.prepareForUpdate(dsList); 
        
        Test.stopTest();
    }
     static testMethod void testHttpCallout3() 
    {
        manualUpdateTest();
        prepareTestData();
        dsList = new list<Deal_State__c>();
        dsList.add(dealState3);
        
        Test.startTest();
        DS_CallDocusignAPI_Handler dsdocusignapi = new DS_CallDocusignAPI_Handler();
        DS_CallDocusignAPI_Handler.TextTabs dst = new DS_CallDocusignAPI_Handler.TextTabs();
        DS_CallDocusignAPI_Handler.prepareForUpdate(dsList); 
        
        Test.stopTest();
    }
	
}