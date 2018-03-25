public class DEP_DeploymentStatus_Controller
{    
    public List<Change_Set_Deployment__c> changeSetDeployments{get;set;}
    
    public DEP_DeploymentStatus_Controller()
    {
        getChangeSetDeployment();
    }
    
    public void getChangeSetDeployment()
    {
        changeSetDeployments = [SELECT Id, Sandbox__c, Change_Set__r.Name, Status__c,Deployment_Error__c FROM Change_Set_Deployment__c Order By Change_Set__r.Name];
    }
        
    public Class Message
    {
        public String messageBody{get;set;}
        public String messageSeverity{get;set;}
        public Message()
        {
            messageBody = messageSeverity = '';
        }
        
    }
}