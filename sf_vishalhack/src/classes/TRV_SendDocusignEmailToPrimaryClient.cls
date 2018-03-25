//2017-01-16	vishal.bandari@cdk.com	RQ-08242-changed the subject of Email
//2017-05-02	lalitha.adduru@cdk.com	subject and blurb needs to be in french if french docusign needed is checked. - RQ-08667
global class TRV_SendDocusignEmailToPrimaryClient {
    
    webservice static void sendEmail(Id b4bCoachingId) {
        
        Traver_Coaching__c objTC;
        
		//2017-05-02	lalitha.adduru@cdk.com	added French_DocuSign_Needed__c to be retrieved - RQ-08667
        List<Traver_Coaching__c> lstTC = new List<Traver_Coaching__c>([ SELECT Id, Name, Visit_Start_Date__c, TRV_FRM_Resource_Name_onResource__c, 
                                                                       Delivery_Location__c, TRV_Completed_By__c, Primary_Client_Contacts__c, 
                                                                       Primary_Client_Email__c, Traver_Project__r.French_DocuSign_Needed__c  
                                                                        FROM Traver_Coaching__c 
                                                                        WHERE id=:b4bCoachingId
                                                                    ]);
        if(lstTC.isEmpty()) {
            
           return; 
        }
        else {
            
            objTC = lstTC[0];
            
            if(objTC.Primary_Client_Email__c == null || objTC.Primary_Client_Email__c == '') {
                
                return;
            }
        }
        
        //String webServiceUrl = 'https://demo.docusign.net/api/3.0/dsapi.asmx';
        
        List<DocusignAPI_Users__c> lstDocusignCredentials = DocusignAPI_Users__c.getAll().values();  
        
        if(lstDocusignCredentials.isEmpty()) {
            
            return;
        }
        
        DocusignAPI_Users__c objCredentials = lstDocusignCredentials.get(0);
        
        String accountId = objCredentials.AccountId__c;
        String userId = objCredentials.UserId__c;
        String password = objCredentials.Password__c;
        String integratorsKey = objCredentials.Second_Integrator_Key__c;
        String webServiceUrl = objCredentials.WebServiceUrl__c;
        
        TRV_CallDocusignAPI_Handler.APIServiceSoap dsApiSend = new TRV_CallDocusignAPI_Handler.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;

        //Set Authentication
        String auth = '<DocuSignCredentials><Username>'+ userId 
                    + '</Username><Password>' + password 
                    + '</Password><IntegratorKey>' + integratorsKey 
                    + '</IntegratorKey></DocuSignCredentials>';
            
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', auth);
 
        TRV_CallDocusignAPI_Handler.Envelope envelope = new TRV_CallDocusignAPI_Handler.Envelope();
        
        //2017-01-16   vishal.bandari@cdk.com    RQ-08242-changed the subject of Email
        //2017-05-02  lalitha.adduru@cdk.com subject needs to be in french if french docusign needed is checked. - RQ-08667
        envelope.Subject = objTC.Traver_Project__r.French_Docusign_Needed__c == true ? 'Demande de confirmation de votre prochaine visite de Consultation CDK':
        'Confirmation request for your upcoming CDK Consulting visit';
        
        //2017-05-02  lalitha.adduru@cdk.com blurb needs to be in french if french docusign needed is checked. - RQ-08667
        envelope.EmailBlurb = objTC.Traver_Project__r.French_Docusign_Needed__c == true ? 'Veuillez signer cette confirmation de visite.':
        'Please sign this B4B Coaching';
        envelope.AccountId  = accountId; 

        // Render the contract
        PageReference pageRef = new PageReference('/apex/TRV_RenderB4BCoachingAsPdf');
        pageRef.getParameters().put('id',objTC.Id);
        Blob pdfBlob;
        
        if (Test.IsRunningTest()) {
            
            pdfBlob = Blob.valueOf('UNIT.TEST');
        }
        else {
            
            pdfBlob = pageRef.getContent();
        }

        // Document
        TRV_CallDocusignAPI_Handler.Document document = new TRV_CallDocusignAPI_Handler.Document();
        document.ID = 1;
        document.pdfBytes = EncodingUtil.base64Encode(pdfBlob);
        document.Name = 'B4B Coaching';
        document.FileExtension = 'pdf';
        envelope.Documents = new TRV_CallDocusignAPI_Handler.ArrayOfDocument();
        envelope.Documents.Document = new TRV_CallDocusignAPI_Handler.Document[1];
        envelope.Documents.Document[0] = document;
        
        TRV_CallDocusignAPI_Handler.CustomField field = new TRV_CallDocusignAPI_Handler.CustomField(); 
        field.Name = 'DSFSSourceObjectId';//##SFTraver_Coaching__c'; //'DSFSSourceObjectId'; 
        field.Value = objTC.Id;   //value of your external source Id
        field.Show = 'false';
        TRV_CallDocusignAPI_Handler.ArrayOfCustomField arrayOfCustomField = new TRV_CallDocusignAPI_Handler.ArrayOfCustomField();
        arrayOfCustomField.CustomField  = new TRV_CallDocusignAPI_Handler.CustomField[1];
        arrayOfCustomField.CustomField[0] = field;
       
        envelope.CustomFields = arrayOfCustomField;
        // Recipient
        
        TRV_CallDocusignAPI_Handler.Recipient recipient = new TRV_CallDocusignAPI_Handler.Recipient();
        recipient.ID = 1;
        recipient.Type_x = 'Signer';
        recipient.RoutingOrder = 1;
        recipient.Email = objTC.Primary_Client_Email__c;//lstuser[0].Email;
        recipient.UserName = objTC.Primary_Client_Contacts__c;//lstuser[0].Name;
            
        // This setting seems required or you see the error:
        // "The string '' is not a valid Boolean value. 
        // at System.Xml.XmlConvert.ToBoolean(String s)" 
        recipient.RequireIDLookup = false;      
        
        envelope.Recipients = new TRV_CallDocusignAPI_Handler.ArrayOfRecipient();
        envelope.Recipients.Recipient = new TRV_CallDocusignAPI_Handler.Recipient[1];
        envelope.Recipients.Recipient[0] = recipient;
        
        // Tab
        TRV_CallDocusignAPI_Handler.Tab tab1 = new TRV_CallDocusignAPI_Handler.Tab();
        tab1.Type_x = 'SignHere';
        tab1.RecipientID = 1;
        tab1.DocumentID = 1;
        tab1.AnchorTabItem = new TRV_CallDocusignAPI_Handler.AnchorTab();
        tab1.AnchorTabItem.AnchorTabString = 'By :';
        tab1.AnchorTabItem.XOffset = 40;
        
        TRV_CallDocusignAPI_Handler.Tab tab2 = new TRV_CallDocusignAPI_Handler.Tab();
        tab2.Type_x = 'DateSigned';
        tab2.RecipientID = 1;
        tab2.DocumentID = 1;
        tab2.AnchorTabItem = new TRV_CallDocusignAPI_Handler.AnchorTab();
        tab2.AnchorTabItem.AnchorTabString = 'Date Signed :';
        tab2.AnchorTabItem.XOffset = 90;
        
        envelope.Tabs = new TRV_CallDocusignAPI_Handler.ArrayOfTab();
        envelope.Tabs.Tab = new TRV_CallDocusignAPI_Handler.Tab[2];
        envelope.Tabs.Tab[0] = tab1;        
        envelope.Tabs.Tab[1] = tab2;        
        
        try {
            
            //if(!Test.isRunningTest()) {
                
                TRV_CallDocusignAPI_Handler.EnvelopeStatus es = dsApiSend.CreateAndSendEnvelope(envelope);
            //}
            
        } catch (CalloutException errorMsg) {
            
            System.debug('Exception - ' + errorMsg.getMessage());
        }
    }
}