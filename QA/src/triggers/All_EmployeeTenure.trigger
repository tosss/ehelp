//------------------------------------------------------------------
//	Author	 : 	Lalitha Adduru
//	Date	 :	20th august 2015
//	Description	: Trigger on Employee Tenure Object
//------------------------------------------------------------------

trigger All_EmployeeTenure on Employee_Tenure__c (after insert,after update) 
{
    
    if(trigger.isInsert)
    {
        All_EmployeeTenure_Handler employeeTenureHandler = new All_EmployeeTenure_Handler();
        employeeTenureHandler.updateEmployeeInfo(trigger.new, null);
    }
    else if(trigger.isUpdate)
    {
        All_EmployeeTenure_Handler employeeTenureHandler = new All_EmployeeTenure_Handler();
        employeeTenureHandler.updateEmployeeInfo(trigger.new, trigger.oldMap);
    }

}