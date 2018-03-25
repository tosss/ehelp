//23-12-2016 lalitha.adduru@cdk.com created RQ-08028
@isTest
public class MyTasks_Test
{
    @testSetup
    public static void dataSetup()
    {
        List<Task> taskList = new List<Task>();
        for(integer i=0;i<5;i++)
        {
            Task newTask = DS_TestObjects.newTask();
            newTask.Subject = 'Subject'+i;
            newTask.ActivityDate = Date.today();
            newTask.Priority = 'High';
            newTask.OwnerId = UserInfo.getUserId();
            newTask.Type = 'Phone Call';
            newTask.Status = 'Not Started';
            newTask.DS_Service_Connect_Visit__c = 'Yes';
            newTask.Completed_Date__c = Date.today();
            taskList.add(newTask);
        }
        insert taskList;
    }
    
    public static testmethod void testController()
    {
        Test.setCurrentPageReference(new PageReference('Page.MyTasks'));
        System.currentPageReference().getParameters().put('column', 'Priority');
        MyTasks_Controller myTasksCOntroller = new MyTasks_Controller();
        myTasksCOntroller.fetchColumnToBeSorted = 'Priority';
        myTasksController.columnToBeSorted = myTasksCOntroller.fetchColumnToBeSorted;
        myTasksCOntroller.fetchTasks();
    }
    
}