//2017-03-22 lalitha.adduru@cdk.com created this handler - RQ-08780
public class ALL_EmployeeInformation_Handler
{
    public static void setOwnerId(List<Employee_Information__c> newEmpInfo, Map<Id, Employee_Information__c> oldEmpInfoMap)
    {
        List<User> integrationUser = [
            SELECT Id 
            FROM User where UserName = :GlobalSettings__c.getOrgDefaults().Admin_Integration_Username__c
        ];
        
        Id integrationUserId = null;
        if(!integrationUser.isEmpty())
        {
            integrationUserId = integrationUser[0].id;
        }
        
        for(Employee_Information__c  empInfo : newEmpInfo)
        {
            Employee_Information__c oldEmpInfo = (oldEmpInfoMap==null || oldEmpInfoMap.isEmpty()) ? new Employee_Information__c() : oldEmpInfoMap.get(empInfo.Id);
            if(oldEmpInfo == null || (oldEmpInfo.User__c != empInfo.User__c) || empInfo.OwnerId != empInfo.User__c)
            {
                if(empInfo.Status__c == 'Inactive' && integrationUserId != null)
                {
                    empInfo.OwnerId = integrationUserId;
                }
                else if(empInfo.User__c != null)
                {
                    empInfo.OwnerId = empInfo.User__c;
                }
            }
        }
    }
    
}