global class ALL_NetworkAccess implements Process.Plugin
{    
    //Author: Anirudh Singh
    //Created Date: 3rd November, 2014
    Map<String,String> sessionAttributes;
    
    String sourceIP;
    
    public ALL_NetworkAccess()
    {
        sourceIP='';
        sessionAttributes=Null;
    }
    
    public ALL_NetworkAccess(String IP)
    {
        sourceIP=IP;
        sessionAttributes=new Map<String,String>();
        sessionAttributes.put('SourceIP','123.123.123.123');
    }
    
    //The main method to be implemented. The Flow calls this at runtime.
    global Process.PluginResult invoke(Process.PluginRequest request)
    {   
        Map<String, Object> result=new Map<String, Object>();  
        
        Boolean isTrustedIP=false;
        
        //The IP is fetched.
        if(sourceIP=='')
        {
            sourceIP=(String)request.inputParameters.get('IP');
        }
        
        //IP not provided, use the current session IP address
        if(sourceIP==Null || sourceIP=='')
        {
            try 
            {
                if(sessionAttributes==Null)
                {
                    sessionAttributes=Auth.SessionManagement.getCurrentSession();
                }
            }
            catch(Exception e)
            {
                result.put('IsTrusted', false);
                
                return new Process.PluginResult(result);
            }
            
            sourceIP=sessionAttributes.get('SourceIp');
        }
        
        system.debug('SourceIP---->'+sourceIp);
        
        if(sourceIp!= Null)
        {
            //If the given IP address is within the organization's trusted IP range according to the organization's Network Access settings, it will return true.
            isTrustedIP=Auth.SessionManagement.inOrgNetworkRange(sourceIP);
        }
        
        //IsTrusted parameter is set.
        result.put('IsTrusted', isTrustedIP);
        
        //Return to Flow.
        return new Process.PluginResult(result);
    }
    
    //Returns the describe information for the interface.
    global Process.PluginDescribeResult describe()
    {
        //Process.PluginDescribeResult class is instantiated.
        Process.PluginDescribeResult result=new Process.PluginDescribeResult();
        
        //This describes the purpose of the class.
        result.description='This plug-in verifies if the input IP address is in your organization trusted IP range.';
        
        //With this field, plug-ins can be grouped by tag name, so they appear together in the Apex plug-in section of the Palette within the Flow Designer.
        //This is helpful if there are multiple plug-ins in flow.
        result.tag='Identity';
        
        //The input parameters passed by the Process.PluginRequest class from a flow to the class that implements the Process.Plugin interface.
        result.inputParameters=new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('IP', Process.PluginDescribeResult.ParameterType.STRING, true)
            };
        
        //The output parameters passed by the Process.PluginResult class from the class that implements the Process.Plugin interface to the flow.
        result.outputParameters=new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('IsTrusted', Process.PluginDescribeResult.ParameterType.Boolean)
            };
                
        return result;
    }
}