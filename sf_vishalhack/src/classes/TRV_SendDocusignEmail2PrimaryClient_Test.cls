@isTest(seeAllData = false)
private class TRV_SendDocusignEmail2PrimaryClient_Test {

    private static testMethod void test() {
        
        Test.setMock(WebServiceMock.class, new TRV_WebserviceMockImplementation_Test());
        TRV_CallDocusignAPI_Handler.APIServiceSoap dsApiSend = new TRV_CallDocusignAPI_Handler.APIServiceSoap();
        
        dsApiSend.SendEnvelope('', '');
        dsApiSend.CreateEnvelopeFromTemplates(new TRV_CallDocusignAPI_Handler.ArrayOfTemplateReference(), new TRV_CallDocusignAPI_Handler.ArrayOfRecipient1(), new TRV_CallDocusignAPI_Handler.EnvelopeInformation(), false);
        dsApiSend.RequestSenderToken('', '', '');
        dsApiSend.RequestRecipientToken('', '', '', '', new TRV_CallDocusignAPI_Handler.RequestRecipientTokenAuthenticationAssertion(), new TRV_CallDocusignAPI_Handler.RequestRecipientTokenClientURLs());
        dsApiSend.CreateAndSendEnvelope(new TRV_CallDocusignAPI_Handler.Envelope());
        dsApiSend.CreateEnvelope(new TRV_CallDocusignAPI_Handler.Envelope());
        dsApiSend.CreateEnvelopeFromTemplatesAndForms(new TRV_CallDocusignAPI_Handler.EnvelopeInformation(), new TRV_CallDocusignAPI_Handler.ArrayOfCompositeTemplate(), false);
        
        Id processCoachVisitId;
        
        List<RecordType> lstRecordType = new List<RecordType>([     SELECT Id, DeveloperName, SobjectType 
                                                                    FROM RecordType 
                                                                    WHERE SobjectType = 'Traver_Coaching__c'
                                                                    AND RecordType.DeveloperName = 'Process_Coach_Visit'
                                                                ]);
                                        
        if(!lstRecordType.isEmpty()) {
            
            processCoachVisitId = lstRecordType[0].Id;
        }
        
        Account objAccount = new Account(   Name = 'Test Account', 
                                            BillingStreet = 'Test Street', 
                                            BillingCity = 'Test City', 
                                            BillingState = 'Test State', 
                                            BillingPostalCode = '123456'
                                        );
        insert objAccount;
        
        Contact objContact = new Contact(   LastName = 'Test Last Contact', 
                                            FirstName = 'Test First Contact', 
                                            Email = 'test@test.com', 
                                            AccountId = objAccount.Id
                                        );
        insert objContact;
        
        Traver_Project__c objTraverProject = new Traver_Project__c(    Account__c = objAccount.Id,
                                                                        Contact__c = objContact.Id
                                                                    );
        insert objTraverProject;
        
        Traver_Coaching__c objTraverCoach = new Traver_Coaching__c(     Status__c = 'Tentative', 
                                                                        Traver_Project__c = objTraverProject.Id,
                                                                        Number_of_Days_Traver__c = 18,
                                                                        RecordTypeId = processCoachVisitId,
                                                                        Primary_Client_Contacts__c = 'Test Contact',
                                                                        Primary_Client_Email__c = 'test@test.com',
                                                                        Delivery_Location__c = objAccount.Id
                                                                    );
        insert objTraverCoach;
        
        DocusignAPI_Users__c objAPIUser = new DocusignAPI_Users__c(     Name = 'Docusign User',
                                                                        AccountId__c = '58303522-4926-45ab-b89e-c0749e3f51bd',
                                                                        Second_Integrator_Key__c = '0c8537cf-dc2b-4c71-a33f-0c953c8f9ce6',
                                                                        Password__c = 'password',
                                                                        UserId__c = '6f40dd7a-ff76-4d8c-9608-fa576a4f2522',
                                                                        WebServiceUrl__c = 'https://demo.docusign.net/api/3.0/dsapi.asmx'
                                                                );
        insert objAPIUser;
        
        TRV_RenderB4BCoachingAsPDF_Controller objController = new TRV_RenderB4BCoachingAsPDF_Controller(new ApexPages.StandardController(objTraverCoach));
        TRV_SendDocusignEmailToPrimaryClient.sendEmail(objTraverCoach.Id);
        
        TRV_CallDocusignAPI_Handler.Expirations objExpirations = new TRV_CallDocusignAPI_Handler.Expirations();
        TRV_CallDocusignAPI_Handler.VaultingOptions objVaultingOptions = new TRV_CallDocusignAPI_Handler.VaultingOptions();
        TRV_CallDocusignAPI_Handler.RecipientStatusEsignAgreementInformation objRecipientStatusEsignAgreementInformation = new TRV_CallDocusignAPI_Handler.RecipientStatusEsignAgreementInformation();
        TRV_CallDocusignAPI_Handler.VaultingDetails objVaultingDetails = new TRV_CallDocusignAPI_Handler.VaultingDetails();
        TRV_CallDocusignAPI_Handler.RecipientPhoneAuthentication objRecipientPhoneAuthentication = new TRV_CallDocusignAPI_Handler.RecipientPhoneAuthentication();
        TRV_CallDocusignAPI_Handler.ArrayOfInlineTemplate objArrayOfInlineTemplate = new TRV_CallDocusignAPI_Handler.ArrayOfInlineTemplate();
        TRV_CallDocusignAPI_Handler.PDFMetaDataTemplate objPDFMetaDataTemplate = new TRV_CallDocusignAPI_Handler.PDFMetaDataTemplate();
        TRV_CallDocusignAPI_Handler.FormData objFormDataXfdfField = new TRV_CallDocusignAPI_Handler.FormData();
        TRV_CallDocusignAPI_Handler.AuthenticationStatus objAuthenticationStatus = new TRV_CallDocusignAPI_Handler.AuthenticationStatus();
        TRV_CallDocusignAPI_Handler.AnchorTab objAnchorTab = new TRV_CallDocusignAPI_Handler.AnchorTab();
        TRV_CallDocusignAPI_Handler.ArrayOfDocumentStatus objDocumentStatus = new TRV_CallDocusignAPI_Handler.ArrayOfDocumentStatus();
        TRV_CallDocusignAPI_Handler.DOBInformationInput objDOBInformation = new TRV_CallDocusignAPI_Handler.DOBInformationInput();
        TRV_CallDocusignAPI_Handler.CompositeTemplate objCompositeTemplate = new TRV_CallDocusignAPI_Handler.CompositeTemplate();
        TRV_CallDocusignAPI_Handler.TemplateReference objTemplateReference = new TRV_CallDocusignAPI_Handler.TemplateReference();
        TRV_CallDocusignAPI_Handler.TemplateReferenceFieldData objTemplateReferenceFieldData = new TRV_CallDocusignAPI_Handler.TemplateReferenceFieldData();
        TRV_CallDocusignAPI_Handler.ArrayOfMatchBox objMatchBox = new TRV_CallDocusignAPI_Handler.ArrayOfMatchBox();
        TRV_CallDocusignAPI_Handler.TabStatus objTabStatus = new TRV_CallDocusignAPI_Handler.TabStatus();
        TRV_CallDocusignAPI_Handler.IDCheckInformationInput objIDCheckInformationInput = new TRV_CallDocusignAPI_Handler.IDCheckInformationInput();
        TRV_CallDocusignAPI_Handler.ArrayOfServerTemplate objArrayOfServerTemplate = new TRV_CallDocusignAPI_Handler.ArrayOfServerTemplate();
        TRV_CallDocusignAPI_Handler.SSN9InformationInput objSSN9InformationInput = new TRV_CallDocusignAPI_Handler.SSN9InformationInput();
        TRV_CallDocusignAPI_Handler.Notification objNotification = new TRV_CallDocusignAPI_Handler.Notification();
        TRV_CallDocusignAPI_Handler.ArrayOfAttachment objArrayOfAttachment = new TRV_CallDocusignAPI_Handler.ArrayOfAttachment();
        TRV_CallDocusignAPI_Handler.ArrayOfTemplateReferenceRoleAssignment objArrayOfTemplateReferenceRoleAssignment = new TRV_CallDocusignAPI_Handler.ArrayOfTemplateReferenceRoleAssignment   ();
        TRV_CallDocusignAPI_Handler.ArrayOfTabStatus objArrayOfTabStatus = new TRV_CallDocusignAPI_Handler.ArrayOfTabStatus();
        TRV_CallDocusignAPI_Handler.AddressInformationInput objAddressInformation = new TRV_CallDocusignAPI_Handler.AddressInformationInput();
        TRV_CallDocusignAPI_Handler.SSN4InformationInput objSSN4InformationInput = new TRV_CallDocusignAPI_Handler.SSN4InformationInput();
        TRV_CallDocusignAPI_Handler.ArrayOfTemplateReferenceFieldDataDataValue objArrayOfTemplateReferenceFieldDataDataValue = new TRV_CallDocusignAPI_Handler.ArrayOfTemplateReferenceFieldDataDataValue();
        TRV_CallDocusignAPI_Handler.EventNotification objEventNotification = new TRV_CallDocusignAPI_Handler.EventNotification();
        TRV_CallDocusignAPI_Handler.Attachment objAttachment = new TRV_CallDocusignAPI_Handler.Attachment();
        TRV_CallDocusignAPI_Handler.ArrayOfRecipientStatus objArrayOfRecipientStatus = new TRV_CallDocusignAPI_Handler.ArrayOfRecipientStatus();
        TRV_CallDocusignAPI_Handler.EnvelopeEvent objEnvelopeEvent = new TRV_CallDocusignAPI_Handler.EnvelopeEvent();
        TRV_CallDocusignAPI_Handler.RecipientCaptiveInfo objRecipientCaptiveInfo = new TRV_CallDocusignAPI_Handler.RecipientCaptiveInfo();
        TRV_CallDocusignAPI_Handler.TemplateReferenceFieldDataDataValue objTemplateReferenceFieldDataDataValue = new TRV_CallDocusignAPI_Handler.TemplateReferenceFieldDataDataValue();
        TRV_CallDocusignAPI_Handler.IDCheckInformation objIDCheckInformation = new TRV_CallDocusignAPI_Handler.IDCheckInformation();
        TRV_CallDocusignAPI_Handler.RecipientStatus objRecipientStatus = new TRV_CallDocusignAPI_Handler.RecipientStatus();
        TRV_CallDocusignAPI_Handler.Reminders objReminders = new TRV_CallDocusignAPI_Handler.Reminders();
        TRV_CallDocusignAPI_Handler.ServerTemplate objServerTemplate = new TRV_CallDocusignAPI_Handler.ServerTemplate();
        TRV_CallDocusignAPI_Handler.RequestRecipientFaxToken_element objRequestRecipientFaxToken_element = new TRV_CallDocusignAPI_Handler.RequestRecipientFaxToken_element();
        TRV_CallDocusignAPI_Handler.ArrayOfString1 objArrayOfString1 = new TRV_CallDocusignAPI_Handler.ArrayOfString1();
        TRV_CallDocusignAPI_Handler.RecipientSignatureInfo objRecipientSignatureInfo = new TRV_CallDocusignAPI_Handler.RecipientSignatureInfo();
        
    }
}