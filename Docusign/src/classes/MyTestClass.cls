@isTest
public class MyTestClass 
{
    @testSetup static void createData(){
        User u = [select Id from User where NAme='Cast Iron Integration' limit 1];
        system.runAs(u)
        {
            Project__c p = IMP_TestFactory_Helper.buildProject(1);
            insert p;    
        }
    }
}