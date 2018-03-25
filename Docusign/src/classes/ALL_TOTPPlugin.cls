global class ALL_TOTPPlugin implements Process.Plugin
{    
    //Author: Anirudh Singh
    //Created Date: 3rd November, 2014
    
    //The main method to be implemented. The Flow calls this at runtime.
    global Process.PluginResult invoke(Process.PluginRequest request)
    {
        Map<String, String> QR;
        String URL;
        String otp;
        Boolean status=false;
        Map<String, Object> result=new Map<String, Object>();
        
        List<TwoFactorInfo> twoFactors=[SELECT UserId, Type FROM TwoFactorInfo where userID=:UserInfo.getUserId()];
        
        String secret=(String)request.inputParameters.get('SECRET_INPUT');
        
        if(twoFactors.isEmpty() && secret==Null)
        {
            QR=Auth.SessionManagement.getQrCode();
            URL=QR.get('qrCodeUrl');
            Secret=QR.get('secret');
            
            result.put('QR_URL_OUTPUT', URL);
            result.put('SECRET_OUTPUT', Secret);
            
            return new Process.PluginResult(result);
        }
        
        otp=(String)request.inputParameters.get('OTP_REGISTRATION_INPUT');
        
        if(otp==Null)
        {
            otp=(String)request.inputParameters.get('OTP_INPUT');
        }
        
        result.put('IsValid_OUTPUT', validate(otp, secret));
        
        return new Process.PluginResult(result);
    }
    
    //Returns the describe information for the interface.
    global Process.PluginDescribeResult describe()
    {
        //Process.PluginDescribeResult class is instantiated.
        Process.PluginDescribeResult result=new Process.PluginDescribeResult();
        
        //This describes the purpose of the class.
        result.description='This plug-in handles salesforce standard two factor authentication methods.';
        
        //With this field, plug-ins can be grouped by tag name, so they appear together in the Apex plug-in section of the Palette within the Flow Designer.
        //This is helpful if there are multiple plug-ins in flow.
        result.tag='Identity';
        
        //The input parameters passed by the Process.PluginRequest class from a flow to the class that implements the Process.Plugin interface.
        result.inputParameters=new List<Process.PluginDescribeResult.InputParameter> {
            new Process.PluginDescribeResult.InputParameter('OTP_INPUT', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('OTP_REGISTRATION_INPUT', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('SECRET_INPUT', Process.PluginDescribeResult.ParameterType.STRING, true)      
            };
        
        //The output parameters passed by the Process.PluginResult class from the class that implements the Process.Plugin interface to the flow.
        result.outputParameters=new List<Process.PluginDescribeResult.OutputParameter> {
            new Process.PluginDescribeResult.OutputParameter('QR_URL_OUTPUT', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('SECRET_OUTPUT', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('IsValid_OUTPUT', Process.PluginDescribeResult.ParameterType.Boolean)
            };
        
        return result;
    }
    
    //This method is invoked from invoke method.
    private Boolean validate(String otp, String secret)
    {
        String userid=UserInfo.getUserId();   
        Boolean status=false;
        
        if(secret==Null)
        {
            try 
            {
                status=Auth.SessionManagement.validateTotpTokenForUser(otp);
            } 
            catch(Exception e)
            {
                system.debug('The key is invalid or the current user has attempted too many validations.');
            }
            
            return status;
        }
        
        status=Auth.SessionManagement.validateTotpTokenForKey(secret, otp);
        
        if(status==true)
        {
            TwoFactorInfo TwoFactor=new TwoFactorInfo(UserId=userid, Type='TOTP', SharedKey=secret);
            insert(TwoFactor);
        }
        
        return status;
    }    
}