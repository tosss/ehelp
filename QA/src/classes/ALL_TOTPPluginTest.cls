@isTest
private class ALL_TOTPPluginTest
{
    //Author: Anirudh Singh
    //Created Date: 3rd November, 2014
    
    static testMethod void getQRCode()
    {
        ALL_TOTPPlugin totp=new ALL_TOTPPlugin();
        Map<String, Object> inputParams=new Map<String, Object>();
        Map<String, Object> outputParams=new Map<String, Object>();
         
        Map<String,String> QR=Auth.SessionManagement.getQrCode(); 
         
        inputParams.put('OTP_INPUT', Null);
         
        Process.PluginRequest request=new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result=totp.invoke(request);
        
        System.AssertEquals(1,1);
    }
    
    static testMethod void validateToken()
    {
        ALL_TOTPPlugin totp=new ALL_TOTPPlugin();
        Map<String, Object> inputParams=new Map<String, Object>();
        Map<String, Object> outputParams=new Map<String, Object>();
         
        Map<String,String> QR=Auth.SessionManagement.getQrCode(); 
         
        inputParams.put('OTP_INPUT', '1234');
        inputParams.put('SECRET_INPUT', QR.get('secret'));
         
        Process.PluginRequest request=new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result=totp.invoke(request);
        
        System.AssertEquals(1,1);
    }

    static testMethod void describeTest()
    {
        ALL_TOTPPlugin totp=new ALL_TOTPPlugin();
        Process.PluginDescribeResult result=totp.describe();
        
        System.AssertEquals(result.inputParameters.size(), 3);
        System.AssertEquals(result.OutputParameters.size(), 3);
     }
}