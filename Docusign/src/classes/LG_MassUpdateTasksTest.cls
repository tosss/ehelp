@IsTest
public class LG_MassUpdateTasksTest
{
    public static testmethod void Test()
    {
        sObject p = new mpm3__Milestone1_Project__c(Name='Project'); insert p;
        sObject m = new mpm3__Milestone1_Milestone__c(Name='Milestone', mpm3__Project__c=p.Id); insert m; 
        sObject t = new mpm3__Milestone1_Task__c(Name='Task', mpm3__Project_Milestone__c=m.Id); insert t; 
        
        PageReference pg = Page.LG_MassUpdateTasks;
        Test.setCurrentPage(pg);
        
        ApexPages.currentPage().getParameters().put('id', t.Id);
        
        LG_MassUpdateTasks mut = new LG_MassUpdateTasks();
        List<String> Selected = new List<String>{t.Id};
        LG_MassUpdateTasks.MarkCompleted(Selected);
    }
}