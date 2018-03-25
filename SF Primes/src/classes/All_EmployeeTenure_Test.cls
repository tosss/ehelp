//------------------------------------------------------------------
//	Author	 : 	Lalitha Adduru
//	Date	 :	20th august 2015
//	Description	: Test Class for All_EmployeeTenure Trigger
//	Code Coverage	:	100%
//------------------------------------------------------------------

@isTest
public class All_EmployeeTenure_Test {
    
    public static  testmethod void testTrigger()
    {
        Employee_Information__c managerInfo = new Employee_Information__c(Name='Sample Manager');
        insert managerInfo;
        Employee_Information__c empInfo = new Employee_Information__c(Name='Sample Employee');
        insert empInfo;
        Employee_Tenure__c empTenure = new Employee_Tenure__c(Employee_Name__c = empInfo.id,Manager__c = managerInfo.id, Position_Start_Date__c =  date.ValueOf('2015-08-20'), title__c = 'Sample Title', region__c = 'CVR');
        insert empTenure;       
    }
}