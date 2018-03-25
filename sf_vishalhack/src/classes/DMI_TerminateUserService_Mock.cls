//2017-03-30- anirudh.singh@cdk.com- Created this class for RQ-08829 Termination Process.
@isTest
global class DMI_TerminateUserService_Mock implements WebServiceMock
{
    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint,
                         String soapAction, String requestName, String responseNS, String responseName, String responseType)
    {
        if(requestName=='login')
        {
            DMI_PartnerSoapSforceCom_Service.GetUserInfoResult userInfoRef=new DMI_PartnerSoapSforceCom_Service.GetUserInfoResult();
            
            DMI_PartnerSoapSforceCom_Service.loginResponse_element loginRespRef=new DMI_PartnerSoapSforceCom_Service.loginResponse_element();
            loginRespRef.result=new DMI_PartnerSoapSforceCom_Service.LoginResult();
            response.put('response_x', loginRespRef);
        }
        
        if(requestName=='terminateUser')
        {
            DMI_TerminateUser_Service.LogInfo logInfoRef=new DMI_TerminateUser_Service.LogInfo();
            DMI_TerminateUser_Service.DebuggingInfo_element debugInfoRef=new DMI_TerminateUser_Service.DebuggingInfo_element();
            DMI_TerminateUser_Service.address addressRef=new DMI_TerminateUser_Service.address();
            DMI_TerminateUser_Service.CallOptions_element callOptionsRef=new DMI_TerminateUser_Service.CallOptions_element();
            DMI_TerminateUser_Service.DebuggingHeader_element debugHeaderRef=new DMI_TerminateUser_Service.DebuggingHeader_element();
            DMI_TerminateUser_Service.location locationRef=new DMI_TerminateUser_Service.location();
            DMI_TerminateUser_Service.AllowFieldTruncationHeader_element allowTruncHeaderRef=new DMI_TerminateUser_Service.AllowFieldTruncationHeader_element();
            
            DMI_TerminateUser_Service.terminateUserResponse_element respElement=new DMI_TerminateUser_Service.terminateUserResponse_element();
            respElement.result='Test';
            response.put('response_x', respElement);
        }
    }
}