@isTest
private class ALL_NetworkAccessTest
{
    //Author: Anirudh Singh
    //Created Date: 3rd November, 2014
    
    static testMethod void inputIP()
    {
        ALL_NetworkAccess network=new ALL_NetworkAccess();
        Map<String, Object> inputParams=new Map<String, Object>();
        Map<String, Object> outputParams=new Map<String, Object>();
        
        inputParams.put('IP', '1.1.1.1');
        
        Process.PluginRequest request=new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result=network.invoke(request);
        System.AssertEquals(false,result.outputParameters.get('IsTrusted'));
        
        String IP=Null;
        
        ALL_NetworkAccess network1=new ALL_NetworkAccess(IP);
        result=network1.invoke(request);
        System.AssertEquals(false,result.outputParameters.get('IsTrusted'));
    }
    
    static testMethod void describeTest()
    {
        ALL_NetworkAccess network=new ALL_NetworkAccess();
        Process.PluginDescribeResult result=network.describe();
        
        System.AssertEquals(1, result.inputParameters.size());
        System.AssertEquals(1, result.OutputParameters.size());
    }
}