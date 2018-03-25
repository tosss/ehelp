@isTest
global class TRV_WebserviceMockImplementation_Test implements WebServiceMock {

    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        
        if(requestName == 'SendEnvelope') {
            
            TRV_CallDocusignAPI_Handler.SendEnvelopeResponse_element objSendEnvelopeResponse_element = new TRV_CallDocusignAPI_Handler.SendEnvelopeResponse_element();
            objSendEnvelopeResponse_element.SendEnvelopeResult = new TRV_CallDocusignAPI_Handler.EnvelopeStatus();
            response.put('response_x', objSendEnvelopeResponse_element);
        }
        
        if(requestName == 'CreateEnvelopeFromTemplates') {
            
            TRV_CallDocusignAPI_Handler.CreateEnvelopeFromTemplatesResponse_element objCreateEnvelopeFromTemplatesResponse_element = new TRV_CallDocusignAPI_Handler.CreateEnvelopeFromTemplatesResponse_element();
            objCreateEnvelopeFromTemplatesResponse_element.CreateEnvelopeFromTemplatesResult = new TRV_CallDocusignAPI_Handler.EnvelopeStatus();
            response.put('response_x', objCreateEnvelopeFromTemplatesResponse_element);
        }
        
        if(requestName == 'RequestSenderToken') {
            
            TRV_CallDocusignAPI_Handler.RequestSenderTokenResponse_element objRequestSenderTokenResponse_element = new TRV_CallDocusignAPI_Handler.RequestSenderTokenResponse_element();
            objRequestSenderTokenResponse_element.RequestSenderTokenResult = '';
            response.put('response_x', objRequestSenderTokenResponse_element);
        }
        
        if(requestName == 'RequestRecipientToken') {
            
            TRV_CallDocusignAPI_Handler.RequestRecipientTokenResponse_element objRequestRecipientTokenResponse_element = new TRV_CallDocusignAPI_Handler.RequestRecipientTokenResponse_element();
            objRequestRecipientTokenResponse_element.RequestRecipientTokenResult = '';
            response.put('response_x', objRequestRecipientTokenResponse_element);
        }
        
        if(requestName == 'CreateAndSendEnvelope') {
            
            TRV_CallDocusignAPI_Handler.CreateAndSendEnvelopeResponse_element objCreateAndSendEnvelopeResponse_element = new TRV_CallDocusignAPI_Handler.CreateAndSendEnvelopeResponse_element();
            objCreateAndSendEnvelopeResponse_element.CreateAndSendEnvelopeResult = new TRV_CallDocusignAPI_Handler.EnvelopeStatus();
            response.put('response_x', objCreateAndSendEnvelopeResponse_element);
        }
        
        if(requestName == 'CreateEnvelope') {
            
            TRV_CallDocusignAPI_Handler.CreateEnvelopeResponse_element objEnvelopeResponse = new TRV_CallDocusignAPI_Handler.CreateEnvelopeResponse_element();
            objEnvelopeResponse.CreateEnvelopeResult = new TRV_CallDocusignAPI_Handler.EnvelopeStatus();
            response.put('response_x', objEnvelopeResponse);
        }
        
        if(requestName == 'CreateEnvelopeFromTemplatesAndForms') {
            
            TRV_CallDocusignAPI_Handler.CreateEnvelopeFromTemplatesAndFormsResponse_element objCreateEnvelopeFromTemplatesAndFormsResponse_element = new TRV_CallDocusignAPI_Handler.CreateEnvelopeFromTemplatesAndFormsResponse_element();
            objCreateEnvelopeFromTemplatesAndFormsResponse_element.CreateEnvelopeFromTemplatesAndFormsResult = new TRV_CallDocusignAPI_Handler.EnvelopeStatus();
            response.put('response_x', objCreateEnvelopeFromTemplatesAndFormsResponse_element);
        }
    }
}