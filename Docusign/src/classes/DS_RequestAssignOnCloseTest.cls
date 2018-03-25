@IsTest
public class DS_RequestAssignOnCloseTest
{
    public static testmethod void TestRequest()
    {
        //User u = [Select Id, Name, UserRole.Name From User Where UserRole.Name = 'System Administrator' limit 1];
        User u = DS_TestObjects.CurrentUser();
        
        System.runAs(DS_TestObjects.CurrentUser()) 
        {
            Request__c r = null;
            r = new Request__c(Name='Test Request', ownerid=u.Id); insert r;
            
            if(r != null) {
                r.Status__c = 'Closed'; 
                r.Reason_Not_Completed_In_All_Environments__c = 'Testing...';
                r.Change_Classification__c = 'Routine';
                r.Duration_to_Completion__c = 25;
                r.Assigned_Config__c = u.Id;
                r.All_Request_Team_Members__c = 'Bobo, Vovo';
                r.Initial_Estimate__c = 40;
                r.SF_Config_Admins__c = 'Cameron Wong';
                update r;
            }
        }
    }
}